//
//  SceneNodeCreator.swift
//
//
//  Created by Ashis Laha on 14/07/17.
//

import Foundation
import SceneKit

func intToCGPoint(x: Int, y: Int) -> CGPoint {
    return CGPoint(x: x, y: y)
}

class SceneNodeCreator {
    
    static let windowRoot : (x:Float,y:Float) = (-0.25,-0.25) // default is (0.0,0.0)
    static let z : Float = -0.5 // Z axis of AR co-ordinates
    
    // calculate nodes based on data for shape detection
    class func getSceneNode(shapreResults : [[String : Any]] ) -> [CGPoint]?  { // input is array of dictionary
        let convertionRatio : Float = 1000.0
        let imageWidth : Int = 499
        
        //for eachShape in shapreResults {
        guard let eachShape = shapreResults.first else { return nil }
        if let dictionary = eachShape.first {
            
            let values = dictionary.value as! [[String : Any]]
            switch dictionary.key {
            case "circle" :
                
                if let circleParams = values.first as? [String : Float] {
                    let x = circleParams["center.x"] ?? 0.0
                    let y = circleParams["center.y"] ?? 0.0
                    let radius = circleParams["radius"] ?? 0.0
                    let center = SCNVector3Make(Float(Float(imageWidth)-y)/convertionRatio+SceneNodeCreator.windowRoot.x, Float(Float(imageWidth)-x)/convertionRatio+SceneNodeCreator.windowRoot.y, SceneNodeCreator.z)
                }
                return nil
            //case "line","triangle", "rectangle","pentagon","hexagon":
            default:
                var arrayOfPoints: [CGPoint] = []
                for i in 0..<values.count { // connect all points usning straight lines (basic)
                    let x = values[i]["x"] as! Int
                    let y = values[i]["y"] as! Int
                    let point = intToCGPoint(x: x, y: y)
                    arrayOfPoints.append(point)
                }
                return arrayOfPoints
            }
        }
        //}
        return nil
    }
    
    class func centroidOfTriangle(point1 : (Float,Float), point2 : (Float,Float), point3 : (Float,Float)) -> (Float,Float) {
        var centroid : (x:Float, y:Float) = (0.0,0.0)
        let middleOfp1p2 : (x:Float, y:Float) = ((point1.0+point2.0)/2 , (point1.1+point2.1)/2)
        centroid.x = point3.0 + 2/3*(middleOfp1p2.x-point3.0)
        centroid.y = point3.1 + 2/3*(middleOfp1p2.y-point3.1)
        return centroid
    }
    
    class func center(diagonal_p1: (Float,Float), diagonal_p2 : (Float,Float)) -> (Float,Float) {
        return ((diagonal_p1.0+diagonal_p2.0)/2 ,(diagonal_p1.1+diagonal_p2.1)/2)
    }
    
}

/*
 ******************************** Below extension NOT USED FOR SHAPE DETECTION *******************************
 */


enum GeometryNode {
    case Box
    case Pyramid
    case Capsule
    case Cone
    case Cylinder
}

enum ArrowDirection {
    case towards
    case backwards
    case left
    case right
}

extension UIColor {
    class func getRandomColor() -> UIColor {
        let random = Int(arc4random_uniform(8))
        switch random {
        case 0: return UIColor.red
        case 1: return UIColor.brown
        case 2: return UIColor.green
        case 3: return UIColor.yellow
        case 4: return UIColor.blue
        case 5: return UIColor.purple
        case 6: return UIColor.cyan
        case 7: return UIColor.orange
        default: return UIColor.darkGray
        }
    }
}

extension UIFont {
    // Based on: https://stackoverflow.com/questions/4713236/how-do-i-set-bold-and-italic-on-uilabel-of-iphone-ipad
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
}
