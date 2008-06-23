//
//  XBMessageWaitingView.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XBMessageWaitingView.h"


@implementation XBMessageWaitingView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
}

- (void)setMessages:(int)x {
	messages = x;	
}

@end
