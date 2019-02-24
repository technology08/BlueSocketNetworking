//
//  VisionData.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 6/13/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import CoreGraphics
import Foundation

struct RectangleData: Codable {
    
    ///The difference between the center of the FoV and the rectangle's center
    private var degrees: Float = 0.0
    ///The timestamp given in ISO 8061 format: "YYYY-MM-DD HH:MM:SS +0000\n"
    private var timestamp: String = Formatter.iso8601.string(from: Date())
    ///The approximate distance given in inches.
    private var distance: Float = 0.0
    ///Whether a rectangle has been detected.
    private var detected = false
    
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
        return "inFov^\(self.detected)|angle1^\(self.degrees)|distance^\(self.distance)|time^\(self.timestamp)\n"
    }
    
}
