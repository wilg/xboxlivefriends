//
//  GIBreakdownChartController.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GIBreakdownChartController : GITabController {

	IBOutlet MQPieGraphView *pieGraph;
	IBOutlet NSTextField *sliceTitle;
	IBOutlet NSTextField *sliceCaption;
	IBOutlet NSTextField *percentField;
	IBOutlet NSImageView *sliceImage;

	MQSlice *lastSlice;
	int lastColorUsed;
	
	MAAttachedWindow *infoPop;
	IBOutlet NSView *infoView;
}

- (void)displayPieChart:(NSArray *)gameList;
- (NSColor *)colorForSlice;
- (void)doInfoPopAt:(NSPoint)position withSlice:(MQSlice *)slice;
- (void) closeInfoPop;

@end
