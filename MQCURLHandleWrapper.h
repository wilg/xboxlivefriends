//
//  MQCURLHandleWrapper.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/19/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <cURLHandle/cURLHandle.h>
#import <cURLHandle/cURLHandle+extras.h>

@class CURLHandle;

@interface MQCURLHandleWrapper : NSObject <NSURLHandleClient>
{
	CURLHandle *mURLHandle;
}

+ (MQCURLHandleWrapper *)sharedInstance;

- (NSString *)fetchURLtoString:(NSURL *)url;
- (NSString *)fetchURLtoString:(NSURL *)url withTimeout:(int)secs;
- (NSData *)fetchURLtoData:(NSURL *)url;
- (NSData *)fetchURLtoData:(NSURL *)url withTimeout:(int)secs;

@end
