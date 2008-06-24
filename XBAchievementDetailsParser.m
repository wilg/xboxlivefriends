//
//  XBAchivementDetailsParser.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "XBAchievementDetailsParser.h"

@implementation XBAchievementDetailsParser

- (id)init	{
	if (![super init])
	return nil;

	return self;
}

+ (NSArray *)fetchWithGameID:(NSString *)gameID tag:(NSString *)tag {
	return [self fetchWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/Achievements/ViewAchievementDetails.aspx?tid=%@&compareTo=%@", gameID, [tag replace:@" " with:@"+"]]]];
}

+ (NSArray *)fetchWithURL:(NSURL *)URL {	

	NSString *theSource = [[NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil] mutableCopy];
	
	//make arrays
	NSArray *rows = [theSource cropRowsMatching:@"<td class=\"XbcAchYouDetailsName\">" rowEnd:@"</tr>"];
	

	//convert to list of XBAchievements
	NSMutableArray *achievementArray = [NSMutableArray array];
	
	for (NSString *thisAchievementSource in rows){

		XBAchievement *thisAchievement = [XBAchievement achievement];


		NSString *theirArea;
		NSString *myArea;
		@try {
			NSRange endOfTheirArea = [thisAchievementSource rangeOfString:@"</span></p></div></td>"];
			theirArea = [thisAchievementSource substringToIndex:endOfTheirArea.location];
			myArea = [thisAchievementSource substringFromIndex:endOfTheirArea.location];
		}
		@catch (NSException *exception) {
			theirArea = thisAchievementSource;
			myArea = thisAchievementSource;
		}


		[thisAchievement setTitle:[thisAchievementSource cropFrom:@"<strong class=\"XbcAchievementsTitle\">" to:@"</strong>"]];
		[thisAchievement setSubtitle:[thisAchievementSource cropFrom:@"</p></div><p>" to:@"</p>"]];
		

		NSNumber *myValue;
		NSString *myValueString = [myArea cropFrom:@"</div><p><strong>" to:@" <img src="];
		if ([myValueString isEqualToString:@"--"])
			myValue = nil;
		else
			myValue = [NSNumber numberWithInt:[myValueString intValue]];

		
		NSNumber *theirValue;
		NSString *theirValueString = [theirArea cropFrom:@"</div><p><strong>" to:@" <img src="];
		if ([theirValueString isEqualToString:@"--"])
			theirValue = nil;
		else
			theirValue = [NSNumber numberWithInt:[theirValueString intValue]];


		[thisAchievement determineAchievementSettingsFromMyValue:myValue
													  theirValue:theirValue
													  myTile:[myArea cropFrom:@"<img src=\"" to:@"\""]
													  theirTile:[theirArea cropFrom:@"<img src=\"" to:@"\""]
		];
				

		[achievementArray addObject:thisAchievement];
	}


	return [achievementArray copy];
}


@end
