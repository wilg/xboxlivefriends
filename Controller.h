//
//  Controller.h
//  Xbox Live Friends
//
//  i trip blind kids, what's your anti-drug?
// 
//  � 2006 mindquirk
//  

#import <Cocoa/Cocoa.h>

@interface Controller : NSObject {

	//misc
	IBOutlet NSTextView *sourceLogger;
	NSTimer *refreshTimer;

	BOOL isRegistered;
	NSOperationQueue *queue;
}

- (NSOperationQueue *)operationQueue;
- (void)timedRefresh;


@end
