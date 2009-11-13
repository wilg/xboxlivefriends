//
//  GITabController.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 5/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GITabController : NSObject {
	id lastFetch;
	NSString *lastFetchTag;
	NSString *errorForTab;
}

@property(copy) NSString *lastFetchTag;
@property(copy) NSString *errorForTab;
@property(copy) id lastFetch;
- (void)clearErrorForTab;

- (NSString *)notificationName;
- (BOOL)postsDoneNotificationAutomatically;
- (BOOL)threadedLoad;
- (void)loadingComplete;
- (void)displayGamerInfo:(NSString *)gamertag;
- (void)clearTab;
- (void)tabBecameVisible;

@end
