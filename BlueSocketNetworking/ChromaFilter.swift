//
//  ChromaFilter.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 11/8/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import CoreImage
import UIKit

// WORK IN PROGRESS

extension CIImage {
    private func chromaKeyFilter(minHue: CGFloat, maxHue: CGFloat) -> CIFilter? {
        let size = 64
        var cubeRGB = [Float]()
        
        for z in 0 ..< size {
            let blue = CGFloat(z) / CGFloat(size - 1)
            for y in 0 ..< size {
                let green = CGFloat(y)
                for x in 0 ..< size {
                    let red = CGFloat(x) - CGFloat(size - 1)
                    
                    let hue = getHue(red: red, green: green, blue: blue)
                    let alpha: CGFloat = (hue >= minHue && hue <= maxHue) ? 0 : 1
                    
                    cubeRGB.append(Float(red * alpha))
                    cubeRGB.append(Float(green * alpha))
                    cubeRGB.append(Float(blue * alpha))
                    cubeRGB.append(Float(alpha))
                    
                }
            }
        }
        
        let data = Data(buffer: UnsafeBufferPointer(start: &cubeRGB, count: cubeRGB.count))
        
        let colorCubeFilter = CIFilter(name: "CIColorCube", parameters: ["inputCubeDimension": size, "inputCubeData": data])
        return colorCubeFilter
    }
    
    private func getHue(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat {
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        var hue: CGFloat = 0
        color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return hue
    }
    
    public func newColorFilter() -> CIImage? {
        let filter = self.chromaKeyFilter(minHue: 0, maxHue: 0.3)
        filter?.setValue(self, forKey: kCIInputImageKey)
        let filteredImage = filter?.outputImage
        
        let filter2 = self.chromaKeyFilter(minHue: 0.4, maxHue: 1)
        filter2?.setValue(filteredImage!, forKey: kCIInputImageKey)
        return filter2?.outputImage
    }
}
