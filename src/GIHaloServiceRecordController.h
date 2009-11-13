//
//  GIHaloServiceRecordController.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GIHaloServiceRecordController : GITabController {
	
	IBOutlet NSImageView *rankImageView;
	IBOutlet NSTextField *rankTitleField;
	IBOutlet NSTextField *experienceField;
	IBOutlet NSTextField *skillField;
	IBOutlet NSTextField *promotionField;
	IBOutlet NSTextField *serviceTagField;

	IBOutlet NSTableView *recentGamesTable;
	NSArray *tableViewRecords;
}

- (void)displayServiceRecord:(NSDictionary *)serviceRecord;
- (void)displayRecentGames:(NSArray *)recentGames;


@end
