//
//  Filter.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 6/28/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import CoreImage
import UIKit
import AVFoundation

extension CIImage {
    
    /**
     Applies a green color filter. All pixels are either white or black depending on if they fit in the color range.
     */
    public func colorFilter(
        redMin  : Float,
        redMax  : Float,
        greenMin: Float,
        greenMax: Float,
        blueMin : Float,
        blueMax : Float
        ) -> CIImage? {
        
        //  textureColor.r > 0.00 && textureColor.r < 0.35 && textureColor.g > 0.25 && textureColor.g < 0.60 && textureColor.b > 0.00 && textureColor.b < 0.25
        let kernelString =
        """
        kernel vec4 thresholdFilter(__sample textureColor, float redMin, float redMax, float greenMin, float greenMax, float blueMin, float blueMax) {

            if (textureColor.r > redMin && textureColor.r < redMax && textureColor.g > greenMin && textureColor.g < greenMax && textureColor.b > blueMin && textureColor.b < blueMax) {
                
            } else {
                textureColor.rgb = vec3(0.0, 0.0, 0.0);
            }

            return textureColor;
        }
        """
        
        let dansKernelString =
        """
        kernel vec4 thresholdFilter(__sample textureColor, float redMin, float redMax, float greenMin, float greenMax, float blueMin, float blueMax) {
            if ((textureColor.r + textureColor.b) > (textureColor.g * 1.5)) {
                textureColor.rgb = vec3(0.0, 0.0, 0.0);
            } else {

                textureColor.rgb = vec3(0.0, textureColor.g, 0.0);
                if (textureColor.g > greenMin && textureColor.g <= greenMax) {
                    textureColor.rgb = vec3(1.0, 1.0, 1.0);
                } else {
                    textureColor.rgb = vec3(0.0, 0.0, 0.0);
                }
            }
            return textureColor;
        }
        """
        
        let onlyGreen =
        """
         kernel vec4 thresholdFilter(__sample textureColor, float redMin, float redMax, float greenMin, float greenMax, float blueMin, float blueMax) {
                if (textureColor.g > greenMin) {

                    textureColor.rgb = vec3(textureColor.g * 1.5, textureColor.g * 1.5, textureColor.g * 1.5);
                }
            return textureColor;
        }
        """
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        let data = try! Data(contentsOf: url)
        let kernel = try! CIColorKernel(functionName: "thresholdFilter", fromMetalLibraryData: data)
        //guard let kernel = CIColorKernel(source: onlyGreen) else { return nil }
        let filtered = kernel.apply(extent: self.extent, arguments: [self, redMin, redMax, greenMin, greenMax, blueMin, blueMax])
        return filtered
        
    }
}

extension CMSampleBuffer {
    /**
     Converts CMSampleBuffer produced from delegate to CIImage. Also sets the size of the pixel buffer to self.pixelBufferSize for use in calculations.
     - Parameter sampleBuffer: The sample buffer produced from the captureOutput function to be processed.
     - Parameter filtered: If set to true, the image will be filtered by the `colorFilter()` func.
     - Returns: `CIImage` from sample buffer, potentially filtered and `CGSize` of pixel buffer.
     */
    func getFilteredImage(redMin: Float, redMax: Float, greenMin: Float, greenMax: Float, blueMin: Float, blueMax: Float, filtered: Bool) -> (CIImage, CGSize) {
        let buffer = CMSampleBufferGetImageBuffer(self)! as CVPixelBuffer
        
        let pixelBufferSize = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
        
        let image = CIImage(cvPixelBuffer: buffer)
        if filtered {
            /*let filteredImage = image.colorFilter(redMin: redMin, redMax: redMax, greenMin: greenMin, greenMax: greenMax, blueMin: blueMin, blueMax: blueMax)!
            return (filteredImage, pixelBufferSize)*/
            let filter = MetalKernelFilter(inputImage: image, inputGreen: greenMin)
            let image = filter.outputImage!
            return (image, pixelBufferSize)
        } else {
            return (image, pixelBufferSize)
        }
    }
}
