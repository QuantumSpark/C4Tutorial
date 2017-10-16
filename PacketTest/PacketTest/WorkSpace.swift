//
//  WorkSpace.swift
//  PacketTest
//
//  Created by Geyi Liu on 2017-09-08.
//  Copyright © 2017 Geyi Liu. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import SwiftSocket

class WorkSpace: CanvasController,GCDAsyncUdpSocketDelegate {
    @IBOutlet weak var dataSize: UITextField!
    @IBOutlet weak var fps: UITextField!
    let client=TCPClient(address:"10.0.0.143",port:3000)
    @IBAction func sendData(_ sender: Any) {
        var tempData = Data(repeating: 2, count: 2000)
        
        var result =  client.send(data: tempData)
        var FPS = Int(fps.text!)
        for var j in Int(0)..<FPS!{
            result=client.send(data:tempData)
            print(result)
        }

    }

    override func setup() {
        //Work your magic here.
        let socketManager = SocketManager.sharedManager
        socketManager.workspace = self
        let str="hello"
        let data = str.data(using: .utf8)
       
        switch client.connect(timeout: 10){
        case .success:
            print("Connected to James")
            var result=client.send(data: data!)
            print("result of sending from client is: \(result)")
        case .failure(let error):
            print(" not connected")
        }
        
        

    }
}


