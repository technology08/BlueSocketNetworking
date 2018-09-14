//
//  OCVRect.m
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 9/13/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

#import "OCVRect.h"

@implementation OCVRect
- (instancetype)initWithArea:(int)Area
                      height:(int)height
                       width:(int)width
                           x:(int)x
                           y:(int)y {
    self = [super init];
    if (self) {
        _area = Area;
        _height = height;
        _width = width;
        _x = x;
        _y = y;
    }
    return self;
}
@end
