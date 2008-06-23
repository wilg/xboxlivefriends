//
//  XBReputationView.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 9/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XBReputationView.h"


@implementation XBReputationView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setReputationPercentage:0.0];
	}
    return self;
}

- (void)drawRect:(NSRect)rect {
	NSLog(@"reputationViewDrawRect");

	NSImage *foreground = [[[NSImage imageNamed:@"stars_full"] copy] autorelease];
	NSImage *background = [[[NSImage imageNamed:@"stars_empty"] copy] autorelease];
	
	//resize to view
	//[self bounds].size.height
	
	NSSize perspectiveSize;
	perspectiveSize.width = ([self bounds].size.height * [foreground size].width) / [foreground size].height;
	perspectiveSize.height = [self bounds].size.height;

	[foreground setSize:perspectiveSize];
	[background setSize:perspectiveSize];

	float computedWidth = [foreground size].width * [self reputationPercentage];
	
	NSPoint origin = NSMakePoint(0.0, 0.0);
		
	[background compositeToPoint:origin operation:NSCompositeSourceOver];
	[foreground compositeToPoint:origin fromRect:NSMakeRect(0.0, 0.0, computedWidth, [foreground size].height) operation:NSCompositeSourceOver];
	
}

- (float)reputationPercentage {
	return reputationPercentage;
}

- (void)setReputationPercentage:(float)percent
{
	reputationPercentage = percent;
	//[self setNeedsDisplay:YES];
	[self display];
}

@end
