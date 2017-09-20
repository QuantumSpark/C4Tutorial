//
//  WorkSpace.swift
//  PacketTest
//
//  Created by Geyi Liu on 2017-09-08.
//  Copyright © 2017 Geyi Liu. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class WorkSpace: CanvasController,GCDAsyncUdpSocketDelegate {

    override func setup() {
//        //Work your magic here.
//        let socketManager = SocketManager.sharedManager
//        socketManager.workspace = self
//        let str="wtf"
//        let data = str.data(using: .utf8)
//        let packet = Packet(type: PacketType(rawValue: 100000), id: 3, payload: data)
//        
//        do {
//            try socketManager.broadcastPacket(packet)
//            print("broadcasted wtf")
//        } catch  {
//            print("Error broadcasting wtf")
//        }
        
        
        let camera=Camera(frame:Rect(200,200,150,150))
        camera.backgroundColor=C4Blue
        canvas.add(camera)
    }
}


