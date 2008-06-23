//
//  FriendOptionsController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "FriendOptionsController.h"
#import "NSImage+BHReflectedImage.h"


@implementation FriendOptionsController

- (void)awakeFromNib {
	[self clearWindow];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsListSelectionChanged:) name:@"FriendsListSelectionChanged" object:nil];
}

- (void)clearWindow {
	[pictureDisplayMatrix setTag:0];
	[pictureDisplayMatrix setEnabled:NO];
	
	[gamertag setEnabled:NO];
	[gamertag setStringValue:@""];
	
	[realName setEnabled:NO];
	[realName setStringValue:@""];
	[gamertile setImage:[NSImage imageNamed:@"loading_tile"]];
	[gamertileReflection setImage:[NSImage reflectedImage:[NSImage imageNamed:@"loading_tile"] amountReflected:0.5]];
}

- (void)enableWindow {
	[pictureDisplayMatrix setEnabled:YES];
	[gamertag setEnabled:YES];
	[realName setEnabled:YES];
}


- (void)updateWindow {
	if (![friendOptionsWindow isVisible])
		return;

	if (!currentFriend) {
		[self clearWindow];
		return;
	}
	
	[self enableWindow];

	[gamertag setStringValue:[currentFriend gamertag]];
	[gamertile setImage:[currentFriend tileImage]];
	[gamertileReflection setImage:[NSImage reflectedImage:[currentFriend tileImage] amountReflected:0.4]];

	if ([currentFriend realName])
		[realName setStringValue:[currentFriend realName]];
	else
		[realName setStringValue:@""];
	
	if ([XBFriendDefaultsManager addressBookImageForPerson:[realName stringValue]] != nil) {
		[[pictureDisplayMatrix cellWithTag:XBAddressBookIconStyle] setEnabled:YES];
	}
	else {
		[[pictureDisplayMatrix cellWithTag:XBAddressBookIconStyle] setEnabled:NO];
		if([[pictureDisplayMatrix selectedCell] tag] == XBAddressBookIconStyle) {
			[pictureDisplayMatrix selectCellWithTag:XBGamerPictureIconStyle];
		}
	}

	
	[pictureDisplayMatrix selectCellWithTag:[currentFriend iconStyle]];

}

- (void)friendsListSelectionChanged:(NSNotification *)notification {

	if ([notification object])
		currentFriend = [notification object];
	else
		currentFriend = nil;
		
	[self updateWindow];
}

#pragma mark Real Name Stuff
- (IBAction)saveRealName:(id)sender {
	[currentFriend setRealName:[realName stringValue]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRedraw" object:nil];
	[self updateWindow];
}

#pragma mark Matrix Stuff
- (IBAction)saveIconStyle:(id)sender {
	[currentFriend setIconStyle:[pictureDisplayMatrix selectedTag]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRedraw" object:nil];
	[self updateWindow];
}


#pragma mark Window Delegate
- (void)windowDidBecomeKey:(NSNotification *)notification {
	[self updateWindow];
}

@end
