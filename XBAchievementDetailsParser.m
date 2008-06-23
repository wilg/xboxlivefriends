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

+ (NSArray *)fetchWithGameID:(NSString *)gameID tag:(NSString *)tag
{
	NSMutableString *mutableGamerTag = [[tag mutableCopy] autorelease];
	[mutableGamerTag replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutableGamerTag length])];
	return [self fetchWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/Achievements/ViewAchievementDetails.aspx?tid=%@&compareTo=%@", gameID, mutableGamerTag]]];
}

+ (NSArray *)fetchWithURL:(NSURL *)URL
{	

	//make arrays
	NSMutableArray *rows = [[NSMutableArray alloc] init];

	//download source
	NSString *editString = [[NSString stringWithContentsOfURL:URL encoding:NSISOLatin1StringEncoding error:nil] mutableCopy];

	while ([editString rangeOfString:@"<td class=\"XbcAchYouDetailsName\">"].location != NSNotFound )	{
		NSRange range;
		int offset;

		range = [editString rangeOfString:@"<td class=\"XbcAchYouDetailsName\">"];
		offset = range.location + range.length;

		range = [editString rangeOfString:@"</tr>" options:0 range:NSMakeRange(offset, [editString length] - offset)];

		NSString *thisRow = [editString substringWithRange:NSMakeRange(offset, range.location - offset)];
		
		[rows addObject:thisRow];
				
		editString = [editString substringFromIndex:range.location];
	}
	

	//convert to list of XBAchievements
	NSMutableArray *achievementArray = [[NSMutableArray alloc] init];
	int i;
	for (i = 0; i < [rows count]; i++){

		XBAchievement *thisAchievement = [XBAchievement achievement];
		NSMutableString *thisAchievementSource = [[rows objectAtIndex:i] mutableCopy];


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


		[thisAchievement setTitle:[MQFunctions cropString:thisAchievementSource between:@"<strong class=\"XbcAchievementsTitle\">" and:@"</strong>"]];
		[thisAchievement setSubtitle:[MQFunctions cropString:thisAchievementSource between:@"</p></div><p>" and:@"</p>"]];
		

		NSNumber *myValue;
		NSString *myValueString = [MQFunctions cropString:myArea between:@"</div><p><strong>" and:@" <img src="];
		if ([myValueString isEqualToString:@"--"])
			myValue = nil;
		else
			myValue = [NSNumber numberWithInt:[myValueString intValue]];

		
		NSNumber *theirValue;
		NSString *theirValueString = [MQFunctions cropString:theirArea between:@"</div><p><strong>" and:@" <img src="];
		if ([theirValueString isEqualToString:@"--"])
			theirValue = nil;
		else
			theirValue = [NSNumber numberWithInt:[theirValueString intValue]];


		[thisAchievement determineAchievementSettingsFromMyValue:myValue
													  theirValue:theirValue
													  myTile:[MQFunctions cropString:myArea between:@"<img src=\"" and:@"\""]
													  theirTile:[MQFunctions cropString:theirArea between:@"<img src=\"" and:@"\""]
		];
				

		[achievementArray addObject:thisAchievement];

		[thisAchievementSource release];
	}


	return [achievementArray copy];
}


@end
