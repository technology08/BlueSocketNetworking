//
//  Extensions.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 8/2/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import CoreGraphics
import Foundation

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

extension Formatter {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

/**
 A Swift multithreaded locking function.
 - Parameter obj: The object you wish to lock, or pause read/write actions.
 - Parameter blk: The function in which you update the obj.
 */
func lock(obj: AnyObject, blk:() -> ()) {
    objc_sync_enter(obj)
    blk()
    objc_sync_exit(obj)
}

// GCD sync not async
