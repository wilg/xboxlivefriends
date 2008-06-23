//
//  Person.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 5/13/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Person.h"


@implementation Person
- (void)setName:(NSString *)newName
{
	[name release];
	name = [newName retain];
}


- (NSString *)name
{
	return name;
}

@end