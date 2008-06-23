//
//  XBGamesPlayedParser.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "XBGamesPlayedParser.h"

NSString* achievementURL = @"http://live.xbox.com/en-US/profile/Achievements/ViewAchievementSummary.aspx?compareTo=";

@implementation XBGamesPlayedParser

- (id)init	{
	if (![super init])
	return nil;

	return self;
}

+ (NSArray *)fetchWithTag:(NSString *)tag
{
	NSMutableString *mutableGamerTag = [[tag mutableCopy] autorelease];
	[mutableGamerTag replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutableGamerTag length])];
	return [self fetchWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", achievementURL, mutableGamerTag]]];
}

+ (NSArray *)fetchWithURL:(NSURL *)URL
{	

	NSString *editString = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];
	NSMutableArray *rows = [[NSMutableArray alloc] init];

	//rows
	while ([editString rangeOfString:@"<tbody"].location != NSNotFound ) {
	
		NSRange range;
		int offset;
		range = [editString rangeOfString:@"<tbody"];
		offset = range.location + range.length;
		range = [editString rangeOfString:@"</tr>" options:0 range:NSMakeRange(offset, [editString length] - offset)];
		NSString *thisRow = [editString substringWithRange:NSMakeRange(offset, range.location - offset)];
		[rows addObject:thisRow];
				
		editString = [editString substringFromIndex:range.location];
	}

	NSMutableArray *gamesArray = [NSMutableArray array];
	NSEnumerator *enumerator = [rows objectEnumerator];
	id rowSource;
	while ((rowSource = [enumerator nextObject])) {
		
		XBGame *thisGame = [XBGame game];
		[thisGame setName:[MQFunctions cropString:rowSource between:@"XbcAchievementsTitle\">" and:@"</strong>"]];
		[thisGame setTileURL:[NSURL URLWithString:[MQFunctions cropString:rowSource between:@"AchievementsGameIcon\" src=\"" and:@"\" alt=\""]]];

		NSString *yourScore = [MQFunctions cropString:rowSource between:@"XbcAchMeCell\"><strong>" and:@" <img src"];
		if ([yourScore rangeOfString:@"No Gamerscore"].location != NSNotFound || yourScore == nil)
			yourScore = @"-1 of 1000";
		[thisGame setYourScore:yourScore];

		NSString *theirScore = [MQFunctions cropString:rowSource between:@"XbcAchYouCell\"><strong>" and:@" <img src"];
		if ([theirScore rangeOfString:@"No Gamerscore"].location != NSNotFound || theirScore == nil)
			theirScore = @"-1 of 1000";
		[thisGame setTheirScore:theirScore];

		[thisGame setGameID:[MQFunctions cropString:rowSource between:@"ViewAchievementDetails.aspx?tid=" and:@"&amp;"]];

		[gamesArray addObject:thisGame];
	}

	[rows release];
	return [[gamesArray copy] retain];
}

//+ (NSMutableDictionary *)fetchWithTag:(NSString *)tag
//{
//	NSMutableString *mutableGamerTag = [[tag mutableCopy] autorelease];
//	[mutableGamerTag replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutableGamerTag length])];
//	return [self fetchWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", achievementURL, mutableGamerTag]]];
//}

//
//+ (NSMutableDictionary *)fetchWithURL:(NSURL *)URL
//{
//	//make dictionary
//	NSMutableDictionary *achievementDict = [NSMutableDictionary dictionary];
//
//	//make arrays
//	NSMutableArray *yourScores = [[NSMutableArray alloc] init];
//	NSMutableArray *theirScores = [[NSMutableArray alloc] init];
//	//NSMutableArray *yourAchievementCount = [[NSMutableArray alloc] init];
//	//NSMutableArray *theirAchievementCount = [[NSMutableArray alloc] init];
//	NSMutableArray *gameNames = [[NSMutableArray alloc] init];
//	NSMutableArray *gameIcons = [[NSMutableArray alloc] init];
//	NSMutableArray *gameIDs = [[NSMutableArray alloc] init];
//
//	NSLog(@"about to download source");
//
//	//download source
//	NSString *string = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];//[NSString stringWithContentsOfURL:URL encod];
//	NSString *editString = string;
//		NSLog(@"source done");
//
//	
//	//gameNames
//	while ([editString rangeOfString:@"XbcAchievementsTitle\">"].location != NSNotFound )	{
//		NSRange range;
//		int offset;
//
//		range = [editString rangeOfString:@"XbcAchievementsTitle\">"];
//		offset = range.location + range.length;
//
//		range = [editString rangeOfString:@"</strong>" options:0 range:NSMakeRange(offset, [editString length] - offset)];
//
//		NSString *thisGameName = [editString substringWithRange:NSMakeRange(offset, range.location - offset)];
//
//		[gameNames addObject:thisGameName];
//				
//		editString = [editString substringFromIndex:range.location];
//	}
//	[achievementDict setObject:gameNames forKey:@"gameNames"];
//
//	//gameIDs
//	editString = string;
//	while ([editString rangeOfString:@"ViewAchievementDetails.aspx?tid="].location != NSNotFound )	{
//	
//		NSRange range;
//		int offset;
//
//		range = [editString rangeOfString:@"ViewAchievementDetails.aspx?tid="];
//		offset = range.location + range.length;
//		range = [editString rangeOfString:@"&amp;" options:0 range:NSMakeRange(offset, [editString length] - offset)];
//
//		[gameIDs addObject:[MQFunctions cropString:editString between:@"ViewAchievementDetails.aspx?tid=" and:@"&amp;"]];
//
//		editString = [editString substringFromIndex:range.location];
//	}
//	[achievementDict setObject:gameIDs forKey:@"gameIDs"];
//
//	//gameIcons
//	editString = string;
//	while ([editString rangeOfString:@"AchievementsGameIcon\" src=\""].location != NSNotFound )	{
//		NSRange range;
//		int offset;
//
//		range = [editString rangeOfString:@"AchievementsGameIcon\" src=\""];
//		offset = range.location + range.length;
//
//		range = [editString rangeOfString:@"\" alt=\"" options:0 range:NSMakeRange(offset, [editString length] - offset)];
//
//		NSString *thisGameIcon = [editString substringWithRange:NSMakeRange(offset, range.location - offset)];
//
//		[gameIcons addObject:thisGameIcon];
//				
//		editString = [editString substringFromIndex:range.location];
//	}
//	[achievementDict setObject:gameIcons forKey:@"gameIcons"];
//
//	//yourScores
//	editString = string;
//	while ([editString rangeOfString:@"XbcAchMeCell\"><strong>"].location != NSNotFound )	{
//		NSRange range;
//		int offset;
//
//		range = [editString rangeOfString:@"XbcAchMeCell\"><strong>"];
//		offset = range.location + range.length;
//
//		range = [editString rangeOfString:@"</strong>" options:0 range:NSMakeRange(offset, [editString length] - offset)];
//
//		NSString *ys = [editString substringWithRange:NSMakeRange(offset, range.location - offset)];
//
//		if ([ys rangeOfString:@"No Gamerscore"].location != NSNotFound){
//			ys = @"-1 of 0";
//		}
//
//		[yourScores addObject:[MQFunctions flattenHTML:ys]];
//
//		editString = [editString substringFromIndex:range.location];
//	}
//	[achievementDict setObject:yourScores forKey:@"yourScores"];
//
//	//theirScores
//	editString = string;
//	while ([editString rangeOfString:@"XbcAchYouCell\"><strong>"].location != NSNotFound )	{
//		NSRange range;
//		int offset;
//
//		range = [editString rangeOfString:@"XbcAchYouCell\"><strong>"];
//		offset = range.location + range.length;
//
//		range = [editString rangeOfString:@"</strong>" options:0 range:NSMakeRange(offset, [editString length] - offset)];
//
//		NSString *ts = [editString substringWithRange:NSMakeRange(offset, range.location - offset)];
//		if ([ts rangeOfString:@"No Gamerscore"].location != NSNotFound){
//			ts = @"0 of 0";
//		}
//
//		[theirScores addObject:[MQFunctions flattenHTML:ts]];
//				
//		editString = [editString substringFromIndex:range.location];
//	}
//	[achievementDict setObject:theirScores forKey:@"theirScores"];
//
//
//	return achievementDict;
//}
//


@end
