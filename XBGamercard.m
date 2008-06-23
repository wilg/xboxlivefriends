//
//  XBGamercard.m
//  Xbox Live Friends
//
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "XBGamercard.h"

NSString* gamerCardURL = @"http://live.xbox.com/en-US/profile/profile.aspx?pp=0&GamerTag=";

@implementation XBGamercard

+ (XBGamercard *)cardForFriend:(XBFriend *)theFriend
{
	return [[[XBGamercard alloc] initWithFriend:theFriend] autorelease];
}

+ (XBGamercard *)cardForURL:(NSURL *)theURL;
{
	return [[[XBGamercard alloc] initWithURL:theURL] autorelease];
}

- (id)initWithFriend:(XBFriend *)theFriend
{
	if (![super init])
	return nil;

	[self fetchWithTag:[theFriend urlEscapedGamertag]];
	
	[gamertag retain];
	[motto retain];
	[gamerscore retain];
	[gamertile retain];
	[gamerzone retain];
	[bio retain];
	[realName retain];
	[location retain];

	return self;
}

- (id)initWithURL:(NSURL *)theURL
{
	if (![super init])
	return nil;

	[self fetchWithURL:theURL];
	
	[gamertag retain];
	[motto retain];
	[gamerscore retain];
	[gamertile retain];
	[gamerzone retain];
	[bio retain];
	[realName retain];
	[location retain];

	return self;
}

- (void)dealloc
{
	[gamertag release];
	[motto release];
	[gamerscore release];
	[gamertile release];
	[gamerzone release];
	[bio release];
	[realName release];
	[location release];
    [super dealloc]; 
}


- (void)fetchWithTag:(NSString *)escapedTag
{
	[self fetchWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", gamerCardURL, escapedTag]]];
}

- (void)fetchWithURL:(NSURL *)URL
{
	[MQFunctions debugLog:@"fetchWithURL"];

	NSString *editString = [NSString stringWithContentsOfURL:URL];
	
	[MQFunctions debugLog:@"Finding Gamertag..."];
	NSString *thisGamertag = [MQFunctions cropString:editString between:@"<div class=\"XbcGamercardMe\">" and:@"</h3>"];
	if (thisGamertag)
		gamertag = [MQFunctions cropString:thisGamertag between:@"AlignLeft\">" and:@"</span>"];
	else {
		gamertag = nil;
		return;
	}
	
	[MQFunctions debugLog:@"Finding Motto..."];
	//find motto
	motto = [MQFunctions cropString:editString between:@"XbcGamercardMotto\"><p>" and:@"<br />"];

	[MQFunctions debugLog:@"Finding Gamerscore..."];
	intGamerscore = [[MQFunctions cropString:editString between:@"Gamerscore:</span><span class=\"XbcFloatRightAlignRight\">" and:@"</span>"] intValue];
	gamerscore = [MQFunctions stringWithThousandSeperatorFromInt:intGamerscore];
	
	[MQFunctions debugLog:@"Finding Gamertile..."];
	//find tile
	NSString *tile_tag = [MQFunctions cropString:editString between:@"class=\"XbcGamercardGamertile\" height=\"64\" width=\"64\"" and:@"/>"];
	gamertile = [NSURL URLWithString:[MQFunctions cropString:tile_tag between:@"src=\"" and:@"\""]];
	
	[MQFunctions debugLog:@"Finding Gamerzone..."];
	gamerzone = [MQFunctions cropString:editString between:@"Zone:</span><span class=\"XbcFloatRightAlignRight\">" and:@"</span>"];

	[MQFunctions debugLog:@"Finding Bio..."];
	bio = [MQFunctions cropString:editString between:@"Bio</h6><p class=\"XbcProfileForceWordWrap\">" and:@"</p>"];

	[MQFunctions debugLog:@"Finding Location..."];
	location = [MQFunctions cropString:editString between:@"Location</h6><p class=\"XbcProfileForceWordWrap\">" and:@"</p>"];

	[MQFunctions debugLog:@"Finding realName..."];
	realName = [MQFunctions cropString:editString between:@"Name</h6><p class=\"XbcProfileForceWordWrap\">" and:@"</p>"];

	[MQFunctions debugLog:@"Finding Reputation..."];
	//find rep
	NSString *repNumerator = [MQFunctions cropString:editString between:@"Reputation:</span><span class=\"XbcFloatRightAlignRight\"><img src=\"/xweb/lib/images/gc_repstars_meyou_" and:@".gif"];
	rep = [repNumerator floatValue] / 20.0;
	
	[MQFunctions debugLog:@"Gamercard Fetched"];
}

- (NSString *)gamertag
{
	return gamertag;
}

- (NSString *)motto
{
	return motto;
}

- (NSString *)bio
{
	return bio;
}

- (NSString *)realName
{
	return realName;
}

- (NSString *)location
{
	return location;
}

- (NSString *)gamerscore
{
	return gamerscore;
}


- (int)gamerscoreAsInt
{
	return intGamerscore;
}

- (NSURL *)gamertileURL
{
	return gamertile;
}

- (NSImage *)gamertileImage
{	
	return [[[NSImage alloc] initWithContentsOfURL:[self gamertileURL]] autorelease];
}

- (NSString *)gamerzone
{
	return gamerzone;
}

- (float)rep
{
	return rep;
}


@end
