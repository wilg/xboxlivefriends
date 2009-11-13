#import <Cocoa/Cocoa.h>


@interface NSImage (MQReflectedImage)

+ (NSImage *)reflectedImage:(NSImage *)sourceImage amountReflected:(float)fraction;
+ (NSImage *)completeReflectedImage:(NSImage *)sourceImage amountReflected:(float)fraction;
+ (NSImage *) imageFromCIImage:(CIImage *)ciImage;
+ (NSImage *)imageWithPerspectiveAndReflection:(NSImage *)sourceImage amountReflected:(float)reflection amountTurned:(float)turn;



@end
