//
//  GIGamerDetailsController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 5/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "GITabController.h"
#import "GIGamerDetailsController.h"
#import "LoginController.h"


@implementation GIGamerDetailsController

- (NSString *)notificationName
{
	return @"GIDetailsLoadNotification";
}

- (void)clearTab {
	[avatar setImageAlignment:NSImageAlignBottom];
	[avatar setImage:[NSImage imageNamed:@"no_avatar"]];
	[bio setStringValue:@""];
	[location setStringValue:@""];
	[name setStringValue:@""];
	[zone setStringValue:@""];
	[reputation setReputationPercentage:0];
	[repStars setImage:nil];
}

- (void)displayGamerInfo:(NSString *)gamertag
{
	//NSString *myTag = [LoginController myGamertag];
	
	XBFriend *theFriend = [XBFriend friendWithTag:gamertag];
	XBGamercard *gamercard = [XBGamercard cardForFriend:theFriend];
	
	/*
	if ([myTag isEqualToString:gamertag]) {
		gamercard = [XBGamercard cardForSelf];
		NSLog(@"Loading my tag: %@", [gamercard gamertag]);
	} else {
		gamercard = [XBGamercard cardForFriend:theFriend];
		NSLog(@"Gamertags not equal");
	}
	*/
	
	[bio setStringValue:[gamercard bio]];
	[location setStringValue:[gamercard location]];
	[name setStringValue:[gamercard realName]];
	//[zone setStringValue:[gamercard gamerzone]];
	[reputation setReputationPercentage:[gamercard rep]];
	[repStars setImage:[gamercard repStars]]; // Ruaridh
	
	NSImage *avatarImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://avatar.xboxlive.com/avatar/%@/avatar-body.png", [theFriend urlEscapedGamertag]]]];
	if (avatarImage)
		[avatar setImage:avatarImage];
}

@end
