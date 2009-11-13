//
//  XBGamerInfoAchievementsController.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GIAchievementsController : GITabController {

	IBOutlet WebView *comparisonWebView;
	IBOutlet NSPopUpButton *filterPopup;
	IBOutlet NSTextField *searchField;

//	NSArray *lastFetch;
//	NSString *lastFetchTag;

}

- (IBAction)refilter:(id)sender;
- (IBAction)searchGames:(id)sender;

- (void)displayGamesPlayed:(NSArray *)gamesList forGamertag:(NSString *)gamertag;

- (float)percentCompletedFromString:(NSString *)blankOfBlank;
- (NSString *)completedPointsFromString:(NSString *)blankOfBlank;
- (NSString *)totalPointsFromString:(NSString *)blankOfBlank;
- (NSString *)checkmark:(BOOL)x;

@end
