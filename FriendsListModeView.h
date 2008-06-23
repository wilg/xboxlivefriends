//
//  FriendsListModeView.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FriendsListModeView : NSObject {

	IBOutlet NSView *contentView;
    NSView *currentView;

	IBOutlet NSProgressIndicator *loadingProgress;

	//tabs
	IBOutlet NSView *friendsList;
	IBOutlet NSView *loadingView;
	IBOutlet NSView *loginView;

}

- (void)setCurrentView:(NSView *)newView;

@end
