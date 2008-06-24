//
//  XBMessageCenterController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#include "Xbox Live Friends.h"
#include "XBMessageCenterController.h"
#include "XBMessagesParser.h"
#include "SendMessage.h"

@implementation XBMessageCenterController

- (void)awakeFromNib
{

	records = [[NSMutableArray array] retain];
	
	isGoldMember = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestedMessageForFriend:) name:@"SendMessageToFriend" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsListRefreshed:) name:@"FriendsListNeedsRefresh" object:nil];
	
	[messagesTable setDataSource:self];
	[messagesTable setDelegate:self];
	[messageCenterWindow setDelegate:self];
	
}


#pragma mark -
#pragma mark NSTableView Delegate Methods

- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{

}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	int theRow = [messagesTable selectedRow];
	if (theRow != -1){
		//if
		XBMessage *msg = [messages objectAtIndex:theRow];
		[self loadFullMessage:msg];
	}
	else
		[self loadFullMessage:nil];
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	return YES;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if (!records)
		return 0;
	return [records count];
}

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex 
{
	id theRecord, theValue;
    
	theRecord = [records objectAtIndex:rowIndex];
	theValue = [theRecord objectForKey:[aTableColumn identifier]];

	return theValue;
}

#pragma mark -
#pragma mark Table Loading Methods

- (void)friendsListRefreshed:(NSNotification *)notification {
	[self loadMessageCenterThreaded];
}

- (void)loadMessageCenterThreaded {
    NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadMessageCenter) object:nil];
     [[[[NSApplication sharedApplication] delegate] operationQueue] addOperation:theOp];	
}

- (void)loadMessageCenter
{
    //sometimes it does this twice at the same time to due threads
	[records removeAllObjects];	

	messages = [[XBMessagesParser messages] copy];
	
	int unreadCount = 0;
	for (XBMessage *msg in messages) {
		if (![msg isRead])
			unreadCount++;
		[records addObject:[msg tableViewRecord]];
	}
	
	[messagesTable reloadData];

    NSLog(@"has chececked");
	isGoldMember = [XBMessagesParser isGoldMember];
	    NSLog(@"afterballs");

	//notify in dock and growl
	[self badgeDockIconWithNumber:unreadCount];
	
//	if ([myMessageListObject unreadCount] == 1)
//		[GrowlController notifyWithTitle:@"New Message" description:@"You have one new message from Xbox Live." notificationName:@"New Message" iconImage:nil clickContext:nil];
//	if ([myMessageListObject unreadCount] > 1)
//		[GrowlController notifyWithTitle:@"New Messages" description:[NSString stringWithFormat:@"You have %i new messages from Xbox Live.", [myMessageListObject unreadCount]] notificationName:@"New Message" iconImage:nil clickContext:nil];

}

- (void)loadFullMessage:(XBMessage *)message
{
	NSString *toInsert;

	if (message != nil) {
	
		XBFriend *theFriendObj = [XBFriend friendWithTag:[message sender]];
		
		NSString *theBody = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/message.htm"] encoding:NSMacOSRomanStringEncoding error:NULL];

		NSMutableString *theBodyMut = [theBody mutableCopy];
		
		[theBodyMut replaceOccurrencesOfString:@"$MESSAGE" withString:[message contents] options:0 range:NSMakeRange(0, [theBodyMut length])];
		[theBodyMut replaceOccurrencesOfString:@"$FROM" withString:[theFriendObj realNameWithFormat:XBGamertagRealNameDisplayStyle] options:0 range:NSMakeRange(0, [theBodyMut length])];
		[theBodyMut replaceOccurrencesOfString:@"$DATE" withString:[MQFunctions humanReadableDate:[message date]] options:0 range:NSMakeRange(0, [theBodyMut length])];
		[theBodyMut replaceOccurrencesOfString:@"$EXPDATE" withString:[message expirationDate] options:0 range:NSMakeRange(0, [theBodyMut length])];
		[theBodyMut replaceOccurrencesOfString:@"$SUMMARY" withString:[message subject] options:0 range:NSMakeRange(0, [theBodyMut length])];

		toInsert = [theBodyMut copy];
		[theBodyMut release];
		
	}
	else
		toInsert = @"<html></html>";

	[[messageWebView mainFrame] loadHTMLString:toInsert baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
}

- (IBAction)openMessageCenter:(id)sender
{
		[messageCenterWindow makeKeyAndOrderFront:sender];
		[self loadMessageCenterThreaded];
}

- (IBAction)deleteMessage:(id)sender
{
	int theRow = [messagesTable selectedRow];
	if (theRow != -1){
		NSString *theURL = [NSString stringWithFormat:@"%@%@",@"http://live.xbox.com/en-US/profile/MessageCenter/RemoveMessage.aspx?bk=0&mx=", [[messages objectAtIndex:theRow] identifier]];
		[NSString stringWithContentsOfURL:[NSURL URLWithString:theURL]];
		[self loadMessageCenterThreaded];
	}else
		NSBeep();
}

- (void)badgeDockIconWithNumber:(int)num
{

	if (num >= 1){
		NSImage *icon = [[[NSImage imageNamed:@"NSApplicationIcon"] copy] autorelease];
		NSImage *badge = [NSImage imageNamed:@"badge_1_2"];
		
		NSMutableAttributedString *myString = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i", num]] autorelease];
		[myString beginEditing];
		[myString addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [myString length])];
		[myString addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica-Bold" size:24.0] range:NSMakeRange(0, [myString length])];
		NSMutableParagraphStyle *breakStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		[breakStyle setAlignment:NSCenterTextAlignment];
		static NSDictionary *paraInfo;
		paraInfo = [[[NSDictionary alloc] initWithObjectsAndKeys:breakStyle, NSParagraphStyleAttributeName, nil] autorelease];
		[myString addAttribute:NSParagraphStyleAttributeName value:breakStyle range:NSMakeRange(0, [myString length])];
		[breakStyle release];
		[myString endEditing];
		
		
		[icon lockFocus];
		
		[badge compositeToPoint:NSMakePoint(57.0, 2.0) operation:NSCompositeSourceOver];
		[myString drawInRect:NSMakeRect(57.0, 2.0, 51.0, 43.0)]; 

		[icon unlockFocus];
		
		[NSApp setApplicationIconImage:icon];
		
		[friendsListMessageCount setStringValue:[NSString stringWithFormat:@"%i", num]];
		[friendsListMessageCountBG setHidden:NO];

	}
	else {
	
		[friendsListMessageCount setStringValue:@""];
		[friendsListMessageCountBG setHidden:YES];

		[NSApp setApplicationIconImage:[NSImage imageNamed:@"NSApplicationIcon"]];
	}

}

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
}


#pragma mark -
#pragma mark Sending Related Methods

- (IBAction)openComposePanel:(id)sender
{
	[self sendMessageToFriend:nil];
}

- (void)requestedMessageForFriend:(NSNotification *)notification {
	[self sendMessageToFriend:[notification object]];
}

- (void)sendMessageToFriend:(NSString *)gamertag {
	
	if (![messageCenterWindow isVisible]) {
		[messageCenterWindow makeKeyAndOrderFront:nil];
		[self loadMessageCenterThreaded];
	}
	

	if (isGoldMember) {
		if (gamertag) {
			[recipient setStringValue:gamertag];
			[[messageContents window] makeFirstResponder:messageContents];
		}
		else
			[recipient setStringValue:@""];
		[messageContents setString:@""];
		[NSApp beginSheet:composePanel modalForWindow:messageCenterWindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)  contextInfo:nil];
	}
	else {
		[self displaySimpleErrorMessage:@"Requires Xbox Live Gold" withMessage:@"Sending messages (on the computer) requires an Xbox Live Gold subscription." attachedTo:messageCenterWindow];
	}
}



- (IBAction)replyButton:(id)sender
{
	int theRow = [messagesTable selectedRow];
	if (theRow != -1){
		XBMessage *msg = [messages objectAtIndex:theRow];
		[self sendMessageToFriend:[msg sender]];
	}

}


- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (IBAction)sendMessage:(id)sender
{
	[SendMessage sendMessage:[messageContents string] to:[recipient stringValue] usingWebView:sendMessageWebView];

	[NSApp endSheet:composePanel];
}

- (IBAction)cancelComposePanel:(id)sender
{
	[NSApp endSheet:composePanel];
}


- (BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
	NSString *theString = [messageContents string];
	int numChars = [theString length];
	[charactersUsedText setStringValue:[NSString stringWithFormat:@"%i of 250 char", numChars]];
	[charactersUsedLevel setIntValue:numChars];
	if (affectedCharRange.length > [replacementString length])
		return YES;
	if (numChars >= 250) {
		numChars = 250;
		return NO;
	}
	return YES;
}


@end



























