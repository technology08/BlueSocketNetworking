//
//  VisionData.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 6/13/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import CoreGraphics

/*
struct VisionData: Codable {
    var topLeftX:     Float = 0.0
    var topLeftY:     Float = 0.0
    
    var topRightX:    Float = 0.0
    var topRightY:    Float = 0.0
    
    var bottomRightX: Float = 0.0
    var bottomRightY: Float = 0.0
    
    var bottomLeftX:  Float = 0.0
    var bottomLeftY:  Float = 0.0
    
    var timestamp: Float = 0
    
    var error: String? = nil
    
    init() {
        
    }
    
    init(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
        
        topLeftX     = Float(topLeft.x)
        topLeftY     = Float(topLeft.y)
        topRightX    = Float(topRight.x)
        topRightY    = Float(topRight.y)
        bottomRightX = Float(bottomRight.x)
        bottomRightY = Float(bottomRight.y)
        bottomLeftX  = Float(bottomLeft.x)
        bottomLeftY  = Float(bottomLeft.y)
        
    }
    
    mutating func randomize() {
        
        do {
            self.bottomLeftX  =    Float.random(in: 0...100)
            self.bottomRightX =    Float.random(in: 0...100)
            self.bottomRightY =    Float.random(in: 0...100)
            self.bottomLeftY  =    Float.random(in: 0...100)
            self.topLeftX     =    Float.random(in: 0...100)
            self.topRightX    =    Float.random(in: 0...100)
            self.topRightY    =    Float.random(in: 0...100)
            self.topLeftY     =    Float.random(in: 0...100)
            
            print(self.topLeftX)
        } catch {
            self.error = error.localizedDescription
            fatalError()
        }
        
        
    }
}*/
/*
 extension Float {
 public static func random(in range: ClosedRange<Float>) -> Float {
 return Float(arc4random()) / Float(range.upperBound)
 }
 }
 */

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
    
    ///An initializer for resetting the RectangleData.
    init(degreesOfDifference: CGFloat, date: String, height: CGFloat) {
        self.degrees   = Float(degreesOfDifference)
        self.timestamp = date
        self.distance  = Float(height)
        self.detected  = true
    }
}

//height^3 + height^2 + height + connstant
