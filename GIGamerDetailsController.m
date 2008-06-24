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


@implementation GIGamerDetailsController

- (NSString *)notificationName
{
	return @"GIDetailsLoadNotification";
}

- (void)clearTab {
	[bio setStringValue:@""];
	[location setStringValue:@""];
	[name setStringValue:@""];
	
	[zone setStringValue:@""];
	[reputation setReputationPercentage:0];
}

- (void)displayGamerInfo:(NSString *)gamertag
{
	XBGamercard *gamercard = [XBGamercard cardForFriend:[XBFriend friendWithTag:gamertag]];
	[bio setStringValue:[gamercard bio]];
	[location setStringValue:[gamercard location]];
	[name setStringValue:[gamercard realName]];
	
	[zone setStringValue:[gamercard gamerzone]];
	[reputation setReputationPercentage:[gamercard rep]];
}

@end
