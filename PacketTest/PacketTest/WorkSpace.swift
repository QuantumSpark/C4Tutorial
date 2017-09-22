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
    /*
    func echoService(client: TCPClient) {
        print("Newclient from:\(client.address)[\(client.port)]")
        var d = client.read(1024*10)
        client.send(data: d!)
        client.close()
    }
    
    func testServer() {
        let server = TCPServer(address: "10.0.255.255", port: 80)
        switch server.listen() {
        case .success:
            while true {
                if var client = server.accept() {
                    echoService(client: client)
                } else {
                    print("accept error")
                }
            }
        case .failure(let error):
            print("FUCK YOU")
            print(error)
        }
    }
    
    override func setup() {
        testServer()
    }*/

    override func setup() {
        //Work your magic here.
        let socketManager = SocketManager.sharedManager
        socketManager.workspace = self
        let str="hello"
        let data = str.data(using: .utf8)
        let packet = Packet(type: PacketType(rawValue: 100000), id: 3, payload: data)
        let client=TCPClient(address:"10.0.0.143",port:3000)
        switch client.connect(timeout: 10){
        case .success:
            print("Connected to James")
            var result=client.send(data: data!)
            print("result of sending from client is: \(result)")
        case .failure(let error):
            print(" not connected")
        }
        do {
            try socketManager.broadcastPacket(packet)
            print("broadcasted hello")
        } catch  {
            print("Error broadcasting wtf")
        }
        
        
        let camera=Camera(frame:Rect(200,200,150,150))
        canvas.add(camera)
    }
}


