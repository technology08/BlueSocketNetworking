//
//  ViewController.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 6/13/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import UIKit
import Socket

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let type = Type.Server //Change
        if type == .Server {
            let port: Int32 = 1337
            let server = VisionServer(port: port)
            server.runClient()
        } else if type == .Client {
            let port: Int = 1337
            let server = EchoServer(port: port)
            server.runClient()
        }
       
        print("Connect with a command line window by entering 'nc ::1 1337'")
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

enum Type {
    case Server, Client
}
