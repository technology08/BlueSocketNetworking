//
//  ViewController.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 6/13/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import UIKit
import Socket
import Vision
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var serverSwitch: UISwitch!
    @IBOutlet weak var serverLabel: UILabel!
    
    @IBOutlet weak var visionSwitch: UISwitch!  
    @IBOutlet weak var visionLabel: NSLayoutConstraint!
    
    @IBOutlet weak var previewView: UIView!
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let type = Type.Client//Change
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
        
        do {
            try setupCamera()
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    /*
    func detectRect() {
        let request = VNDetectRectanglesRequest { (request, error) in
            //Process data from request
            guard error == nil else {
                print(error)
                return
            }
            
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: <#T##CVPixelBuffer#>, options: <#T##[VNImageOption : Any]#>)
    }*/


}

enum Type {
    case Server, Client
}
