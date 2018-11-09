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
    @IBOutlet weak var frameStepper  : UIStepper!
    @IBOutlet weak var aspectRatioMin: UISlider!
    @IBOutlet weak var aspectRatioMax: UISlider!
    
    @IBOutlet weak var exposureLabel: UILabel!
    @IBOutlet weak var redMinLabel      : UILabel!
    @IBOutlet weak var redMaxLabel      : UILabel!
    @IBOutlet weak var greenMinLabel    : UILabel!
    @IBOutlet weak var greenMaxLabel    : UILabel!
    @IBOutlet weak var blueMinLabel     : UILabel!
    @IBOutlet weak var blueMaxLabel     : UILabel!
    @IBOutlet weak var frameDroppedLabel: UILabel!
    @IBOutlet weak var aspectRatioMinLabel: UILabel!
    @IBOutlet weak var aspectRatioMaxLabel: UILabel!
    
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
        
        exposureSlider.setValue(defaults.float(forKey: DefaultsMap.exposure ), animated: false)
        redMinSlider  .setValue(defaults.float(forKey: DefaultsMap.redMin   ), animated: false)
        redMaxSlider  .setValue(defaults.float(forKey: DefaultsMap.redMax   ), animated: false)
        greenMinSlider.setValue(defaults.float(forKey: DefaultsMap.greenMin ), animated: false)
        greenMaxSlider.setValue(defaults.float(forKey: DefaultsMap.greenMax ), animated: false)
        blueMinSlider .setValue(defaults.float(forKey: DefaultsMap.blueMin  ), animated: false)
        blueMaxSlider .setValue(defaults.float(forKey: DefaultsMap.blueMax  ), animated: false)
        frameStepper  .value = defaults.double(forKey: DefaultsMap.frames   )
        aspectRatioMin.setValue(defaults.float(forKey: DefaultsMap.aspectMin), animated: false)
        aspectRatioMax.setValue(defaults.float(forKey: DefaultsMap.aspectMax), animated: false)
        updateLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        try! setupCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        defaults.set(exposureSlider.value,  forKey: DefaultsMap.exposure )
        defaults.set(redMinSlider.value,    forKey: DefaultsMap.redMin   )
        defaults.set(redMaxSlider.value,    forKey: DefaultsMap.redMax   )
        defaults.set(greenMinSlider.value,  forKey: DefaultsMap.greenMin )
        defaults.set(greenMaxSlider.value,  forKey: DefaultsMap.greenMax )
        defaults.set(blueMinSlider.value,   forKey: DefaultsMap.blueMin  )
        defaults.set(blueMaxSlider.value,   forKey: DefaultsMap.blueMax  )
        defaults.set(frameStepper.value,    forKey: DefaultsMap.frames   )
        defaults.set(aspectRatioMin.value,  forKey: DefaultsMap.aspectMin)
        defaults.set(aspectRatioMax.value,  forKey: DefaultsMap.aspectMax)
        
        captureSession?.stopRunning()
        captureSession = nil
    }
    
    func updateLabels() {
        exposureLabel      .text = String(Float((exposureSlider.value * 100).rounded())/100)
        redMinLabel        .text = String(Float((redMinSlider  .value * 100).rounded())/100)
        redMaxLabel        .text = String(Float((redMaxSlider  .value * 100).rounded())/100)
        greenMinLabel      .text = String(Float((greenMinSlider.value * 100).rounded())/100)
        greenMaxLabel      .text = String(Float((greenMaxSlider.value * 100).rounded())/100)
        blueMinLabel       .text = String(Float((blueMinSlider .value * 100).rounded())/100)
        blueMaxLabel       .text = String(Float((blueMaxSlider .value * 100).rounded())/100)
        frameDroppedLabel  .text = String(Int(frameStepper.value.rounded()))
        aspectRatioMinLabel.text = String(Float((aspectRatioMin.value * 100).rounded())/100)
        aspectRatioMaxLabel.text = String(Float((aspectRatioMax.value * 100).rounded())/100)
    }
    
    @IBAction func stepperChanged(_ sender: Any) {
        updateLabels()
    }
    
}
