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

extension ViewController {
    
    
    func drawBox(box: VNRectangleObservation) {
        let xCoord = box.topLeft.x * previewView.frame.size.width
        let yCoord = (1 - box.topLeft.y) * previewView.frame.size.height
        let width = (box.topRight.x - box.bottomLeft.x) * previewView.frame.size.width
        let height = (box.topLeft.y - box.bottomLeft.y) * previewView.frame.size.height
        
        let layer = CALayer()
        layer.frame = CGRect(x: xCoord, y: yCoord, width: width, height: height)
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.blue.cgColor
        
        previewView.layer.addSublayer(layer)
    }

    func newDraw(box: VNRectangleObservation) {
        let layer = CALayer()
        layer.frame = CGRect(x: box.topLeft.x, y: box.topLeft.y, width: (box.topRight.x - box.topLeft.x), height: (box.topLeft.y - box.bottomLeft.y))
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.blue.cgColor
        
        previewView.layer.addSublayer(layer)
    }
    
}
