//
//  XBFriendsList.h
//  XBFriendsList
//
//  Copyright 2006 mindquirk. All rights reserved.
//
#import <Cocoa/Cocoa.h>

@interface FriendsListParser : NSObject {
//	NSArray *friends;
	
}

+ (NSArray *)friends;
+ (NSArray *)friendsWithSource:(NSString *)string;

//- (BOOL)populate;
//- (void)populateWithSource:(NSString *)string;
//
//- (NSArray *)friends;

@end