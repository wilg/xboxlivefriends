//
//  Controller.m
//  Xbox Live Friends
//
//  i trip blind kids, what's your anti-drug?
// 
//  © 2006 mindquirk
//  
#import "Xbox Live Friends.h"
#import "Controller.h"
#import "GrowlController.h"
#import "LoginController.h"

StayAround *stayArounds;

@implementation Controller

#pragma mark -
#pragma mark Application Delegates

+ (StayAround *)stayArounds {
	if (!stayArounds)
		stayArounds = [[StayAround alloc] init];
	return stayArounds;
}

- (id)init {
	
	if (![super init])
	return nil;
	
	[Controller stayArounds];
	
	//[MQFunctions startDebugLog];

	[NSApp setDelegate:self];
	[XBFriendDefaultsManager setupDefaults];
	
	refreshTimer = nil;
		
	[[GrowlController alloc] init];
	
	queue = [[NSOperationQueue alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRefreshTimer) name:@"StartRefreshTimer" object:nil];
	 
	/*
	if (refreshTimer == nil) {
		refreshTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(timedRefresh) userInfo:nil repeats:YES];
	}
	 */

	return self;
	
}

- (NSOperationQueue *)operationQueue {
	return queue;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[NSApp setApplicationIconImage:[NSImage imageNamed:@"NSApplicationIcon"]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"InSignInMode"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"friendsListIsLoadedAndReady"];
}

- (void)awakeFromNib {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ShowDebugMenu"]) {
		[[debugMenu menu] removeItem:debugMenu];
	}
	
	if ([autoRefresh state]) {
		[autoRefresh setTitle:@"On"];
	} else {
		[autoRefresh setTitle:@"Off"];
	}
}


#pragma mark -
#pragma mark Refresh Controls

- (void)startRefreshTimer
{
	if ([autoRefresh state]) {
		int timeInt = [[refreshTime stringValue] intValue];
		NSLog(@"%i", timeInt);
		if (timeInt < 30) {
			timeInt = 30;
		}
		refreshTimer = [NSTimer scheduledTimerWithTimeInterval:timeInt target:self selector:@selector(timedRefresh) userInfo:nil repeats:YES];
	}
}

- (IBAction)toggleRefreshTimer:(id)sender
{
	if ([autoRefresh state]) {
		[autoRefresh setTitle:@"On"];
		int timeInt = [[refreshTime stringValue] intValue];
		if (timeInt < 30) {
			timeInt = 30;
		}
		refreshTimer = [NSTimer scheduledTimerWithTimeInterval:timeInt target:self selector:@selector(timedRefresh) userInfo:nil repeats:YES];
	} else {
		// ![autoRefresh state];
		[autoRefresh setTitle:@"Off"];
		[refreshTimer invalidate];
	}
}

- (IBAction)changeRefreshTime:(id)sender
{
	int timeInt = [[refreshTime stringValue] intValue];
	if (timeInt < 30) {
		timeInt = 30;
	}
	NSLog(@"Changing refresh time to: %i", timeInt);
	if ([autoRefresh state]) {
		NSLog(@"Refresh is on");
		[refreshTimer invalidate];
		refreshTimer = [NSTimer scheduledTimerWithTimeInterval:timeInt target:self selector:@selector(timedRefresh) userInfo:nil repeats:YES];
	}
}

- (void)timedRefresh 
{
	if ([LoginController isLoggedIn]) {
		if (![[NSUserDefaults standardUserDefaults] boolForKey:@"InSignInMode"]) {
			NSLog(@"Timed Refresh");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
		} else {
			NSLog(@"Tried to refresh, but the sign in panel was open.");
		}
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListConnectionError" object:nil];
	}
}

@end







