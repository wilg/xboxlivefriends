//
//  Controller.h
//  Xbox Live Friends
//
//  i trip blind kids, what's your anti-drug?
// 
//  © 2006 mindquirk
//  

#import <Cocoa/Cocoa.h>
#import "StayAround.h"

@interface Controller : NSObject {

	//misc
	IBOutlet NSTextView *sourceLogger;
	NSTimer *refreshTimer;
	IBOutlet NSButton *autoRefresh;
	IBOutlet NSTextField *refreshTime;

	BOOL isRegistered;
	NSOperationQueue *queue;
	
	IBOutlet NSMenuItem *debugMenu;
}
+ (StayAround *)stayArounds;

- (NSOperationQueue *)operationQueue;
- (void)timedRefresh;
- (void)startRefreshTimer;
- (IBAction)toggleRefreshTimer:(id)sender;
- (IBAction)changeRefreshTime:(id)sender;


@end
