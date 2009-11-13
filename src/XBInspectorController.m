//
//  XBInspectorController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XBReputationView.h"
#import "Xbox Live Friends.h"
#import "XBInspectorController.h"

XBFriend *currentlySelectedFriend = nil;
static XBInspectorController *sharedInstance = nil;

@implementation XBInspectorController

- (id)init	{
	if (![super init])
	return nil;
		
	sharedInstance = self;
	
	return self;
}

+ (XBInspectorController *)sharedInstance
{
	if (!sharedInstance)
		NSLog(@"no instance initialized");
	return sharedInstance;
}


- (IBAction)TextEndEditing:(id)sender
{
	[self CheckAddressBookForImageAndDisableRadio];
	[currentlySelectedFriend setRealName:[realName stringValue]];
//	[[Controller sharedInstance] refreshFriendsList:NO];
}

- (void)CheckAddressBookForImageAndDisableRadio
{
	NSImage *theImage = [XBFriendDefaultsManager SearchAddressBookForImageForName:[realName stringValue]];
	if (theImage != nil){
		[[iconOptionsMatrix cellWithTag:XBAddressBookIconStyle] setEnabled:YES];
	}
	else {
		[[iconOptionsMatrix cellWithTag:XBAddressBookIconStyle] setEnabled:NO];
		if([[iconOptionsMatrix selectedCell] tag] == XBAddressBookIconStyle) {
			[iconOptionsMatrix selectCellWithTag:XBGamerPictureIconStyle];
		}
	}

}


- (IBAction)RadioButtonClicked:(id)sender
{
	int selectedIconStyle = [[iconOptionsMatrix selectedCell] tag];
	[self CheckAddressBookForImageAndDisableRadio];
	[currentlySelectedFriend setIconStyle:selectedIconStyle];
	if (selectedIconStyle == XBHalo2IconStyle)
		[currentlySelectedFriend haloEmblem];
	[inspectorImage setImage:[currentlySelectedFriend tileImage]];
//	[[Controller sharedInstance] refreshFriendsList:NO];
}

- (IBAction)notificationBoxClicked:(id)sender
{
	[currentlySelectedFriend setShouldShowNotifications:[[NSNumber numberWithInt:[notificationsCheckbox state]] boolValue]];
}

+ (XBFriend *)currentlySelectedFriend
{
	return currentlySelectedFriend;
}


- (void)refreshInspector
{
	if(currentlySelectedFriend != nil){
		
		[self showLoadingTab];
		[inspectorWindow update];

		[self showRequestManager:[currentlySelectedFriend requestType]];
		[self displayGamesPlayedForFriend:currentlySelectedFriend];
		[self displayCard:[XBGamercard cardForFriend:currentlySelectedFriend]];
		[self CheckAddressBookForImageAndDisableRadio];
		
		[self hideLoadingTab];

	}
	else {	
		[self displayEmptyCard];
	}
}

- (void)showLoadingTab
{
	[loadingIndicator startAnimation:nil];
	[inspectorTabView selectTabViewItemWithIdentifier:@"loading"];
}

- (void)hideLoadingTab
{
	[inspectorTabView selectTabViewItemWithIdentifier:@"card"];
	[loadingIndicator stopAnimation:nil];
}

- (void)displayCard:(XBGamercard *)theCard
{

	[fakeTabs setEnabled:YES];
	[inspectorTag setStringValue:[MQFunctions flattenHTML:[theCard gamertag]]];
	[inspectorMessage setStringValue:[MQFunctions flattenHTML:[theCard motto]]];
	[inspectorScore setAttributedStringValue:[self boldThis:@"score " withRegularText:[theCard gamerscore]]];
	[inspectorZone setAttributedStringValue:[self boldThis:@"zone " withRegularText:[theCard gamerzone]]];
	[inspectorImage setImage:[currentlySelectedFriend tileImage]];
	
	//rep
	[inspectorRep setReputationPercentage:[theCard rep]];
	
	
	NSString *theRN = [currentlySelectedFriend realName];
	if (theRN == nil)
		theRN = @"";
	[realName setStringValue:theRN];
	[iconOptionsMatrix selectCellWithTag:[currentlySelectedFriend iconStyle]];
	if ([currentlySelectedFriend shouldShowNotifications])
		[notificationsCheckbox setState:NSOnState];
	else
		[notificationsCheckbox setState:NSOffState];

}

- (void)displayEmptyCard
{
	[self showRequestManager:XBNoFriendRequestType];
	[fakeTabs setEnabled:NO];
	[inspectorTag setStringValue:@""];
	[inspectorMessage setStringValue:@""];
	[inspectorScore setStringValue:@""];
	[inspectorZone setStringValue:@""];
	[inspectorImage setImage:[NSImage imageNamed:@"defaultTile"]];
	NSString *thebase = [NSString stringWithFormat:@"file://%@%@", [[NSBundle mainBundle] resourcePath], @""];
	[[inspectorWebView mainFrame] loadHTMLString:@"<html></html>" baseURL:[NSURL URLWithString:thebase]];
}

- (void)showRequestManager:(int)type
{
	if (type == XBNoFriendRequestType) {
		[self setExtended:NO];
		return;
	}
	
	// the shadow
	NSShadow* theShadow = [[NSShadow alloc] init]; 
	[theShadow setShadowOffset:NSMakeSize(0.0, -1.0)]; 
	[theShadow setShadowBlurRadius:0.5]; 
	[theShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.8]]; 
	[theShadow set];

	NSString *theMessage;
	if (type == XBTheySentFriendRequestType) {
		theMessage = @"This person wants to be your friend.";
		[requestDeny setHidden:NO];
		[requestAccept setHidden:NO];
		[requestCancel setHidden:YES];
	}
	else if (type == XBYouSentFriendRequestType) {
		theMessage = @"You sent this person a friend request.";
		[requestDeny setHidden:YES];
		[requestAccept setHidden:YES];
		[requestCancel setHidden:NO];
	}

	NSMutableAttributedString *messageWithShadow = [[NSMutableAttributedString alloc] initWithString:theMessage];
	[messageWithShadow beginEditing];
	[messageWithShadow addAttribute:NSShadowAttributeName value:theShadow range:NSMakeRange(0, [theMessage length])];
	[messageWithShadow addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [theMessage length])];
	
	static NSDictionary *paraInfo = nil;
	NSMutableParagraphStyle *breakStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[breakStyle setAlignment:NSCenterTextAlignment];
	paraInfo = [[[NSDictionary alloc] initWithObjectsAndKeys:breakStyle, NSParagraphStyleAttributeName, nil] autorelease];
	[breakStyle release];
	[messageWithShadow addAttribute:NSParagraphStyleAttributeName value:breakStyle range:NSMakeRange(0, [messageWithShadow length])];

	[messageWithShadow endEditing];
	
	[requestName setAttributedStringValue:messageWithShadow];
	
	[self setExtended:YES];
}

- (IBAction)cancelFriendRequest:(id)sender
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/FriendsMgmt.aspx?gt=%@&act=Retract", [[currentlySelectedFriend gamertag] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	[NSString stringWithContentsOfURL:url];
	[[Controller sharedInstance] refreshFriendsList:YES];
	[[Controller sharedInstance] clearTableViewSelection];
	[self refreshInspector];
}

- (IBAction)acceptFriendRequest:(id)sender
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/FriendsMgmt.aspx?gt=%@&act=Accept", [[currentlySelectedFriend gamertag] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	[NSString stringWithContentsOfURL:url];
//	[[Controller sharedInstance] refreshFriendsList:YES];
//	[[Controller sharedInstance] clearTableViewSelection];
	[self refreshInspector];
}

- (IBAction)denyFriendRequest:(id)sender
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/FriendsMgmt.aspx?gt=%@&act=Reject", [[currentlySelectedFriend gamertag] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	[NSString stringWithContentsOfURL:url];
//	[[Controller sharedInstance] refreshFriendsList:YES];
//	[[Controller sharedInstance] clearTableViewSelection];
	[self refreshInspector];
}


- (void)extendWindowBy:(int) amount
{
	
	NSView*			cv = [inspectorWindow contentView];
	NSView*			view;
	NSEnumerator*	iter = [[cv subviews] objectEnumerator];
	NSRect			fr;
	NSPoint			fro;
	
	[cv setAutoresizesSubviews:NO];
	[inspectorWindow disableFlushWindow];


	while( view = [iter nextObject])
	{
		fro = [view frame].origin;
		fro.y += amount;
		[view setFrameOrigin:fro];
	}
	
	fr = [inspectorWindow frame];
	
	fr.size.height += amount;
	fr.origin.y -= amount;
	
	[inspectorWindow setFrame:fr display:YES];
	
	
	[inspectorWindow enableFlushWindow];
	[inspectorWindow displayIfNeeded];
	[cv setAutoresizesSubviews:YES];
}

- (void)setExtended:(BOOL)extend
{
	// extend the window and show/hide extra items
	
	if ( extend != _extended )
	{
		_extended = extend;
		
		if ( _extended )
			[self extendWindowBy:59];
		else
			[self extendWindowBy:-59];
	}
}


- (IBAction)OpenInspector:(id)sender
{
	[self refreshInspector];
	[inspectorWindow makeKeyAndOrderFront:nil];

}

- (void)openInspectorDoubleClick
{
	if (![self shouldUpdateInspector]){
		[inspectorWindow makeKeyAndOrderFront:nil];
		[self refreshInspector];
	}
}


- (BOOL)shouldUpdateInspector
{
	if ([inspectorWindow isVisible]){
		return YES;
	}
	else {
		return NO;
	}
}

- (void)setCurrentlySelectedFriend:(XBFriend *)theFriend
{
	currentlySelectedFriend = theFriend;
}

- (void)displayGamesPlayedForFriend:(XBFriend *)theFriend
{
//	NSMutableDictionary *theInfo = [XBGamesPlayedParser fetchWithTag:[theFriend gamertag]];
	
//	NSString *theRow = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/gamesplayed_row.mqhtp"] encoding:NSMacOSRomanStringEncoding error:NULL];
//	NSString *theBody = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/gamesplayed_body.mqhtp"] encoding:NSMacOSRomanStringEncoding error:NULL];
//	NSString *allRows = @"<!-- something something -->";
//	
//	NSMutableString *currentEditRow;
//	
//	BOOL showsError = NO;
//	int usableGames = 0;
//
//	
//	if([[theInfo objectForKey:@"gameIcons"] count] != 0){
//		int i;
//		for (i = 0; i < [[theInfo objectForKey:@"gameIcons"] count]; i++){
//
//			@try{
//				currentEditRow = [theRow mutableCopy];
//				
//				
//				[currentEditRow replaceOccurrencesOfString:@"$GAMETITLE" withString:[[theInfo objectForKey:@"gameNames"] objectAtIndex:i] options:0 range:NSMakeRange(0, [currentEditRow length])];
//
//				[currentEditRow replaceOccurrencesOfString:@"$TILEURL" withString:[[theInfo objectForKey:@"gameIcons"] objectAtIndex:i] options:0 range:NSMakeRange(0, [currentEditRow length])];
//
//				[currentEditRow replaceOccurrencesOfString:@"$GAMERSCORE" withString:[[theInfo objectForKey:@"theirScores"] objectAtIndex:i] options:0 range:NSMakeRange(0, [currentEditRow length])];
//
//
//				//calc percent completed gamerscorelywise
//				NSRange ofRange;
//				NSString *blankOfBlank = [[theInfo objectForKey:@"theirScores"] objectAtIndex:i];
//				ofRange = [blankOfBlank rangeOfString:@" of "];
//				NSString *completedPoints = [blankOfBlank substringWithRange:NSMakeRange(0, ofRange.location)];
//				int offset = ofRange.location + ofRange.length;
//				NSString *totalPoints = [blankOfBlank substringWithRange:NSMakeRange(offset, [blankOfBlank length] - offset)];
//				float percent = [completedPoints floatValue] / [totalPoints floatValue];
//				percent = percent * 50;
//				float negpercent = 50 - percent;
//				[currentEditRow replaceOccurrencesOfString:@"$WIDTH" withString:[NSString stringWithFormat:@"%f", percent] options:0 range:NSMakeRange(0, [currentEditRow length])];
//				[currentEditRow replaceOccurrencesOfString:@"$NEGWIDTH" withString:[NSString stringWithFormat:@"%f", negpercent] options:0 range:NSMakeRange(0, [currentEditRow length])];
//				
//				if([completedPoints intValue] != 0){
//					allRows = [NSString stringWithFormat:@"%@%@", allRows, currentEditRow];
//					usableGames = usableGames + 1;
//				}
//				[currentEditRow release];
//			}
//			@catch (NSException *exception){
//			
//			}
//		}
//	}
//	else
//		showsError = YES;
//
//	if (usableGames == 0)
//		showsError = YES;
//	
//	if (showsError){
//			theBody = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/nogamesplayed_inspector.mqhtp"] encoding:NSMacOSRomanStringEncoding error:NULL];
//	}
//	
//	NSMutableString *theBodyMut = [theBody mutableCopy];
//	
//	[theBodyMut replaceOccurrencesOfString:@"$ACHIEVEMENTROW" withString:allRows options:0 range:NSMakeRange(0, [theBodyMut length])];
//	
//	NSString *thebase = [NSString stringWithFormat:@"file://%@%@", [[NSBundle mainBundle] resourcePath], @""];
//	
//	[theBodyMut replaceOccurrencesOfString:@"$BUNDLE" withString:thebase options:0 range:NSMakeRange(0, [theBodyMut length])];
//
//	[[inspectorWebView mainFrame] loadHTMLString:theBodyMut baseURL:[NSURL URLWithString:thebase]];
//	
//	[theBodyMut release];
}

- (NSAttributedString *)boldThis:(NSString *)toBold withRegularText:(NSString*)toRegular
{
	NSString *theFinalStatus = [NSString stringWithFormat:@"%@%@", toBold, toRegular];
	NSMutableAttributedString *theFinalStatusAttributed = [[[NSMutableAttributedString alloc] initWithString:theFinalStatus] autorelease];
	NSRange statusRange = [theFinalStatus rangeOfString:toBold];
	[theFinalStatusAttributed beginEditing];
	[theFinalStatusAttributed addAttribute:NSForegroundColorAttributeName value:[NSColor disabledControlTextColor] range:statusRange];
	[theFinalStatusAttributed addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:[NSFont systemFontSize]] range:statusRange];
	
	static NSDictionary *paraInfo = nil;
	NSMutableParagraphStyle *breakStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[breakStyle setAlignment:NSCenterTextAlignment];
	paraInfo = [[[NSDictionary alloc] initWithObjectsAndKeys:breakStyle, NSParagraphStyleAttributeName, nil] autorelease];
	[breakStyle release];
	[theFinalStatusAttributed addAttribute:NSParagraphStyleAttributeName value:breakStyle range:NSMakeRange(0, [theFinalStatus length])];

	[theFinalStatusAttributed endEditing];

	return [theFinalStatusAttributed copy];
}







@end





























