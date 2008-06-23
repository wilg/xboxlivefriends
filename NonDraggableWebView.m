//
//  NonDraggableWebView.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 12/4/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NonDraggableWebView.h"


@implementation NonDraggableWebView

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	return NO;
}

@end
