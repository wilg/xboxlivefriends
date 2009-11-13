//
//  XBMessageCenterController.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XBMessageCenterController : NSObject {

    IBOutlet WebView *messageWebView;
	IBOutlet NSTableView *messagesTable;
	IBOutlet NSWindow *messageCenterWindow;
	
	IBOutlet NSWindow *composePanel;
	IBOutlet NSLevelIndicator *charactersUsedLevel;
	IBOutlet NSTextView *messageContents;
	IBOutlet NSTextField *recipient;
	IBOutlet NSTextField *charactersUsedText;

	IBOutlet NSTextField *friendsListMessageCount;
	IBOutlet NSImageView *friendsListMessageCountBG;


	IBOutlet WebView *sendMessageWebView;
    
	NSMutableArray *records;
	NSArray *messages;
	
	NSArray *newMessagesAlreadyNotified;
    
	BOOL isGoldMember;
}

- (void)loadMessageCenterThreaded;
- (void)loadMessageCenter;
- (IBAction)openMessageCenter:(id)sender;
- (void)loadFullMessage:(XBMessage *)message;
- (void)badgeDockIconWithNumber:(int)num;
- (void)displaySimpleErrorMessage:(NSString *)headline withMessage:(NSString *)message attachedTo:(NSWindow *)theWindow;

- (void)sendMessageToFriend:(NSString *)gamertag;
- (IBAction)replyButton:(id)sender;
- (IBAction)openComposePanel:(id)sender;
- (IBAction)cancelComposePanel:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (IBAction)deleteMessage:(id)sender;

@end
