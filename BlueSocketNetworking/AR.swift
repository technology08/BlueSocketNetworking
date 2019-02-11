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

extension ViewController: ARSessionDelegate, ARSCNViewDelegate {
    
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARImageAnchor {
            let referenceImage = anchor.referenceImage
            print((referenceImage.name ?? "nil") + ":" +
                "\(referenceImage.physicalSize.width)x\(referenceImage.physicalSize.height)")
            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
            self.trackedNode = SCNNode(geometry: plane)
            trackedNode?.opacity = 0.25
            
            /*
             `SCNPlane` is vertically oriented in its local coordinate space, but
             `ARImageAnchor` assumes the image is horizontal in its local space, so
             rotate the plane to match.
             */
            //            trackedNode?.eulerAngles.x = -.pi / 2
            //            let transform = anchor.transform.columns.3
            //            trackedNode?.position = SCNVector3Make(transform.x, transform.y, transform.z)
            
            // Add the plane visualization to the scene.
            self.sceneView.scene.rootNode.addChildNode(trackedNode!)
            self.targetAnchor = anchor
            return trackedNode
        } else {
            return node
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        if let anchor = anchor as? ARImageAnchor {
        if anchor.referenceImage == self.targetAnchor?.referenceImage {
            print("Updated size: \(anchor.referenceImage.physicalSize)")
            let transform = anchor.transform.columns.3
            trackedNode = SCNNode(geometry: SCNPlane(width: anchor.referenceImage.physicalSize.width, height: anchor.referenceImage.physicalSize.height))
            trackedNode?.position = SCNVector3Make(transform.x, transform.y, transform.z)
            
        }
        }
    }
    
}
