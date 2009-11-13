//
//  XBGame.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 9/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "XBAchievement.h"


@implementation XBAchievement
@synthesize isJustMe;

- (id)init
{
	if (![super init])
	return nil;

	gameID = nil;
	title = nil;
	subtitle = nil;
	value = nil;
	tileURL = nil;
	
//	iHaveAchievement = nil;
//	theyHaveAchievement = nil;

	self.isJustMe = NO;
	
	[title retain];
	[gameID retain];
	[subtitle retain];
	[tileURL retain];

	return self;
}

- (void)dealloc
{
    [title release];
    [gameID release];
    [subtitle release];
	[tileURL release];
    [super dealloc]; 
}

- (void)determineAchievementSettingsFromMyValue:(NSNumber *)myValue theirValue:(NSNumber *)theirValue myTile:(NSString *)myTile theirTile:(NSString *)theirTile {
	if (myValue == nil && theirValue == nil) {
		[self setAchievementValue:nil];
		[self setTileURL:[NSURL URLWithString:myTile]];
		iHaveAchievement = NO;
		theyHaveAchievement = NO;
	}
	else if (myValue != nil && theirValue == nil) {
		[self setAchievementValue:myValue];
		[self setTileURL:[NSURL URLWithString:myTile]];
		iHaveAchievement = YES;
		theyHaveAchievement = NO;
	}
	else if (theirValue != nil && myValue == nil) {
		[self setAchievementValue:theirValue];
		[self setTileURL:[NSURL URLWithString:theirTile]];
		iHaveAchievement = NO;
		theyHaveAchievement = YES;
	}
	else if (theirValue != nil && myValue != nil) {
		[self setAchievementValue:myValue];
		[self setTileURL:[NSURL URLWithString:myTile]];
		iHaveAchievement = YES;
		theyHaveAchievement = YES;
	}
}

- (NSString *)gameID
{
	return gameID;
}


- (NSString *)title
{
	return title;
}

- (NSString *)subtitle
{
	return subtitle;
}

- (NSNumber *)achievementValue
{
	return value;
}

- (NSURL *)tileURL
{
	return tileURL;
}

- (BOOL)iHaveAchievement
{
	return iHaveAchievement;
}

- (BOOL)theyHaveAchievement
{
	return theyHaveAchievement;
}


- (void)setGameID:(NSString *)x
{
	gameID = x;
}


- (void)setTitle:(NSString *)x
{
	title = x;
}

- (void)setSubtitle:(NSString *)x
{
	subtitle = x;
}



- (void)setAchievementValue:(NSNumber *)x
{
	value = x;
}

- (void)setTileURL:(NSURL *)x
{
	tileURL = x;
}


- (void)setIHaveAchievement:(BOOL)x
{
	iHaveAchievement = x;
}


- (void)setTheyHaveAchievement:(BOOL)x
{
	theyHaveAchievement = x;
}




+ (id)achievement
{
	return [[XBAchievement alloc] init];
}

@end
