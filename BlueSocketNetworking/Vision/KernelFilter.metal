//
//  KernelFilter.metal
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 2/23/19.
//  Copyright © 2019 Connor Espenshade. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <CoreImage/CoreImage.h> // includes CIKernelMetalLib.h

extern "C" { namespace coreimage {
    
    /*float4 myColor(sample_t s) {
        
        return s.grba;
    }*/
    
    float4 thresholdFilter(sample_t textureColor/*, float redMin, float redMax */, float greenMin/*, float greenMax, float blueMin, float blueMax*/) {

        if (textureColor.g > greenMin) {
            
            //textureColor.rgba = float4(textureColor.g * 1.5, textureColor.g * 1.5, textureColor.g * 1.5, textureColor.a);
            textureColor.rgba = float4(1.0, 1.0, 1.0, textureColor.a);
        }
        return textureColor.rgba;
    }
    
    /*float4 dansThreshold(sample_t textureColor, float redMin, float redMax, float greenMin, float greenMax, float blueMin, float blueMax) {
        if ((textureColor.r + textureColor.b) > (textureColor.g * 1.5)) {
            textureColor.rgba = float4(0.0, 0.0, 0.0, 0.0);
        } else {
            
            textureColor.rgba = float4(0.0, textureColor.g, 0.0, 1.0);
            if (textureColor.g > greenMin && textureColor.g <= greenMax) {
                textureColor.rgba = float4(1.0, 1.0, 1.0, 1.0);
                
            } else {
                textureColor.rgba = float4(0.0, 0.0, 0.0, 0.0);
            }
        }
        return textureColor.rgba;
    }*/
    
    /*float4 thresholdFilter(sample_t textureColor, float redMin, float redMax, float greenMin, float greenMax, float blueMin, float blueMax) {
        
        if (textureColor.r > redMin && textureColor.r < redMax && textureColor.g > greenMin && textureColor.g < greenMax && textureColor.b > blueMin && textureColor.b < blueMax) {
            
        } else {
            textureColor.rgba = float4(0.0, 0.0, 0.0, 0.0);
        }
        
        return textureColor;
    }*/
}}
