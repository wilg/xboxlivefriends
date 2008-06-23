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
	
	NSString *bio;
	NSString *realName;
	NSString *location;

}

- (id)initWithFriend:(XBFriend *)theFriend;
- (id)initWithURL:(NSURL *)theURL;

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
- (float)rep;

+ (XBGamercard *)cardForFriend:(XBFriend *)theFriend;
+ (XBGamercard *)cardForURL:(NSURL *)theURL;

@end
