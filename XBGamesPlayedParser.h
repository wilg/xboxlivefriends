//
//  XBGamesPlayedParser.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XBGamesPlayedParser : NSObject {
}

+ (NSArray *)fetchWithTag:(NSString *)tag;
+ (NSArray *)fetchWithURL:(NSURL *)URL;

@end
