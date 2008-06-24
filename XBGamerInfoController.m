//
//  XBGamerInfoController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "XBGamerInfoController.h"


@implementation XBGamerInfoController

@synthesize currentGamertag, currentTabName;


- (id)init	{
	if (![super init])
	return nil;
	
	[self setCurrentGamertag: nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openLookupPanel:) name:@"GIOpenLookupWindow" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lookupRequest:) name:@"GIRequestLookupWithTag" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabSelectionChanged:) name:@"GamerInfoTabChanged" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSpinner:) name:@"GIStartProgressIndicator" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSpinner:) name:@"GIStopProgressIndicator" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paneDoneLoading:) name:@"GIPaneDoneLoading" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestFailed:) name:@"GIRequestFailed" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamercardLoaded:) name:@"GIGamercardLoaded" object:nil];
	
	return self;
}


- (void)lookupRequest:(NSNotification *)notification
{
	[self openGamerInfoWindow];
	[self openProgressPanel];
	[self fullLookup:[notification object]];
}

- (void)requestFailed:(NSNotification *)notification
{
	[self closeProgressPanel];
	[self stopSpinner:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GIShowErrorTab" object:[notification object]];
}

-(void)openGamerInfoWindow {
    if (!gamerInfoWindow) {
        if (![NSBundle loadNibNamed:@"GamerInfo" owner:self])  {
            NSLog(@"Failed to load GamerInfo nib");
            NSBeep();
            return;
        }
	}
	
	[gamerInfoWindow setAutorecalculatesContentBorderThickness:NO forEdge:NSMaxYEdge];
	[gamerInfoWindow setContentBorderThickness:50.0 forEdge:NSMaxYEdge];
	
	[gamerInfoWindow setAutorecalculatesContentBorderThickness:NO forEdge:NSMinYEdge];
	[gamerInfoWindow setContentBorderThickness:30.0 forEdge:NSMinYEdge];

	
	[[gamertag cell] setBackgroundStyle:NSBackgroundStyleRaised];

	
	[gamerInfoWindow orderFront:nil];
}

- (IBAction)openLookupPanel:(id)sender {
	[self openGamerInfoWindow];
	[NSApp beginSheet:lookupPanel modalForWindow:gamerInfoWindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)  contextInfo:nil];
}

- (IBAction)closeLookupPanel:(id)sender {
	[NSApp endSheet:lookupPanel returnCode:CloseWindowPanelReturnCode];
}


- (IBAction)lookupButtonPressed:(id)sender {
	if ([[gamertagInputField stringValue] isEqualToString:@""]) {
		[self closeLookupPanel:nil];
		return;
	}
	[NSApp endSheet:lookupPanel returnCode:OpenProgressBarPanelReturnCode];
	[self fullLookup:[gamertagInputField stringValue]];
}

-(void)fullLookup:(NSString *)gamertagString
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GIEnableSources" object:nil];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"GIStartProgressIndicator" object:nil];

    NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(lookupGamerInfoThreaded:) object:[gamertagString copy]];
     [[[[NSApplication sharedApplication] delegate] operationQueue] addOperation:theOp];

}

-(void)gamercardLoaded:(NSNotification *) notification {

	XBGamercard *theGamercard = [notification object];

	if ([theGamercard gamertag] == nil) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIRequestFailed" object:@"Gamertag Not Found"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIShowErrorTabModal" object:nil];
		[gamertag setStringValue:@""];
		[gamerscore setStringValue:@""];
		[tile setImage:nil];
		return;
	}

	[self setCurrentGamertag:[theGamercard gamertag]];
	[gamertag setStringValue:[theGamercard gamertag]];
	[gamerscore setStringValue:[theGamercard gamerscore]];
	[tile setImage:[theGamercard gamertileImage]];

	if ([[[theGamercard gamertileURL] absoluteString] isEqualToString:@"http://tiles.xbox.com/tiles/8y/ov/0Wdsb2JhbC9EClZWVEoAGAFdL3RpbGUvMC8yMDAwMAAAAAAAAAD+ACrT.jpg"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIRequestFailed" object:@"No Gamer Info for Original Xbox Accounts"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIShowErrorTabModal" object:nil];
		return;
	}


	[self loadCurrentTab];
}

- (void)lookupGamerInfo:(NSString *)gamertagString
{
//	NSLog(@"begin lookupGamerInfo");
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"GIStartProgressIndicator" object:nil];
//	[self setCurrentGamertag:[gamertagString copy]];
//	[progressPanelText setStringValue:@"Loading Gamercard..."];
//	@try{
//		XBGamercard *theGamercard = [XBGamercard cardForFriend:[XBFriend friendWithTag:gamertagString]];
//		NSLog(@"XBGamercard looked up");
//		[gamertag setStringValue:[theGamercard gamertag]];
//		[gamerscore setStringValue:[theGamercard gamerscore]];
//		[tile setImage:[theGamercard gamertileImage]];
//		NSLog(@"UI values set");
//		[self setCurrentGamertag:[theGamercard gamertag]];
//		NSLog(@"gamertag var set");
//	}
//	@catch(NSException *err) {
////		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIRequestFailed" object:@"Gamertag not found."];
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIRequestFailed" object:[NSString stringWithFormat:@"%@: %@", [err name], [err reason]]];
//	}
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"GIGamercardLoaded" object:nil];
//	NSLog(@"notification posted");
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"GIStopProgressIndicator" object:nil];
//	NSLog(@"end lookupGamerInfo");
}

- (void)lookupGamerInfoThreaded:(NSString *)gamertagString {

	XBGamercard *theGamercard = [XBGamercard cardForFriend:[XBFriend friendWithTag:gamertagString]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GIGamercardLoaded" object:theGamercard];

}

- (void)tabSelectionChanged:(NSNotification *)notification
{
	[self setCurrentTabName:[notification object]];
	if (currentGamertag) {
		[self loadCurrentTab];
	}
}

- (void)loadCurrentTab
{
	
	[self startSpinner:nil];
	[progressPanelText setStringValue:[NSString stringWithFormat:@"Loading %@...", currentTabName]];

	if ([currentTabName isEqual:@"Achievements"])
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIAchievementsLoadNotification" object:currentGamertag];
	if ([currentTabName isEqual:@"Breakdown"])
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIBreakdownChartLoadNotification" object:currentGamertag];
	if ([currentTabName isEqual:@"Service Record"])
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIHaloServiceRecordLoadNotification" object:currentGamertag];
	if ([currentTabName isEqual:@"Screenshots"])
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIHaloScreenshotLoadNotification" object:currentGamertag];
	if ([currentTabName isEqual:@"Details"])
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIDetailsLoadNotification" object:currentGamertag];

}

- (void)startSpinner:(NSNotification *)notification
{
	[progressPanelIndicator setUsesThreadedAnimation:YES];
	[spinner startAnimation:nil];
	[progressPanelIndicator startAnimation:nil];
}

- (void)stopSpinner:(NSNotification *)notification
{
	[spinner stopAnimation:nil];
	[progressPanelIndicator stopAnimation:nil];
}

- (void)paneDoneLoading:(NSNotification *)notification
{
	[self stopSpinner:nil];
	[self closeProgressPanel];
}

- (void)openProgressPanel
{
	[NSApp beginSheet:progressPanel modalForWindow:gamerInfoWindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)  contextInfo:nil];
}

- (void)closeProgressPanel
{
	if ([progressPanel isVisible]) {
		[NSApp endSheet:progressPanel];
	}
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
	if (returnCode == CloseWindowPanelReturnCode) {
		[gamerInfoWindow orderOut:nil];
	}
	if (returnCode == OpenProgressBarPanelReturnCode) {
		[self openProgressPanel];
	}
}

@end
