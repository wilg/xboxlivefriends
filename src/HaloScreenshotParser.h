//
//  HaloScreenshotParser.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HaloScreenshotParser : NSObject {
	
}

+ (NSDictionary *)parseScreenshotList:(NSString *)gamertag;

@end
