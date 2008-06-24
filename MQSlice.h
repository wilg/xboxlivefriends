#import <Cocoa/Cocoa.h>

@interface MQSlice : NSObject {

	BOOL identifier, shouldDisplay;

    NSString *message;
    NSDictionary *captionData;
	
    NSBezierPath *path;
    NSColor *color;
	
    float size, degreeSize;
	
}

//sorting
@property(assign) BOOL identifier;
@property(assign) BOOL shouldDisplay;

// caption data
@property(retain) NSString *message;
@property(retain) NSDictionary *captionData;

//drawing data
@property(retain) NSBezierPath *path;
@property(retain) NSColor *color;

//sizing
@property(assign) float size;
@property(assign) float degreeSize;

+ (MQSlice *)slice;

@end
