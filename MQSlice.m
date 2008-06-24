//
//  MQSlice.m
//  
//
//  Created by John Carlyle on 11/12/06.
//  Copyright 2006 mindquirk. All rights reserved.
//

#import "MQSlice.h"

@implementation MQSlice

@synthesize identifier, shouldDisplay, message, captionData, path, color, size, degreeSize;

- (NSComparisonResult)compare:(MQSlice *)slice {
	return [[NSNumber numberWithFloat:[self size]] compare:[NSNumber numberWithFloat:[slice size]]];
}

+ (MQSlice *)slice {
	return [[[MQSlice alloc] init] autorelease];
}

- (void)dealloc {
	if (message)
		[message release];
	if (captionData)
		[captionData release];
	if (path)
		[path release];
	if (color)
		[color release];
	
	[super dealloc];
}

@end
