//
//  MQSlice.m
//  
//
//  Created by John Carlyle on 11/12/06.
//  Copyright 2006 mindquirk. All rights reserved.
//

#import "MQSlice.h"
#import "ColorizeImage.h"


@implementation MQSlice

- (id)init  
{
	return [self initWithColor:[NSColor blueColor] texture:nil slice:10.0f message:@"Unknown Slice" dictionary:nil];
}

- (id)initWithColor:(NSColor *)theColor texture:(NSImage *)tex slice:(float)theSlice message:(NSString *)theMessage dictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self)   {
        color = [theColor retain];
        light = FALSE;
        captionData = [dict retain];
        slice = theSlice;
        message = [theMessage retain];
        degrees = 0.0f;
		shouldDisplay = YES;
        texture = [tex retain];
        if (tex == nil) {
            useTexture = NO;
        }
        else {
            useTexture = YES;
            [self generateTexture];
        }
    }
    return self;
}

- (void)setLight:(BOOL)l
{
    light = l;
}

- (BOOL)getLight
{
    return light;
}


- (void)setCaptionData:(NSDictionary *)data
{
    [captionData release];
    captionData = [data retain];
}

- (NSDictionary *)getCaptionData
{
    return captionData;
}


- (void)setBezierPath:(NSBezierPath *)newPath
{
    [path release];
    path = [newPath retain];
}

- (NSBezierPath *)getBezierPath
{
    return path;
}

- (void)setImage:(NSImage *)image
{
    [texture release];
    texture = [image retain];
    useTexture = TRUE;
}

- (NSImage *)getImage
{
    return texture;
}

- (void)setColor:(NSColor *)newColor
{
    [color release];
    color = [newColor retain];
}

- (NSColor *)getColor
{
    if (useTexture) {
        return colorizedTexture;
    }
    return color;
}

- (NSColor *)untexturedColor
{
    return color;
}

- (void)setUseTexture:(BOOL)t
{
    useTexture = t;
}

- (BOOL)getUseTexture
{
    return useTexture;
}

- (float)getDegrees
{
    return degrees;
}

- (void)setDegrees:(float)newDegree
{
    degrees = newDegree;
}

- (void)setSlice:(float)newSlice
{
    slice = newSlice;
}

- (float)getSlice
{
    return slice;
}

- (BOOL)shouldDisplay
{
	return shouldDisplay;
}

- (void)setShouldDisplay:(BOOL)x
{
	shouldDisplay = x;
}


- (void)setMessage:(NSString *)newMessage
{
    [message release];
    message = [newMessage retain];
}

- (NSString *)getMessage
{
    return message;
}

- (void)dealloc
{
    [captionData release];
    [path release];
    [message release];
    [color release];
	[texture release];
    [super dealloc]; 
}

- (void)generateTexture 
{
    colorizedTexture = [[self generateColorizedTexture] retain];
}

- (NSColor *)generateColorizedTexture
{
    if (texture && color) {
        return [NSColor colorWithPatternImage:[ColorizeImage colorizeImage:texture withColor:color]];
    }
    return nil;
}

+ (MQSlice *)sliceWithColor:(NSColor *)theColor texture:(NSImage *)tex slice:(float)theSlice message:(NSString *)theMessage captionData:(NSDictionary *)dict 
{
	return [[[MQSlice alloc] initWithColor:theColor texture:tex slice:theSlice message:theMessage dictionary:dict] autorelease];
}

@end
