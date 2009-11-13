//
//  XBCompareAchievements.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 9/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XBCompareAchievements : NSObject {

	IBOutlet WebView *comparisonWebView;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSSearchField *searchField;
	IBOutlet NSTableView *statisticsTable;
	IBOutlet NSWindow *comparisonWindow;
	IBOutlet NSPopUpButton *filterPopup;

	IBOutlet MQPieGraphView *pieGraph;
	IBOutlet NSTextField *sliceTitle;
	IBOutlet NSTextField *sliceCaption;
	IBOutlet NSImageView *sliceImage;

	NSMutableArray *statisticsRecords;

	NSDictionary *lastFetch;
	NSString *lastFetchTag;
}

- (IBAction)getComparison:(id)sender;
- (void)displayGamesPlayed:(NSMutableDictionary *)theInfo;
- (void)displayStatistics:(NSMutableDictionary *)theInfo;
- (void)displayPieChart:(NSMutableDictionary *)theInfo;
- (IBAction)compareToInspectorFriend:(id)sender;
- (IBAction)refilter:(id)sender;
+ (NSColor *)colorForSlice:(int)sliceNumber;

- (NSMutableDictionary *)recordWithKey:(NSString *)key yourValue:(NSString *)yourValue theirValue:(NSString *)theirValue;

+ (float)percentCompletedFromString:(NSString *)blankOfBlank;
+ (NSString *)completedPointsFromString:(NSString *)blankOfBlank;
+ (NSString *)totalPointsFromString:(NSString *)blankOfBlank;

- (void)webView:(WebView *)sender windowScriptObjectAvailable: (WebScriptObject *)windowScriptObject;

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector;
- (NSString *)webViewAchievementDetails:(NSString *)gameID;
- (NSString *)checkmark:(BOOL)x;

@end
