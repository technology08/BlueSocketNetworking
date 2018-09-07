//
//  Extensions.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 8/2/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    mutating func convertToPixels(pixelBufferSize: CGSize) {
        self.x *= pixelBufferSize.width
        self.y *= pixelBufferSize.height
    }
}

extension CGFloat {
    enum Axis {
        case x
        case y
    }
    
    func convertToPixels(pixelBufferSize: CGSize, axis: Axis) -> CGFloat {
        switch axis {
        case Axis.x:
            return self * pixelBufferSize.width
        case Axis.y:
            return self * pixelBufferSize.height
        }
    }
}

public enum Target: Int {
    case Paper = 0, Steamworks = 1
}
