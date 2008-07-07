//
//  FriendsListModeView.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "MQColorView.h"
#import "FriendsListModeView.h"


@implementation FriendsListModeView


- (void)awakeFromNib {

	NSLog(@"FACE");
	
	[[Controller stayArounds] addObject:self];

	[loadingProgress startAnimation:nil];
	[[loadingView window] makeKeyAndOrderFront:nil];
	[self setCurrentView:loadingView];
	
    //[contentView setWantsLayer:YES];
	[contentView setAutoresizesSubviews:YES];
	[contentView setAnimations:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstFriendsLoaded:) name:@"FirstFriendsLoaded" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeModeNotification:) name:@"ChangeFriendsListMode" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsListError:) name:@"DisplayFriendsListError" object:nil];

}

- (void)finalize
{
	NSLog(@"SHIT FINALIZED");
	
	[super finalize];
}

- (void)firstFriendsLoaded:(NSNotification *)notification {
NSLog(@"FirstFriendsLoaded");

	[self setCurrentView:friendsList];
	[loadingProgress stopAnimation:nil];

}

- (void)changeMode:(NSString *)mode {
	if ([mode isEqualToString:@"sign_in"]) {
		[NSApp setApplicationIconImage:[NSImage imageNamed:@"xlf_yellow"]];
		[[loginView window] makeKeyAndOrderFront:nil];
		[self setCurrentView:loginView];
		return;
	}
	else if ([mode isEqualToString:@"friends"])
		[self setCurrentView:friendsList];
	else if ([mode isEqualToString:@"loading"])
		[self setCurrentView:loadingView];
	//[NSApp setApplicationIconImage:[NSImage imageNamed:@"NSApplicationIcon"]];
}

- (void)changeModeNotification:(NSNotification *)notification {
NSLog(@"changeModeNotification");
	[self performSelectorOnMainThread:@selector(changeMode:) withObject:[notification object] waitUntilDone:YES];
}

- (void)friendsListError:(NSNotification *)notification {
	[NSApp setApplicationIconImage:[NSImage imageNamed:@"xlf_red"]];
	[errorString setStringValue:[notification object]];
	[self setCurrentView:errorView];
}


- (void)setCurrentView:(NSView *)newView {
NSLog(@"setCurrentView");

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
