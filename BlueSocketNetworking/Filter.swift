//
//  Filter.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 6/28/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import CoreImage
import UIKit

extension CIImage {
    public func colorFilter() -> CIImage? {
        // Actual: UIColor(hue: 126, saturation: 63, brightness: 53, alpha: 1)
        
        //let minColor = UIColor(hue: 110, saturation: 50, brightness: 40, alpha: 0).ciColor
        //60, 102, 51
        //let maxColor = UIColor(hue: 140, saturation: 70, brightness: 60, alpha: 1).ciColor
        //46, 153, 83
        
        let kernelString =
        """
        kernel vec4 thresholdFilter(__sample textureColor) {

            if (textureColor.r > 0.18 && textureColor.r < 0.24 && textureColor.g > 0.40 && textureColor.g < 0.60 && textureColor.b > 0.20 && textureColor.b < 0.33) {
                textureColor.rgb = vec3(1.0, 1.0, 1.0);
            } else {
                textureColor.rgb = vec3(0.0, 0.0, 0.0);
            }

            return textureColor;
        }
        """
        
        guard let kernel = CIColorKernel(source: kernelString) else { return nil }
        let filtered = kernel.apply(extent: self.extent, arguments: [self])
        return filtered
        
    }
}

