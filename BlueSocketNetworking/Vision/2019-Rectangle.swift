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
/*
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
}*/

fileprivate struct Line {
    var p1: CGPoint
    var p2: CGPoint
    
    // y-int (y-y1) = m(x-x1)
    // Given (5, 2) and (1, 6)
    // (y-6)=m(x-2)
    // y-6 = mx-m
    // y= (mx-m) + 6
    // y = mx - m + 6
    
    var yint: CGFloat {
        guard slope != 0.0 else { return .nan}
        guard p1.x != 0.0 && p1.y != 0.0 else { return .nan }
        
        return (slope * (0-p1.x)) + p1.y
    }
    
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
            // y = ax + c
            // y = bx + d
            
            // ax + c = bx + d
            // ax - bx = d - c
            // x(a-b) = d-c
            // x = (d-c)/(a-b)
            // y = mx + b
            let a = ourSlope
            let c = yint
            let b = theirSlope
            let d = other.yint
            
            let xCoordinate = (d-c)/(b-a)
            let yCoordinate = (a * xCoordinate) + c
            return CGPoint(x: xCoordinate, y: yCoordinate)
        }
    }
}

public func isIntersectionAbove(target1: VNRectangleObservation, target2: VNRectangleObservation) -> Bool {
   
        let line1 = Line(p1: target1.bottomLeft, p2: target1.topLeft)
        let line2 = Line(p1: target2.bottomLeft, p2: target2.topLeft)
        
        guard let intersectionPoint = line1.intersection(of: line2) else { return false }
        /////////////////////////////////////////////////////////////////////////
        /// TODO: MAKE SURE THIS IS GREATER THAN NOT LESS THAN FOR PROPORTIONS///
        /////////////////////////////////////////////////////////////////////////
        if intersectionPoint.y < target1.topLeft.y && intersectionPoint.y < target2.topLeft.y {
            print(intersectionPoint)
            print("ABOVE")
            print(target1.topLeft)
            return true
        } else {
            return false
        }
    
}

public func groupResults(target1: VNRectangleObservation, target2: VNRectangleObservation) -> CGRect {
    
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    // Most left determination
    
    x = [target1.topLeft.x, target1.bottomLeft.x, target2.topLeft.x, target2.bottomLeft.x].min()!
    // Lowest point determination
    
    y = [target1.topLeft.y, target1.topRight.y, target2.topLeft.y, target2.topRight.y].min()!
    
    let allX = [target1.topLeft.x, target1.bottomLeft.x, target2.topLeft.x, target2.bottomLeft.x, target1.topRight.x, target1.bottomRight.x, target2.topRight.x, target2.bottomRight.x]
    
    width = allX.max()! - allX.min()!
    
    let allY = [target1.topLeft.y, target1.topRight.y, target2.topLeft.y, target2.topRight.y, target1.bottomLeft.y, target1.bottomRight.y, target2.bottomLeft.y, target2.bottomRight.y]
    height = allY.max()! - allY.min()!
    
    let combinedRect = CGRect(x: x, y: y, width: width, height: height)
    print(combinedRect)
    //let observation = VNRectangleObservation(boundingBox: combinedRect)
    return combinedRect
}

// NEXT STEPS: Try two TrackRectangles algorithms simultaneously, where we can get the center from those.
