//
//  Person.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 5/13/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Person : NSObject {
	NSString *name;
}
- (void)setName:(NSString *)newName;
- (NSString *)name;
@end
