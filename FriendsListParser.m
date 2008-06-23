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
	
	for (NSString *row in rows) {
		
		if (![row contains:@"GamerTag="])
			continue;
	
		NSString *gamertag = [row cropFrom:@"GamerTag=" to:@"\""];
		gamertag = [gamertag replace:@"+" with:@" "];
	
		NSString *gamertileURL = [row cropFrom:@"GamerTile\"><img width=\"32\" height=\"32\" src=\"" to:@"\""];
		if ([gamertileURL contains:@"QuestionMark32x32.jpg"])
			gamertileURL = @"http://live.xbox.com/xweb/lib/images/QuestionMark32x32.jpg";

		NSString *status = [row cropFrom:@"headers=\"Status\">" to:@"</"];
		status = [status cropFrom:@">" to:nil];
	
		NSString *richPresence = [row cropFrom:@"headers=\"Info\"><p>" to:@"</p></td>"];
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
		[friends addObject:theFriend];

	
	}


	return [friends copy];
}


@end


















