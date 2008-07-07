//
//  StayAround.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/30/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StayAround.h"

@implementation StayAround
@synthesize objects;

- (id)init {
	if (![super init])
	return nil;

	self.objects = [NSArray array];

	return self;
}

- (void) addObject:(id)obj {
	self.objects = [self.objects arrayByAddingObject:obj];
}


@end
