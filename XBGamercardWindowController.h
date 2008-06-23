//
//  XBGamercardWindowController.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 10/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XBGamercardWindowController : NSObject {

	IBOutlet NSTextField *gamertagField;
	IBOutlet NSTextField *scoreField;
	IBOutlet XBReputationView *reputationView;
	IBOutlet NSImageView *tileImageView;
	IBOutlet NSWindow *gamercardWindow;


}

- (void)friendsListSelectionChanged:(NSNotification *)notification;
- (void)updateGamercardWindowWithTag:(XBFriend *)friend;


@end
