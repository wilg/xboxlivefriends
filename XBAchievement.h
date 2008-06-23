//
//  XBGame.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 9/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XBAchievement : NSObject {

	NSString *gameID;
	NSString *title;
	NSString *subtitle;
	NSNumber *value;
	NSURL *tileURL;
	
	BOOL iHaveAchievement;
	BOOL theyHaveAchievement;

}

- (id)init;
- (void)dealloc;

- (void)determineAchievementSettingsFromMyValue:(NSNumber *)myValue theirValue:(NSNumber *)theirValue myTile:(NSString *)myTile theirTile:(NSString *)theirTile;

- (NSString *)gameID;
- (NSString *)title;
- (NSString *)subtitle;
- (NSNumber *)achievementValue;
- (NSURL *)tileURL;
- (BOOL)iHaveAchievement;
- (BOOL)theyHaveAchievement;

- (void)setGameID:(NSString *)x;
- (void)setTitle:(NSString *)x;
- (void)setSubtitle:(NSString *)x;
- (void)setAchievementValue:(NSNumber *)x;
- (void)setTileURL:(NSURL *)x;

- (void)setIHaveAchievement:(BOOL)x;
- (void)setTheyHaveAchievement:(BOOL)x;

+ (id)achievement;

@end;