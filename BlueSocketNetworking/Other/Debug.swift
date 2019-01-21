//
//  Debug.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 6/23/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import Vision
import CoreGraphics
import UIKit

class DebugView: UIView {
    var debugRect: UIView? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func drawRect(boundingBox: CGRect, size: CGSize) {
        let unnormalized = boundingBox.unnormalize(frameSize: size)
        DispatchQueue.main.async {
            if self.debugRect == nil {
                // Create RectView
                print("Frame is ")
                print(unnormalized)
                self.debugRect = UIView(frame: unnormalized)
                self.debugRect?.layer.borderColor = UIColor.red.cgColor
                self.debugRect?.layer.borderWidth = 5.0
                self.addSubview(self.debugRect!)
            } else {
                print("Frame is ")
                print(unnormalized)
                self.debugRect!.frame = unnormalized
            }
        }
    }
    
    func removeRect() {
        debugRect!.removeFromSuperview()
        self.debugRect = nil
    }
}

extension CGRect {
    func unnormalize(frameSize: CGSize) -> CGRect {
        return CGRect(x: self.minX * frameSize.width, y: frameSize.height - (self.minY * frameSize.height), width: self.width * frameSize.width, height: self.height * frameSize.height)
    }
    
    func normalize(frameSize: CGSize) -> CGRect {
        return CGRect(x: self.minX / frameSize.width, y: frameSize.height - (self.minY / frameSize.height), width: self.width / frameSize.width, height: self.height / frameSize.height)
    }
}
