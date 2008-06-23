//
//  FriendsListModeView.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MQColorView.h"
#import "FriendsListModeView.h"


@implementation FriendsListModeView


- (void)awakeFromNib {
//	[loadingView setBackgroundColor:[NSColor colorWithCalibratedHue:0.5808 saturation:0.07 brightness:0.9 alpha:1.0]];
	//[loadingProgress setUsesThreadedAnimation:YES];
	[loadingProgress startAnimation:nil];
	[[loadingView window] makeKeyAndOrderFront:nil];
	[self setCurrentView:loadingView];
    //[contentView setWantsLayer:YES];
	[contentView setAutoresizesSubviews:YES];
	[contentView setAnimations:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstFriendsLoaded:) name:@"FirstFriendsLoaded" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMode:) name:@"ChangeFriendsListMode" object:nil];

}

- (void)firstFriendsLoaded:(NSNotification *)notification {

	[self setCurrentView:friendsList];
	[loadingProgress stopAnimation:nil];

}

- (void)changeMode:(NSNotification *)notification {
	NSString *mode = [notification object];
	if ([mode isEqualToString:@"sign_in"]) {
		[[loginView window] makeKeyAndOrderFront:nil];
		[self setCurrentView:loginView];
	}
	else if ([mode isEqualToString:@"friends"])
		[self setCurrentView:friendsList];
	else if ([mode isEqualToString:@"loading"])
		[self setCurrentView:loadingView];
}


- (void)setCurrentView:(NSView *)newView {
	[newView setFrameSize:[contentView frame].size];
	[newView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];

    if (!currentView) {
		[contentView addSubview:newView];
		currentView = newView;
        return;
    }

    [[contentView animator] replaceSubview:currentView with:newView];
	
    currentView = newView;
}

@end
