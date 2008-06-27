//
//  XBGame.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 9/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XBGame : NSObject {

	NSString *gameID;
	NSString *name;
	NSString *yourScore;
	NSString *theirScore;
	NSURL *tileURL;
	NSString *yourAchievementCount;
	NSString *theirAchievementCount;
	
	BOOL isJustMe;
}

@property(assign) BOOL isJustMe;

- (id)init;

- (NSString *)description;

- (NSString *)gameID;
- (NSString *)name;
- (NSString *)yourScore;
- (NSString *)theirScore;
- (NSURL *)tileURL;
- (NSString *)yourAchievementCount;
- (NSString *)theirAchievementCount;


- (void)setGameID:(NSString *)x;
- (void)setName:(NSString *)x;
- (void)setYourScore:(NSString *)x;
- (void)setTheirScore:(NSString *)x;
- (void)setTileURL:(NSURL *)x;
- (void)setYourAchievementCount:(NSString *)x;
- (void)setTheirAchievementCount:(NSString *)x;

+ (id)game;

@end;