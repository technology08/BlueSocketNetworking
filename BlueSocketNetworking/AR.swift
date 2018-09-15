//
//  Camera.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 6/14/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import AVFoundation
import UIKit
import ARKit

extension ViewController: ARSessionDelegate {
    
    /**
     Configures AR Session. Run in viewDidLoad().
 */
    func setupARSession() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {print("No images"); return}
        let config = ARImageTrackingConfiguration()
        config.trackingImages = referenceImages
        sceneView.session = session
        session.delegate = self
        session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let anchor = anchor as? ARImageAnchor else { return }
            print((anchor.referenceImage.name ?? "nil") + ":" +
                "\(anchor.referenceImage.physicalSize.width)x\(anchor.referenceImage.physicalSize.height)")
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let anchor = anchor as? ARImageAnchor else { return }
            if anchor == self.targetAnchor {
                print("Updated size: \(anchor.referenceImage.physicalSize)")
            }
        }
    }
}
