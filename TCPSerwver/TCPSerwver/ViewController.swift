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
    func echoService(client: TCPClient) {
        print("Newclient from:\(client.address)[\(client.port)]")
        var d = client.read(1024*5*5*5*5)
        var data = Data(bytes: d!, count: (d?.count)!);
        var str=String(data:data,encoding: .utf8)
        print("str is \(str)")
        client.send(data: d!)
        client.close()
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


}

