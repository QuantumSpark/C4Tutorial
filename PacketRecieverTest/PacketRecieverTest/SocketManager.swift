// Copyright © 2016 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.


import Foundation
import CocoaAsyncSocket

open class SocketManager: NSObject, GCDAsyncUdpSocketDelegate {
    static let masterPort = UInt16(10101)
    static let peripheralPort = UInt16(11111)
    static let masterHost = "192.168.1.1"
    static let broadcastHost = "192.168.1.255"

    //255.255.0.0 (DHCP subnet mask)
    //10.0.0.2 (router network)
    static let sharedManager = SocketManager()

    var workspace: ViewController?

    let maxDeviceID = 28

    var bound = false

    //the socket that will be used to connect to the core app
    var socket: GCDAsyncUdpSocket!

    open lazy var deviceID: Int = 20
  
    public override init() {
        super.init()

        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        socket.setIPv4Enabled(true)
        socket.setIPv6Enabled(false)
        open()

        let packet = Packet(type: .handshake, id: deviceID)
        socket.send(packet.serialize() as Data, toHost: SocketManager.masterHost, port: SocketManager.masterPort, withTimeout: -1, tag: 0)
    }

    open func close() {
        socket.close()
        bound = false
    }

    open func open() {
        if !bound {
            do {
                try socket.enableBroadcast(true)
                try socket.bind(toPort: SocketManager.peripheralPort)
                try socket.beginReceiving()
                print("Connected to UDP host")
            } catch {
                print("could not open socket")
                return
            }
            bound = true

        }
    }

    open func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        var packet: Packet!
        do {
            packet = try Packet((data as NSData) as Data)
        } catch {
            return
        }
        if let data = packet.payload {
            print(data.count)
        }
    }

    open func broadcastPacket(_ packet: String) {
        socket.send(packet.data(using: .utf8)!, toHost: SocketManager.broadcastHost, port: SocketManager.peripheralPort, withTimeout: -1, tag: 0)
    }
}
