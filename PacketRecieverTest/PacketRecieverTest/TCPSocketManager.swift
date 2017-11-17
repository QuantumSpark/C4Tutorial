//
//  TCPSocketManager.swift
//  PacketTest
//
//  Created by James Park on 2017-09-18.
//  Copyright © 2017 Geyi Liu. All rights reserved.
//


import Foundation
import CocoaAsyncSocket
import AVFoundation

open class TCPSocketManager: NSObject, GCDAsyncSocketDelegate {
    static let masterPort = UInt16(80)
    static let peripheralPort = UInt16(80)
    static let masterHost = "0.0.0.0"
    static let broadcastHost = "10.0.255.255"

    private let nStartCodeLength:size_t = 4
    private let nStartCode:[UInt8] = [0x00, 0x00, 0x00, 0x01]
    private var timescale = 1000000000
    var connectedSockets = [GCDAsyncSocket]()

    var listOfTempFrame = [ [UInt8(0)], [UInt8(0)]]
    var numbOfIPads = -1

    private var numOfFrames = 0

    static let sharedManager = TCPSocketManager()

    let maxDeviceID = 28

    var bound = false

    //the socket that will be used to connect to the core app
    var socket: GCDAsyncSocket!

    var workspace: ViewController?

    open lazy var deviceID = 0

    public override init() {
        super.init()

        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)

        do {
            try socket.accept(onPort: 3000)
        } catch {
            print("Failed to connect")
        }

        let port = socket.localPort

        print("\(port)")
    }


    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Disconnected")
        print(err)
    }

    public func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("Accept to new socket")

        self.connectedSockets.append(newSocket)
        listOfTempFrame.append([UInt8(0)])
        numbOfIPads+=1
        print("There are \(numbOfIPads) ipads connected")
        newSocket.readData(withTimeout: -1, tag: numbOfIPads)


        let welcomMessage = "Hello from the server";
        newSocket.write(welcomMessage.data(using: .utf8)!, withTimeout: -1, tag: numbOfIPads)
    }


    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        sock.readData(withTimeout: -1, tag: tag)
        print(tag)
        updateDisplay(data, withTag: tag)
    }

    public func updateDisplay(_ data: Data, withTag tag: Int) {
        let wholeData = Array(data)
        var i = 0
        while (i<=wholeData.count-1){
            if ( listOfTempFrame[tag].count>=4) {
                let tempFrameSize =  listOfTempFrame[tag].count
                if ( listOfTempFrame[tag][tempFrameSize-1] == 0xFF &&  listOfTempFrame[tag][tempFrameSize-2] == 0xFF &&  listOfTempFrame[tag][tempFrameSize-3] == 0xFF &&  listOfTempFrame[tag][tempFrameSize-4] == 0xFF){
                    print("===============================================================")
                    let frameData = (Data(bytes:  listOfTempFrame[tag]))
                    generateCMSampleBuffer(frameData, tag)
                    listOfTempFrame[tag] = [UInt8(0)]

                }else{
                     listOfTempFrame[tag].append(wholeData[i])
                }
            } else{
                 listOfTempFrame[tag].append(wholeData[i])
            }
            i = i + 1
        }
    }

    private func generateCMSampleBuffer(_ elementaryStream:Data, _ tag:Int) {

        let (formatDescription, offset) = constructCMVideoDescription(from:  NSMutableData(data: elementaryStream ))
        guard formatDescription != nil else {
            return
        }
        let (cmblockbuffer, secondOffset) = constructCMBlockBuffer(from: NSMutableData(data: elementaryStream ), with: offset)
        let (timeSecond, thirdOffset) = constructSeconds(from:  NSMutableData(data: elementaryStream ), with: secondOffset)
        let deviceID = constructID(from: NSMutableData(data: elementaryStream ), with: thirdOffset)
        let pTS = CMTime(seconds: timeSecond, preferredTimescale: CMTimeScale(self.timescale))
        var sampleSize = CMBlockBufferGetDataLength(cmblockbuffer)
        var timing = CMSampleTimingInfo(duration: CMTime(), presentationTimeStamp: pTS, decodeTimeStamp: CMTime())

        var reconstructedSampleBuffer: CMSampleBuffer?

        let statusBuffer = CMSampleBufferCreate(kCFAllocatorDefault, cmblockbuffer, true, nil, nil, formatDescription, 1, 1, &timing, 1, &sampleSize, &reconstructedSampleBuffer)

        if statusBuffer == noErr {
            print("Succeeded in making a CMSampleBuffer")
            self.numOfFrames=self.numOfFrames+1
            print("We have \(self.numOfFrames) frames")
            let attachments = CMSampleBufferGetSampleAttachmentsArray(reconstructedSampleBuffer!, true)
            let dict = CFArrayGetValueAtIndex(attachments, 0)
            let dictRef = unsafeBitCast(dict, to: CFMutableDictionary.self)

            CFDictionarySetValue(dictRef, unsafeBitCast(kCMSampleAttachmentKey_DisplayImmediately, to: UnsafeRawPointer.self), unsafeBitCast(kCFBooleanTrue, to :UnsafeRawPointer.self ))
            print("DisplayLayer can display? \(workspace?.listOfDisplaySampleLayer[0].isReadyForMoreMediaData)")
            workspace?.listOfDisplaySampleLayer[tag].enqueue(reconstructedSampleBuffer!)
        } else {
            print("Error: ")
        }

    }
    private func constructSeconds(from data: NSMutableData, with secondOffset : Int) -> (Double, Int) {
        let tmpptr = data.bytes.assumingMemoryBound(to: UInt8.self)
        let ptr = UnsafeMutablePointer<UInt8>(mutating: tmpptr)
        let idOffset = findStartCode(using: ptr, offset: secondOffset, count: data.length)
        let dataSize = idOffset - secondOffset - nStartCodeLength - nStartCodeLength
        let secondDataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: dataSize)

        memcpy(secondDataPointer, &ptr[Int(secondOffset+4)], dataSize)


        let secondData = NSData(bytes: secondDataPointer, length: dataSize)

        let reconstructedSecondData = (secondData as Data).double


        return (reconstructedSecondData, idOffset)
    }

    private func constructID (from data: NSMutableData, with thirdOffset : Int) -> Int {
        let tmpptr = data.bytes.assumingMemoryBound(to: UInt8.self)
        let ptr = UnsafeMutablePointer<UInt8>(mutating: tmpptr)
        let dataSize = data.length - thirdOffset - nStartCodeLength
        let deviceIDPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: dataSize)

        memcpy(deviceIDPointer, &ptr[Int(thirdOffset+4)], dataSize)


        let deviceIDData = NSData(bytes: deviceIDPointer, length: 1)
        print("The data for deviceName \(deviceIDData)")
        return (deviceIDData as Data).integer
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

