//
//  MAAttachedWindowNonActivating.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ClickableAttachedWindow.h"


@implementation ClickableAttachedWindow

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
	return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {	
    if ([self delegate])
        [[self delegate] mouseDown:theEvent];
}


@end
