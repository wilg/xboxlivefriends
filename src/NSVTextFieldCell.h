//
//  NSVTextFieldCell.h
//
//  Created by Ferruccio Vitale on 18/08/06.
//  Copyright 2006 /dev/zero. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSVTextFieldCell : NSTextFieldCell {
	@private
	BOOL _vAlign;
}
- (void) setVerticalAlignment:(BOOL)bValue;
- (BOOL) isVerticalAligned;
@end
