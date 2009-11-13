//
//  XBFriendsList.m
//  Xbox Live Friends
//
//  Copyright 2006 mindquirk. All rights reserved.
//

#import "FriendsListParser.h"
#import "Xbox Live Friends.h"

NSString* friendsListURL = @"http://live.xbox.com/en-US/profile/Friends.aspx";
NSString* statusNewlineReplacement = @" - ";

@implementation FriendsListParser

+ (NSArray *)friends {

	NSArray *friendsArray;
	NSString *theSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:friendsListURL] encoding:NSUTF8StringEncoding error:nil];

	BOOL success = NO;
	if ([theSource length] >= 5) {
		@try {
			
			int pageIndex = 1;
			NSString *thisSource = theSource;
			while ([thisSource contains:@"<a class=\"XbcNP\""]) {
				pageIndex++;
				thisSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?p=%i", friendsListURL, pageIndex]] encoding:NSUTF8StringEncoding error:nil];
				theSource = [theSource stringByAppendingString:thisSource];
			}
		
		
			friendsArray = [self friendsWithSource:theSource];
			if ([friendsArray count] != 0) {
				success = YES;
			}
		}
		@catch(id err){}
	}
	
	if (!success)
		return nil;

	return friendsArray;
}

+ (NSArray *)friendsWithSource:(NSString *)theSource {
	if ([theSource contains:@"<title>Continue</title>"])
		[NSException raise:@"Signed Out" format:@"Please sign in to Windows Live ID."];

	NSMutableArray *friends = [NSMutableArray array];
	
	
	NSArray *rows = [theSource cropRowsMatching:@"<tr" rowEnd:@"</tr>"];
	
	BOOL demoMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"DebugDemoMode"];
	
	if (demoMode) {
		//demo mode shit
		[friends addObject:[XBFriend friendWithTag:@"my hand" tileURLString:@"http://www.xbox.com/NR/rdonlyres/A5B41DAF-4921-4478-B5D6-955B537E02BD/0/cod4forcerecon01.jpg" statusString:@"Online" infoString:@"Call of Duty 4 - Search and Destroy on Creek"]];
		[friends addObject:[XBFriend friendWithTag:@"Darksoul0X" tileURLString:@"http://tiles.xbox.com/tiles/IL/Ef/0mdsb2JgbC8RX1ZeV0oAGAZfL3RpbGUvMC8xODBlZQAAAQAAAAD9MLEA.jpg" statusString:@"Online" infoString:@"Xbox 360 Dashboard"]];
		[friends addObject:[XBFriend friendWithTag:@"hkmhrnz777" tileURLString:@"http://tiles.xbox.com/tiles/nw/6K/1Gdsb2JgbC9CCgUNBBwAGAFYL3RpbGUvMC8xODAwNgAAAQAAAAD7pQ6-.jpg" statusString:@"Online" infoString:@"Gears of War - Execution Mansion"]];
		[friends addObject:[XBFriend friendWithTag:@"Unholy Vanny" tileURLString:@"http://www.xbox.com/NR/rdonlyres/A5B41DAF-4921-4478-B5D6-955B537E02BD/0/cod4forcerecon01.jpg" statusString:@"Online" infoString:@"Rainbow Six Vegas - Campaign"]];
		[friends addObject:[XBFriend friendWithTag:@"KnownEvil Homer" tileURLString:@"http://tiles.xbox.com/tiles/09/4Q/1mdsb2JgbC9ECgRcBBwAF1EPL3RpbGUvMC8xODAwMAAAAQAAAAD5P97z.jpg" statusString:@"Busy" infoString:@"47 minutes ago - Xbox 360 Dashboard"]];
		[friends addObject:[XBFriend friendWithTag:@"Omega Spawn" tileURLString:@"http://tiles.xbox.com/tiles/BK/Hv/1Gdsb2JgbC8SCgUMBRkAGAFbL3RpbGUvMC8xODAwZgAAAQAAAAD7wKEk.jpg" statusString:@"Away" infoString:@"Watching a movie"]];
	}

	for (NSString *row in rows) {
		
		if (![row contains:@"GamerTag="])
			continue;
	
		NSString *gamertag = [row cropFrom:@"GamerTag=" to:@"\""];
		gamertag = [gamertag replace:@"+" with:@" "];
	
		NSString *gamertileURL = [row cropFrom:@"<td class=\"XbcGamerTile" to:@"</td>"];
		gamertileURL = [gamertileURL cropFrom:@"src=\"" to:@"\""];
		if ([gamertileURL contains:@"QuestionMark32x32.jpg"])
			gamertileURL = @"http://live.xbox.com/xweb/lib/images/QuestionMark32x32.jpg";

		NSString *status = [row cropFrom:@"headers=\"Status\">" to:@"</td>"];
		status = [status stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
		NSString *richPresence = [row cropFrom:@"headers=\"Info\">" to:@"</td>"];
		richPresence = [richPresence replace:@"&nbsp;" with:@" "];
		richPresence = [richPresence replace:@"<br />" with:@"\n"];
		richPresence = [richPresence replace:@"<br>" with:@"\n"];
		richPresence = [richPresence replace:@"\r\n" with:@"\n"];
		richPresence = [richPresence replace:@"\r" with:@"\n"];
		richPresence = [richPresence replace:@"Playing " with:@""];
		if ([richPresence contains:@"Last seen "]) {
			richPresence = [richPresence replace:@"Last seen " with:@""];
			richPresence = [richPresence replace:@" playing " with:@"\n"];
		}
		richPresence = [richPresence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		richPresence = [richPresence replace:@"\n" with:statusNewlineReplacement];
		richPresence = [richPresence replace:@"   " with:@" "];


		XBFriend *theFriend = [XBFriend friendWithTag:gamertag tileURLString:gamertileURL statusString:status infoString:richPresence];

		if (demoMode) {
		
			if ([status isEqualToString:@"Pending"]) {
				[friends insertObject:theFriend atIndex:0];
				continue;
			}
			
			if (![status isEqualToString:@"Offline"]) {
				[friends insertObject:theFriend atIndex:1];
				continue;
			}
		}


		[friends addObject:theFriend];

	
	}


	return [friends copy];
}


@end


















