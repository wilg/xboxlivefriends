//
//  XBGame.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 9/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "XBGame.h"


@implementation XBGame
@synthesize isJustMe;

- (id)init
{
	if (![super init])
	return nil;

	name = nil;
	gameID = nil;
	yourScore = nil;
	theirScore = nil;
	tileURL = nil;
	yourAchievementCount = nil;
	theirAchievementCount = nil;
	
	[name retain];
	[gameID retain];
	[yourScore retain];
	[theirScore retain];
	[tileURL retain];
	[yourAchievementCount retain];
	[theirAchievementCount retain];

	return self;
}

- (void)dealloc
{
	[name release];
	[gameID release];
	[yourScore release];
	[theirScore release];
	[tileURL release];
	[yourAchievementCount release];
	[theirAchievementCount release];
    [super dealloc]; 
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"XBGame - name: %@ - gameID: %@ - yourScore: %@ - theirScore: %@ - tileURL: %@", name, gameID, yourScore, theirScore, [tileURL absoluteString]];
}

- (NSString *)gameID
{
	return gameID;
}


- (NSString *)name
{
	return name;
}

- (NSString *)yourScore
{
	return yourScore;
}


- (NSString *)theirScore
{
	return theirScore;
}


- (NSURL *)tileURL
{
	return tileURL;
}


- (NSString *)yourAchievementCount
{
	return yourAchievementCount;
}


- (NSString *)theirAchievementCount
{
	return theirAchievementCount;
}


- (void)setGameID:(NSString *)x
{
	[gameID release];
	gameID = [x retain];
}


- (void)setName:(NSString *)x
{
	[name release];
	name = [x retain];
}

- (void)setYourScore:(NSString *)x
{
	[yourScore release];
	yourScore = [x retain];
}


- (void)setTheirScore:(NSString *)x
{
	[theirScore release];
	theirScore = [x retain];
}


- (void)setTileURL:(NSURL *)x
{
	[tileURL release];
	tileURL = [x retain];
}


- (void)setYourAchievementCount:(NSString *)x
{
	[yourAchievementCount release];
	yourAchievementCount = [x retain];
}


- (void)setTheirAchievementCount:(NSString *)x
{
	[theirAchievementCount release];
	theirAchievementCount = [x retain];
}



+ (id)game
{
	return [[[XBGame alloc] init] retain];
}

@end
