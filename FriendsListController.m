//
//  FriendsListController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MAAttachedWindowNonActivating.h"
#include "Xbox Live Friends.h"
#include "FriendsListController.h"
#include "GrowlController.h"
#include "FriendsListParser.h"
#include "FriendStatusCell.h"

static BOOL loadThreaded = true;

@implementation FriendsListController

@synthesize friends;

- (id)init;
{
	if (![super init])
	return nil;

	tableViewItems = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsListNeedsRefresh:) name:@"FriendsListNeedsRefresh" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsListNeedsRedraw:) name:@"FriendsListNeedsRedraw" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFriendsList:) name:@"ShowFriendsList" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstFriendsListLoad:) name:NSApplicationDidFinishLaunchingNotification object:nil];


	return self;
}

- (void)awakeFromNib {

	[friendsListWindow setAutorecalculatesContentBorderThickness:NO forEdge:NSMaxYEdge];
	[friendsListWindow setContentBorderThickness:39.0 forEdge:NSMaxYEdge];
	
	[friendsListWindow setAutorecalculatesContentBorderThickness:NO forEdge:NSMinYEdge];
	[friendsListWindow setContentBorderThickness:36.0 forEdge:NSMinYEdge];

	[[myTag cell] setBackgroundStyle:NSBackgroundStyleRaised];
	[[myMessage cell] setBackgroundStyle:NSBackgroundStyleRaised];


	[friendsTable setDelegate:self];
	[friendsTable setDataSource:self];
	[friendsTable setDoubleAction: @selector(doubleAction:)];
	[friendsTable setTarget: self];


	FriendStatusCell *statusCell = [[[FriendStatusCell alloc] init] autorelease];
	[statusCell setControlView:[friendsListWindow contentView]];
	[[friendsTable tableColumnWithIdentifier:@"gt_and_status"] setDataCell:statusCell];

}

- (void)firstFriendsListLoad:(NSNotification *)notification {
	NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(firstFriendsListLoadThread) object:nil];
	[[[NSApp delegate] operationQueue] addOperation:theOp];	
}

- (void)firstFriendsListLoadThread {
	[self performSelectorOnMainThread:@selector(friendsListLocked:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
	if ([self downloadFriendsList]) {
		[self displayFriendsList];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FirstFriendsLoaded" object:nil];
	}
}

- (void)friendsListLocked:(NSNumber *)lockedNum {
	BOOL locked = [lockedNum boolValue];
	if (locked) {
		[myBead setImage:[NSImage imageNamed:@"red_bead"]];
		[[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"friendsListIsLoadedAndReady"];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"friendsListIsLoadedAndReady"];
		[myBead setImage:[NSImage imageNamed:@"green_bead"]];
	}
}


- (void)friendsListNeedsRefresh:(NSNotification *)notification {
	if (loadThreaded) {
		NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(refreshFriendsListThread) object:nil];
		[[[NSApp delegate] operationQueue] addOperation:theOp];	
	}
   else {
		if ([self downloadFriendsList])
			[self displayFriendsList];
   }
}

- (void)showFriendsList:(NSNotification *)notification {
	[friendsListWindow makeKeyAndOrderFront:nil];
}

- (void)friendsListNeedsRedraw:(NSNotification *)notification {
	if (loadThreaded) {
		NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(displayFriendsListThread) object:nil];
		[[[NSApp delegate] operationQueue] addOperation:theOp];	
	}
   else
		[self displayFriendsList];
}

- (BOOL)downloadFriendsList {

	NSArray *oldFriends = friends;
	
	if (friends)
		[friends release];
	friends = [[FriendsListParser friends] retain];
	
	BOOL success = NO;
	if (friends) {

		success = YES;
		[self checkFriendsForStatusChange:friends oldFriends:oldFriends];
		[self displayMyGamercard];

		[[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeFriendsListMode" object:@"friends"];

		[self performSelectorOnMainThread:@selector(friendsListLocked:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
		
	}
	else {
		[self performSelectorOnMainThread:@selector(friendsListLocked:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListConnectionError" object:nil];
	}
	


	return success;
}


- (void)checkFriendsForStatusChange:(NSArray *)newFriends oldFriends:(NSArray *)oldFriends {
		

	NSMutableDictionary *oldFriendsDict = [NSMutableDictionary dictionary];
	for (XBFriend *friend in oldFriends) {
		[oldFriendsDict setObject:friend forKey:[friend gamertag]];
	}

	
	int differences = 0;

	newFriends = friends;
	for (XBFriend *newFriend in newFriends) {
		
		XBFriend *correspondingOldFriend = [oldFriendsDict objectForKey:[newFriend gamertag]];
		if (correspondingOldFriend) {
			//NSLog(@"%@ (new) corresponds to %@ (old)", [newFriend gamertag], [correspondingOldFriend gamertag]);

			NSString *notificationTitle;
			NSString *notificationName;

			if ([newFriend statusHasChangedFromFriend:correspondingOldFriend]) {

				differences++;
				
				if ([[correspondingOldFriend status] isEqual:@"Offline"]) {
					if ([[newFriend status] isNotEqualTo:@"Offline"]) {
						notificationTitle = @" is now online";
						notificationName = @"Friend Signed In";
					}
				}
				else if ([[correspondingOldFriend status] isNotEqualTo:@"Offline"]) {
					if ([[newFriend status] isEqual:@"Offline"]) {
						notificationTitle = @" went offline";
						notificationName = @"Friend Signed Out";
					}
				}
				
				notificationTitle = [NSString stringWithFormat:@"%@ %@", [newFriend realNameWithFormat:XBUnknownNameDisplayStyle], notificationTitle];
			
				if (notificationName && notificationTitle) { 
					[[NSNotificationCenter defaultCenter] postNotificationName:@"GrowlNotify" object:
					
					[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:notificationName, notificationTitle, [newFriend info], [[newFriend tileImage] TIFFRepresentation], nil] forKeys:[NSArray arrayWithObjects:@"GROWL_NOTIFICATION_NAME", @"GROWL_NOTIFICATION_TITLE", @"GROWL_NOTIFICATION_DESCRIPTION", @"GROWL_NOTIFICATION_ICON", nil]]
					
					];
				}
				
			}

			if ([newFriend currentGameHasChangedFromFriend:correspondingOldFriend]) {
				NSLog(@"currentGameHasChangedFromFriend %@ to %@", [newFriend gamertag], [newFriend info]);

				differences++;
				
				notificationName = @"Friend Switched Game";
				notificationTitle = [newFriend realNameWithFormat:XBUnknownNameDisplayStyle];

				if ([[correspondingOldFriend info] rangeOfString:@"Joinable"].location == NSNotFound) {
					if ([[newFriend info] rangeOfString:@"Joinable"].location != NSNotFound) {
						notificationTitle = [NSString stringWithFormat:@"%@ is Joinable", [newFriend realNameWithFormat:XBUnknownNameDisplayStyle]];
						notificationName = @"Friend Is Joinable";
					}
				}
							
				[[NSNotificationCenter defaultCenter] postNotificationName:@"GrowlNotify" object:
				
				[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:notificationName, notificationTitle, [newFriend info], [[newFriend tileImage] TIFFRepresentation], nil] forKeys:[NSArray arrayWithObjects:@"GROWL_NOTIFICATION_NAME", @"GROWL_NOTIFICATION_TITLE", @"GROWL_NOTIFICATION_DESCRIPTION", @"GROWL_NOTIFICATION_ICON", nil]]
				
				];
			}
			
		}
		
	}
	
}

- (void)displayFriendsList {
	

	[tableViewItems removeAllObjects];
	
	for (XBFriend *currentFriend in [[friends copy] autorelease]) {
		[tableViewItems addObject:[currentFriend tableViewRecord]];
	}

	[friendsTable reloadData];

}

- (void)displayFriendsListThread {
	[self displayFriendsList];	
}


- (void)refreshFriendsListThread {

	if ([self downloadFriendsList])
		[self displayFriendsList];
	
}



- (void)displayMyGamercard {

	//Download my Gamercard
	XBGamercard *myCard = [XBGamercard cardForURL:[NSURL URLWithString:@"http://live.xbox.com/en-US/profile/profile.aspx"]];
	
	[myTag setObjectValue:[myCard gamertag]];
	[myMessage setObjectValue:[myCard motto]];
	[myScore setStringValue:[myCard gamerscore]];
	[myTile setImage:[myCard gamertileImage]];

}

#pragma mark -
#pragma mark IB Actions

- (IBAction)OpenAddFriendPanel:(id)sender
{
	[NSApp beginSheet:addFriendSheet modalForWindow:friendsListWindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)  contextInfo:nil];
}

- (IBAction)AddFriend:(id)sender
{
	NSString *theGamertag = [addFriendTag stringValue];
	NSString *theRealName = [addFriendRealName stringValue];
	
	[[XBFriend friendWithTag:theGamertag] setRealName:theRealName];

	NSString *theURLBase = @"http://live.xbox.com/en-US/profile/FriendsMgmt.aspx?act=Add&gt=";
	NSMutableString *mutableGamerTag = [theGamertag mutableCopy];
	[mutableGamerTag replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutableGamerTag length])];
	NSString *theStringURL = [NSString stringWithFormat:@"%@%@", theURLBase, mutableGamerTag];
	[mutableGamerTag release];
	[NSApp endSheet:addFriendSheet];
	//querys xbox.com and gets a response
	NSString *response = [NSString stringWithContentsOfURL:[NSURL URLWithString:theStringURL]];
	NSRange errorRange = [response rangeOfString:@"The gamertag you entered does not exist on Xbox Live."];
	if (errorRange.location != NSNotFound){
		//gamertag doesn't exist
		NSString *theError = [NSString stringWithFormat:@"The gamertag \"%@\" does not exist on Xbox Live.", theGamertag];
		[self displaySimpleErrorMessage:@"Gamertag Doesn't Exist" withMessage:theError attachedTo:friendsListWindow];
	}
	[NSString stringWithContentsOfURL:[NSURL URLWithString:theStringURL]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
}

- (IBAction)RemoveSelectedFriend:(id)sender
{
	int theRow = [friendsTable selectedRow];
	if (theRow != -1){

		XBFriend *currentFriend = [friends objectAtIndex:theRow];
		
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"Remove"];
		[alert addButtonWithTitle:@"Don't Remove"];
		[alert setMessageText:@"Remove Friend"];
		[alert setInformativeText:[NSString stringWithFormat:@"Do you want to remove %@ from your friends list?", [currentFriend gamertag]]];
		[alert setAlertStyle:NSWarningAlertStyle];

		NSArray *context = [[NSArray arrayWithObjects:@"remove_friend", [currentFriend gamertag], nil] retain];
		[alert beginSheetModalForWindow:friendsListWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:context];

		
	}
}

- (IBAction)CancelParentSheet:(id)sender;
{
	[NSApp endSheet:[sender window]];
}

- (IBAction)FetchButton:(id)sender{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
}

- (IBAction)updateTableView:(id)sender{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRedraw" object:nil];
}

- (void)deleteButtonEnabled:(BOOL)isEnabled
{
	[deleteFriendMenu setEnabled:isEnabled];
}

#pragma mark -
#pragma mark TableView Methods


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [tableViewItems count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex 
{
	return [[tableViewItems objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
}


- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self doRequestPop];
	int theRow = [friendsTable selectedRow];
	if (theRow != -1){
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListSelectionChanged" object:[friends objectAtIndex:theRow]];
		[self deleteButtonEnabled:YES];
	}
	else{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListSelectionChanged" object:nil];
	}
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	return YES;
}

- (void)doubleAction:(id)sender
{
	[self highlightedGamerInfo:nil];
}

- (void)clearTableViewSelection
{
	[friendsTable deselectRow:[friendsTable selectedRow]];
}


- (XBFriend *)currentlySelectedFriend {
	XBFriend *currentFriend = nil;
	int theRow = [friendsTable selectedRow];
	if (theRow != -1){
		currentFriend = [friends objectAtIndex:theRow];
	}
	return currentFriend;
}

- (XBFriend *)contextSelectedFriend {
	XBFriend *currentFriend = nil;
	int theRow = [friendsTable clickedRow];
	if (theRow != -1){
		currentFriend = [friends objectAtIndex:theRow];
	}
	return currentFriend;
}

#pragma mark -
#pragma mark NSWindow Delegates


- (void)windowDidResignKey:(NSNotification *)aNotification
{
}

- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

#pragma mark -
#pragma mark Panel Methods


- (void)displaySimpleErrorMessage:(NSString *)headline withMessage:(NSString *)message attachedTo:(NSWindow *)theWindow
{
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:headline];
	[alert setInformativeText:message];
	[alert setAlertStyle:NSWarningAlertStyle];
	if (theWindow == nil){
		[alert runModal];
	}else{
		[alert beginSheetModalForWindow:theWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
	}
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(id)contextInfo
{	
	if ([contextInfo objectAtIndex:0] == @"remove_friend"){
		if (returnCode == NSAlertFirstButtonReturn) {
			NSString *theURLBase = @"http://live.xbox.com/en-US/profile/FriendsMgmt.aspx?act=Delete&gt=";
			NSMutableString *mutableGamerTag = [[contextInfo objectAtIndex:1] mutableCopy];
			[mutableGamerTag replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutableGamerTag length])];
			NSString *theStringURL = [NSString stringWithFormat:@"%@%@", theURLBase, mutableGamerTag];
			[mutableGamerTag release];
			//querys xbox.com and gets a response
			[NSString stringWithContentsOfURL:[NSURL URLWithString:theStringURL]];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
		}
	}
	[contextInfo release];
}

#pragma mark -
#pragma mark Panel Methods

- (IBAction)contextualGamerInfo:(id)sender{
	if ([self contextSelectedFriend])
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIRequestLookupWithTag" object:[[self contextSelectedFriend] gamertag]];
}

- (IBAction)normalGamerInfo:(id)sender{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GIOpenLookupWindow" object:nil];
}

- (IBAction)highlightedGamerInfo:(id)sender{
	if ([self currentlySelectedFriend])
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIRequestLookupWithTag" object:[[self currentlySelectedFriend] gamertag]];
}

- (IBAction)contextSendMessageToFriend:(id)sender{
	if ([self contextSelectedFriend])
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SendMessageToFriend" object:[[self contextSelectedFriend] gamertag]];
}

- (IBAction)contextualXboxProfile:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/profile.aspx?GamerTag=%@", [[self contextSelectedFriend] urlEscapedGamertag]]]];
}

- (IBAction)contextualMyGamercardProfile:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://profile.mygamercard.net/%@", [[self contextSelectedFriend] urlEscapedGamertag]]]];
}

- (IBAction)contextualBungieNetProfile:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.bungie.net/Stats/Halo3/Default.aspx?player=%@", [[self contextSelectedFriend] urlEscapedGamertag]]]];
}

- (IBAction)openURLMindquirk:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://mindquirk.com"]];
}

- (IBAction)openURLDonate:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://mindquirk.com/donate"]];
}

- (IBAction)openURLEmailUs:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:software@mindquirk.com"]];
}


#pragma mark -
#pragma mark Accept/Reject Friends


- (void)doRequestPop {

	XBFriend *theFriend = [self currentlySelectedFriend];

    if (theFriend && [theFriend requestType] != XBNoFriendRequestType) {
	
	
//		if ([[mImageBrowser selectionIndexes] count] == 0)
//			return;
//
//		NSUInteger selectedIndex =  [[mImageBrowser selectionIndexes] firstIndex];
//
//		NSRect frame = [mImageBrowser itemFrameAtIndex:selectedIndex];
//		frame = [mImageBrowser convertRectToBase:frame];
//		
//		NSRect browserRect = [[mImageBrowser superview] frame];
//		browserRect.origin = [[mImageBrowser window] convertBaseToScreen:browserRect.origin];
//		
//		NSPoint point = [[mImageBrowser window] convertBaseToScreen:frame.origin];
//		point.x += frame.size.width;
//		point.y += frame.size.height / 2;
//		
//		if (point.y > browserRect.origin.y + browserRect.size.height + [infoWindowView frame].size.height + 10 || point.y < browserRect.origin.y  + [infoWindowView frame].size.height + 10) {
//		
//			[self closeInfoPop];
//			return;
//
//		}
//
		if (!requestPop) {
			NSView *theView;
			if ([theFriend requestType] == XBYouSentFriendRequestType)
				theView = youRequestedView;
			else
				theView = wantsToBeView;
			
			NSRect rowRect = [friendsTable rectOfRow:[friendsTable selectedRow]];
			
			NSPoint point = [friendsTable convertRectToBase:rowRect].origin;
			point = [friendsListWindow convertBaseToScreen:point];
			
			point.y += rowRect.size.height / 2;
			point.x += rowRect.size.width - 10;

			requestPop = [[MAAttachedWindowNonActivating alloc] initWithView:theView attachedToPoint:point onSide:MAPositionRight];
			[requestPop setViewMargin:15.0];
			[requestPop setBackgroundColor:[NSColor colorWithCalibratedHue:0.6273 saturation:0.9 brightness:0 alpha:0.95]];
			[friendsListWindow addChildWindow:requestPop ordered:NSWindowAbove];

		}
//				
//		[infoPopTitle setStringValue:[myImageTitles objectAtIndex:selectedIndex]];
//		[infoPopDescription setStringValue:[myImageDescriptions objectAtIndex:selectedIndex]];
//
//		[infoPop setPoint:point side:MAPositionRight];
	

		
		
    } else {
		[self closeRequestPop];
    }

}

- (IBAction)cancelFriendRequest:(id)sender
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/FriendsMgmt.aspx?gt=%@&act=Retract", [[self currentlySelectedFriend] urlEscapedGamertag]]];
	[NSString stringWithContentsOfURL:url];
	[friendsTable selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
	[self closeRequestPop];
}

- (IBAction)acceptFriendRequest:(id)sender
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/FriendsMgmt.aspx?gt=%@&act=Accept", [[self currentlySelectedFriend] urlEscapedGamertag]]];
	[NSString stringWithContentsOfURL:url];
	[friendsTable selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
	[self closeRequestPop];
}

- (IBAction)denyFriendRequest:(id)sender
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/FriendsMgmt.aspx?gt=%@&act=Reject", [[self currentlySelectedFriend] urlEscapedGamertag]]];
	[NSString stringWithContentsOfURL:url];
	[friendsTable selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
	[self closeRequestPop];
}


- (void)closeRequestPop {
	if (requestPop) {
		[friendsListWindow removeChildWindow:requestPop];
		[requestPop orderOut:self];
		[requestPop release];
		requestPop = nil;
	}
}


@end
