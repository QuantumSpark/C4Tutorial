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
    var displaySampleLayer3 = AVSampleBufferDisplayLayer()
    var displaySampleLayer4 = AVSampleBufferDisplayLayer()

    var height = CGFloat(150.0)
    var width = CGFloat(150.0)

    var listOfDisplaySampleLayer = [AVSampleBufferDisplayLayer]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displaySampleLayer.bounds = CGRect(x: self.view.frame.size.width*0.5+980, y: self.view.frame.size.height*0.5, width: width, height: height)
        self.displaySampleLayer.position = CGPoint(x: self.view.frame.size.width*0.5, y: self.view.frame.size.height*0.5)
        self.displaySampleLayer.backgroundColor = CGColor(red: 22, green: 22, blue: 22, alpha: 1.0)

        self.displaySampleLayer2.bounds = CGRect(x: self.view.frame.size.width*0.75, y: self.view.frame.size.height*0.75, width: width, height: height)
          self.displaySampleLayer2.position = CGPoint(x: self.view.frame.size.width*0.75 + 250, y: self.view.frame.size.height*(0.75))
        self.displaySampleLayer2.backgroundColor = CGColor.black


        self.displaySampleLayer3.bounds = CGRect(x: self.view.frame.size.width*0.75, y: self.view.frame.size.height*0.75, width: width, height: height)
        self.displaySampleLayer3.position = CGPoint(x: self.view.frame.size.width*0.75 + 500, y: self.view.frame.size.height*0.75)
        self.displaySampleLayer3.backgroundColor = NSColor.red.cgColor


        self.displaySampleLayer4.bounds = CGRect(x: self.view.frame.size.width*0.75, y: self.view.frame.size.height*0.75, width: width, height: height)
        self.displaySampleLayer4.position = CGPoint(x: self.view.frame.size.width*0.75 + 100, y: self.view.frame.size.height*0.75)
        self.displaySampleLayer4.backgroundColor = NSColor.blue.cgColor


        

        self.view.layer?.addSublayer(displaySampleLayer)
        self.view.layer?.addSublayer(displaySampleLayer2)
        self.view.layer?.addSublayer(displaySampleLayer3)
        self.view.layer?.addSublayer(displaySampleLayer4)

        listOfDisplaySampleLayer.append(displaySampleLayer)
        listOfDisplaySampleLayer.append(displaySampleLayer2)
        listOfDisplaySampleLayer.append(displaySampleLayer3)
        listOfDisplaySampleLayer.append(displaySampleLayer4)


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

