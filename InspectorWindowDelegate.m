//
//  InspectorWindowDelegate.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/15/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "InspectorWindowDelegate.h"


@implementation InspectorWindowDelegate

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
	if (proposedFrameSize.width > 251.0) {
		proposedFrameSize.width = 251.0;
	}
	return proposedFrameSize;
}

@end
