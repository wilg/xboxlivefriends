//
//  XBFriend.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/13/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	XBRealNameDisplayStyle = 0,
	XBRealGamertagNameDisplayStyle = 1,
    XBGamertagRealNameDisplayStyle = 2,
	XBGamertagNameDisplayStyle = 3,
	XBUnknownNameDisplayStyle = 4,
} XBNameDisplayStyle;

typedef enum {
	XBNoFriendRequestType = 0,
	XBYouSentFriendRequestType = 1,
    XBTheySentFriendRequestType = 2,
} XBFriendRequestType;


@interface XBFriend : NSObject {

	NSString *gamertag;
	NSString *status;
	NSURL *tileURL;
	NSString *info;
	NSString *realName;
	float reputation;
	int iconStyle;
	BOOL shouldShowNotifications;
	BOOL isSelectedRow;
	BOOL displaysInKeyWindow;
}

- (id)initWithTag:(NSString *)aTag tileURLString:(NSString *)aTile statusString:(NSString *)aStatus infoString:(NSString *)anInfo;

- (NSString *)gamertag;
- (NSString *)urlEscapedGamertag;
- (NSString *)status;
- (NSURL *)tileURL;
- (NSString *)info;
- (NSDictionary *)tableViewRecord;
- (NSAttributedString *)dockMenuString;
- (NSImage *)bead;
- (NSImage *)tileImage;
- (NSImage *)tileImageWithOfflineGrayedOut;

- (NSString *)realName;
+ (XBNameDisplayStyle)preferredNameStyle;
- (NSString *)realNameWithFormat:(XBNameDisplayStyle)format;
- (void)setRealName:(NSString *)rn;
- (int)iconStyle;
- (void)setIconStyle:(int)style;
- (BOOL)shouldShowNotifications;
- (void)setShouldShowNotifications:(int)style;
- (int)requestType;

- (BOOL)isSelectedRow;
- (void)setIsSelectedRow:(BOOL)x;
- (BOOL)displaysInKeyWindow;
- (void)setDisplaysInKeyWindow:(BOOL)x;

- (BOOL)haloEmblem;
- (BOOL)currentGameHasChangedFromFriend:(XBFriend *)oldFriend;
- (BOOL)statusHasChangedFromFriend:(XBFriend *)oldFriend;

+ (id)friendWithTag:(NSString *)aTag tileURLString:(NSString *)aTile statusString:(NSString *)aStatus infoString:(NSString *)anInfo;
+ (id)friendWithTag:(NSString *)aTag;


@end
