//
//  TCPSocketManager.swift
//  PacketTest
//
//  Created by James Park on 2017-09-18.
//  Copyright © 2017 Geyi Liu. All rights reserved.
//


import Foundation
import CocoaAsyncSocket

open class TCPSocketManager: NSObject, GCDAsyncSocketDelegate {
    static let masterPort = UInt16(80)
    static let peripheralPort = UInt16(80)
    static let masterHost = "0.0.0.0"
    static let broadcastHost = "10.0.255.255"


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


    public func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("Accept to new socket")
        self.socket = newSocket;
        let welcomMessage = "Hello from the server";
        self.socket.write(welcomMessage.data(using: .utf8)!, withTimeout: -1, tag: 1)
        self.socket.readData(withTimeout: -1, tag: 0)

    }


    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        sock.readData(withTimeout: -1, tag: 0)
        let stringData = String(data: data, encoding: .utf8)
        print("read data \(stringData)")
        
    }
}
