//
//  DefaultWebViewDelegate.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 5/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#include <WebKit/WebKit.h>
#import "DefaultWebViewDelegate.h"


@implementation DefaultWebViewDelegate

- (unsigned)webView:(WebView *)sender dragSourceActionMaskForPoint:(NSPoint)point
{
    return WebDragSourceActionNone;
}

@end
