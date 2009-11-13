//
//  XBImageLoaderThread.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/19/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XBImageLoaderThread : NSObject {

}

+ (void)imageLoaderThread:(id)anObject;

+ (BOOL)shouldExit;
+ (void)setShouldExit:(BOOL)x;
+ (BOOL)shouldLoad;
+ (void)setShouldLoad:(BOOL)x;


@end
