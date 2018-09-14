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
    /**
     Applies a green color filter. All pixels are either white or black depending on if they fit in the color range.
     */
    public func colorFilter(target: Int = 0) -> CIImage? {
        // Actual: UIColor(hue: 126, saturation: 63, brightness: 53, alpha: 1)
        
        //let minColor = UIColor(hue: 110, saturation: 50, brightness: 40, alpha: 0).ciColor
        //60, 102, 51
        //let maxColor = UIColor(hue: 140, saturation: 70, brightness: 60, alpha: 1).ciColor
        //46, 153, 83
        //122, 165, 86 -> 0.48, 0.65, 0.34
        
        //HSV: 5,0,0 to 80,255,255
        //Ratios h2w 0.2-0.53
        //Ratios w2h 5-1.88
        //Area ratio 1.75-2.1
        
        var kernelString: String = ""
        
        switch target {
        case 0:
            kernelString =
            """
            kernel vec4 thresholdFilter(__sample textureColor) {
            
            if (textureColor.r > 0.20 && textureColor.r < 0.57 && textureColor.g > 0.28 && textureColor.g < 0.71 && textureColor.b > 0.15 && textureColor.b < 0.41 &&
            textureColor.g > textureColor.r &&
            textureColor.g > textureColor.b) {
            textureColor.rgb = vec3(1.0, 1.0, 1.0);
            } else {
            textureColor.rgb = vec3(0.0, 0.0, 0.0);
            }
            
            return textureColor;
            }
            """
        case 1:
            kernelString =
            """
            kernel vec4 thresholdFilter(__sample textureColor) {
            
            if (textureColor.r > 0.00 && textureColor.r < 0.50 && textureColor.g > 0.78 && textureColor.g < 1.00 && textureColor.b > 0.50 && textureColor.b < 1.00 &&
            textureColor.g > textureColor.r &&
            textureColor.g > textureColor.b) {
            textureColor.rgb = vec3(1.0, 1.0, 1.0);
            } else {
            textureColor.rgb = vec3(0.0, 0.0, 0.0);
            }
            
            return textureColor;
            }
            """
        default:
            kernelString = ""
        }
        
        
        
        guard let kernel = CIColorKernel(source: kernelString) else { return nil }
        let filtered = kernel.apply(extent: self.extent, arguments: [self])
        return filtered
        
    }
    
    func floodFill() -> CIImage? {
        
        let kernelString =
        """
        kernel vec4 thresholdFilter(__sample textureColor) {
            
            vec3 lastPixelColor = vec3(0.0, 0.0, 0.0);

            if (textureColor.rgb == vec3(1.0, 1.0, 1.0)) {
                if (lastPixelColor == vec3(0.0, 0.0, 0.0)) {
                    lastPixelColor = vec3(1.0, 1.0, 1.0);
                } else {
                    lastPixelColor = vec3(0.0, 0.0, 0.0);
                }
            } else {
                if (lastPixelColor == vec3(1.0, 1.0, 1.0)) {
                    textureColor.rgb = vec3(1.0, 1.0, 1.0);
                } else {
                    textureColor.rgb = vec3(0.0, 0.0, 0.0);
                }
            }

            return textureColor;
        }
        """
        
        guard let kernel = CIColorKernel(source: kernelString) else { return nil }
        let filtered = kernel.apply(extent: self.extent, arguments: [self])
        return filtered
    }
}

