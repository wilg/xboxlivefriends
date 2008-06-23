//
//  NSVTextFieldCell.m
//
//  Created by Ferruccio Vitale on 18/08/06.
//  Copyright 2006 /dev/zero. All rights reserved.
//

#import "NSVTextFieldCell.h"


@implementation NSVTextFieldCell

- (id) init
{
	self = [super init];
	if (self)
		_vAlign = TRUE;
	return self;
}

- (void)drawInteriorWithFrame:(NSRect)frame inView:(NSView *)controlView
{
	if (_vAlign) {
		int i = (frame.size.height - [[self font] pointSize])/2;
		i -= 3.0;
		frame.origin.y += i;
		frame.size.height -= i;
	}
	
    [super drawInteriorWithFrame:frame inView:controlView];
}

- (void) setVerticalAlignment:(BOOL)bValue
{
	_vAlign = bValue;
}

- (BOOL) isVerticalAligned
{
	return _vAlign;
}

@end
