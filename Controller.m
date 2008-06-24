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

@implementation Controller

#pragma mark -
#pragma mark Application Delegates


- (id)init {
	
	if (![super init])
	return nil;
	
	//[MQFunctions startDebugLog];

	[NSApp setDelegate:self];
	[XBFriendDefaultsManager setupDefaults];
	
	refreshTimer = nil;
		
	[[GrowlController alloc] init];
	
	queue = [[NSOperationQueue alloc] init];
		
	if (refreshTimer == nil)
		refreshTimer = [[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(timedRefresh) userInfo:nil repeats:YES] retain];


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

}

- (void)awakeFromNib {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ShowDebugMenu"])
		[[debugMenu menu] removeItem:debugMenu];
}


#pragma mark -
#pragma mark Miscellaneous

- (void)timedRefresh {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"InSignInMode"]) {
		NSLog(@"Timed Refresh");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
	}
	else {
		NSLog(@"Tried to refresh, but the sign in panel was open.");
	}
}

@end







