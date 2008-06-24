//
//  MQPieGraphView.m
//  
//
//  Created by John Carlyle on 11/12/06.
//  Copyright 2006 mindquirk. All rights reserved.
//

#import "MQSlice.h"
#import "MQPieGraphView.h"
#import "NSBezierPath+MCAdditions.h"
#import "NSShadow+MCAdditions.h"

@implementation MQPieGraphView

@synthesize delegate, backgroundColor, slices, padding, fadeFactor;

- (id)initWithFrame:(NSRect)frameRect {

    self = [super initWithFrame:frameRect];
    
    if (self)   {
		
		currentIdentifier = 5;
		
		[self setFadeFactor:0.5];
		[self setBackgroundColor:[NSColor whiteColor]];
		[self setSlices:[NSMutableArray array]];
		
    }
    
    return self;
}

- (void)dealloc {
    [slices release];
    [backgroundColor release];
    [super dealloc];
}


- (void)clearSelection {
	highlightedSliceIdentifier = 0;
	[self setNeedsDisplay:YES];
}

- (void)sort {
	[self setSlices:[[[slices sortedArrayUsingSelector:@selector(compare:)] mutableCopy] autorelease]];
}

- (void)drawRect:(NSRect)rect {

	NSGradient *backgroundGradient = [[NSGradient alloc] initWithStartingColor:backgroundColor endingColor:[NSColor colorWithCalibratedWhite:0.1 alpha:1.0]];

	[backgroundGradient drawInRect:rect angle:-90];
    
	[backgroundGradient release];
	
	int size = MIN(rect.size.width / 2 - padding, rect.size.height / 2 - padding);
    
    NSPoint centerPoint;
    centerPoint.x = rect.size.width / 2;
    centerPoint.y = rect.size.height / 2;
    
    //prepare the pie background circle
    NSBezierPath *pieBackground = [NSBezierPath bezierPath];
	[pieBackground appendBezierPathWithArcWithCenter:centerPoint radius:size startAngle:0.0f endAngle:360.0f];
	
	//prepare a shadow on the whole pie
	NSShadow *pieShadow = [[NSShadow alloc] initWithColor:[NSColor colorWithCalibratedWhite:0 alpha:.8] offset:NSMakeSize(0, 0.0) blurRadius:10.0];

	
	//do the drawing
	[NSGraphicsContext saveGraphicsState];
	[pieShadow set];
	[pieBackground fill];

	[[NSColor blackColor] set];
		
	[pieBackground fill];

	[NSGraphicsContext restoreGraphicsState];

	//the angle we start at and go around
	float angle = 90.0f;
	
	NSShadow *sliceDropShadow = [[NSShadow alloc] initWithColor:[NSColor colorWithCalibratedWhite:0 alpha:.5] offset:NSMakeSize(0, 0.0) blurRadius:6.0];
	
    for (MQSlice *slice in slices)  {
		[NSGraphicsContext saveGraphicsState];
		
		//get the path for the slice
		NSBezierPath *sliceShape = [NSBezierPath bezierPath];
		[sliceShape moveToPoint:centerPoint];
		[sliceShape appendBezierPathWithArcWithCenter:centerPoint radius:size startAngle:angle - 0.02 endAngle:angle + [slice degreeSize] + 0.02];
		
		//tell the slice what we're up to
		[slice setPath:sliceShape];
		

		// draw drop shadow
		if (![self inLiveResize]) {
			[NSGraphicsContext saveGraphicsState];
			[sliceDropShadow set];
			[sliceShape fill];
			[NSGraphicsContext restoreGraphicsState];
		}
		
		//draw fill
		[NSGraphicsContext saveGraphicsState];
		if (highlightedSliceIdentifier == [slice identifier]) {
			NSGradient *highlightGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:.506 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:.376 alpha:1.0]];
			[highlightGradient drawInBezierPath:sliceShape angle:angle];
				
			if (![self inLiveResize]) {

				NSShadow *highlightedInnerShadow = [[NSShadow alloc] initWithColor:[NSColor colorWithCalibratedWhite:0 alpha:.9] offset:NSMakeSize(0, 0.0) blurRadius:55.0];
				[sliceShape fillWithInnerShadow:highlightedInnerShadow];
				[highlightGradient release];
			}

		}
		else {
			NSColor *theColor = [slice color];
			[theColor set];
			[sliceShape fill];
		}
		[NSGraphicsContext restoreGraphicsState];

		angle += [slice degreeSize];
		
		[NSGraphicsContext restoreGraphicsState];
	}

	[sliceDropShadow release];

}

- (void)viewDidEndLiveResize {
    [self setNeedsDisplay:YES];
}

- (void)recalibrateSliceSizes {
	NSMutableArray *array = [NSMutableArray array];
    float total = 0.0;
	for (MQSlice *slice in slices) {
		total += [slice size];
	}
	for (MQSlice *slice in slices) {
        [slice setDegreeSize:[slice size] / total * 360.0f];
		[array addObject:slice];
    }
	[self setSlices:array];
}

- (void)removeSliceAtIndex:(int)index {
    [slices removeObjectAtIndex:index];
}

- (void)clearSlices {
    [slices removeAllObjects];
}


- (void)mouseDown:(NSEvent *)event {

    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	highlightedSliceIdentifier = [[self sliceForPoint:point] identifier];
    [self setNeedsDisplay:YES];
	
    if (delegate)
        [delegate mouseDown:event];

}

- (MQSlice *)lastClickedSlice {
	return [self sliceWithIdentifier:highlightedSliceIdentifier];
}


- (void)addSlice:(MQSlice *)slice {
	[slice setIdentifier:currentIdentifier];
    [slices addObject:slice];
	currentIdentifier++;
}

- (BOOL)acceptsMouseEvents {
    return YES;
}

- (MQSlice *)sliceWithIdentifier:(int)i {
    for (MQSlice *slice in slices) {
		if ([slice identifier] == i)
			return slice;
	}
	return nil;
}

- (MQSlice *)sliceForPoint:(NSPoint)point {
    for (MQSlice *slice in slices) {
        if ([[slice path] containsPoint:point]) {
            return slice;
        }
    }
    return nil;
}


- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)mouseDownCanMoveWindow {
    return NO;
}

@end
