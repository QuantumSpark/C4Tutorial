// Copyright © 2016 Slant.
//
// This file is part of MO. The full MO copyright notice, including terms
// governing use, modification, and redistribution, is contained in the file
// LICENSE at the root of the source code distribution tree.

import Foundation
import Cocoa
import CocoaAsyncSocket


public class TCPSocketManagerMaster: NSObject, GCDAsyncSocketDelegate {
    static let masterID = Int(INT_MAX)
    static let masterPort = UInt16(80)

    static let sharedManager = TCPSocketManagerMaster()

    var queue: DispatchQueue
    var socket: GCDAsyncSocket!

    /// A list of all the peripherals by IP address
    var peripherals = [String: TCPPeripheral]()

    /// Action invoked when there is a change in status
    var changeAction: (() -> Void)?

    weak var pingTimer: Timer?

    public override init() {
        queue = DispatchQueue(label: "SocketManagerMaster", attributes: [])
        super.init()

        socket = GCDAsyncSocket(delegate: self, delegateQueue: queue)
        do {
            try socket.connect(toHost: "0.0.0.0", onPort: TCPSocketManager.masterPort)
        } catch {
            print("hello world")
        }
       
    }

    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("Success")
    }

    public func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("Accept to new socket")

        var hostString: NSString? = NSString()
        var port: UInt16 = 0


        
        GCDAsyncSocket.getHost(&hostString, port: &port, fromAddress: newSocket.connectedAddress!)

        guard let host = hostString as? String else {
            //            DDLogWarn("Received data from an invalid host")
            return
        }

        if let peripheral = peripherals[host] {
            Swift.print("Hello")
        } else {
            let peripheral = TCPPeripheral(address: host, socket: newSocket)
            peripheral.didReceivePacketAction = processPacket
            peripherals[host] = peripheral
        }
    }

    func processPacket(_ packet: Packet, peripheral: TCPPeripheral) {
        switch packet.packetType {
        case PacketType.handshake:
            DispatchQueue.main.async {
                self.changeAction?()
            }

        case PacketType.ping:
            DispatchQueue.main.async {
                self.changeAction?()
            }

        default:
            break
        }
    }

    // MARK: - Pinging

    func ping() {
        updateStatuses()
        let p = Packet(type: .ping, id: TCPSocketManagerMaster.masterID)

        socket.write(p.serialize(), withTimeout: -1, tag: 0)
    }

    func updateStatuses() {
        for (_, p) in peripherals {
            if p.lag > Peripheral.pingTimeout {
                // Disconnect if we don't get a ping for a while
                p.status = .Disconnected
                //                DDLogVerbose("Disconnected from: \(p.id)")
                queue.async {
                    self.peripherals.removeValue(forKey: p.address)
                }
            }
        }
    }
}
