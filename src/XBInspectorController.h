//
//  XBInspectorController.h
//  Xbox Live Friends
//
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XBInspectorController : NSObject {



	IBOutlet NSWindow *inspectorWindow;
	IBOutlet NSImageView *inspectorImage;
	
	//card tab
	IBOutlet NSTextField *inspectorTag;
	IBOutlet NSTextField *inspectorMessage;
	IBOutlet NSTextField *inspectorScore;
	IBOutlet NSTextField *inspectorZone;
	IBOutlet XBReputationView *inspectorRep;

	//requests
	IBOutlet NSButton *requestDeny;
	IBOutlet NSButton *requestAccept;
	IBOutlet NSButton *requestCancel;
	IBOutlet NSTextField *requestName;

	//options tab
	IBOutlet NSMatrix *iconOptionsMatrix;
	IBOutlet NSTextField *realName;
	IBOutlet NSButton *notificationsCheckbox;

	IBOutlet NSSegmentedControl *fakeTabs;
	IBOutlet NSTabView *inspectorTabView;
	IBOutlet NSProgressIndicator *loadingIndicator;

    IBOutlet WebView *inspectorWebView;

	BOOL _extended;
}

+ (XBInspectorController *)sharedInstance;


- (void)CheckAddressBookForImageAndDisableRadio;
- (void)refreshInspector;
- (void)displayCard:(XBGamercard *)myCard;
- (void)displayEmptyCard;

- (void)showLoadingTab;
- (void)hideLoadingTab;

- (BOOL)shouldUpdateInspector;
- (void)openInspectorDoubleClick;

- (void)showRequestManager:(int)type;
- (void)extendWindowBy:(int) amount;
- (void)setExtended:(BOOL)extend;

+ (XBFriend *)currentlySelectedFriend;


- (void)setCurrentlySelectedFriend:(XBFriend *)theFriend;

- (void)displayGamesPlayedForFriend:(XBFriend *)theFriend;

- (IBAction)RadioButtonClicked:(id)sender;
- (IBAction)TextEndEditing:(id)sender;
- (IBAction)OpenInspector:(id)sender;
- (IBAction)notificationBoxClicked:(id)sender;

- (IBAction)cancelFriendRequest:(id)sender;
- (IBAction)acceptFriendRequest:(id)sender;
- (IBAction)denyFriendRequest:(id)sender;


- (NSAttributedString *)boldThis:(NSString *)toBold withRegularText:(NSString *)toRegular;


@end
