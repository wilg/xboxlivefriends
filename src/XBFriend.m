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

- (id)initWithTag:(NSString *)aTag tileURLString:(NSString *)aTile statusString:(NSString *)aStatus infoString:(NSString *)anInfo {
	if (![super init])
	return nil;

	gamertag = aTag;
	status = aStatus;
	if (aTile != nil) {
		tileURLString = aTile;
		tileURL = [NSURL URLWithString:aTile];
	}
	info = anInfo;
	realName = nil;
	isSelectedRow = NO;
	displaysInKeyWindow = NO;
		
	return self;
}

- (NSDictionary *)tableViewRecord {

	NSMutableDictionary *record = [NSMutableDictionary dictionary];
	
	NSString *myInfo = [self info];
	
	NSString *primaryTitle;
	NSString *secondaryTitle;
	
	XBNameDisplayStyle displayStyle = [XBFriend preferredNameStyle];

	if ([self realName]){
		if (displayStyle == XBRealNameDisplayStyle) {
			primaryTitle = [self realName];
			secondaryTitle = nil;
		}
		if (displayStyle == XBRealGamertagNameDisplayStyle) {
			primaryTitle = [self realName];
			secondaryTitle = [self gamertag];
		}
		if (displayStyle == XBGamertagRealNameDisplayStyle) {
			primaryTitle = [self gamertag];
			secondaryTitle = [self realName];
		}
		if (displayStyle == XBGamertagNameDisplayStyle) {
			primaryTitle = [self gamertag];
			secondaryTitle = nil;
		}
	}
	else {
		primaryTitle = [self gamertag];
		secondaryTitle = nil;
	}


	[record setObject:[self bead] forKey:@"bead"];	
	[record setObject:[self tileImageWithOfflineGrayedOut] forKey:@"tile"];
	[record setObject:[NSDictionary dictionaryWithObjectsAndKeys:[self realNameWithFormat:XBUnknownNameDisplayStyle], @"gamertag", myInfo,  @"textstatus", [self status], @"onlinestatus", primaryTitle, @"primaryTitle", secondaryTitle, @"secondaryTitle", nil] forKey:@"gt_and_status"];
	return record;
}

- (NSDictionary *)tableViewRecordWithZone {
	
	NSMutableDictionary *record = [NSMutableDictionary dictionary];
	
	NSString *myInfo = [self info];
	
	NSString *primaryTitle;
	NSString *secondaryTitle;
	
	XBNameDisplayStyle displayStyle = [XBFriend preferredNameStyle];
	
	if ([self realName]){
		if (displayStyle == XBRealNameDisplayStyle) {
			primaryTitle = [self realName];
			secondaryTitle = nil;
		}
		if (displayStyle == XBRealGamertagNameDisplayStyle) {
			primaryTitle = [self realName];
			secondaryTitle = [self gamertag];
		}
		if (displayStyle == XBGamertagRealNameDisplayStyle) {
			primaryTitle = [self gamertag];
			secondaryTitle = [self realName];
		}
		if (displayStyle == XBGamertagNameDisplayStyle) {
			primaryTitle = [self gamertag];
			secondaryTitle = nil;
		}
	}
	else {
		primaryTitle = [self gamertag];
		secondaryTitle = nil;
	}
	
	
	[record setObject:[self bead] forKey:@"bead"];
	[record setObject:[self zone] forKey:@"zone"];
	[record setObject:[self tileImageWithOfflineGrayedOut] forKey:@"tile"];
	[record setObject:[NSDictionary dictionaryWithObjectsAndKeys:[self realNameWithFormat:XBUnknownNameDisplayStyle], @"gamertag", myInfo,  @"textstatus", [self status], @"onlinestatus", primaryTitle, @"primaryTitle", secondaryTitle, @"secondaryTitle", nil] forKey:@"gt_and_status"];
	return record;
}

- (NSAttributedString *)dockMenuString {
//	return @"FUCKK";
//	return [NSString stringWithFormat:@"%@ %@", self.gamertag, self.info];
	
	NSMutableDictionary *attributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
												[NSColor grayColor],NSForegroundColorAttributeName,
												[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize: NSSmallControlSize]],NSFontAttributeName,
												nil] autorelease];
	NSAttributedString *string = [[NSAttributedString alloc] initWithString:self.info attributes:attributes];
	
	return string;
	
	NSMutableAttributedString *gt = [[NSMutableAttributedString alloc] initWithString:self.gamertag];
	
	[gt appendAttributedString:string];
	
	return [gt copy];
}

- (NSImage *)bead {
	if ([self.status isEqual:@"Online"])
		return [NSImage imageNamed:@"green_bead"];

	else if ([self.status isEqual:@"Busy"])
		return [NSImage imageNamed:@"yellow_bead"];
	
	else if ([self.status isEqual:@"Away"])
		return [NSImage imageNamed:@"red_bead"];
	
	else if ([self.status isEqual:@"Pending"])
		return [NSImage imageNamed:@"blue_bead"];
	
	return [NSImage imageNamed:@"empty"];
}

- (NSImage *)tileImage {	
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

- (NSString *)description {
	return gamertag;
}


- (NSString *)gamertag
{
	return gamertag;
}

- (NSString *)urlEscapedGamertag {
	return [[self gamertag] replace:@" " with:@"%20"];
}


- (NSString *)status
{
	return status;
}

- (NSURL *)tileURL
{
	return tileURL;
}

- (NSString *)tileURLString
{
	return tileURLString;
}

- (NSString *)zone
{
	return zone;
}

- (void)setZone:(NSString *)theZone
{
	zone = theZone;
}

- (NSString *)realName {
	
	if (realName)
		return realName;
	
	NSString *name = [XBFriendDefaultsManager realNameForTag:[self gamertag]];
	if (name == nil || [name  isEqualToString:@""] || [name  isEqualToString:@" "] || [name  length] < 1)
		name = nil;
		
	realName = name;
	
	return name;
}

+ (XBNameDisplayStyle)preferredNameStyle {
	int userNamePref;
	NSNumber *styleNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"nameDisplayStyle"];
	if (styleNumber == nil)
		userNamePref = XBRealNameDisplayStyle;
	else
		userNamePref = [styleNumber intValue];
	return userNamePref;
}

- (NSString *)realNameWithFormat:(XBNameDisplayStyle)format {

	NSString *name = [self gamertag];
	
	if (!format || format == XBUnknownNameDisplayStyle){
		format = [XBFriend preferredNameStyle];
	}
	
	if ([self realName]){
		if (format == XBRealNameDisplayStyle)
			name = [self realName];
		if (format == XBRealGamertagNameDisplayStyle)
			name = [NSString stringWithFormat:@"%@ (%@)", [self realName], [self gamertag]];
		if (format == XBGamertagRealNameDisplayStyle)
			name = [NSString stringWithFormat:@"%@ (%@)", [self gamertag], [self realName]];
		if (format == XBGamertagNameDisplayStyle)
			name = [self gamertag];
	}
	
	return name;
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

- (NSString *)info {
	NSString *myStatus = [self status];
	NSString *myInfo = [[info copy] autorelease];

	if ([myStatus isEqual:@"Busy"]){
		if ([myInfo contains:@"ago"]) {
		
			myInfo = [myInfo replace:@" minutes ago" with:@"min)"];
			myInfo = [myInfo replace:@" minute ago" with:@"min)"];
			myInfo = [myInfo replace:@" hours ago" with:@"hrs)"];
			myInfo = [myInfo replace:@" hour ago" with:@"hrs)"];

			myInfo = [NSString stringWithFormat:@"%@%@", @"Busy (", myInfo];
		}
		else {
			myInfo = [NSString stringWithFormat:@"%@%@", @"Busy - ", myInfo];
		}
	}
	
	if ([myStatus isEqual:@"Away"]) {
		if ([myInfo contains:@"ago"] ) {
		
			myInfo = [myInfo replace:@" minutes ago" with:@"min)"];
			myInfo = [myInfo replace:@" minute ago" with:@"min)"];
			myInfo = [myInfo replace:@" hours ago" with:@"hrs)"];
			myInfo = [myInfo replace:@" hour ago" with:@"hrs)"];

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
	
	return myInfo;

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
