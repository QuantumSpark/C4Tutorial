//
//  ViewController.swift
//  PacketRecieverTest
//
//  Created by James Park on 2017-09-08.
//  Copyright © 2017 James Park. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket
import AVFoundation

class ViewController: NSViewController, GCDAsyncSocketDelegate {
    //var displaySampleLayer = AVSampleBufferDisplayLayer()

    var listOfDisplaySampleLayer = [AVSampleBufferDisplayLayer]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let socketManager = TCPSocketManager.sharedManager
        socketManager.workspace = self
        // Do any additional setup after loading the view.
        let height = CGFloat(150.0)
        let width = CGFloat(150.0)
        for i in 1...4 {
            for j in 1...7 {
                let tempDisplaySampleLayer = AVSampleBufferDisplayLayer()
                tempDisplaySampleLayer.bounds = CGRect(x: CGFloat(Double(width)*(Double(j) - 0.5)), y: CGFloat(Double(width)*(Double(i) - 0.5)), width: width, height: height)
                tempDisplaySampleLayer.position=CGPoint(x: CGFloat(Double(width)*(Double(j) - 0.5)), y: CGFloat(Double(width)*(Double(i) - 0.5)))
                let myColor=NSColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0).cgColor
                tempDisplaySampleLayer.backgroundColor=myColor
                 self.view.layer?.addSublayer(tempDisplaySampleLayer)
                listOfDisplaySampleLayer.append(tempDisplaySampleLayer)
            }
        }
    }

    @IBAction func zoomIn(_ sender: Any) {
        print("zooming in")
        let str="zoomIn"
        let zoomInPacket=Packet(type: PacketType(rawValue: 100000),id:3, payload: str.data(using: .utf8) as! Data)
        let udpSocketManager=SocketManager.sharedManager
        udpSocketManager.broadcastPacket(str)
    }
    @IBAction func zoomOut(_ sender: Any) {
        print("zooming out")
        let str="zoomOut"
        let zoomInPacket=Packet(type: PacketType(rawValue: 100000),id:3, payload: str.data(using: .utf8) as! Data)
        let udpSocketManager=SocketManager.sharedManager
        udpSocketManager.broadcastPacket(str)
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

