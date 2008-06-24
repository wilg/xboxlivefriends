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

@synthesize delegate, backgroundColor, slices, clickedSlice, overSlice, padding, fadeFactor;

- (void)awakeFromNib {
    [[self window] makeFirstResponder:self];
}

- (id)initWithFrame:(NSRect)frameRect {

    self = [super initWithFrame:frameRect];
    
    if (self)   {
		
		[self setFadeFactor:0.5];
		[self setBackgroundColor:[NSColor whiteColor]];
		[self setSlices:[NSMutableArray array]];
		[self setClickedSlice:nil];
		[self setOverSlice:nil];
		
    }
    
    return self;
}

- (void)dealloc {
    [slices release];
    [backgroundColor release];
	[clickedSlice release];
	[overSlice release];
    [super dealloc];
}


- (void)clearSelection {
	if (clickedSlice)
		[clickedSlice setLight:FALSE];
	clickedSlice = nil;
	overSlice = nil;
	[self setNeedsDisplay:YES];
}

- (void)sort {
    int i, j;
    for (i = 1; i < [slices count]; i++)  {
        for (j = 0; j < [slices count] - i; j++)  {
            MQSlice *a = [slices objectAtIndex:j];
            MQSlice *b = [slices objectAtIndex:j+1];
            if ([a getSlice] > [b getSlice])   {
                [slices exchangeObjectAtIndex:j withObjectAtIndex:j+1];
            }
        }
    }
}

- (void)reverseSort {
    int i, j;
    for (i = 1; i < [slices count]; i++)  {
        for (j = 0; j < [slices count] - i; j++)  {
            MQSlice *a = [slices objectAtIndex:j];
            MQSlice *b = [slices objectAtIndex:j+1];
            if ([a getSlice] < [b getSlice])   {
                [slices exchangeObjectAtIndex:j withObjectAtIndex:j+1];
            }
        }
    }
}

- (void)drawRect:(NSRect)rect {

	NSGradient *backgroundGradient = [[NSGradient alloc] initWithStartingColor:backgroundColor endingColor:[NSColor colorWithCalibratedWhite:0.1 alpha:1.0]];
	[backgroundGradient drawInRect:rect angle:-90];
    
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
	
    for (MQSlice *slice in slices)  {
		[NSGraphicsContext saveGraphicsState];
		
		//setup shadow
		NSShadow *dropShadow = [[NSShadow alloc] initWithColor:[NSColor colorWithCalibratedWhite:0 alpha:.4] offset:NSMakeSize(0, 0.0) blurRadius:6.0];
		
		
		//get the path for the slice
		NSBezierPath *sliceShape = [NSBezierPath bezierPath];
		[sliceShape moveToPoint:centerPoint];
		[sliceShape appendBezierPathWithArcWithCenter:centerPoint radius:size startAngle:angle - 0.01 endAngle:angle + [slice getDegrees] + 0.01];
		
		//tell the slice what we're up to
		[slice setBezierPath:sliceShape];
		

		// draw drop shadow
		[NSGraphicsContext saveGraphicsState];
		[dropShadow set];
		[sliceShape fill];
		[NSGraphicsContext restoreGraphicsState];
		
		//draw fill
		[NSGraphicsContext saveGraphicsState];
		if (![slice getLight]) {
			NSColor *theColor = [slice getLight] ? [slice untexturedColor] : [slice getColor];
			[theColor set];
			[sliceShape fill];
		}
		else {
			NSGradient *highlightGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:.506 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:.376 alpha:1.0]];
			[highlightGradient drawInBezierPath:sliceShape angle:angle];

			NSShadow *highlightedInnerShadow = [[NSShadow alloc] initWithColor:[NSColor colorWithCalibratedWhite:0 alpha:.9] offset:NSMakeSize(0, 0.0) blurRadius:55.0];
			[sliceShape fillWithInnerShadow:highlightedInnerShadow];
			[highlightGradient release];
		}
		[NSGraphicsContext restoreGraphicsState];


		angle += [slice getDegrees];
		[dropShadow release];
		
		[NSGraphicsContext restoreGraphicsState];
	}

}

- (void)updateView {
    [self recalibrateSliceSizes];
    [self setNeedsDisplay:YES];
}

- (void)recalibrateSliceSizes {
    int i, j;
    float total = 0.0f;
    for (i = 0 ; i < [slices count]; i++)  {
        int sliceSize = [[slices objectAtIndex:i] getSlice];
        total += sliceSize;
    }
    for (j = 0 ; j < [slices count]; j++)  {
        [[slices objectAtIndex:j] setDegrees:[[slices objectAtIndex:j] getSlice] / total * 360.0f];
    }
}

- (void)removeSliceAtIndex:(int)index {
    [slices removeObjectAtIndex:index];
}

- (void)clearSlices {
    [slices removeAllObjects];
}


- (void)mouseDown:(NSEvent *)event {

    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	[clickedSlice release];
	clickedSlice = nil;
	for (MQSlice *slice in slices) {
		[slice setLight:FALSE];
        if ([[slice getBezierPath] containsPoint:point])   {
            clickedSlice = [slice retain];
            [slice setLight:TRUE];
        }
	}
	
    [self setNeedsDisplay:YES];
	
    if (delegate)   {
        [delegate mouseDown:event];
    }

}

- (void)addSlice:(MQSlice *)slice {
    [slices addObject:slice];
}

- (BOOL)acceptsMouseEvents {
    return YES;
}

- (MQSlice *)sliceAtIndex:(int)index {
    return [slices objectAtIndex:index];
}

- (MQSlice *)sliceForPoint:(NSPoint)p {
    int j;
    for (j = 0 ; j < [slices count]; j++)  {
        NSBezierPath *path = [[slices objectAtIndex:j] getBezierPath];
        if ([path containsPoint:p])   {
            return [slices objectAtIndex:j];
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
