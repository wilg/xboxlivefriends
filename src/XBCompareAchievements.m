//
//  XBCompareAchievements.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 9/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#include "XBAchievementDetailsParser.h"
#include "MQSlice.h"
#include "MQPieGraphView.h"

#import "Xbox Live Friends.h"
#import "XBCompareAchievements.h"


@implementation XBCompareAchievements


- (id)init	{
	if (![super init])
	return nil;
	
	statisticsRecords = [[NSMutableArray alloc] init];
	lastFetch = [[NSDictionary alloc] init];

	[lastFetch retain];
	
	return self;
}


- (void)awakeFromNib
{


	[statisticsTable setDataSource:self];
	[statisticsTable setDelegate:self];
	[statisticsTable setTarget: self];
    [pieGraph setDelegate:self];
	[pieGraph setPadding:15.0];
	[pieGraph setDrawsLegend:NO];
	[pieGraph updateView];

    [comparisonWebView setFrameLoadDelegate:self];

}

- (IBAction)compareToInspectorFriend:(id)sender
{
	[searchField setStringValue:[[XBInspectorController currentlySelectedFriend] gamertag]];
	[comparisonWindow makeKeyAndOrderFront:nil];
	[self getComparison:nil];
}

- (IBAction)refilter:(id)sender
{
		
	[self displayGamesPlayed:[lastFetch mutableCopy]];

}


- (IBAction)getComparison:(id)sender
{
//	[progressIndicator startAnimation:nil];
//
//
//	NSMutableDictionary *theInfo = [XBGamesPlayedParser fetchWithTag:[searchField stringValue]];
//	lastFetchTag = [searchField stringValue];
//	lastFetch = [theInfo copy];
//
//	[self displayGamesPlayed:theInfo];
//
//	[self displayStatistics:theInfo];
//
//	[self displayPieChart:theInfo];
//
//	[progressIndicator stopAnimation:nil];
}

- (void)displayGamesPlayed:(NSMutableDictionary *)theInfo
{
	
	NSString *theRow = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/compare_row.htm"] encoding:NSMacOSRomanStringEncoding error:NULL];
	NSString *theBody = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/compare_body.htm"] encoding:NSMacOSRomanStringEncoding error:NULL];
	NSString *allRows = @"<!-- something something -->";
	
	NSMutableString *currentEditRow;
	
	BOOL showsError = NO;
	int usableGames = 0;

	
	if([[theInfo objectForKey:@"gameIcons"] count] != 0){
		int i;
		for (i = 0; i < [[theInfo objectForKey:@"gameIcons"] count]; i++){
			BOOL shouldDisplayThisGame = YES;
			@try{
				currentEditRow = [theRow mutableCopy];
				
				
				NSString *rowEvenness;
				if (usableGames % 2 == 1) {
					rowEvenness = @"odd";
				}
				else {
					rowEvenness = @"even";
				}
				[currentEditRow replaceOccurrencesOfString:@"$even_or_odd" withString:rowEvenness options:0 range:NSMakeRange(0, [currentEditRow length])];

				
				[currentEditRow replaceOccurrencesOfString:@"$game_title" withString:[[theInfo objectForKey:@"gameNames"] objectAtIndex:i] options:0 range:NSMakeRange(0, [currentEditRow length])];
				
				[currentEditRow replaceOccurrencesOfString:@"$game_id" withString:[[theInfo objectForKey:@"gameIDs"] objectAtIndex:i] options:0 range:NSMakeRange(0, [currentEditRow length])];

				[currentEditRow replaceOccurrencesOfString:@"$row_number" withString:[NSString stringWithFormat:@"%i", i] options:0 range:NSMakeRange(0, [currentEditRow length])];


				[currentEditRow replaceOccurrencesOfString:@"$tile_url" withString:[[theInfo objectForKey:@"gameIcons"] objectAtIndex:i] options:0 range:NSMakeRange(0, [currentEditRow length])];
				
				NSString *yourScore = [[theInfo objectForKey:@"yourScores"] objectAtIndex:i];
				NSString *theirScore = [[theInfo objectForKey:@"theirScores"] objectAtIndex:i];

				float theirPercent;
				float yourPercent;

				//calc percent completed gamerscorelywise
				if ([yourScore rangeOfString:@"of 0"].location != NSNotFound || [theirScore rangeOfString:@"of 0"].location != NSNotFound) {
					yourPercent = 0.0;
					theirPercent = 0.0;
					yourScore = @"No Score";
					theirScore = @"No Score";
				}
				else {
					theirPercent = [XBCompareAchievements percentCompletedFromString:[[theInfo objectForKey:@"theirScores"] objectAtIndex:i]];
					yourPercent = [XBCompareAchievements percentCompletedFromString:[[theInfo objectForKey:@"yourScores"] objectAtIndex:i]];
				}
				
				[currentEditRow replaceOccurrencesOfString:@"$their_gamerscore" withString:theirScore options:0 range:NSMakeRange(0, [currentEditRow length])];
				[currentEditRow replaceOccurrencesOfString:@"$your_gamerscore" withString:yourScore options:0 range:NSMakeRange(0, [currentEditRow length])];

												

				[currentEditRow replaceOccurrencesOfString:@"$their_percentage" withString:[NSString stringWithFormat:@"%f", theirPercent *100] options:0 range:NSMakeRange(0, [currentEditRow length])];
				[currentEditRow replaceOccurrencesOfString:@"$your_percentage" withString:[NSString stringWithFormat:@"%f", yourPercent *100] options:0 range:NSMakeRange(0, [currentEditRow length])];
				
				
				int myScore = [[XBCompareAchievements completedPointsFromString:[[theInfo objectForKey:@"yourScores"] objectAtIndex:i]] intValue];
				int theirIntScore = [[XBCompareAchievements completedPointsFromString:[[theInfo objectForKey:@"theirScores"] objectAtIndex:i]] intValue];
				int totalPointsPossible = [[XBCompareAchievements totalPointsFromString:[[theInfo objectForKey:@"theirScores"] objectAtIndex:i]] intValue];
				float theirCompletion = [XBCompareAchievements percentCompletedFromString:[[theInfo objectForKey:@"theirScores"] objectAtIndex:i]];
				float myCompletion = [XBCompareAchievements percentCompletedFromString:[[theInfo objectForKey:@"yourScores"] objectAtIndex:i]];

				if ([[filterPopup selectedItem] tag] == 1) {
					if (myScore > 0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;

				}
				else if ([[filterPopup selectedItem] tag] == 2) {
					if (theirIntScore > 0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if ([[filterPopup selectedItem] tag] == 3) {
					if (theirIntScore > 0 && myScore > 0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if ([[filterPopup selectedItem] tag] == 4) {
					if (myScore == 0 && theirIntScore > 0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if ([[filterPopup selectedItem] tag] == 5) {
					if (theirIntScore == 0 && myScore > 0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if ([[filterPopup selectedItem] tag] == 6) {
					if (totalPointsPossible > 200)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if ([[filterPopup selectedItem] tag] == 7) {
					if (totalPointsPossible == 200)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if ([[filterPopup selectedItem] tag] == 8) {
					if (totalPointsPossible <= 0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}

				else if ([[filterPopup selectedItem] tag] == 9) {
					if (theirCompletion >= 1.0 || myCompletion >= 1.0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if ([[filterPopup selectedItem] tag] == 10) {
					if (theirCompletion < 1.0 && theirCompletion > 0.0)
						shouldDisplayThisGame = YES;
					else if (myCompletion < 1.0 && myCompletion > 0.0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}

				

				if(shouldDisplayThisGame){
						allRows = [NSString stringWithFormat:@"%@%@", allRows, currentEditRow];
						usableGames = usableGames + 1;
						
				}
				[currentEditRow release];
			}
			@catch (NSException *exception){

			}
		}
	}
	else
		showsError = YES;

	if (usableGames == 0)
		showsError = YES;
	
	if (showsError){
			NSMutableString *errorMut = [[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/error_message.htm"] encoding:NSMacOSRomanStringEncoding error:NULL] mutableCopy];
			if ([[filterPopup selectedItem] tag] == 0) {
				[errorMut replaceOccurrencesOfString:@"$title" withString:@"Gamertag Not Found" options:0 range:NSMakeRange(0, [errorMut length])];
			}
			else {
				[errorMut replaceOccurrencesOfString:@"$title" withString:@"No Matches" options:0 range:NSMakeRange(0, [errorMut length])];
			}
			[errorMut replaceOccurrencesOfString:@"$subtitle" withString:@"" options:0 range:NSMakeRange(0, [errorMut length])];
			theBody = [errorMut copy];
			[errorMut release];
	}
	
	NSMutableString *theBodyMut = [theBody mutableCopy];

	[theBodyMut replaceOccurrencesOfString:@"$their_tag" withString:[searchField stringValue] options:0 range:NSMakeRange(0, [theBodyMut length])];
	[theBodyMut replaceOccurrencesOfString:@"$games_list" withString:allRows options:0 range:NSMakeRange(0, [theBodyMut length])];
	
	[[comparisonWebView mainFrame] loadHTMLString:theBodyMut baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
	[theBodyMut release];
}

+ (float)percentCompletedFromString:(NSString *)blankOfBlank
{
	NSRange ofRange;
	ofRange = [blankOfBlank rangeOfString:@" of "];
	NSString *completedPoints = [blankOfBlank substringWithRange:NSMakeRange(0, ofRange.location)];
	int offset = ofRange.location + ofRange.length;
	NSString *totalPoints = [blankOfBlank substringWithRange:NSMakeRange(offset, [blankOfBlank length] - offset)];
	return [completedPoints floatValue] / [totalPoints floatValue];
}

+ (NSString *)completedPointsFromString:(NSString *)blankOfBlank
{
	NSRange ofRange;
	ofRange = [blankOfBlank rangeOfString:@" of "];
	return [blankOfBlank substringWithRange:NSMakeRange(0, ofRange.location)];
}

+ (NSString *)totalPointsFromString:(NSString *)blankOfBlank
{
	NSRange ofRange;
	ofRange = [blankOfBlank rangeOfString:@" of "];
	int offset = ofRange.location + ofRange.length;
	return [blankOfBlank substringWithRange:NSMakeRange(offset, [blankOfBlank length] - offset)];
}


- (void)displayPieChart:(NSMutableDictionary *)theInfo
{

	[pieGraph clearSlices];

	int i, j;
	float totalScore = 0.0;
	float otherScore = 0.0;
	
	if([[theInfo objectForKey:@"theirScores"] count] != 0){
	

		for (j = 0; j < [[theInfo objectForKey:@"theirScores"] count]; j++){
			totalScore = totalScore + [[[theInfo objectForKey:@"theirScores"] objectAtIndex:j] floatValue];
		}

		for (i = 0; i < [[theInfo objectForKey:@"theirScores"] count]; i++){
			
			float theirScore = [[[theInfo objectForKey:@"theirScores"] objectAtIndex:i] floatValue];
			NSString *gameTitle = [[theInfo objectForKey:@"gameNames"] objectAtIndex:i];
			
			BOOL shouldDisplaySlice = YES;
			float percent = theirScore / totalScore * 100.0;
			
			if ([[theInfo objectForKey:@"theirScores"] count] > 18 && percent < 0.8)
				shouldDisplaySlice = NO;

			if (theirScore <= 0)
				shouldDisplaySlice = NO;
				
			if (shouldDisplaySlice) {
				NSImage *gameIcon = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[[theInfo objectForKey:@"gameIcons"] objectAtIndex:i]]];

				NSMutableDictionary *dict = [NSMutableDictionary dictionary];
				[dict setObject:[[theInfo objectForKey:@"theirScores"] objectAtIndex:i] forKey:@"score"];
				[dict setObject:gameIcon forKey:@"image"];
				[dict setObject:gameTitle forKey:@"title"];

//				[pieGraph addSlice:[MQSlice sliceWithColor:[XBCompareAchievements colorForSlice:i] slice:theirScore message:gameTitle captionData:[dict copy]]];
			}
			else
				otherScore = otherScore + theirScore;
		}
	}
	
	// if (otherScore > 0.0)
	// [pieGraph addSlice:[MQSlice sliceWithColor:[MQFunctions colorFromHexRGB:@"666666"] slice:otherScore message:@"Other Games"]];
	
	[pieGraph sort];
	[pieGraph updateView];

}

int lastColorUsed2 = 0;

+ (NSColor *)colorForSlice:(int)sliceNumber
{
	NSArray *colors = [NSArray arrayWithObjects: @"6FA1FF", @"835C11", @"D09F46", @"9D3725", @"524E69", @"1F4283", @"4E9D25", @"D75E88", @"D0911C", @"4676D0", @"372F22", nil];
	
	if (lastColorUsed2 >= [colors count])
		lastColorUsed2 = 0;
	
	NSColor *theColor = [MQFunctions colorFromHexRGB:[colors objectAtIndex:lastColorUsed2]];
	
	/*	NSImage *texture = [[[NSImage imageNamed:@"pie_texture"] copy] autorelease];
		NSImage *canvas = [[NSImage alloc] autorelease];
		
		NSSize  size = [texture size];
		NSRect bounds = NSMakeRect (0, 0, size.width, size.height);


		[canvas lockFocus];
		
		
		[[MQFunctions colorFromHexRGB:[colors objectAtIndex:lastColorUsed2]] set];
		NSRectFill(bounds);

		[canvas compositeToPoint:NSMakePoint(0.0, 0.0) operation:NSCompositeClear];

		[canvas unlockFocus];

	
	NSColor *theColor = [NSColor colorWithPatternImage:canvas];

	*/
	lastColorUsed2 = lastColorUsed2 + 1;
	
	return theColor;
}




- (void)displayStatistics:(NSMutableDictionary *)theInfo
{

	[statisticsRecords addObject:[self recordWithKey:@"Games Played" yourValue:@"45" theirValue:@"600"]];

	[statisticsTable reloadData];

}


- (NSMutableDictionary *)recordWithKey:(NSString *)keyName yourValue:(NSString *)yourValue theirValue:(NSString *)theirValue
{
	NSMutableDictionary *record = [NSMutableDictionary dictionary];
	[record setObject:keyName forKey:@"keyName"];
	[record setObject:theirValue forKey:@"theirValue"];
	[record setObject:yourValue forKey:@"yourValue"];
	return record;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [statisticsRecords count];
}

-(id)tableView:(NSTableView *)aTableView
  objectValueForTableColumn:(NSTableColumn *)aTableColumn 
  row:(int)rowIndex 
{
	id theRecord, theValue;

	theRecord = [statisticsRecords objectAtIndex:rowIndex];
	theValue = [theRecord objectForKey:[aTableColumn identifier]];

	return theValue;
}

- (void)mouseDown:(NSEvent *)event
{
}

- (void)keyDown:(NSEvent *)event
{
    NSLog(@"%@", [event characters]);
}

MQSlice *lastSlice = nil;

- (void)mouseMoved:(NSEvent *)event
{
    MQSlice *slice = [pieGraph getLastOver];
	if (slice != lastSlice) {
		NSDictionary *data = [slice getCaptionData];
		[sliceCaption setAttributedStringValue:[MQFunctions stringWithShadowFrom:[data objectForKey:@"score"]]];
		[sliceTitle setAttributedStringValue:[MQFunctions stringWithShadowFrom:[data objectForKey:@"title"]]];
		[sliceImage setImage:[data objectForKey:@"image"]];
		[pieGraph updateView];
		lastSlice = slice;
	}
}

- (void)webView:(WebView *)sender windowScriptObjectAvailable: (WebScriptObject *)windowScriptObject
{

	[windowScriptObject setValue:self forKey:@"XBCompareAchievements"];

}


- (NSString *)webViewAchievementDetails:(NSString *)gameID
{

	[progressIndicator startAnimation:nil];
	NSLog(gameID);

	NSArray *achievementArray = [XBAchievementDetailsParser fetchWithGameID:gameID tag:lastFetchTag];
	NSString *achievementDetailsSource = @"";
	NSString *theRow = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/achievement_row.htm"] encoding:NSMacOSRomanStringEncoding error:NULL];

	int i;
	for (i = 0; i < [achievementArray count]; i++){

			NSMutableString *currentEditRow = [theRow mutableCopy];
			XBAchievement *theAchievement = [achievementArray objectAtIndex:i];
			
			NSString *disabledString;
			if ([theAchievement iHaveAchievement] || [theAchievement theyHaveAchievement]) {
				disabledString = @"achievement_enabled";
			}
			else {
				disabledString = @"achievement_disabled";
			}
			[currentEditRow replaceOccurrencesOfString:@"$achievement_disabled" withString:disabledString options:0 range:NSMakeRange(0, [currentEditRow length])];

			NSString *achievementValue;
			if ([theAchievement achievementValue] != 0)
				achievementValue = [NSString stringWithFormat:@"<span class='achievement_value'>%i<img src='gamerscore_icon.png' class='gamerscore' /></span", [theAchievement achievementValue]];
			else
				achievementValue = @"";
				
			[currentEditRow replaceOccurrencesOfString:@"$achievement_value" withString:achievementValue options:0 range:NSMakeRange(0, [currentEditRow length])];
			
			
			[currentEditRow replaceOccurrencesOfString:@"$achievement_title" withString:[theAchievement title] options:0 range:NSMakeRange(0, [currentEditRow length])];
			[currentEditRow replaceOccurrencesOfString:@"$achievement_subtitle" withString:[theAchievement subtitle] options:0 range:NSMakeRange(0, [currentEditRow length])];
			[currentEditRow replaceOccurrencesOfString:@"$tile_url" withString:[[theAchievement tileURL] absoluteString] options:0 range:NSMakeRange(0, [currentEditRow length])];

			[currentEditRow replaceOccurrencesOfString:@"$their_checkmark" withString:[self checkmark:[theAchievement theyHaveAchievement]] options:0 range:NSMakeRange(0, [currentEditRow length])];
			[currentEditRow replaceOccurrencesOfString:@"$your_checkmark" withString:[self checkmark:[theAchievement iHaveAchievement]] options:0 range:NSMakeRange(0, [currentEditRow length])];

			achievementDetailsSource = [achievementDetailsSource stringByAppendingString:currentEditRow];
			[currentEditRow release];
	}


	[progressIndicator stopAnimation:nil];

	return achievementDetailsSource;

}

- (NSString *)checkmark:(BOOL)x {
	NSString *y;
	if (x) {
		y = @"&#10004;";
	}
	else {
		y = @"-";
	}
	return y;
}


+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector { return NO; }



@end
