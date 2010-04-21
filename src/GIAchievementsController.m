//
//  XBGamerInfoAchievementsController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "XBAchievementDetailsParser.h"
#import "XBGame.h"
#import "Xbox Live Friends.h"
#import "GITabController.h"
#import "GIAchievementsController.h"
#import "XBGamesPlayedParser.h"

@implementation GIAchievementsController

- (NSString *)notificationName {
	return @"GIAchievementsLoadNotification";
}

- (void)awakeFromNib {	
    [comparisonWebView setFrameLoadDelegate:self];
	[comparisonWebView setUIDelegate:self];
	[comparisonWebView setShouldCloseWithWindow:NO];
}

- (void)displayGamerInfo:(NSString *)gamertag {
	NSArray *gamesPlayed = [XBGamesPlayedParser fetchWithTag:gamertag];
	if (gamesPlayed) {
		[self setLastFetch:gamesPlayed];
		[self setLastFetchTag:gamertag];
		[self performSelectorOnMainThread:@selector(refilter:) withObject:nil waitUntilDone:YES];
	}
	else {
		//[self setErrorForTab:@"An Error Occurred"];
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GIShowErrorTab" object:@"An Error Occurred"]];
	}

}

- (void)clearTab {
	[[comparisonWebView mainFrame] loadHTMLString:@"" baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
}


- (IBAction)refilter:(id)sender
{
	[self displayGamesPlayed:[self lastFetch] forGamertag:[self lastFetchTag]];
}

- (IBAction)searchGames:(id)sender{
	[self displayGamesPlayed:[self lastFetch] forGamertag:[self lastFetchTag]];
}


- (void)displayGamesPlayed:(NSArray *)gamesList forGamertag:(NSString *)gamertag
{
	


	
	NSString *theRow = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/compare_row.htm"] encoding:NSMacOSRomanStringEncoding error:NULL];
	NSString *theBody = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/compare_body.htm"] encoding:NSMacOSRomanStringEncoding error:NULL];
	NSString *allRows = @"<!-- something something -->";
	
	NSMutableString *currentEditRow;
	
	BOOL showsError = NO;
	int usableGames = 0;

	int popupTag = [[filterPopup selectedItem] tag];
	
	if([gamesList count] != 0){
		int i = 0;
		for (XBGame *thisGame in gamesList){
			BOOL shouldDisplayThisGame = YES;
			@try{
				currentEditRow = [theRow mutableCopy];
				
				if (thisGame.isJustMe) {
					//[self setErrorForTab:@"Cannot View Your Own Achievements"];
					[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GIShowErrorTab" object:@"Cannot View Your Own Achievements"]];
					return;
				}
				
				NSString *rowEvenness;
				if (usableGames % 2 == 1) {
					rowEvenness = @"odd";
				}
				else {
					rowEvenness = @"even";
				}
				[currentEditRow replaceOccurrencesOfString:@"$even_or_odd" withString:rowEvenness options:0 range:NSMakeRange(0, [currentEditRow length])];

				NSMutableString *gameName = [[[thisGame name] mutableCopy] autorelease];
				[gameName replaceOccurrencesOfString:@"(PC)" withString:@"<span class='pc'>PC</span>" options:0 range:NSMakeRange(0, [gameName length])];
				[gameName replaceOccurrencesOfString:@"(Windows)" withString:@"<span class='pc'>PC</span>" options:0 range:NSMakeRange(0, [gameName length])];

				[currentEditRow replaceOccurrencesOfString:@"$game_title" withString:gameName options:0 range:NSMakeRange(0, [currentEditRow length])];
				
				[currentEditRow replaceOccurrencesOfString:@"$game_id" withString:[thisGame gameID] options:0 range:NSMakeRange(0, [currentEditRow length])];

				[currentEditRow replaceOccurrencesOfString:@"$row_number" withString:[NSString stringWithFormat:@"%i", i] options:0 range:NSMakeRange(0, [currentEditRow length])];


				[currentEditRow replaceOccurrencesOfString:@"$tile_url" withString:[[thisGame tileURL] absoluteString] options:0 range:NSMakeRange(0, [currentEditRow length])];
				
				NSString *yourScore = [thisGame yourScore];
				NSString *theirScore = [thisGame theirScore];

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
					theirPercent = [self percentCompletedFromString:[thisGame theirScore]];
					yourPercent = [self percentCompletedFromString:[thisGame yourScore]];
				}
				
				[currentEditRow replaceOccurrencesOfString:@"$their_gamerscore" withString:theirScore options:0 range:NSMakeRange(0, [currentEditRow length])];
				[currentEditRow replaceOccurrencesOfString:@"$your_gamerscore" withString:yourScore options:0 range:NSMakeRange(0, [currentEditRow length])];

												

				[currentEditRow replaceOccurrencesOfString:@"$their_percentage" withString:[NSString stringWithFormat:@"%f", theirPercent *100] options:0 range:NSMakeRange(0, [currentEditRow length])];
				[currentEditRow replaceOccurrencesOfString:@"$your_percentage" withString:[NSString stringWithFormat:@"%f", yourPercent *100] options:0 range:NSMakeRange(0, [currentEditRow length])];
				
				
				int myScore = [[self completedPointsFromString:[thisGame yourScore]] intValue];
				int theirIntScore = [[self completedPointsFromString:[thisGame theirScore]] intValue];
				int totalPointsPossible = [[self totalPointsFromString:[thisGame theirScore]] intValue];
				float theirCompletion = [self percentCompletedFromString:[thisGame theirScore]];
				float myCompletion = [self percentCompletedFromString:[thisGame yourScore]];

				if (popupTag == 1) {
					if (myScore > 0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;

				}
				else if (popupTag == 2) {
					if (theirIntScore > 0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if (popupTag == 3) {
					if (theirIntScore > 0 && myScore > 0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if (popupTag == 4) {
					if (myScore == 0 && theirIntScore > 0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if (popupTag == 5) {
					if (theirIntScore == 0 && myScore > 0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if (popupTag == 6) {
					if (totalPointsPossible > 250)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if (popupTag == 7) {
					if (totalPointsPossible <= 250 && totalPointsPossible > 0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if (popupTag == 8) {
					if (totalPointsPossible <= 0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}

				else if (popupTag == 9) {
					if (theirCompletion >= 1.0 || myCompletion >= 1.0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if (popupTag == 10) {
					if (theirCompletion < 1.0 && theirCompletion > 0.0)
						shouldDisplayThisGame = YES;
					else if (myCompletion < 1.0 && myCompletion > 0.0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if (popupTag == 11) {
					if (myScore > theirIntScore && myScore > 0  && theirIntScore > 0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}
				else if (popupTag == 12) {
					if (myScore < theirIntScore && myScore > 0  && theirIntScore > 0)
						shouldDisplayThisGame = YES;
					else
						shouldDisplayThisGame = NO;
				}

				
				//filter games list in accordance with search string
				if ([[searchField stringValue] length] > 0 && [[thisGame name] rangeOfString:[searchField stringValue] options:NSCaseInsensitiveSearch].location == NSNotFound) {
						shouldDisplayThisGame = NO;
				}

				

				if(shouldDisplayThisGame){
						allRows = [NSString stringWithFormat:@"%@%@", allRows, currentEditRow];
						usableGames = usableGames + 1;
						
				}
				[currentEditRow release];
			}
			@catch (NSException *exception){
//				NSLog([exception name]);
//				NSLog([exception reason]);

			}
			i++;
		}
	}
	else
		showsError = YES;

	if (usableGames == 0)
		showsError = YES;
	
	if (showsError){
			NSMutableString *errorMut = [[[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/simple_error_message.htm"] encoding:NSMacOSRomanStringEncoding error:NULL] mutableCopy] autorelease];

			if (popupTag == 0 && [[searchField stringValue] length] == 0) {
				[errorMut replaceOccurrencesOfString:@"$title" withString:@"Gamertag Not Found" options:0 range:NSMakeRange(0, [errorMut length])];
			}
			else {
				[errorMut replaceOccurrencesOfString:@"$title" withString:@"No Matches" options:0 range:NSMakeRange(0, [errorMut length])];
			}
			[errorMut replaceOccurrencesOfString:@"$subtitle" withString:@"" options:0 range:NSMakeRange(0, [errorMut length])];
			theBody = [[errorMut copy] autorelease];
	}
	
	NSMutableString *theBodyMut = [[theBody mutableCopy] autorelease];

	[theBodyMut replaceOccurrencesOfString:@"$their_tag" withString:gamertag options:0 range:NSMakeRange(0, [theBodyMut length])];
	[theBodyMut replaceOccurrencesOfString:@"$games_list" withString:allRows options:0 range:NSMakeRange(0, [theBodyMut length])];
		
	[[comparisonWebView mainFrame] loadHTMLString:theBodyMut baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
}

- (float)percentCompletedFromString:(NSString *)blankOfBlank
{
	NSRange ofRange;
	ofRange = [blankOfBlank rangeOfString:@" of "];
	NSString *completedPoints = [blankOfBlank substringWithRange:NSMakeRange(0, ofRange.location)];
	int offset = ofRange.location + ofRange.length;
	NSString *totalPoints = [blankOfBlank substringWithRange:NSMakeRange(offset, [blankOfBlank length] - offset)];
	return [completedPoints floatValue] / [totalPoints floatValue];
}

- (NSString *)completedPointsFromString:(NSString *)blankOfBlank
{
	NSRange ofRange;
	ofRange = [blankOfBlank rangeOfString:@" of "];
	return [blankOfBlank substringWithRange:NSMakeRange(0, ofRange.location)];
}

- (NSString *)totalPointsFromString:(NSString *)blankOfBlank
{
	NSRange ofRange;
	ofRange = [blankOfBlank rangeOfString:@" of "];
	int offset = ofRange.location + ofRange.length;
	return [blankOfBlank substringWithRange:NSMakeRange(offset, [blankOfBlank length] - offset)];
}


- (void)webView:(WebView *)sender windowScriptObjectAvailable: (WebScriptObject *)windowScriptObject
{

	[windowScriptObject setValue:self forKey:@"XBCompareAchievements"];

}


- (void)webViewAchievementDetails:(NSDictionary *)info {

	NSString *gameID = [info objectForKey:@"gameID"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GIStartProgressIndicator" object:nil];

	NSArray *achievementArray = [XBAchievementDetailsParser fetchWithGameID:gameID tag:[self lastFetchTag]];
	NSString *achievementDetailsSource = @"";
	NSString *rowSource = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/achievement_row.htm"] encoding:NSMacOSRomanStringEncoding error:NULL];

	for (XBAchievement *theAchievement in achievementArray){

			NSString *row = [[rowSource copy] autorelease];
			
			NSString *disabledString;
			if ([theAchievement iHaveAchievement] || [theAchievement theyHaveAchievement]) {
				disabledString = @"achievement_enabled";
			}
			else {
				disabledString = @"achievement_disabled";
			}
			
			row = [row replace:@"$achievement_disabled" with:disabledString];

			NSString *achievementValue;
			if ([theAchievement achievementValue] != 0)
				achievementValue = [NSString stringWithFormat:@"<span class='achievement_value'>%@<img src='gamerscore_icon.png' class='gamerscore' /></span>", [theAchievement achievementValue]];
			else
				achievementValue = @"";
			
			row = [row replace:@"$achievement_value" with:achievementValue];
			row = [row replace:@"$achievement_title" with:[theAchievement title]];
			row = [row replace:@"$achievement_subtitle" with:[theAchievement subtitle]];
			row = [row replace:@"$tile_url" with:[[theAchievement tileURL] absoluteString]];
			row = [row replace:@"$their_checkmark" with:[self checkmark:[theAchievement theyHaveAchievement]]];
			row = [row replace:@"$your_checkmark" with:[self checkmark:[theAchievement iHaveAchievement]]];

			
			achievementDetailsSource = [achievementDetailsSource stringByAppendingString:row];			
			
			
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GIStopProgressIndicator" object:nil];

	[[comparisonWebView windowScriptObject] callWebScriptMethod:@"details_loaded" withArguments:[NSArray arrayWithObjects:achievementDetailsSource, gameID,[info objectForKey:@"row"], nil]];


	//return achievementDetailsSource;
}

- (void)beginLoadingDetailsForGame:(NSString *)gameID row:(NSString *)row {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:gameID, @"gameID", row, @"row", nil];
//	NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(webViewAchievementDetails:) object:dict];
//	[[[NSApp delegate] operationQueue] addOperation:theOp];	


		[self performSelectorOnMainThread:@selector(webViewAchievementDetails:) withObject:dict waitUntilDone:YES];

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


+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector {
	return NO;
}

- (unsigned)webView:(WebView *)sender dragSourceActionMaskForPoint:(NSPoint)point
{
    return WebDragSourceActionNone;
}

@end
