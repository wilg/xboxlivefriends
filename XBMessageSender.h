//
//  XBMessageSender.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 10/1/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XBMessageSender : NSObject {

}

+ (NSString *)sendMessage:(NSString *)theMsg toTag:(NSString *)theTag;

@end
