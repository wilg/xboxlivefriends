//
//  XBReputationView.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 9/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XBReputationView.h"
#import <QuartzCore/QuartzCore.h>


@implementation XBReputationView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setReputationPercentage:0.0];
	}
    return self;
}

- (void)drawRect:(NSRect)rect {

	NSImage *foreground = [[[NSImage imageNamed:@"stars_full.png"] copy] autorelease];
	NSImage *background = [[[NSImage imageNamed:@"stars_empty.png"] copy] autorelease];
//	
//	foreground = [self colorizeImage:foreground withColor:[NSColor redColor]];
//	background = [self colorizeImage:background withColor:[NSColor redColor]];

	//resize to view
	//[self bounds].size.height
	
	NSSize perspectiveSize;
	perspectiveSize.width = ([self bounds].size.height * [foreground size].width) / [foreground size].height;
	perspectiveSize.height = [self bounds].size.height;

	[foreground setSize:perspectiveSize];
	[background setSize:perspectiveSize];
	
//	NSRect foregroundRect = NSZeroRect;
//	foregroundRect.size = [foreground size];
//	
//	NSRect backgroundRect = NSZeroRect;
//	backgroundRect.size = [background size];
//
//	[self drawColoredImage:background withFrame:backgroundRect inView:self];
//	[self drawColoredImage:foreground withFrame:foregroundRect inView:self];
	float computedWidth = [foreground size].width * [self reputationPercentage];
	
	NSPoint origin = NSMakePoint(0.0, 0.0);
		
	[background compositeToPoint:origin operation:NSCompositeSourceOver];
	[foreground compositeToPoint:origin fromRect:NSMakeRect(0.0, 0.0, computedWidth, [foreground size].height) operation:NSCompositeSourceOver];
	
}

- (float)reputationPercentage {
	return reputationPercentage;
}

- (void)setReputationPercentage:(float)percent {
	reputationPercentage = percent;
	//[self setNeedsDisplay:YES];
	[self display];
}


- (void)drawColoredImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSButton *)view
{
	// Desaturate the image and pump up its brightness to get a good embossing highlight.
	CIFilter *colorAdjust = [CIFilter filterWithName:@"CIColorControls"];
	[colorAdjust setValue:[NSNumber numberWithFloat:0.0] forKey:@"inputSaturation"];
	[colorAdjust setValue:[NSNumber numberWithFloat:0.75] forKey:@"inputBrightness"];
	[colorAdjust setValue:[CIImage imageWithData:[image TIFFRepresentation]] forKey:@"inputImage"];
	
	CIImage *result = [colorAdjust valueForKey:@"outputImage"];
		if ([view isFlipped])
	{
		// CIImage doesn't have a setFlipped, so we need to flip it the long way.
		CIFilter *transform = [CIFilter filterWithName:@"CIAffineTransform"];
		[transform setValue:result forKey:@"inputImage"];
		NSAffineTransform *affineTransform = [NSAffineTransform transform];
		[affineTransform translateXBy:0 yBy:[image size].height];
		[affineTransform scaleXBy:1 yBy:-1];
		[transform setValue:affineTransform forKey:@"inputTransform"];
		result = [transform valueForKey:@"outputImage"];
	}		
		
	[result drawAtPoint:NSMakePoint(NSMidX(frame) - [image size].width / 2.0, NSMidY(frame) - [image size].width / 2.0) fromRect:(NSRect){NSZeroPoint, [image size]} operation:NSCompositeSourceAtop fraction:0.6];
}


- (NSImage *)colorizeImage:(NSImage *)src withColor:(NSColor *)color {
    NSImage *newImage = [[NSImage alloc] initWithSize:[src size]];
                        
    [newImage lockFocus];
    [color set];
    [NSBezierPath fillRect:NSMakeRect(0, 0, [src size].width, [src size].width)];
    [src compositeToPoint:NSMakePoint(0,0) operation:NSCompositePlusLighter];
    [newImage unlockFocus];

    return [newImage autorelease];
}

@end
