//
//  FriendOptionsController.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FriendOptionsController : NSObject {

	IBOutlet NSWindow *friendOptionsWindow;
	IBOutlet NSMatrix *pictureDisplayMatrix;
	IBOutlet NSTextField *realName;
	
	IBOutlet NSTextField *gamertag;
	IBOutlet NSImageView *gamertile;
	IBOutlet NSImageView *gamertileReflection;

	XBFriend *currentFriend;

}

- (void)clearWindow;
- (void)enableWindow;
- (void)updateWindow;

- (IBAction)saveRealName:(id)sender;
- (IBAction)saveIconStyle:(id)sender;


@end
