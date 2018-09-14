//
//  OpenCVWrapper.h
//  Shape Detection in AR
//
//  Created by Ashis Laha on 27/09/17.
//  Copyright © 2017 Ashis Laha. All rights reserved.
//

/*
 This is a wrapper class for creating your helping functions using openCV.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OCVRect.h"

@interface OpenCVWrapper : NSObject

-(NSMutableArray*) findContourPoints :(UIImage *)image;
-(CVPixelBufferRef) getContourImage :(CVPixelBufferRef)image;
-(OCVRect*) boundingRect :(CVPixelBufferRef)image;

@end


