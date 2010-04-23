//
//  XBGamesPlayedParser.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "XBGamesPlayedParser.h"

#define ACHI_SELF_URL @"http://live.xbox.com/en-US/profile/Achievements/ViewAchievementSummary.aspx"

NSString* achievementURL = @"http://live.xbox.com/en-US/profile/Achievements/ViewAchievementSummary.aspx?compareTo=";

@implementation XBGamesPlayedParser

+ (NSArray *)fetchWithTag:(NSString *)tag {
	return [self fetchWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", achievementURL, [tag replace:@" " with:@"+"]]]];
}

+ (NSArray *)fetchWithURL:(NSURL *)URL {	

	NSString *editString = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];
	NSArray *rows = [editString cropRowsMatching:@"<tbody" rowEnd:@"</tr>"];

	NSMutableArray *gamesArray = [NSMutableArray array];

	for (NSString *row in rows) {
		
		XBGame *thisGame = [XBGame game];
		
		if (![row contains:@"XbcAchYouCell"]) {
			return nil;
			//thisGame.isJustMe = YES;
		}
		
		[thisGame setName:[row cropFrom:@"XbcAchievementsTitle\">" to:@"</strong>"]];
		[thisGame setTileURL:[NSURL URLWithString:[row cropFrom:@"AchievementsGameIcon\" src=\"" to:@"\" alt=\""]]];
		
		NSString *yourScore;
		if (thisGame.isJustMe) {
			yourScore = [row cropFrom:@"XbcAchGamerData\"><strong>" to:@" <img src"];
		}
		else {
			yourScore = [row cropFrom:@"XbcAchMeCell\"><strong>" to:@" <img src"];
		}
		if ([yourScore rangeOfString:@"No Gamerscore"].location != NSNotFound || yourScore == nil)
			yourScore = @"-1 of 1000";
		[thisGame setYourScore:yourScore];

		NSString *theirScore = [row cropFrom:@"XbcAchYouCell\"><strong>" to:@" <img src"];
		if ([theirScore rangeOfString:@"No Gamerscore"].location != NSNotFound || theirScore == nil)
			theirScore = @"-1 of 1000";
		[thisGame setTheirScore:theirScore];

		[thisGame setGameID:[row cropFrom:@"ViewAchievementDetails.aspx?tid=" to:@"&amp;"]];

		[gamesArray addObject:thisGame];
	}

	return [[gamesArray copy] autorelease];
}

+ (NSArray *)fetchForSelf
{
	NSString *editString = [NSString stringWithContentsOfURL:[NSURL URLWithString:ACHI_SELF_URL] encoding:NSUTF8StringEncoding error:nil];
	NSArray *rows = [editString cropRowsMatching:@"<tbody" rowEnd:@"</tr>"];
	
	NSMutableArray *gamesArray = [NSMutableArray array];
	
	for (NSString *row in rows) {
		
		XBGame *thisGame = [XBGame game];
		
		/*
		if (![row contains:@"XbcAchYouCell"]) {
			return nil;
			//thisGame.isJustMe = YES;
		}
		 */
		
		NSString *tempName = [row cropFrom:@"class=\"XbcAchievementsTitle\">" to:@"</strong>"];
		tempName = [MQFunctions flattenHTML:tempName];
		
		NSURL *tempURL = [NSURL URLWithString:[row cropFrom:@"AchievementsGameIcon\" src=\"" to:@"\" alt=\""]];
		
		[thisGame setName:tempName];
		[thisGame setTileURL:tempURL];
		
		NSString *yourScore = [row cropFrom:@"XbcAchGamerData\"><strong>" to:@" <img src"];
		/*
		if (thisGame.isJustMe) {
			yourScore = [row cropFrom:@"XbcAchGamerData\"><strong>" to:@" <img src"];
		}
		else {
			yourScore = [row cropFrom:@"XbcAchMeCell\"><strong>" to:@" <img src"];
		}
		 */
		/*
		if ([yourScore rangeOfString:@"No Gamerscore"].location != NSNotFound || yourScore == nil) {
			yourScore = @"-1 of 1000";
		}
		 */
		
		[thisGame setYourScore:yourScore];
		
		/*
		NSString *theirScore = [row cropFrom:@"XbcAchYouCell\"><strong>" to:@" <img src"];
		if ([theirScore rangeOfString:@"No Gamerscore"].location != NSNotFound || theirScore == nil)
			theirScore = @"-1 of 1000";
		[thisGame setTheirScore:theirScore];
		*/
		
		NSString *tempGameID = [row cropFrom:@"ViewAchievementDetails.aspx?tid=" to:@"\""];
		[thisGame setGameID:tempGameID];
		
		[gamesArray addObject:thisGame];
	}
	
	return [[gamesArray copy] autorelease];
}

@end
