//
//  ViewController.swift
//  TCPSerwver
//
//  Created by Geyi Liu on 2017-09-20.
//  Copyright © 2017 Geyi Liu. All rights reserved.
//

import Cocoa
import SwiftSocket

class ViewController: NSViewController {
    var server: TCPServer!

    override func viewDidLoad() {
        super.viewDidLoad()
        testServer()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func echoService(client: TCPClient) {
        print("Newclient from:\(client.address)[\(client.port)]")
        var d = client.read(640000)
        let chunkShit = chunkMessage(d!)
        client.send(data: d!)
        //client.close()
    }

    func chunkMessage(_ wholeData: [Byte]) -> [NSData] {
        var chunks : [NSData] = [] //return value
        var i=0;
        var startIndex=0;
        while(i<wholeData.count - 4){
            if(wholeData[i] == 0xFF && wholeData[i+1] == 0xFF && wholeData[i+2] == 0xFF && wholeData[i+3] == 0xFF){
                let tempSubArray = wholeData[startIndex...i]
                startIndex=i+4;
                let tempSubData=(Data(bytes: tempSubArray)) as NSData
                chunks.append(tempSubData)
                i=i+4
            } else {
                i = i + 1
            }

        }
        return chunks
    }
    
    
    func testServer() {
        server = TCPServer(address: "0.0.0.0", port: 3000)
        //server.close()
        switch server.listen() {
        case .success:
            print("Connection success")
            if var client = server.accept() {
                echoService(client: client)
            } else {
                print("accept error")
            }
        case .failure(let error):
            //print("Failure")
            print(error)
        }
    }
    



}

