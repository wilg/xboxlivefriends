//
//  RoundedBox.m
//  RoundedBox
//
//  Created by Matt Gemmell on 01/11/2005.
//  Copyright 2006 Matt Gemmell. http://mattgemmell.com/
//
//  Permission to use this code:
//
//  Feel free to use this code in your software, either as-is or 
//  in a modified form. Either way, please include a credit in 
//  your software's "About" box or similar, mentioning at least 
//  my name (Matt Gemmell). A link to my site would be nice too.
//
//  Permission to redistribute this code:
//
//  You can redistribute this code, as long as you keep these 
//  comments. You can also redistribute modified versions of the 
//  code, as long as you add comments to say that you've made 
//  modifications (keeping these original comments too).
//
//  If you do use or redistribute this code, an email would be 
//  appreciated, just to let me know that people are finding my 
//  code useful. You can reach me at matt.gemmell@gmail.com
//

#import "RoundedBox.h"


@implementation RoundedBox


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}


- (void)dealloc
{
    [borderColor release];
    [titleColor release];
    [gradientStartColor release];
    [gradientEndColor release];
    [backgroundColor release];
    [titleAttrs release];
    
    [super dealloc];
}


- (void)setDefaults
{
    borderWidth = 2.0;
    [self setBorderColor:[NSColor grayColor]];
    [self setTitleColor:[NSColor whiteColor]];
    [self setGradientStartColor:[NSColor colorWithCalibratedWhite:0.92 alpha:1.0]];
    [self setGradientEndColor:[NSColor colorWithCalibratedWhite:0.82 alpha:1.0]];
    [self setBackgroundColor:[NSColor colorWithCalibratedWhite:0.90 alpha:1.0]];
    [self setTitleFont:[NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
    
    // Set up text attributes for drawing
    NSMutableParagraphStyle *paragraphStyle;
    paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    [paragraphStyle setAlignment:NSLeftTextAlignment];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    
    titleAttrs = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
        [self titleFont], NSFontAttributeName,
        [self titleColor], NSForegroundColorAttributeName,
        [paragraphStyle autorelease], NSParagraphStyleAttributeName,
        nil] retain];
    
    [self setDrawsFullTitleBar:NO];
    [self setSelected:NO];
    [self setDrawsGradientBackground:YES];
}


- (void)awakeFromNib
{
    // For when we've been created in a nib file
    [self setDefaults];
}


- (BOOL)preservesContentDuringLiveResize
{
    // NSBox returns YES for this, but doing so would screw up the gradients.
    return NO;
}


- (void)drawRect:(NSRect)rect {
    
    // Construct rounded rect path
    NSRect boxRect = [self bounds];
    NSRect bgRect = boxRect;
    bgRect = NSInsetRect(boxRect, borderWidth / 2.0, borderWidth / 2.0);
    bgRect = NSIntegralRect(bgRect);
    bgRect.origin.x += 0.5;
    bgRect.origin.y += 0.5;
    int minX = NSMinX(bgRect);
    int midX = NSMidX(bgRect);
    int maxX = NSMaxX(bgRect);
    int minY = NSMinY(bgRect);
    int midY = NSMidY(bgRect);
    int maxY = NSMaxY(bgRect);
    float radius = 4.0;
    NSBezierPath *bgPath = [NSBezierPath bezierPath];
    
    // Bottom edge and bottom-right curve
    [bgPath moveToPoint:NSMakePoint(midX, minY)];
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                     toPoint:NSMakePoint(maxX, midY) 
                                      radius:radius];
    
    // Right edge and top-right curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                     toPoint:NSMakePoint(midX, maxY) 
                                      radius:radius];
    
    // Top edge and top-left curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                     toPoint:NSMakePoint(minX, midY) 
                                      radius:radius];
    
    // Left edge and bottom-left curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, minY) 
                                     toPoint:NSMakePoint(midX, minY) 
                                      radius:radius];
    [bgPath closePath];
    
    
    // Draw background
    
    if ([self drawsGradientBackground]) {
        // Draw gradient background
        NSGraphicsContext *nsContext = [NSGraphicsContext currentContext];
        [nsContext saveGraphicsState];
        [bgPath addClip];
        NSGradient *gradient = [[[NSGradient alloc] initWithStartingColor:[self gradientStartColor] endingColor:[self gradientEndColor]] autorelease];
        NSRect gradientRect = [bgPath bounds];
        [gradient drawInRect:gradientRect angle:270.0];
        [nsContext restoreGraphicsState];
    } else {
        // Draw solid color background
        [backgroundColor set];
        [bgPath fill];
    }
    
    
    // Create drawing rectangle for title
    
    float titleHInset = borderWidth + 4.0;
    float titleVInset = borderWidth;
    NSSize titleSize = [[self title] sizeWithAttributes:titleAttrs];
    NSRect titleRect = NSMakeRect(boxRect.origin.x + titleHInset, 
                                  boxRect.origin.y + boxRect.size.height - titleSize.height - (titleVInset * 2.0), 
                                  titleSize.width + borderWidth, 
                                  titleSize.height);
    titleRect.size.width = MIN(titleRect.size.width, boxRect.size.width - (2.0 * titleHInset));
    
    if ([self selected]) {
        [[NSColor alternateSelectedControlColor] set];
        // We use the alternate (darker) selectedControlColor since the regular one is too light.
        // The alternate one is the highlight color for NSTableView, NSOutlineView, etc.
        // This mimics how Automator highlights the selected action in a workflow.
    } else {
        [borderColor set];
    }
    
    
    // Draw title background
    //NSRectFill(titleRect);
    [[self titlePathWithinRect:bgRect cornerRadius:radius titleRect:titleRect] fill];
    
    
    // Draw rounded rect around entire box
    if (borderWidth > 0.0) {
        [bgPath setLineWidth:borderWidth];
        [bgPath stroke];
    }
    
    
    // Draw title text
    [[self title] drawInRect:titleRect withAttributes:titleAttrs];
    //[[self titleCell] setTextColor:[self titleColor]];
    //[[self titleCell] drawWithFrame:titleRect inView:self];
}


- (NSBezierPath *)titlePathWithinRect:(NSRect)rect cornerRadius:(float)radius titleRect:(NSRect)titleRect
{
    // Construct rounded rect path
    
    NSRect bgRect = rect;
    int minX = NSMinX(bgRect);
    int maxX = minX + titleRect.size.width + ((titleRect.origin.x - rect.origin.x) * 2.0);
    int maxY = NSMaxY(bgRect);
    int minY = NSMinY(titleRect) - (maxY - (titleRect.origin.y + titleRect.size.height));
    float titleExpansionThreshold = 20.0;
    // i.e. if there's less than 20px space to the right of the short titlebar, just draw the full one.
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(minX, minY)];
    
    if (bgRect.size.width - titleRect.size.width >= titleExpansionThreshold && ![self drawsFullTitleBar]) {
        // Draw a short titlebar
        [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                       toPoint:NSMakePoint(maxX, maxY) 
                                        radius:radius];
        [path lineToPoint:NSMakePoint(maxX, maxY)];
    } else {
        // Draw full titlebar, since we're either set to always do so, or we don't have room for a short one.
        [path lineToPoint:NSMakePoint(NSMaxX(bgRect), minY)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(NSMaxX(bgRect), maxY) 
                                       toPoint:NSMakePoint(NSMaxX(bgRect) - (bgRect.size.width / 2.0), maxY) 
                                        radius:radius];
    }
    
    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                   toPoint:NSMakePoint(minX, minY) 
                                    radius:radius];
    
    [path closePath];
    
    return path;
}


- (void)setTitle:(NSString *)newTitle
{
    [super setTitle:newTitle];
    [self setNeedsDisplay:YES];
}


- (BOOL)drawsFullTitleBar
{
    return drawsFullTitleBar;
}


- (void)setDrawsFullTitleBar:(BOOL)newDrawsFullTitleBar
{
    drawsFullTitleBar = newDrawsFullTitleBar;
    [self setNeedsDisplay:YES];
}


- (BOOL)selected
{
    return selected;
}


- (void)setSelected:(BOOL)newSelected
{
    selected = newSelected;
    [self setNeedsDisplay:YES];
}


- (NSColor *)borderColor
{
    return borderColor;
}


- (void)setBorderColor:(NSColor *)newBorderColor
{
    [newBorderColor retain];
    [borderColor release];
    borderColor = newBorderColor;
    [self setNeedsDisplay:YES];
}


- (NSColor *)titleColor
{
    return titleColor;
}


- (void)setTitleColor:(NSColor *)newTitleColor
{
    [newTitleColor retain];
    [titleColor release];
    titleColor = newTitleColor;
    
    [titleAttrs setObject:titleColor forKey:NSForegroundColorAttributeName];
    
    [self setNeedsDisplay:YES];
}


- (NSColor *)gradientStartColor
{
    return gradientStartColor;
}


- (void)setGradientStartColor:(NSColor *)newGradientStartColor
{
    // Must ensure gradient colors are in NSCalibratedRGBColorSpace, or Core Image gets angry.
    NSColor *newCalibratedGradientStartColor = [newGradientStartColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    [newCalibratedGradientStartColor retain];
    [gradientStartColor release];
    gradientStartColor = newCalibratedGradientStartColor;
    if ([self drawsGradientBackground]) {
        [self setNeedsDisplay:YES];
    }
}


- (NSColor *)gradientEndColor
{
    return gradientEndColor;
}


- (void)setGradientEndColor:(NSColor *)newGradientEndColor
{
    // Must ensure gradient colors are in NSCalibratedRGBColorSpace, or Core Image gets angry.
    NSColor *newCalibratedGradientEndColor = [newGradientEndColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    [newCalibratedGradientEndColor retain];
    [gradientEndColor release];
    gradientEndColor = newCalibratedGradientEndColor;
    if ([self drawsGradientBackground]) {
        [self setNeedsDisplay:YES];
    }
}


- (NSColor *)backgroundColor
{
    return backgroundColor;
}


- (void)setBackgroundColor:(NSColor *)newBackgroundColor
{
    [newBackgroundColor retain];
    [backgroundColor release];
    backgroundColor = newBackgroundColor;
    if (![self drawsGradientBackground]) {
        [self setNeedsDisplay:YES];
    }
}


- (BOOL)drawsGradientBackground
{
    return drawsGradientBackground;
}


- (void)setDrawsGradientBackground:(BOOL)newDrawsGradientBackground
{
    drawsGradientBackground = newDrawsGradientBackground;
    [self setNeedsDisplay:YES];
}


@end
