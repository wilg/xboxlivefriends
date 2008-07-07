//
//  StayAround.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/30/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface StayAround : NSObject {
	IBOutlet NSArray *objects;
}
@property(assign) NSArray *objects;
- (void) addObject:(id)obj;

@end
