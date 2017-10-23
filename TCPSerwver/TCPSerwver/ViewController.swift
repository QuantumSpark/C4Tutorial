//
//  ViewController.swift
//  TCPSerwver
//
//  Created by Geyi Liu on 2017-09-20.
//  Copyright © 2017 Geyi Liu. All rights reserved.
//

import Cocoa
import SwiftSocket
import AVFoundation

class ViewController: NSViewController {
    var server: TCPServer!
    private let nStartCodeLength:size_t = 4
    private let nStartCode:[UInt8] = [0x00, 0x00, 0x00, 0x01]
    private var listOfCMSampleBuffer = [CMSampleBuffer]()
    private var timescale = 1000000000
    var displaySampleLayer: AVSampleBufferDisplayLayer = {
        let display = AVSampleBufferDisplayLayer()
        return display
    }()

    @IBAction func playTheVideo(_ sender: Any) {
        guard !listOfCMSampleBuffer.isEmpty else {
            return
        }
        
        for sbuf in listOfCMSampleBuffer {
            self.displaySampleLayer.enqueue(sbuf)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDisplaySampleLayer()
        testServer()
        
        for sbuf in listOfCMSampleBuffer {
            self.displaySampleLayer.enqueue(sbuf)
        }
        

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
            for sbuf in listOfCMSampleBuffer {
                self.displaySampleLayer.enqueue(sbuf)
            }
        }
    }
    
    func echoService(client: TCPClient) {
        print("Newclient from:\(client.address)[\(client.port)]")
        var d = client.read(200000)
        let chunkShit = chunkMessage(d!)
        generateCMSampleBuffer(chunkShit)
        client.send(data: d!)
        client.close()
    }
    
    func generateCMSampleBuffer(_ chunks: [Data]) {
        for (index, elementaryStream) in chunks.enumerated() {
            
            let (formatDescription, offset) = constructCMVideoDescription(from:  NSMutableData(data: elementaryStream ))
            guard formatDescription != nil else {
                print(index)
                continue
            }
            let (cmblockbuffer, secondOffset) = constructCMBlockBuffer(from: NSMutableData(data: elementaryStream ), with: offset)
            let timeSecond=constructSeconds(from:  NSMutableData(data: elementaryStream ), with: secondOffset)
            let pTS = CMTime(seconds: timeSecond, preferredTimescale: CMTimeScale(self.timescale))
            var sampleSize = CMBlockBufferGetDataLength(cmblockbuffer)
            
            var timing = CMSampleTimingInfo(duration: CMTime(), presentationTimeStamp: pTS, decodeTimeStamp: CMTime())
            
            var reconstructedSampleBuffer: CMSampleBuffer?
            
            let statusBuffer = CMSampleBufferCreate(kCFAllocatorDefault, cmblockbuffer, true, nil, nil, formatDescription, 1, 1, &timing, 1, &sampleSize, &reconstructedSampleBuffer)
            
            if statusBuffer == noErr {
                print("Succeeded in making a CMSampleBuffer")
                let attachments = CMSampleBufferGetSampleAttachmentsArray(reconstructedSampleBuffer!, true)
                let dict = CFArrayGetValueAtIndex(attachments, 0)
                let dictRef = unsafeBitCast(dict, to: CFMutableDictionary.self)
                
                CFDictionarySetValue(dictRef, unsafeBitCast(kCMSampleAttachmentKey_DisplayImmediately, to: UnsafeRawPointer.self), unsafeBitCast(kCFBooleanTrue, to :UnsafeRawPointer.self ))
                
                listOfCMSampleBuffer.append(reconstructedSampleBuffer!)
            }
        }
    }
    
    func chunkMessage(_ wholeData: [Byte]) -> [Data] {
        var chunks : [Data] = [] //return value
        var i=0;
        var startIndex=0;
        while(i<wholeData.count - 4){
            if(wholeData[i] == 0xFF && wholeData[i+1] == 0xFF && wholeData[i+2] == 0xFF && wholeData[i+3] == 0xFF){
                let tempSubArray = wholeData[startIndex...i]
                startIndex=i+4;
                let tempSubData=(Data(bytes: tempSubArray))
                chunks.append(tempSubData)
                i=i+4
            } else {
                i = i + 1
            }
        }
        return chunks
    }
    
    
    func testServer() {
        server = TCPServer(address: "0.0.0.0", port: 3000)
        //server.close()
        switch server.listen() {
        case .success:
            print("Connection success")
            if var client = server.accept() {
                echoService(client: client)
            } else {
                print("accept error")
            }
        case .failure(let error):
            //print("Failure")
            print(error)
        }
    }
    
    private func constructCMVideoDescription(from data: NSMutableData) -> (CMFormatDescription?, Int) {
        var formatDesc:CMFormatDescription?
        
        let naluData = UnsafeMutablePointer<UInt8>(mutating: data.bytes.assumingMemoryBound(to: UInt8.self))
        let ptr = UnsafeMutablePointer<UInt8>(mutating: naluData)
        
        let secondStartCodeIndex = findStartCode(using: ptr, offset: 0, count: data.length)
        let spsSize = UInt8(secondStartCodeIndex)
        
        let thirdStartCodeIndex = findStartCode(using: ptr, offset: Int(spsSize),count: data.length)
        var ppsSize = UInt8()
        if thirdStartCodeIndex == -1 {
            ppsSize = UInt8(data.length - Int(spsSize))
        } else {
            ppsSize = UInt8(Int(thirdStartCodeIndex) - Int(spsSize))
        }
        
        let sps = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(spsSize) - 4)
        let pps = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(ppsSize) - 4)
        // copy in the actual sps and pps values, again ignoring the 4 byte header
        
        memcpy(sps, &ptr[4] , Int(spsSize) - 4)
        memcpy(pps, &ptr[Int(spsSize)+4], Int(ppsSize) - 4)
        
        let spsPointer = UnsafePointer<UInt8>(sps)
        let ppsPointer = UnsafePointer<UInt8>(pps)
        
        // now we set our H264 parameters
        let parameterSetArray = [spsPointer, ppsPointer]
        
        let parameterSetPointers = UnsafePointer<UnsafePointer<UInt8>>(parameterSetArray)
        let sizeParamArray = [Int(spsSize - 4), Int(ppsSize - 4)]
        
        
        let parameterSetSizes = UnsafePointer<Int>(sizeParamArray)
        let status = CMVideoFormatDescriptionCreateFromH264ParameterSets(
            kCFAllocatorDefault,
            2,
            parameterSetPointers,
            parameterSetSizes,
            4,
            &formatDesc
        )
        
        if status == noErr {
            print("CMVideoFormatDescription has been successfully created")
        } else {
            print("Failed to create CMVideoFormatDescription")
        }
        
        return (formatDesc , Int(ppsSize + spsSize))
    }
    private func constructCMBlockBuffer (from elementaryStream: NSMutableData, with offset: Int) -> (CMBlockBuffer, Int) {
        var cmblockBuffer: CMBlockBuffer?
        let tmpptr = elementaryStream.bytes.assumingMemoryBound(to: UInt8.self)
        let ptr = UnsafeMutablePointer<UInt8>(mutating: tmpptr)
        
        let timeCodeIndex = findStartCode(using: ptr, offset: offset, count: elementaryStream.length)
        let dataSize = timeCodeIndex - offset - nStartCodeLength
        
        
        let frameData = UnsafeMutablePointer<UInt8>.allocate(capacity: dataSize)
        
        memcpy(frameData, &ptr[Int(offset+4)], dataSize)
        
        let status = CMBlockBufferCreateWithMemoryBlock(nil, frameData,  // memoryBlock to hold buffered data
            dataSize,  // block length of the mem block in bytes.
            kCFAllocatorNull, nil,
            0, // offsetToData
            dataSize,   // dataLength of relevant bytes, starting at offsetToData
            0, &cmblockBuffer);
        
        if status == noErr {
            print("CMBlockBuffer has been successfully created")
        } else {
            print("Failed to create CMBlockBuffer")
        }
        return (cmblockBuffer!, timeCodeIndex)
    }
    
    private func findStartCode(using dataPointer: UnsafeMutablePointer<UInt8>, offset: Int, count: Int) -> Int {
        for i in offset + 4..<count {
            if dataPointer[i] == 0x00 && dataPointer[i + 1] == 0x00 && dataPointer[i + 2] == 0x00 && dataPointer[i + 3] == 0x01 {
                return i
            }
        }
        return -1
    }
    func setupDisplaySampleLayer() {
        self.view.layer?.addSublayer(displaySampleLayer)
        self.displaySampleLayer.bounds = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 500, height: 500)
    }
    
    private func constructSeconds(from data: NSMutableData, with secondOffset : Int) -> Double {
        let tmpptr = data.bytes.assumingMemoryBound(to: UInt8.self)
        let ptr = UnsafeMutablePointer<UInt8>(mutating: tmpptr)
        let dataSize = data.length - secondOffset
        let secondDataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: dataSize)
        
        memcpy(secondDataPointer, &ptr[Int(secondOffset+4)], dataSize)
        
        
        let secondData = NSData(bytes: secondDataPointer, length: dataSize)
        
        let reconstructedSecondData = (secondData as Data).double
        
        
        return reconstructedSecondData
    }
    
}

extension Data {
    var integer: Int {
        return withUnsafeBytes { $0.pointee }
    }
    var int32: Int32 {
        return withUnsafeBytes { $0.pointee }
    }
    var float: Float {
        return withUnsafeBytes { $0.pointee }
    }
    var double: Double {
        return withUnsafeBytes { $0.pointee }
    }
    var string: String {
        return String(data: self, encoding: .utf8) ?? ""
    }
}

