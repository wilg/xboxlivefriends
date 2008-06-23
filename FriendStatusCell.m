#import "FriendStatusCell.h"

@implementation FriendStatusCell

- (void)drawInteriorWithFrame:(NSRect)theCellFrame inView:(NSView *)theControlView {
	
	// Inset the cell frame to give everything a little horizontal padding
	NSRect		anInsetRect = NSInsetRect(theCellFrame, 0, 0);
	
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
	NSString *	aTitle = [[self objectValue] objectForKey:@"gamertag"];
	// get the size of the string for layout
	NSSize		aTitleSize = [aTitle sizeWithAttributes:aTitleAttributes];
	
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
		aCombinedHeight = aTitleSize.height + aSubtitleSize.height + aVerticalPadding;
	else
		aCombinedHeight = aTitleSize.height;
		
	NSRect		aTextBox = NSMakeRect(anInsetRect.origin.x + aHorizontalPadding,
									  anInsetRect.origin.y + anInsetRect.size.height*.5 - aCombinedHeight*.5,
									  anInsetRect.size.width - aHorizontalPadding,
									  aCombinedHeight);
	
	// Now split the text box in half and put the title box in the top half and subtitle box in bottom half
	NSRect		aTitleBox = NSMakeRect(aTextBox.origin.x, 
									   aTextBox.origin.y + aTextBox.size.height*.5 - aTitleSize.height,
									   aTextBox.size.width,
									   aTitleSize.height);
											
	NSRect		aSubtitleBox = NSMakeRect(aTextBox.origin.x,
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
		[aTitle drawInRect:aTitleBox withAttributes:aTitleAttributes];
	}
	else {
		[aTitle drawInRect:aTextBox withAttributes:aTitleAttributes];
	}

}

- (NSView *)controlView {
	return controlView;
}

- (void)setControlView:(NSView *)view {
	controlView = view;
}




@end
