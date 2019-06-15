//
//  CIMetalFilter.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 2/24/19.
//  Copyright © 2019 Connor Espenshade. All rights reserved.
//

import CoreImage

class MetalKernelFilter: CIFilter {
    private var inputImage: CIImage?
    private var inputGreen: Float?
    private var inputBrightness: Float?
    private var customKernel: CIColorKernel?
    
    fileprivate func initializeKernel() {
        if customKernel == nil {
            let kernelURL: URL? = Bundle.main.url(forResource: "default", withExtension: "metallib")
            var error: Error?
            var data: Data? = nil
            if let kernelURL = kernelURL {
                data = try! Data(contentsOf: kernelURL)
            }
            if let data = data {
                customKernel = try! CIColorKernel(functionName: "thresholdFilter", fromMetalLibraryData: data)
            }
        }
    }
    
    override init() {
        super.init()
        initializeKernel()
    }
    
    convenience init(inputImage: CIImage, inputGreen: Float? = 0.5, inputBrightness: Float? = 0.5) {
        
        self.init()
        self.inputImage = inputImage
        self.inputGreen = inputGreen
        self.inputBrightness = inputBrightness
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var outputImage: CIImage? {
        guard let inputImage = inputImage else { return nil }
        return customKernel?.apply(extent: inputImage.extent, arguments: [inputImage, inputGreen ?? 0.5, inputBrightness ?? 0.5])
    }
    
}

