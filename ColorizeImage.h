//
//  ColorizeImage.h
//  MQPieChartTest
//
//  Created by John Carlyle on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ColorizeImage : NSObject {

}
+ (NSImage *)colorizeImage:(NSImage *)src withColor:(NSColor *)color;
+ (NSColor *)makeImageColorPattern:(NSImage *)image;
@end
