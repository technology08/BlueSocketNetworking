//
//  OCVRect.h
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 9/13/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCVRect : NSObject

@property (assign) int area;
@property (assign) int height;
@property (assign) int width;
@property (assign) int x;
@property (assign) int y;

- (instancetype)initWithArea:(int)Area
                  height:(int)height
                  width:(int)width
                           x:(int)x
                           y:(int)y;

@end

NS_ASSUME_NONNULL_END
