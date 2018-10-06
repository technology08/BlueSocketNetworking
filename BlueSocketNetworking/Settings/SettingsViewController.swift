//
//  SettingsViewController.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 10/5/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import UIKit
import AVFoundation

class SettingsViewController: UIViewController {
    @IBOutlet weak var exposureSlider: UISlider!
    @IBOutlet weak var redMinSlider  : UISlider!
    @IBOutlet weak var redMaxSlider  : UISlider!
    @IBOutlet weak var greenMinSlider: UISlider!
    @IBOutlet weak var greenMaxSlider: UISlider!
    @IBOutlet weak var blueMinSlider : UISlider!
    @IBOutlet weak var blueMaxSlider : UISlider!
    
    @IBOutlet weak var exposureLabel: UILabel!
    @IBOutlet weak var redMinLabel  : UILabel!
    @IBOutlet weak var redMaxLabel  : UILabel!
    @IBOutlet weak var greenMinLabel: UILabel!
    @IBOutlet weak var greenMaxLabel: UILabel!
    @IBOutlet weak var blueMinLabel : UILabel!
    @IBOutlet weak var blueMaxLabel : UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    let defaults = UserDefaults.standard
    
    var captureSession: AVCaptureSession? = nil
    var output = AVCaptureVideoDataOutput()
    var device: AVCaptureDevice? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func sliderChanged(_ sender: Any) {
        updateLabels()
        device?.setExposureTargetBias(exposureSlider.value, completionHandler: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        exposureSlider.setValue(defaults.float(forKey: "exposure"), animated: false)
        redMinSlider  .setValue(defaults.float(forKey: "redMin"  ), animated: false)
        redMaxSlider  .setValue(defaults.float(forKey: "redMax"  ), animated: false)
        greenMinSlider.setValue(defaults.float(forKey: "greenMin"), animated: false)
        greenMaxSlider.setValue(defaults.float(forKey: "greenMax"), animated: false)
        blueMinSlider .setValue(defaults.float(forKey: "blueMin" ), animated: false)
        blueMaxSlider .setValue(defaults.float(forKey: "blueMax" ), animated: false)
        updateLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        try! setupCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        defaults.set(exposureSlider.value, forKey: "exposure")
        defaults.set(redMinSlider.value,   forKey: "redMin"  )
        defaults.set(redMaxSlider.value,   forKey: "redMax"  )
        defaults.set(greenMinSlider.value, forKey: "greenMin")
        defaults.set(greenMaxSlider.value, forKey: "greenMax")
        defaults.set(blueMinSlider.value,  forKey: "blueMin" )
        defaults.set(blueMaxSlider.value,  forKey: "blueMax" )
        
        captureSession?.stopRunning()
        captureSession = nil
    }
    
    func updateLabels() {
        exposureLabel.text = String(Float((exposureSlider.value * 100).rounded())/100)
        redMinLabel  .text = String(Float((redMinSlider  .value * 100).rounded())/100)
        redMaxLabel  .text = String(Float((redMaxSlider  .value * 100).rounded())/100)
        greenMinLabel.text = String(Float((greenMinSlider.value * 100).rounded())/100)
        greenMaxLabel.text = String(Float((greenMaxSlider.value * 100).rounded())/100)
        blueMinLabel .text = String(Float((blueMinSlider .value * 100).rounded())/100)
        blueMaxLabel .text = String(Float((blueMaxSlider .value * 100).rounded())/100)
    }
}
