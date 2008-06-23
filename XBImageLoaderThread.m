//
//  XBImageLoaderThread.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/19/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "XBImageLoaderThread.h"

BOOL shouldExit = NO;
BOOL shouldLoad = NO;


@implementation XBImageLoaderThread

+ (void)imageLoaderThread:(id)anObject
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	
	// Start the run loop.
	NSDate*    endDate = [NSDate distantFuture];
	do
	{
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
		
		if ([self shouldLoad]){
//			//load messages
//			[[XBMessageCenterController sharedInstance] loadMessageCenter];
//		
//			//cycle through all friends who are set to download halo emblems
//			NSArray *friends = [[Controller friendsListObject] friends];
//			int i;
//			for (i = 0; i < [friends count]; i++) {
//				XBFriend *curFriend = [[[Controller friendsListObject] friends] objectAtIndex:i];
//				if ([curFriend iconStyle] == XBHalo2IconStyle){
//					if ([curFriend haloEmblem]) //returns true if did load
//						[[Controller sharedInstance] refreshFriendsList:NO];
//				}
//			}
//			[self setShouldLoad:NO];
		}

	}
	while (![self shouldExit]);

	[pool release];
}

+ (BOOL)shouldExit {

	return shouldExit;

}

+ (void)setShouldExit:(BOOL)x {

	shouldExit = x;

}

+ (BOOL)shouldLoad {

	return shouldLoad;

}

+ (void)setShouldLoad:(BOOL)x {

	shouldLoad = x;

}


@end
