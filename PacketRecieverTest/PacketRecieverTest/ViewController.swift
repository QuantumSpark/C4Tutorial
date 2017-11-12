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
    var displaySampleLayer = AVSampleBufferDisplayLayer()
    var displaySampleLayer2 = AVSampleBufferDisplayLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.displaySampleLayer.bounds = CGRect(x: self.view.frame.size.width*0.5+980, y: self.view.frame.size.height*0.5, width: 500, height: 500)
        self.displaySampleLayer.position = CGPoint(x: self.view.frame.size.width*0.5, y: self.view.frame.size.height*0.5)
        self.displaySampleLayer.backgroundColor = CGColor(red: 22, green: 22, blue: 22, alpha: 1.0)

        self.displaySampleLayer2.bounds = CGRect(x: self.view.frame.size.width*0.75, y: self.view.frame.size.height*0.75, width: 500, height: 500)
          self.displaySampleLayer2.position = CGPoint(x: self.view.frame.size.width*0.75 + 500, y: self.view.frame.size.height*0.75)
        self.displaySampleLayer2.backgroundColor = CGColor.black
        self.view.layer?.addSublayer(displaySampleLayer)
        self.view.layer?.addSublayer(displaySampleLayer2)
        let socketManager = TCPSocketManager.sharedManager
        socketManager.workspace = self
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

