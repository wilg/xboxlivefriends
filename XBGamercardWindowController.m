//
//  XBGamercardWindowController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 10/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "XBGamercardWindowController.h"
#import "NSImage+MQReflectedImage.h"


@implementation XBGamercardWindowController

- (id)init	{
	if (![super init])
	return nil;
		

	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(friendsListSelectionChanged:)
		name:@"FriendsListSelectionChanged" object:nil];
	
	return self;
}

- (void)friendsListSelectionChanged:(NSNotification *)notification
{
	if ([gamercardWindow isVisible]) {
		[NSThread detachNewThreadSelector:@selector(updateGamercardWindowWithTag:) toTarget:self withObject:[notification object]];
	}

}

- (void)updateGamercardWindowWithTag:(XBFriend *)friend 
{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
 
	XBGamercard *theGamercard = [XBGamercard cardForFriend:friend];
	
	[gamertagField setStringValue:[theGamercard gamertag]];
	[scoreField setStringValue:[theGamercard gamerscore]];
	NSImage *tile = [theGamercard gamertileImage];
	[tileImageView setImageAlignment:NSImageAlignTop];
	[tileImageView setImage:[NSImage imageWithPerspectiveAndReflection:tile amountReflected:0.25 amountTurned:.25]];
	[reputationView setReputationPercentage:[theGamercard rep]];

 
    [pool release];

}
@end