//
//  InspectorWebViewDelegate.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/8/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "InspectorWebViewDelegate.h"
#import <WebKit/WebKit.h>


@implementation InspectorWebViewDelegate

- (unsigned)webView:(WebView *)sender dragSourceActionMaskForPoint:(NSPoint)point
{
    return WebDragSourceActionNone;
}

- (BOOL)webView:(WebView *)webView shouldChangeSelectedDOMRange:(DOMRange *)currentRange toDOMRange:(DOMRange *)proposedRange affinity:(NSSelectionAffinity)selectionAffinity stillSelecting:(BOOL)flag
{

	return NO;
}
@end
