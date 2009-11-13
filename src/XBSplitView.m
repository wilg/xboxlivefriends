//
//  XBSplitView.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XBSplitView.h"


@implementation XBSplitView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect
{
	[self drawDividerInRect:rect];
}

- (void)drawDividerInRect:(NSRect)aRect
{
	// Create a canvas
	NSImage * canvas = [[[NSImage alloc] initWithSize:aRect.size] autorelease];
	NSImage * grip = [NSImage imageNamed:@"splitview_grip"];
	NSImage * bar = [NSImage imageNamed:@"splitview_bar"];

	// Draw bar and grip onto the canvas
	NSRect canvasRect = NSMakeRect(0, 0, [canvas size].width, [canvas size].height);
	NSRect gripRect = canvasRect;
	gripRect.origin.x = (NSMidX(aRect) - ([grip size].width/2));
	[canvas lockFocus];
	[bar setSize:aRect.size];
	[bar drawInRect:canvasRect fromRect:canvasRect operation:NSCompositeSourceOver fraction:1.0];
	[grip drawInRect:gripRect fromRect:canvasRect operation:NSCompositeSourceOver fraction:1.0];
	[canvas unlockFocus];
	
	// Draw canvas to divider bar
	[self lockFocus];
	[canvas drawInRect:aRect fromRect:canvasRect operation:NSCompositeSourceOver fraction:1.0];
	[self unlockFocus];
}

@end
