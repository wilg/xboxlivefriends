//
//  XBGamerInfoTableController.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XBGamerInfoTableController : NSObject {
	IBOutlet NSTableView *infoTable;

	IBOutlet NSTabView *gamerInfoContentView;
	
	IBOutlet NSView *theContentView;
    NSView *currentView;


	//tabs
	IBOutlet NSView *gamerInfoTextView;
	IBOutlet NSView *gamerInfoAchievementView;
	IBOutlet NSView *gamerInfoPieView;
	IBOutlet NSView *gamerInfoHaloMultiplayerSRView;
	IBOutlet NSView *gamerInfoHaloScreenshotsView;
	IBOutlet NSView *gamerInfoDetailsView;
	IBOutlet NSView *gamerFriendsOfFriend;

	IBOutlet NSTextField *gamerInfoErrorText;

	NSMutableArray *records;
}

- (NSDictionary *)tableViewRecordForTab:(NSString *)tabName icon:(id)icon view:(id)view;

- (void)showErrorTab:(NSNotification *)notification;

@end
