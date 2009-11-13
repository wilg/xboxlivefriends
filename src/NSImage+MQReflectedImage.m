#import "CTGradient.h"
#import "NSImage+MQReflectedImage.h"
#import <QuartzCore/QuartzCore.h>

@implementation NSImage (MQReflectedImage)

+ (NSImage *)reflectedImage:(NSImage *)sourceImage amountReflected:(float)fraction
{
	NSImage *reflection = [[NSImage alloc] initWithSize:[sourceImage size]];
	[reflection setFlipped:YES];

	[reflection lockFocus];
	
	CTGradient *fade = [CTGradient gradientWithBeginningColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.3] endingColor:[NSColor clearColor]];
	[fade fillRect:NSMakeRect(0, 0, [sourceImage size].width, [sourceImage size].height * fraction) angle:90.0];
	
//	NSGradient *fade = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.5] endingColor:[NSColor clearColor]];
//	[fade drawInRect:NSMakeRect(0, 0, [sourceImage size].width, [sourceImage size].height*fraction) angle:90.0];
//	[fade release];
	
	[sourceImage drawAtPoint:NSMakePoint(0,0) fromRect:NSZeroRect operation:NSCompositeSourceIn fraction:1.0];
	[reflection unlockFocus];

	return [reflection autorelease];
}

+ (NSImage *)completeReflectedImage:(NSImage *)sourceImage amountReflected:(float)fraction {
	
	NSImage *reflectionImage = [NSImage reflectedImage:sourceImage amountReflected:fraction];
	NSSize newSize = [sourceImage size];
	newSize.height = newSize.height + [reflectionImage size].height + 1.0;
	
	NSImage *fullImage = [[NSImage alloc] initWithSize:newSize];
	[fullImage lockFocus];
	[sourceImage compositeToPoint:NSMakePoint(0.0, [sourceImage size].height + 1.0) operation:NSCompositeSourceOver];
	[reflectionImage compositeToPoint:NSMakePoint(0.0, 0.0) operation:NSCompositeSourceOver];
	[fullImage unlockFocus];
	
	return [fullImage autorelease];
}

+ (NSImage *)imageWithPerspectiveAndReflection:(NSImage *)sourceImage amountReflected:(float)reflection amountTurned:(float)turn {

	return [NSImage completeReflectedImage:sourceImage amountReflected:reflection];

//	// convert NSImage to bitmap
//	NSData  * tiffData = [[NSImage completeReflectedImage:sourceImage amountReflected:reflection] TIFFRepresentation];
//	NSBitmapImageRep * bitmap;
//	bitmap = [NSBitmapImageRep imageRepWithData:tiffData];
//
//	// create CIImage from bitmap
//	CIImage * ciImage = [[CIImage alloc] initWithBitmapImageRep:bitmap];
//	[ciImage autorelease];
//	
//	NSLog(@"%f", [ciImage extent].origin.x);
//	NSLog(@"%f", [ciImage extent].origin.y);
//
//	
//	// filter image
//	CIFilter *filter = [CIFilter filterWithName:@"CIPerspectiveTransform"];
//	//[filter setValue:ciImage forKey:@"inputImage"];
////	[filter setValue:[CIVector vectorWithX:[ciImage extent].origin.x Y:[ciImage extent].origin.y] forKey: @"inputCenter"];
////	[filter setValue:[NSNumber numberWithFloat:15.0] forKey: @"inputRadius"];
//
//	[filter setValue: [CIVector vectorWithX:0.0 Y:0.0] forKey: @"inputTopLeft"];
//	[filter setValue: [CIVector vectorWithX:16.0 Y:0.0] forKey: @"inputTopRight"];
//	[filter setValue: [CIVector vectorWithX:0.0 Y:16.0] forKey: @"inputBottomLeft"];
//	[filter setValue: [CIVector vectorWithX:16.0 Y:16.0] forKey: @"inputBottomRight"];
//
//	//[transform setValue:affineTransform forKey:@"inputTransform"];
//
//	// get the new CIImage
//	CIImage * result = [filter valueForKey:@"outputImage"];
//
//	// cleanup
//	return [NSImage imageFromCIImage:ciImage];


}


+(NSImage *) imageFromCIImage:(CIImage *)ciImage
{
	NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize([ciImage extent].size.width, [ciImage extent].size.height)] autorelease];
	[image addRepresentation:[NSCIImageRep imageRepWithCIImage:ciImage]];
	return image;
}



@end
