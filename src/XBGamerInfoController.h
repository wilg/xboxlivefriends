//
//  XBGamerInfoController.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	OpenProgressBarPanelReturnCode = 11701,
	CloseWindowPanelReturnCode = 11702,
	ErrorPanelReturnCode = 11703,
} PanelReturnCode;

@interface XBGamerInfoController : NSObject {

	IBOutlet NSPanel *lookupPanel;
	IBOutlet NSPanel *progressPanel;
	IBOutlet NSPanel *errorPanel;
	IBOutlet NSWindow *gamerInfoWindow;
	IBOutlet NSTextField *gamertagInputField;

	IBOutlet NSProgressIndicator *spinner;
	IBOutlet NSProgressIndicator *progressPanelIndicator;
	IBOutlet NSTextField *progressPanelText;

	IBOutlet NSTextField *gamerscore;
	IBOutlet NSTextField *gamertag;
	IBOutlet NSTextField *motto;
	IBOutlet NSImageView *tile;

	NSString *currentTabName;
	NSString *currentGamertag;
}

@property(copy) NSString *currentGamertag;
@property(copy) NSString *currentTabName;

- (void)lookupRequest:(NSNotification *)notification;
-(void)openGamerInfoWindow;

- (IBAction)openLookupPanel:(id)sender;
- (IBAction)closeLookupPanel:(id)sender;
- (IBAction)lookupButtonPressed:(id)sender;

- (void)startSpinner:(NSNotification *)notification;
- (void)stopSpinner:(NSNotification *)notification;
- (void)paneDoneLoading:(NSNotification *)notification;

-(void)fullLookup:(NSString *)gamertagString;
- (void)lookupGamerInfo:(NSString *)gamertagString;

- (void)loadCurrentTab;
- (void)closeProgressPanel;
- (void)openProgressPanel;

- (void)openErrorPanel;
- (IBAction)closeErrorPanel:(id)sender;

@end
