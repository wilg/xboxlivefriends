#import <Cocoa/Cocoa.h>


@interface NSImage (BHReflectedImage)

+ (NSImage *)reflectedImage:(NSImage *)sourceImage amountReflected:(float)fraction;

@end
