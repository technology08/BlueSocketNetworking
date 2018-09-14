//
//  OpenCVWrapper.m
//  BlueSocketNetworking
//
//  Created by Ashis Laha on 9/13/17.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#import <UIKit/UIKit.h>

cv::Mat cvMatFromPixelBuffer (CVPixelBufferRef pixelBuffer) {
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    int bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
    int bytePerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    unsigned char *pixel = (unsigned char *) CVPixelBufferGetBaseAddress(pixelBuffer);
    cv::Mat image = cv::Mat(bufferHeight, bufferWidth, CV_8UC4, pixel, bytePerRow);
    
    return image;
}

CVPixelBufferRef getPixelBufferFromMat (cv::Mat mat) {
    
    cv::cvtColor(mat, mat, CV_BGR2BGRA);
    
    int width = mat.cols;
    int height = mat.rows;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             // [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             // [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             [NSNumber numberWithInt:width], kCVPixelBufferWidthKey,
                             [NSNumber numberWithInt:height], kCVPixelBufferHeightKey,
                             nil];
    
    CVPixelBufferRef imageBuffer;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorMalloc, width, height, kCVPixelFormatType_32BGRA, (CFDictionaryRef) CFBridgingRetain(options), &imageBuffer) ;
    
    
    //NSParameterAssert(status == kCVReturnSuccess && imageBuffer != NULL);
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *base = CVPixelBufferGetBaseAddress(imageBuffer) ;
    memcpy(base, mat.data, mat.total()*4);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return imageBuffer;
}

@implementation OpenCVWrapper

-(NSMutableArray*) findContourPoints :(CVPixelBufferRef)image {
    cv::Mat cvmat = cvMatFromPixelBuffer(image);
    std::vector<std::vector<cv::Point>> contours;
    cv::findContours(cvmat, contours, cv::RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    
    
    NSMutableArray *returnType = [NSArray init];
    
    for (std::vector<cv::Point> vector : contours ) {
        NSMutableArray *rowPoints = [NSMutableArray array];
        
        for (cv::Point point : vector) {
            CGPoint cgpoint = CGPointMake(point.x, point.y);
            
            NSValue *pointValue = [NSValue valueWithCGPoint:cgpoint];
            
            [rowPoints addObject: pointValue];
        }
        
        [returnType addObject:rowPoints];
        
    }
    
    return returnType;
    
}

-(CVPixelBufferRef) getContourImage :(CVPixelBufferRef)image {
    cv::Mat cvmat = cvMatFromPixelBuffer(image);
    std::vector<std::vector<cv::Point>> contours;
    cv::findContours(cvmat, contours, cv::RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    
    
    CVPixelBufferRef buffer = getPixelBufferFromMat(cvmat);
    
    return buffer;
    
}

-(OCVRect*) boundingRect :(CVPixelBufferRef)image {
    cv::Mat cvmat = cvMatFromPixelBuffer(image);
    std::vector<std::vector<cv::Point>> contours;
    cv::findContours(cvmat, contours, cv::RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    
    cv::Rect rect = cv::boundingRect(cvmat);
    OCVRect* swiftRect = [[OCVRect alloc] initWithArea:rect.area() height:rect.height width:rect.width x:rect.x y:rect.y];
    
    return swiftRect;
    
}

@end

