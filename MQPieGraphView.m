//
//  MQPieGraphView.m
//  
//
//  Created by John Carlyle on 11/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MQSlice.h"
#import "MQPieGraphView.h"
#import "NSBezierPath+MCAdditions.h"
#import "NSShadow+MCAdditions.h"

//#define MIN(x, y) (x < y) ? x : y;

@implementation MQPieGraphView

- (void)awakeFromNib
{
    [[self window] makeFirstResponder:self];
    //[[self window] setAcceptsMouseMovedEvents:YES];
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (self)   {
        drawLegend = NO;
        autosize = YES;
        fadeFactor = .5;
        size = 50;
        bg = [NSColor whiteColor];
        lineColor = [NSColor blackColor];
        textColor = [NSColor blackColor];
        slices = [[NSMutableArray alloc] initWithCapacity:2];
        clickedSlice = [[MQSlice alloc] init];
        overSlice = [[MQSlice alloc] init];
    }
    
    return self;
}

- (void)setDelegate:(id)dele
{
    [delegate release];
    delegate = [dele retain];
}

- (id)getDelegate
{
    return delegate;
}

- (MQSlice *)getLastClicked
{
    return clickedSlice;
}

- (void)setFadeFactor:(float)f
{
    fadeFactor = f;
}

- (float)getFadeFactor
{
    return fadeFactor;
}

- (MQSlice *)getLastOver
{
    return overSlice;
}

- (void)clearSelection {
	if (clickedSlice)
		[clickedSlice setLight:FALSE];
	clickedSlice = nil;
	overSlice = nil;
	[self setNeedsDisplay:YES];
}

- (void)sort
{
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

- (void)reverseSort
{
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


- (MQSlice *)getSliceForPoint:(NSPoint)p
{
    int j;
    for (j = 0 ; j < [slices count]; j++)  {
        NSBezierPath *path = [[slices objectAtIndex:j] getBezierPath];
        if ([path containsPoint:p])   {
            return [slices objectAtIndex:j];
        }
    }
    return nil;
}


- (void)drawRect:(NSRect)rect
{
    [bg set];
    [NSBezierPath fillRect:rect];
    
    int oldSize = size;
    if (autosize)   {
        size = MIN(rect.size.width / 2 - padding, rect.size.height / 2 - padding);
    }
    
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

	
	size = oldSize;
}


- (void)drawLegend:(MQSlice *)slice i:(int)i
{
    NSPoint drawPoint;
    drawPoint.x = 17;
    drawPoint.y = (i * 15) + 15;
    
    [NSBezierPath fillRect:NSMakeRect(drawPoint.x - 7, drawPoint.y + 10, 10, 10)];
    
    NSTextStorage *storage = [[NSTextStorage alloc] initWithString:[slice getMessage]];
    [storage setForegroundColor:textColor];
    NSLayoutManager *lm = [[NSLayoutManager alloc] init];
    NSTextContainer *container = [[NSTextContainer alloc] init];
    
    [lm addTextContainer:container];
    [container release];
    [storage addLayoutManager:lm];
    [lm release];
    
    NSRange glyphRange = [lm glyphRangeForTextContainer:container];
    [self lockFocus];
    [lm drawGlyphsForGlyphRange:glyphRange atPoint:drawPoint];
    [self unlockFocus];
    
    [storage release];
}

- (void)updateView
{
    [self recalibrateSliceSizes];
    [self setNeedsDisplay:YES];
}

- (void)recalibrateSliceSizes
{
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

- (BOOL)getDrawsLegend
{
    return drawLegend;
}

- (void)setDrawsLegend:(BOOL)s
{
    drawLegend = s;
}


- (BOOL)getAutosizes
{
    return autosize;
}

- (void)setAutosizes:(BOOL)s
{
    autosize = s;
}


- (void)setSize:(int)s
{
    size = s;
}

- (int)getSize
{
    return size;
}

- (void)setPadding:(float)pad
{
    padding = pad;
}

- (float)getPadding
{
    return padding;
}

- (void)addSlice:(MQSlice *)slice
{
    [slices addObject:slice];
}

- (void)removeSliceAtIndex:(int)index
{
    [slices removeObjectAtIndex:index];
}

- (void)clearSlices
{
    [slices removeAllObjects];
}


- (MQSlice *)getSliceAtIndex:(int)index
{
    return [slices objectAtIndex:index];
}

- (void)setLineColor:(NSColor *)newColor
{
    [lineColor release];
    lineColor = [newColor retain];
}

- (NSColor *)getLineColor
{
    return lineColor;
}

- (void)setTextColor:(NSColor *)newColor
{
    [textColor release];
    textColor = [newColor retain];
}

- (NSColor *)getTextColor
{
    return textColor;
}


- (void)setBackground:(NSColor *)newColor
{
    [bg release];
    bg = [newColor retain];
}

- (NSColor *)getBackground
{
    return bg;
}

- (void)mouseMoved:(NSEvent *)event
{
//    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
//	
//	for (MQSlice *slice in slices) {
//        if ([[slice getBezierPath] containsPoint:point])   {
//            [overSlice release];
//            overSlice = [slice retain];
//            [slice setLight:TRUE];
//        }
//        else    {
//            [slice setLight:FALSE];
//        }
//	}
//	
//    if (delegate)   {
//        [delegate mouseMoved:event];
//    }
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

- (void)keyDown:(NSEvent *)event
{
    [delegate keyDown:event];
}

- (void)dealloc
{
    [slices release];
    [bg release];
    [textColor release];
    [lineColor release];
    [super dealloc];
}

- (BOOL)acceptsMouseEvents
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)mouseDownCanMoveWindow {
    return NO;
}

@end
