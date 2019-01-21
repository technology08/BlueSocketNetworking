//
//  DataCaptureViewController.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 1/5/19.
//  Copyright © 2019 Connor Espenshade. All rights reserved.
//

import UIKit
import AVFoundation
import Zip

class DataCaptureViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var captureView: UIImageView!    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var filteredSwitch: UISwitch!
    @IBOutlet var percentView: PercentView!
    
    let defaults = UserDefaults.standard
    @IBOutlet weak var labelStepper: UIStepper!
    @IBOutlet weak var labelLabel: UILabel!
    
    var currentLabelName = "2019angledvision"
    var captureSession: AVCaptureSession? = nil
    var output = AVCaptureVideoDataOutput()
    var device: AVCaptureDevice? = nil
    var currentImage: UIImage? = nil
    var handleView: HandlesView? = nil
    var mode: DataCaptureMode = .Capture {
        didSet {
            switch mode {
            case .Capture:
                button.setTitle("Capture", for: .normal)
                cancelButton.title = "Delete All"
                cancelButton.isEnabled = true
                handleView?.remove()
                handleView = nil
                captureSession?.startRunning()
            case .BoundingBox:
                button.setTitle("Save", for: .normal)
                cancelButton.title = "Cancel"
                cancelButton.isEnabled = true
                captureSession?.stopRunning()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        try! setupCamera()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func capturePressed(_ sender: Any) {
        switch mode {
        case .Capture:
            mode = .BoundingBox
            
            handleView = HandlesView(frame: self.captureView.bounds)
            handleView!.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.captureView.addSubview(handleView!)
            
            //Custom property that contains the selected area of the rectangle. Its updated while resizing.
            handleView?.setSelectedFrame(CGRect(x: 128.0, y: 128.0, width: 200.0, height: 200.0))
            captureView.isUserInteractionEnabled = true
        case .BoundingBox:
            
            let boundingBox = handleView!.selectedFrame!
            mode = .Capture
            
            let frameSize = captureView.frame.size
            
            let randomIDNumber = Int.random(in: 1..<9999)
            
            //Assuming image output resolution is 1080x1920
            let outputWidth : CGFloat = 1080
            let outputHeight: CGFloat = 1920
            
            let string = "{\"coordinates\": {\"x\": \(boundingBox.minX / frameSize.width * outputWidth), \"y\": \(boundingBox.minY / frameSize.height * outputHeight), \"height\": \(boundingBox.height / frameSize.height * outputHeight), \"width\": \(boundingBox.width / frameSize.height * outputHeight)}, \"label\": \"\(currentLabelName)\"}"
            
            let textFile = "annotations/\(randomIDNumber).txt" //this is the file. we will write to and read from it
            let imageFile = "img/\(randomIDNumber).png"
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let textFileURL = dir.appendingPathComponent(textFile)
                let imageFileURL = dir.appendingPathComponent(imageFile)
                
                let textFolder = dir.appendingPathComponent("annotations")
                let imageFolder = dir.appendingPathComponent("img")
                
                do {
                    try FileManager.default.createDirectory(at: textFolder, withIntermediateDirectories: true, attributes: nil)
                    try FileManager.default.createDirectory(at: imageFolder, withIntermediateDirectories: true, attributes: nil)
                    try string.write(to: textFileURL, atomically: false, encoding: .utf8)
                    let image = self.captureView.image!
                    let png = image.pngData()
                    try png?.write(to: imageFileURL)
                } catch {
                    fatalError(error.localizedDescription)
                }
                
            }
            
        }

    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        switch mode {
        case .Capture:
            // Delete all
            let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete all stored data?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Delete All", style: .destructive, handler: { (action) in
                guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                print(dir)
                let fileURLS = try! FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])
                print(fileURLS)
                for url in fileURLS {
                    do {
                        try FileManager.default.removeItem(at: url)
                    } catch {
                        print("FileManager couldn't remove item at \(url.path): " + error.localizedDescription)
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        case .BoundingBox:
            // Go back
            mode = .Capture
        }
    }
    
    
    @IBAction func export(_ sender: Any) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            do {
                let fileURLS = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])
                // process files
                let archiveURL = try Zip.quickZipFiles(fileURLS, fileName: "Data.zip") { (percent) in
                    if percent < 1.0 {
                        self.showPercentView()
                        self.percentView.setProgress(percent: Float(percent))
                    } else {
                        self.dismissPercentView()
                    }
                }
                let activity = UIActivityViewController(activityItems: [archiveURL], applicationActivities: nil)
                self.present(activity, animated: true, completion: nil)
            } catch {
                print("Error while enumerating files \(dir.path): \(error.localizedDescription)")
            }
            
        }
    }
    @IBAction func stepperChanged(_ sender: Any) {
        labelLabel.text = String(labelStepper.value)
        if labelStepper.value == 0.0 {
            currentLabelName = "2019angledvision"
        } else {
            currentLabelName = String(Int(labelStepper.value))
        }   
    }
    
}

enum DataCaptureMode {
    case Capture
    case BoundingBox
}
