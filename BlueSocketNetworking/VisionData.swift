//
//  VisionData.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 6/13/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import CoreGraphics

struct RectangleData: Codable {
    
    ///The difference between the center of the FoV and the rectangle's center
    var degrees: Float = 0.0
    ///The timestamp given in ISO 8061 format: "YYYY-MM-DD HH:MM:SS +0000\n"
    var timestamp: String = ""
    ///The approximate distance given in inches.
    var distance: Float = 0.0
    ///Whether a rectangle has been detected.
    var detected = false
    
    ///A blank initializer which turns `detected` to false.
    init() {
        detected = false
    }
    
    /**
     An initializer for resetting the RectangleData.
     - Parameter degreesOfDifference: The difference between the center of the FoV and the rectangle's center
     - Parameter date: The timestamp given in ISO 8061 format: "YYYY-MM-DD HH:MM:SS +0000\n"
     - Parameter height: The approximate distance given in inches.
    */
    init(degreesOfDifference: CGFloat, date: String, height: CGFloat) {
        self.degrees   = Float(degreesOfDifference)
        self.timestamp = date
        self.distance  = Float(height)
        self.detected  = true
    }
}

//height^3 + height^2 + height + connstant
