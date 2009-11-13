//
//  GIServiceRecordParser.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GIServiceRecordParser : NSObject {

}

+ (NSDictionary *)fetchWithTag:(NSString *)tag;
+ (NSDictionary *)fetchWithURL:(NSURL *)URL;


@end
