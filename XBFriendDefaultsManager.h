//
//  XBFriendDefaultsManager.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/15/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	XBNoneIconStyle = 0,
	XBGamerPictureIconStyle = 1,
    XBHalo2IconStyle = 2,
    XBAddressBookIconStyle = 3
} XBIconStyle;

@interface XBFriendDefaultsManager : NSObject {

}

+ (NSImage *)addressBookImageForPerson:(NSString *)theName;


+ (void)setRealName:(NSString *)realName forTag:(NSString *)theTag;
+ (NSString *)realNameForTag:(NSString *)theTag;
+ (void)setIconStyle:(int)style forTag:(NSString *)theTag;
+ (int)iconStyleForTag:(NSString *)theTag;
+ (void)setShouldShowNotifications:(BOOL)theBool forTag:(NSString *)theTag;
+ (BOOL)shouldShowNotificationsForTag:(NSString *)theTag;


+ (NSMutableDictionary *)prefsDictionaryForTag:(NSString *)theTag;
+ (void)setPrefsDictionary:(NSMutableDictionary *)dict forTag:(NSString *)theTag;


+ (void)setupDefaults;

@end
