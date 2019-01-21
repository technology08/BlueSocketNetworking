//
//  2019-Rectangle.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 1/21/19.
//  Copyright © 2019 Connor Espenshade. All rights reserved.
//

// Code specific to the 2019 season, where it must find if the slope of two rectangles intersect above the space.

import Vision

// From https://rosettacode.org/wiki/Find_the_intersection_of_two_lines#Swift

fileprivate struct Line {
    var p1: CGPoint
    var p2: CGPoint
    
    var slope: CGFloat {
        guard p1.x - p2.x != 0.0 else { return .nan }
        
        return (p1.y-p2.y) / (p1.x-p2.x)
    }
    
    func intersection(of other: Line) -> CGPoint? {
        let ourSlope = slope
        let theirSlope = other.slope
        
        guard ourSlope != theirSlope else { return nil }
        
        if ourSlope.isNaN && !theirSlope.isNaN {
            return CGPoint(x: p1.x, y: (p1.x - other.p1.x) * theirSlope + other.p1.y)
        } else if theirSlope.isNaN && !ourSlope.isNaN {
            return CGPoint(x: other.p1.x, y: (other.p1.x - p1.x) * ourSlope + other.p1.y)
        } else {
            let x = (ourSlope*p1.x - theirSlope*other.p1.x + other.p1.y - p1.y) / (ourSlope - theirSlope)
            return CGPoint(x: x, y: theirSlope*(x - other.p1.x) + other.p1.y)
        }
    }
}

public func isIntersectionAbove(target1: VNRectangleObservation, target2: VNRectangleObservation) -> Bool {
    let line1 = Line(p1: target1.bottomLeft, p2: target1.topLeft)
    let line2 = Line(p1: target2.bottomRight, p2: target2.topRight)
    
    guard let interserctionPoint = line1.intersection(of: line2) else { return false }
    if interserctionPoint.y > target1.topLeft.y && interserctionPoint.y > target2.topLeft.y {
        return true
    } else {
        return false
    }
}

public func groupResults(target1: VNRectangleObservation, target2: VNRectangleObservation) -> VNDetectedObjectObservation {
    
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    // Most left determination
    
    let xValues = [target1.topLeft.x, target1.bottomLeft.x, target2.topLeft.x, target2.bottomLeft.x]
    x = xValues.min()!
    // Lowest point determination
    
    let yValues = [target1.topLeft.y, target1.topRight.y, target2.topLeft.y, target2.topRight.y]
    y = yValues.min()!
    
    width = xValues.max()! - xValues.min()!
    height = yValues.max()! - yValues.min()!
    
    let combinedRect = CGRect(x: x, y: y, width: width, height: height)
    
    let observation = VNDetectedObjectObservation(boundingBox: combinedRect)
    return observation
}
