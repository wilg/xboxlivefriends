#import "FriendStatusCell.h"

@implementation FriendStatusCell

- (void)drawInteriorWithFrame:(NSRect)theCellFrame inView:(NSView *)theControlView {
	
	// Inset the cell frame to give everything a little horizontal padding
	//NSRect		anInsetRect = NSInsetRect(theCellFrame, 0, 0);
	NSRect anInsetRect = theCellFrame;
	anInsetRect.origin = NSMakePoint(anInsetRect.origin.x, anInsetRect.origin.y + 1);
	
	// Make the icon
//	NSImage *	anIcon = [NSImage imageNamed:@"example"];
	
	// Flip the icon because the entire cell has a flipped coordinate system
//	[anIcon setFlipped:YES];
	
	// get the size of the icon for layout
//	NSSize		anIconSize = [anIcon size];
	
	// Make attributes for our strings
	NSMutableParagraphStyle * aParagraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[aParagraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	
	// Title attributes: system font, 14pt, black, truncate tail
	NSMutableDictionary * aTitleAttributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
											 [NSColor blackColor],NSForegroundColorAttributeName,
											 [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize: NSRegularControlSize]],NSFontAttributeName,
											 aParagraphStyle, NSParagraphStyleAttributeName,
											 nil] autorelease];

//	NSMutableDictionary *secondaryTitleAttributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
//											 [NSColor grayColor], NSForegroundColorAttributeName,
//											 [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize: NSRegularControlSize]], NSFontAttributeName,
//											 aParagraphStyle, NSParagraphStyleAttributeName,
//											 nil] autorelease];

											
	// Subtitle attributes: system font, 12pt, gray, truncate tail
	NSMutableDictionary * aSubtitleAttributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
												[NSColor grayColor],NSForegroundColorAttributeName,
												[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize: NSSmallControlSize]],NSFontAttributeName,
												aParagraphStyle, NSParagraphStyleAttributeName,
												nil] autorelease];
											
	// Make the strings and get their sizes
	// I'm hard coding these strings here.  In a real implementation of a table cell, you'll 
	// use the cell's "objectValue" to display real data.
	
	//	NSString *	aTitle = @"A Realy Realy Realy Really Long Title"; // try using this string as the title for testing the truncating tail attribute
	
	// Make a Title string
//	NSString *primaryTitle = [[self objectValue] objectForKey:@"primaryTitle"];
//	NSString *secondaryTitle = [[self objectValue] objectForKey:@"secondaryTitle"];	
//	primaryTitle = [primaryTitle stringByAppendingString:@" "];
//	NSSize primaryTitleSize = [primaryTitle sizeWithAttributes:aTitleAttributes];
	
	
	NSString *fullTitle = [[self objectValue] objectForKey:@"gamertag"];
	NSSize fullTitleSize = [fullTitle sizeWithAttributes:aTitleAttributes];
	
	// Make a Subtitle string
	NSString *	aSubtitle = [[self objectValue] objectForKey:@"textstatus"];
	
	BOOL hasSubtitle = YES;
	if (!aSubtitle || [aSubtitle length] <= 3 || [aSubtitle isEqualTo:@""] || [aSubtitle isEqualTo:@" "]) {
		hasSubtitle = NO;
	}
	
	NSSize aSubtitleSize = [aSubtitle sizeWithAttributes:aSubtitleAttributes];
	// get the size of the string for layout
	
	
	// Make the layout boxes for all of our elements - remember that we're in a flipped coordinate system when setting the y-values
	
	// Vertical padding between the lines of text
	float		aVerticalPadding = 5.0;
	
	// Horizontal padding between icon and text
	float		aHorizontalPadding = 0;
	
	// Icon box: center the icon vertically inside of the inset rect
//	NSRect		anIconBox = NSMakeRect(anInsetRect.origin.x,
//									   anInsetRect.origin.y + anInsetRect.size.height*.5 - anIconSize.height*.5,
//									   anIconSize.width,
//									   anIconSize.height);
	
	// Make a box for our text
	// Place it next to the icon with horizontal padding
	// Size it horizontally to fill out the rest of the inset rect
	// Center it vertically inside of the inset rect
	float aCombinedHeight;
	if (hasSubtitle)
		aCombinedHeight = fullTitleSize.height + aSubtitleSize.height + aVerticalPadding;
	else
		aCombinedHeight = fullTitleSize.height;
		
	NSRect	aTextBox = NSMakeRect(anInsetRect.origin.x + aHorizontalPadding,
									  anInsetRect.origin.y + anInsetRect.size.height*.5 - aCombinedHeight*.5,
									  anInsetRect.size.width - aHorizontalPadding,
									  aCombinedHeight);
	
	// Now split the text box in half and put the title box in the top half and subtitle box in bottom half
//	NSRect	primaryTitleBox = NSMakeRect(aTextBox.origin.x, 
//									   aTextBox.origin.y + aTextBox.size.height*.5 - fullTitleSize.height,
//									   primaryTitleSize.width,
//									   fullTitleSize.height);
//									   
//	NSRect	secondaryTitleBox = NSMakeRect(aTextBox.origin.x + primaryTitleSize.width, 
//								   aTextBox.origin.y + aTextBox.size.height*.5 - fullTitleSize.height,
//								   aTextBox.size.width - primaryTitleSize.width,
//								   fullTitleSize.height);
																															
	NSRect	aSubtitleBox = NSMakeRect(aTextBox.origin.x,
										  aTextBox.origin.y + aTextBox.size.height*.5,
										  aTextBox.size.width,
										  aSubtitleSize.height);
	
	
	if(	[self isHighlighted] && [[[self controlView] window] isKeyWindow]) {
		// if the cell is highlighted, draw the text white
		[aTitleAttributes setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[aSubtitleAttributes setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	}
	else {
		if (![[[self objectValue] objectForKey:@"onlinestatus"] isEqualTo:@"Offline"]) {
			// if the cell is not highlighted, draw the title black and the subtile gray
			[aTitleAttributes setValue:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
			[aSubtitleAttributes setValue:[NSColor grayColor] forKey:NSForegroundColorAttributeName];
		}
		else {
			[aTitleAttributes setValue:[NSColor headerColor] forKey:NSForegroundColorAttributeName];
			[aSubtitleAttributes setValue:[NSColor headerColor] forKey:NSForegroundColorAttributeName];
		}
	}
	
	
	// Draw the text
	if (hasSubtitle) {
		[aSubtitle drawInRect:aSubtitleBox withAttributes:aSubtitleAttributes];
		[fullTitle drawInRect:aTextBox withAttributes:aTitleAttributes];
//		[secondaryTitle drawInRect:secondaryTitleBox withAttributes:secondaryTitleAttributes];
	}
	else {
		[fullTitle drawInRect:aTextBox withAttributes:aTitleAttributes];
	}

}


// Expansion tool tip support
//
//- (NSRect)expansionFrameWithFrame:(NSRect)cellFrame inView:(NSView *)view {
//	cellFrame.size = [self cellSize];
//	return cellFrame;
//    // We could access our reccomended cell size with [self cellSize] and see if it fits in cellFrame, but NSBrowserCell already does this for us!
//    NSRect expansionFrame = [super expansionFrameWithFrame:cellFrame inView:view];
//    // If we do need an expansion frame, the rect will be non-empty. We need to move it over, and shrink it, since we won't be drawing the icon in it
//    if (!NSIsEmptyRect(expansionFrame)) {
//        NSSize iconSize = iconImage ? [iconImage size] : NSZeroSize;
//        expansionFrame.origin.x = expansionFrame.origin.x + iconSize.width + ICON_INSET_HORIZ + ICON_TEXT_SPACING;
//        expansionFrame.size.width = expansionFrame.size.width - (iconSize.width + ICON_TEXT_SPACING + ICON_INSET_HORIZ / 2.0);
//    }
//    return expansionFrame;
//}
//
//- (void)drawWithExpansionFrame:(NSRect)cellFrame inView:(NSView *)view {
//    // We want to ignore the image that is to be custom drawn, and just let the superclass handle the drawing. This will correctly draw just the text, but nothing else
//    [self drawInteriorWithFrame:cellFrame inView:view];
//}
//


- (NSView *)controlView {
	return controlView;
}

- (void)setControlView:(NSView *)view {
	controlView = view;
}




@end
