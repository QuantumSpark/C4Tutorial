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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.displaySampleLayer.bounds = CGRect(x: self.view.frame.size.width*0.5, y: self.view.frame.size.height*0.5, width: 500, height: 500)
        self.view.layer = displaySampleLayer
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

