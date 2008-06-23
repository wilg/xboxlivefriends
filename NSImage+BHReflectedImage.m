#import "NSImage+BHReflectedImage.h"

@implementation NSImage (BHReflectedImage)

+ (NSImage *)reflectedImage:(NSImage *)sourceImage amountReflected:(float)fraction
{
	NSImage *reflection = [[NSImage alloc] initWithSize:[sourceImage size]];
	[reflection setFlipped:YES];

	[reflection lockFocus];
	NSGradient *fade = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.5] endingColor:[NSColor clearColor]] autorelease];
	[fade drawInRect:NSMakeRect(0, 0, [sourceImage size].width, [sourceImage size].height*fraction) angle:90.0];	
	[sourceImage drawAtPoint:NSMakePoint(0,0) fromRect:NSZeroRect operation:NSCompositeSourceIn fraction:1.0];
	[reflection unlockFocus];

	return [reflection autorelease];
}

@end
