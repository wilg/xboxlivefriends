//
//  GIServiceRecordParser.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GIHalo3RecentGamesParser : NSObject {

}

+ (NSArray *)fetchWithTag:(NSString *)tag;
+ (NSArray *)fetchWithURL:(NSURL *)URL;


@end
