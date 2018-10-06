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

extension UIImage {
    class func circle(point: CGPoint) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 5, height: 5), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        let rect = CGRect(x: point.x, y: point.y, width: 5, height: 5)
        ctx.setFillColor(UIColor.blue.cgColor)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
}
