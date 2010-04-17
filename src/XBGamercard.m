//
//  XBGamercard.m
//  Xbox Live Friends
//
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "XBGamercard.h"

#define PROFILE_URL @"http://live.xbox.com/en-US/default.aspx"
#define EDIT_PROFILE_URL @"https://live.xbox.com/en-US/signup/UIPStartPage.aspx?appid=xboxcom_gamerCard"
#define GAMERCARD_URL @"http://live.xbox.com/en-US/profile/profile.aspx?pp=0&GamerTag="
#define SHELLGAMERCARD @"http://live.xbox.com/ShellGamercardV2.ashx"

//NSString* gamerCardURL = @"http://live.xbox.com/en-US/profile/profile.aspx?pp=0&GamerTag=";
//NSString* shellGamercard = @"http://live.xbox.com/ShellGamercardV2.ashx";
//NSString* profileURL = @"http://live.xbox.com/en-US/default.aspx";

@implementation XBGamercard

+ (XBGamercard *)cardForSelf
{
	return [[[XBGamercard alloc] initWithSelf] autorelease];
}

+ (XBGamercard *)cardForFriend:(XBFriend *)theFriend
{
	return [[[XBGamercard alloc] initWithFriend:theFriend] autorelease];
}

+ (XBGamercard *)cardForURL:(NSURL *)theURL;
{
	return [[[XBGamercard alloc] initWithURL:theURL] autorelease];
}

- (id)initWithSelf
{
	if (![super init]) {
		return nil;
	}
	
	[self fetchSelf];
	
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

- (id)initWithFriend:(XBFriend *)theFriend
{
	if (![super init])
	return nil;

	[self fetchWithTag:[theFriend urlEscapedGamertag]];
	//[self fetchFriend:theFriend];
	
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

- (void)fetchSelf
{
	// We can find out if we are a gold member from the shellGamercard.
	NSString *shellCard = [NSString stringWithContentsOfURL:[NSURL URLWithString:SHELLGAMERCARD] encoding:NSUTF8StringEncoding error:nil];
	NSString *profileSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:PROFILE_URL] encoding:NSUTF8StringEncoding error:nil];
	// Fetching the extra source takes its time, so will leave it out till we need it.
	//NSString *editProfileSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:EDIT_PROFILE_URL] encoding:NSUTF8StringEncoding error:nil];
	
	gamertag = [shellCard cropFrom:@"<p><a href=\"http://live.xbox.com/en-US/default.aspx\">" to:@"</a>"];
	
	NSString *tileURL = [shellCard cropFrom:@"default.aspx\"><img src=\"" to:@"\""];
	gamertile = [NSURL URLWithString:tileURL];
	
	gamerscore = [shellCard cropFrom:@"\"PointsIcon\" /><span> " to:@"</span>"];
	
	motto = [profileSource cropFrom:@"<span id=\"ctl00_MainContent_myXboxAvatarCard_mottoLabel\">" to:@"</span>"];
	
	/*
	bio = [editProfileSource cropFrom:@"class=\"XbcPersonalProfile\">" to:@"</textarea>"];
	location = [editProfileSource cropFrom:@"ctl00$MainContent$personalProfile$ctl01$txtLocation\" type=\"text\" value=\"" to:@"\""];
	realName = [editProfileSource cropFrom:@"\"ctl00$MainContent$personalProfile$ctl01$txtName\" type=\"text\" value=\"" to:@"\""];
	*/
	bio = @"";
	location = @"";
	realName = @"";
	
	// gamerzone can't be found anywhere anymore?
}

- (void)fetchFriend:(XBFriend *)theFriend
{
	NSString *editString = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", GAMERCARD_URL, [theFriend urlEscapedGamertag]]] encoding:NSUTF8StringEncoding error:nil];
	
	gamertag = [theFriend gamertag];
	
	motto = [editString cropFrom:@"myXboxAvatarCard_mottoLabel\">" to:@"</span>"];
	
	intGamerscore = [[MQFunctions cropString:editString between:@"myXboxAvatarCard_gamerscoreLabel\">" and:@"</span>"] intValue];
	gamerscore = [MQFunctions stringWithThousandSeperatorFromInt:intGamerscore];
	
	// Why is this (null)?
	gamertile = [theFriend tileURL];
	
	gamerzone = [MQFunctions cropString:editString between:@"Zone:</span><span class=\"XbcFloatRightAlignRight\">" and:@"</span>"];
	
	bio = [MQFunctions cropString:editString between:@"ctl00_MainContent_myXboxAvatarCard_profileInfoPopOver_bioFlyoutLabel\" class=\"XbcProfileInfoText\">" and:@"</span>"];
	bio = [MQFunctions flattenHTML:bio];
	
	location = [MQFunctions cropString:editString between:@"ctl00_MainContent_myXboxAvatarCard_profileInfoPopOver_locationLabel\" class=\"XbcProfileInfoText\">" and:@"</span>"];
	location = [MQFunctions flattenHTML:location];
	
	realName = [MQFunctions cropString:editString between:@"ctl00_MainContent_myXboxAvatarCard_profileInfoPopOver_nameLabel\" class=\"XbcProfileInfoText\">" and:@"</span>"];
	realName = [MQFunctions flattenHTML:realName];
	
	//find rep
	NSString *repNumerator = [MQFunctions cropString:editString between:@"MyXbox/repstars" and:@"."];
	rep = [repNumerator floatValue] / 20.0;
	
	//Get golden repstars
	NSString *repStarsURL = [NSString stringWithFormat:@"http://live.xbox.com/xweb/lib/images/MyXbox/repstars%@.png", repNumerator];
	repStars = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:repStarsURL]];
	
}

- (void)fetchWithTag:(NSString *)escapedTag
{
	[self fetchWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", GAMERCARD_URL, escapedTag]]];
}

- (void)fetchWithURL:(NSURL *)URL
{

	NSString *editString = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];
	
	NSString *thisGamertag = [MQFunctions cropString:editString between:@"myXboxAvatarCard_gamertagLabel\">" and:@"</span>"];
	NSString *urlGamertag = [thisGamertag replace:@" " with:@"%20"];
	if (thisGamertag) {
		gamertag = thisGamertag;
	}
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
	gamertile = [NSURL URLWithString:[NSString stringWithFormat:@"http://avatar.xboxlive.com/avatar/%@/avatarpic-l.png", urlGamertag]];

	gamerzone = [MQFunctions cropString:editString between:@"Zone:</span><span class=\"XbcFloatRightAlignRight\">" and:@"</span>"];

	bio = [MQFunctions cropString:editString between:@"ctl00_MainContent_myXboxAvatarCard_profileInfoPopOver_bioFlyoutLabel\" class=\"XbcProfileInfoText\">" and:@"</span>"];
	bio = [MQFunctions flattenHTML:bio];
	/*
	bio = [bio replace:@"&amp;" with:@"&"];
	bio = [bio replace:@"&quot;" with:@"\""];
	 */
	 
	location = [MQFunctions cropString:editString between:@"ctl00_MainContent_myXboxAvatarCard_profileInfoPopOver_locationLabel\" class=\"XbcProfileInfoText\">" and:@"</span>"];
	location = [MQFunctions flattenHTML:location];
	/*
	location = [location replace:@"&amp;" with:@"&"];
	location = [location replace:@"&quot;" with:@"\""];
	 */
	 
	realName = [MQFunctions cropString:editString between:@"ctl00_MainContent_myXboxAvatarCard_profileInfoPopOver_nameLabel\" class=\"XbcProfileInfoText\">" and:@"</span>"];
	realName = [MQFunctions flattenHTML:realName];
	/*
	realName = [realName replace:@"&amp;" with:@"&"];
	realName = [realName replace:@"&quot;" with:@"\""];
	 */

	//find rep
	NSString *repNumerator = [MQFunctions cropString:editString between:@"MyXbox/repstars" and:@"."];
	rep = [repNumerator floatValue] / 20.0;
	
	//Get golden repstars
	NSString *repStarsURL = [NSString stringWithFormat:@"http://live.xbox.com/xweb/lib/images/MyXbox/repstars%@.png", repNumerator];
	repStars = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:repStarsURL]];
	
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

- (NSImage *)repStars
{
	return repStars;
}

- (float)rep
{
	return rep;
}


@end
