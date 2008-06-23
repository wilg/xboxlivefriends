//
//  ColorizeImage.m
//  MQPieChartTest
//
//  Created by John Carlyle on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ColorizeImage.h"


@implementation ColorizeImage


+ (NSImage *)colorizeImage:(NSImage *)src withColor:(NSColor *)color
{
    NSImage *newImage = [[NSImage alloc] initWithSize:[src size]];
                        
    [newImage lockFocus];
    [color set];
    [NSBezierPath fillRect:NSMakeRect(0, 0, [src size].width, [src size].width)];
    [src compositeToPoint:NSMakePoint(0,0) operation:NSCompositePlusLighter];
    [newImage unlockFocus];

    return [newImage autorelease];
}

+ (NSColor *)makeImageColorPattern:(NSImage *)image
{
    return [NSColor colorWithPatternImage:image];
}


@end
