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
    private var degrees: Float = 0.0
    ///The timestamp given in ISO 8061 format: "YYYY-MM-DD HH:MM:SS +0000\n"
    private var timestamp: String? = nil
    ///The approximate distance given in inches.
    private var distance: Float = 0.0
    ///Whether a rectangle has been detected.
    private var detected = false
    /// The percent area the target takes up of the overall field of view
    private var areaPercent = 0.0
    /// The height of the bounding box
    private var heightOfBoundingBox = 0.0
    /// Vertical distance of the rectangle to the top of the view.
    private var verticalDistancetoTop = 0.0
    
    ///A blank initializer which turns `detected` to false.
    public init() {
        detected = false
    }
    
    /**
     An initializer for resetting the RectangleData.
     - Parameter degreesOfDifference: The difference between the center of the FoV and the rectangle's center
     - Parameter date: The timestamp given in ISO 8061 format: "YYYY-MM-DD HH:MM:SS +0000\n"
     - Parameter height: The approximate distance given in inches.
    */
    public init(degreesOfDifference: CGFloat, date: String, height: CGFloat) {
        self.degrees   = Float(degreesOfDifference)
        self.timestamp = date
        self.distance  = Float(height)
        self.detected  = true
    }
    
    // PIPE LIMITED STRING
    public func getPipeString() -> String {
        switch detected {
        case true:
            return "degrees: \(self.degrees) | time: \(self.timestamp!) | detected: \(self.detected)"
        case false:
            return "detected: \(self.detected)"
        }
        
    }
    
}

//height^3 + height^2 + height + connstant
