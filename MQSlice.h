

#import <Cocoa/Cocoa.h>


@interface MQSlice : NSObject {
    NSDictionary *captionData;
    NSBezierPath *path;
    NSColor *color, *colorizedTexture;
    NSImage *texture;
    float slice, degrees;
    NSString *message;
	BOOL shouldDisplay, light, useTexture;
}

- (void)setCaptionData:(NSDictionary *)data;
- (NSDictionary *)getCaptionData;

- (void)setLight:(BOOL)l;
- (BOOL)getLight;

- (void)setUseTexture:(BOOL)t;
- (BOOL)getUseTexture;
- (NSColor *)generateColorizedTexture;
- (void)generateTexture;

- (void)setBezierPath:(NSBezierPath *)newPath;
- (NSBezierPath *)getBezierPath;

- (void)setImage:(NSImage *)image;
- (NSImage *)getImage;

- (void)setColor:(NSColor *)newColor;
- (NSColor *)getColor;
- (NSColor *)untexturedColor;

- (void)setSlice:(float)newSlice;
- (float)getSlice;

- (void)setMessage:(NSString *)newMessage;
- (NSString *)getMessage;

- (float)getDegrees;
- (void)setDegrees:(float)newDegree;

- (BOOL)shouldDisplay;
- (void)setShouldDisplay:(BOOL)x;

+ (MQSlice *)sliceWithColor:(NSColor *)theColor texture:(NSImage *)tex slice:(float)theSlice message:(NSString *)theMessage captionData:(NSDictionary *)dict;
- (id)initWithColor:(NSColor *)theColor texture:(NSImage *)tex slice:(float)theSlice message:(NSString *)theMessage dictionary:(NSDictionary *)dict;

@end
