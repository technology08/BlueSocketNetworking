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
    
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!    
    @IBOutlet weak var confidenceSlider: UISlider!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    //AVCapture variables
    
    var captureSession: AVCaptureSession?
    //var cameraStream: AVCaptureVideoPreviewLayer?
    var cameraOutput = AVCaptureVideoDataOutput()
    
    ///The server used for communicating with the robot.
    var server: EchoServer?
    
    var sequenceRequestHandler = VNSequenceRequestHandler()
    ///The last observation to be passed into the tracking request.
    var lastRectObservation: VNRectangleObservation? = nil
    
    ///The last observation to be passed into the tracking request.
    var lastMLObservation: VNRecognizedObjectObservation? = nil
    
    ///The camera's horizontal field of view in degrees.
    var horizontalFoV: Float?
    
    ///The size in pixels of the pixel buffer.
    var pixelBufferSize = CGSize(width: 0, height: 0)
    
    ///Confidence level
    var confidence: Float = 0.4
        
    var debugValue = "No rectangle detected."
    
    ///The current data ready to be fetched by the server.
    //var currentData = RectangleData()
    
    ///Defaults stores values in filter settings
    let defaults = UserDefaults.standard
    
    var trackingDropped = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        self.runServer()
        
        // Configure confidence slider
        confidence = defaults.float(forKey: DefaultsMap.confidence)
        confidenceSlider.setValue(confidence, animated: false)
        confidenceLabel.text = String(confidence)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            try self.setupCamera()
        } catch {
            print(error)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        captureSession?.stopRunning()
        captureSession = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //let qos = DispatchQueue(label: "server")
        //qos.async {
        
        //}
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    
    }
    /**
     Creates a server running of a TCP socket through a port.
     * Using an Lightning to USB 3 camera adapter, connect a USB to Ethernet adapter and an Ethernet cable to the robot radio. In Settings -> Ethernet, configure IP to be `10.40.28.6`. Then connect to the specified port through the radio, and send the word "VISION" on a loop.
     * Using the simulator, open a terminal window and enter `nc ::1 1337`
     - Parameter port: Defaults to 1337.
 */
    func runServer(port: Int = 1337) {
        self.server = EchoServer(port: port)
        self.server?.runClient()
    }

    @IBAction func confidenceChanged(_ sender: Any) {
        confidence = confidenceSlider.value
        confidenceLabel.text = String((confidence * 100).rounded()/100)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        defaults.set(confidence, forKey: DefaultsMap.confidence)
    }
}
