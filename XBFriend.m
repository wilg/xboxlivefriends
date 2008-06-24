//
//  XBFriend.m
//  Xbox Live Friends
//
//  Copyright 2006 mindquirk software. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "XBFriend.h"

NSString *halo2StatsURL = @"http://www.bungie.net/Stats/PlayerStats.aspx?player=";


@implementation XBFriend

- (id)initWithTag:(NSString *)aTag tileURLString:(NSString *)aTile statusString:(NSString *)aStatus infoString:(NSString *)anInfo
{
	if (![super init])
	return nil;

	gamertag = aTag;
	status = aStatus;
	if (aTile != nil)
		tileURL = [NSURL URLWithString:aTile];
	info = anInfo;
	realName = nil;
	isSelectedRow = NO;
	displaysInKeyWindow = NO;
		
	[realName retain];
	[gamertag retain];
	[status retain];
	[tileURL retain];
	[info retain];

	return self;
}

- (NSDictionary *)tableViewRecord
{
	NSMutableDictionary *record = [NSMutableDictionary dictionary];
	
	NSString *theGT = [self realNameWithFormat:XBUnknownNameDisplayStyle];
	NSString *myInfo = [self info];
		
	if ([[self status] isEqual:@"Online"])
		[record setObject:[NSImage imageNamed:@"green_bead"] forKey:@"bead"];

	if ([[self status] isEqual:@"Busy"])
		[record setObject:[NSImage imageNamed:@"yellow_bead"] forKey:@"bead"];
	
	if ([[self status] isEqual:@"Away"])
		[record setObject:[NSImage imageNamed:@"red_bead"] forKey:@"bead"];
	
	if ([[self status] isEqual:@"Pending"])
		[record setObject:[NSImage imageNamed:@"blue_bead"] forKey:@"bead"];
		
	[record setObject:[self tileImageWithOfflineGrayedOut] forKey:@"tile"];
	[record setObject:[NSDictionary dictionaryWithObjectsAndKeys:theGT, @"gamertag", myInfo,  @"textstatus", [self status], @"onlinestatus", nil] forKey:@"gt_and_status"];
	[record setObject:theGT forKey:@"gt"];

	return record;
}

- (NSImage *)tileImage
{	
	int selectedIconStyle = [self iconStyle];
	
	NSImage *theTile;
	if(selectedIconStyle == XBNoneIconStyle){
		theTile = [NSImage imageNamed:@"empty"];
	}
	
	if(selectedIconStyle == XBHalo2IconStyle){
		selectedIconStyle = XBGamerPictureIconStyle;
	}
	if(selectedIconStyle == XBAddressBookIconStyle){
		theTile = [XBFriendDefaultsManager addressBookImageForPerson:[self realName]];
		if (!theTile)
			[self setIconStyle:XBGamerPictureIconStyle];
	}
	if(selectedIconStyle == XBGamerPictureIconStyle){
		if ([[[self tileURL] absoluteString] rangeOfString:@"QuestionMark32x32.jpg"].location != NSNotFound)
			theTile = [NSImage imageNamed:@"defaultfriend"];
		else
			theTile = [[[NSImage alloc] initWithContentsOfURL:[self tileURL]] autorelease];
	}
	
	if (theTile == nil)
		theTile = [NSImage imageNamed:@"empty"];
	
	return theTile;
}

- (NSImage *)tileImageWithOfflineGrayedOut
{
	NSImage *theTile = [self tileImage];
	
	if (![[self status] isEqual:@"Offline"])
		return theTile;
	if ([[theTile name] isEqual:@"empty"])
		return theTile;
	if ([[theTile name] isEqual:@"loadingBorder"])
		return theTile;
	if ([[theTile name] isEqual:@"unknown"])
		return theTile;
	
	NSImage *dimmedImage = [[[NSImage alloc] initWithSize:[theTile size]] autorelease];
	[dimmedImage lockFocus];
	[theTile compositeToPoint:NSMakePoint(0.0, 0.0) fromRect:NSMakeRect(0.0, 0.0, [theTile size].width, [theTile size].height) operation:NSCompositeSourceOver fraction:0.4];
	[dimmedImage unlockFocus];

	return dimmedImage;
}


- (NSString *)gamertag
{
	return gamertag;
}

- (NSString *)urlEscapedGamertag
{
	NSMutableString *mutableGamerTag = [[[self gamertag] mutableCopy] autorelease];
	[mutableGamerTag replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutableGamerTag length])];
	return [[mutableGamerTag copy] autorelease];
}


- (NSString *)status
{
	return status;
}

- (NSURL *)tileURL
{
	return tileURL;
}

- (NSString *)realName
{
	realName = [XBFriendDefaultsManager realNameForTag:[self gamertag]];
	return realName;
}

- (NSString *)realNameWithFormat:(XBNameDisplayStyle)theSpecifiedFormat
{

	NSString *theFormattedName = [self gamertag];
	int userNamePref;
	if (theSpecifiedFormat == XBUnknownNameDisplayStyle){
		NSNumber *styleNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"nameDisplayStyle"];
		if (styleNumber == nil)
			userNamePref = XBRealNameDisplayStyle;
		else
			userNamePref = [styleNumber intValue];
	}
	else
		userNamePref = theSpecifiedFormat;
	
	if ([self realName] != nil){
		if ([[self realName]  isNotEqualTo:@""]){
			if ([[self realName]  isNotEqualTo:@" "]){
				if ([[self realName]  length] >= 1){
					if (userNamePref == XBRealNameDisplayStyle)
						theFormattedName = [self realName];
					if (userNamePref == XBRealGamertagNameDisplayStyle)
						theFormattedName = [NSString stringWithFormat:@"%@ (%@)", [self realName], [self gamertag]];
					if (userNamePref == XBGamertagRealNameDisplayStyle)
						theFormattedName = [NSString stringWithFormat:@"%@ (%@)", [self gamertag], [self realName]];
					if (userNamePref == XBGamertagNameDisplayStyle)
						theFormattedName = [self gamertag];
				}
			}
		}
	}
	return theFormattedName;
}


- (void)setRealName:(NSString *)rn
{
	[XBFriendDefaultsManager setRealName:rn forTag:[self gamertag]];
}

- (int)iconStyle
{
	return [XBFriendDefaultsManager iconStyleForTag:[self gamertag]];
}

- (void)setIconStyle:(int)style
{
	[XBFriendDefaultsManager setIconStyle:style forTag:[self gamertag]];
}

- (BOOL)shouldShowNotifications
{
	shouldShowNotifications = [XBFriendDefaultsManager shouldShowNotificationsForTag:[self gamertag]];
	return shouldShowNotifications;
}

- (void)setShouldShowNotifications:(int)not
{
	[XBFriendDefaultsManager setShouldShowNotifications:not forTag:[self gamertag]];
}

- (int)requestType
{
	int type;
	if ([[self status] isEqual:@"Pending"]) {
		if ([info rangeOfString:@"wants to be your friend"].location != NSNotFound)
			type = XBTheySentFriendRequestType;
		else
			type = XBYouSentFriendRequestType;
	}
	else
		type = XBNoFriendRequestType;
		
	return type;
}

- (NSString *)info
{
	NSString *myStatus = [self status];
	NSMutableString *myInfo = [info mutableCopy];

	if ([myStatus isEqual:@"Busy"]){
		if ([myInfo rangeOfString:@"ago"].location != NSNotFound ) {
			[myInfo replaceOccurrencesOfString:@" minutes ago" withString:@"min)" options:0 range:NSMakeRange(0, [myInfo length])];
			[myInfo replaceOccurrencesOfString:@" minute ago" withString:@"min)" options:0 range:NSMakeRange(0, [myInfo length])];
			[myInfo replaceOccurrencesOfString:@" hours ago" withString:@"hrs)" options:0 range:NSMakeRange(0, [myInfo length])];
			[myInfo replaceOccurrencesOfString:@" hour ago" withString:@"hr)" options:0 range:NSMakeRange(0, [myInfo length])];
			myInfo = [NSString stringWithFormat:@"%@%@", @"Busy (", myInfo];
		}
		else {
			myInfo = [NSString stringWithFormat:@"%@%@", @"Busy - ", myInfo];
		}
	}
	
	if ([myStatus isEqual:@"Away"]) {
		if ([myInfo rangeOfString:@"ago"].location != NSNotFound ) {
			[myInfo replaceOccurrencesOfString:@" minutes ago" withString:@"min)" options:0 range:NSMakeRange(0, [myInfo length])];
			[myInfo replaceOccurrencesOfString:@" minute ago" withString:@"min)" options:0 range:NSMakeRange(0, [myInfo length])];
			[myInfo replaceOccurrencesOfString:@" hours ago" withString:@"hrs)" options:0 range:NSMakeRange(0, [myInfo length])];
			[myInfo replaceOccurrencesOfString:@" hour ago" withString:@"hr)" options:0 range:NSMakeRange(0, [myInfo length])];
			myInfo = [NSString stringWithFormat:@"%@%@", @"Away (", myInfo];
		}
		else {
			myInfo = [NSString stringWithFormat:@"%@%@", @"Away - ", myInfo];
		}
		
	}
	
	if ([self requestType] == XBTheySentFriendRequestType)
		myInfo = @"Wants To Be Your Friend";
	else if ([self requestType] == XBYouSentFriendRequestType)
		myInfo = @"Friend Request Sent";
	
	return [NSString stringWithFormat:@"%@%@", @"", [[myInfo copy] autorelease]];

}

- (BOOL)isSelectedRow
{
	return isSelectedRow;
}

- (void)setIsSelectedRow:(BOOL)x
{
	isSelectedRow = x;
}

- (BOOL)displaysInKeyWindow
{
	return displaysInKeyWindow;
}

- (void)setDisplaysInKeyWindow:(BOOL)x
{
	displaysInKeyWindow = x;
}

- (BOOL)haloEmblem
{
	return NO;
}

- (BOOL)currentGameHasChangedFromFriend:(XBFriend *)oldFriend
{

	if ([[self status] isNotEqualTo:@"Online"]) {
		return FALSE;
	}

	if ([[self info]  isEqual:[oldFriend info]]) {
		return FALSE;
	}

	return TRUE;
}

- (BOOL)statusHasChangedFromFriend:(XBFriend *)oldFriend
{	
	if ([[self status] isEqual:[oldFriend status]]) {
		return FALSE;
	}
	return TRUE;
}


+ (id)friendWithTag:(NSString *)aTag tileURLString:(NSString *)aTile statusString:(NSString *)aStatus infoString:(NSString *)anInfo
{
	return [[[XBFriend alloc] initWithTag:aTag tileURLString:aTile statusString:aStatus infoString:anInfo] autorelease];
}

+ (id)friendWithTag:(NSString *)aTag
{
	return [[[XBFriend alloc] initWithTag:aTag tileURLString:nil statusString:nil infoString:nil] autorelease];
}

@end
