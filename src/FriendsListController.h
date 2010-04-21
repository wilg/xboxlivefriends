//
//  FriendsListController.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
// i trip blind kids, whats your anti-drug?

#import <Cocoa/Cocoa.h>
#import "MAAttachedWindow.h"

@class LoginController;

@interface FriendsListController : NSObject {

	//add friend sheet
	IBOutlet NSWindow *addFriendSheet;
	IBOutlet NSTextField *addFriendTag;
	IBOutlet NSTextField *addFriendRealName;

	//friends list
	IBOutlet NSWindow *friendsListWindow;

	IBOutlet NSTableView *friendsTable;
	IBOutlet NSTextField *myTag;
	IBOutlet NSTextField *myMessage;

	IBOutlet NSImageView *myTile;
	IBOutlet NSImageView *myBead;
	IBOutlet NSTextField *myScore;
	
	//menu bar
	IBOutlet NSMenuItem *deleteFriendMenu;
	
	//dock menu
	IBOutlet NSMenu *dockMenu;
	
	//variables
	NSMutableArray *tableViewItems;
	NSArray *friends;
	//XBFriendsList *friendsListObject;
	
	MAAttachedWindow *requestPop;
	IBOutlet NSView *wantsToBeView;
	IBOutlet NSView *youRequestedView;

}

@property(copy) NSArray *friends;

- (BOOL)downloadFriendsList;
- (void)displayFriendsList;
- (void)showDockMenu;
- (void)checkFriendsForStatusChange:(NSArray *)newFriends oldFriends:(NSArray *)oldFriends;

- (void)friendsListLocked:(NSNumber *)lockedNum;

- (void)addFriendFromNotification:(NSNotification *)notification;
- (void)addFriendWithTag:(NSString *)theGamertag;

- (IBAction)FetchButton:(id)sender;
- (IBAction)updateTableView:(id)sender;
- (IBAction)AddFriend:(id)sender;
- (IBAction)RemoveSelectedFriend:(id)sender;
- (IBAction)CancelParentSheet:(id)sender;
- (IBAction)OpenAddFriendPanel:(id)sender;

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView;
- (void)deleteButtonEnabled:(BOOL)isEnabled;
- (void)clearTableViewSelection;
- (XBFriend *)currentlySelectedFriend;
- (XBFriend *)contextSelectedFriend;

- (void)displayMyGamercard;

- (void)displaySimpleErrorMessage:(NSString *)headline withMessage:(NSString *)message attachedTo:(NSWindow *)theWindow;

- (IBAction)contextualGamerInfo:(id)sender;
- (IBAction)normalGamerInfo:(id)sender;
- (IBAction)highlightedGamerInfo:(id)sender;
- (IBAction)contextualXboxProfile:(id)sender;
- (IBAction)contextSendMessageToFriend:(id)sender;
- (IBAction)contextualMyGamercardProfile:(id)sender;
- (IBAction)contextualBungieNetProfile:(id)sender;

- (IBAction)openURLMindquirk:(id)sender;
- (IBAction)openURLDonate:(id)sender;
- (IBAction)openURLEmailUs:(id)sender;


- (void)doRequestPop;
- (IBAction)cancelFriendRequest:(id)sender;
- (IBAction)acceptFriendRequest:(id)sender;
- (IBAction)denyFriendRequest:(id)sender;
- (void)closeRequestPop;

+ (NSString *)myGamertag;

@end
