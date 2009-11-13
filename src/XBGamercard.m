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

	NSString *editString = [NSString stringWithContentsOfURL:URL];
	
	NSString *thisGamertag = [MQFunctions cropString:editString between:@"myXboxAvatarCard_gamertagLabel\">" and:@"</span>"];
	if (thisGamertag)
		gamertag = thisGamertag;
	else {
		gamertag = nil;
		return;
	}
	
	//find motto
	motto = [MQFunctions cropString:editString between:@"myXboxAvatarCard_mottoLabel\">" and:@"</span>"];

	intGamerscore = [[MQFunctions cropString:editString between:@"myXboxAvatarCard_gamerscoreLabel\">" and:@"</span>"] intValue];
	gamerscore = [MQFunctions stringWithThousandSeperatorFromInt:intGamerscore];
	
	//find tile
//	NSString *tile_tag = [MQFunctions cropString:editString between:@"class=\"XbcGamercardGamertile\" height=\"64\" width=\"64\"" and:@"/>"];
//	gamertile = [NSURL URLWithString:[MQFunctions cropString:tile_tag between:@"src=\"" and:@"\""]];
	gamertile = [NSURL URLWithString:[NSString stringWithFormat:@"http://avatar.xboxlive.com/avatar/%@/avatarpic-l.png", thisGamertag]];

	gamerzone = [MQFunctions cropString:editString between:@"Zone:</span><span class=\"XbcFloatRightAlignRight\">" and:@"</span>"];

	bio = [MQFunctions cropString:editString between:@"ctl00_MainContent_myXboxAvatarCard_profileInfoPopOver_bioFlyoutLabel\" class=\"XbcProfileInfoText\">" and:@"</span>"];
	bio = [bio replace:@"&amp;" with:@"&"];
	bio = [bio replace:@"&quot;" with:@"\""];

	location = [MQFunctions cropString:editString between:@"ctl00_MainContent_myXboxAvatarCard_profileInfoPopOver_locationLabel\" class=\"XbcProfileInfoText\">" and:@"</span>"];
	location = [location replace:@"&amp;" with:@"&"];
	location = [location replace:@"&quot;" with:@"\""];

	realName = [MQFunctions cropString:editString between:@"ctl00_MainContent_myXboxAvatarCard_profileInfoPopOver_nameLabel\" class=\"XbcProfileInfoText\">" and:@"</span>"];
	realName = [realName replace:@"&amp;" with:@"&"];
	realName = [realName replace:@"&quot;" with:@"\""];

	//find rep
	NSString *repNumerator = [MQFunctions cropString:editString between:@"MyXbox/repstars" and:@"."];
	rep = [repNumerator floatValue] / 20.0;
	
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
