//
//  XBLGamercard.h
//  Xbox Live Friends
//
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XBGamercard : NSObject {

	NSString *gamertag;
	NSString *motto;
	NSString *gamerscore;
	int intGamerscore;
	NSURL *gamertile;
	NSString *gamerzone;
	float rep;
	NSImage *repStars;
	
	NSString *bio;
	NSString *realName;
	NSString *location;

}

- (id)initWithSelf;
- (id)initWithFriend:(XBFriend *)theFriend;
- (id)initWithURL:(NSURL *)theURL;

- (void)fetchSelf;
- (void)retrieveEditProfileDetails;

- (void)fetchFriend:(XBFriend *)theFriend;
- (void)fetchWithTag:(NSString *)escapedTag;
- (void)fetchWithURL:(NSURL *)URL;

- (NSString *)gamertag;
- (NSString *)motto;
- (NSString *)gamerscore;
- (NSString *)bio;
- (NSString *)realName;
- (NSString *)location;
- (int)gamerscoreAsInt;
- (NSURL *)gamertileURL;
- (NSImage *)gamertileImage;
- (NSString *)gamerzone;
- (NSImage *)repStars;
- (float)rep;

+ (XBGamercard *)cardForSelf;
+ (XBGamercard *)cardForFriend:(XBFriend *)theFriend;
+ (XBGamercard *)cardForURL:(NSURL *)theURL;

@end
