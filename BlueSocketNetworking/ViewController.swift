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
    var cameraStream: AVCaptureVideoPreviewLayer?
    var output = AVCaptureVideoDataOutput()
    
    var server: EchoServer?
    
    var sequenceRequestHandler = VNSequenceRequestHandler()
    var lastObservation: VNRectangleObservation?
    
    var horizontalFoV: Float?
    var pixelBufferSize = CGSize(width: 0, height: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /*
            let port: Int = 1337
            self.server = EchoServer(port: port)
            self.server?.runClient()
            
            print("Connect with a command line window by entering 'nc ::1 1337'")
        */

        do {
            try self.setupCamera()
        } catch {
            print(error)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    @IBAction func serverSwitchChanged(_ sender: Any) {
    
        if self.serverSwitch.isOn {
            let port: Int = 1337
            self.server = EchoServer(port: port)
            self.server?.runClient()
            
            print("Connect with a command line window by entering 'nc ::1 1337'")
        } else if !self.serverSwitch.isOn {
            self.server?.shutdownServer()
        }

    }
    
}
