//
//  MQColorView.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MQColorView.h"


@implementation MQColorView

@synthesize backgroundColor;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[NSColor whiteColor]];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {

    [[self backgroundColor] set];
    [NSBezierPath fillRect:rect];
}

- (BOOL)mouseDownCanMoveWindow {
    return NO;
}

@end
