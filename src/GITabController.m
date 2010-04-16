//
//  GITabController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 5/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GITabController.h"
#import "Controller.h"

@implementation GITabController

@synthesize lastFetch, lastFetchTag;
@dynamic errorForTab;

- (id)init {
	if (![super init])
	return nil;
	
	[[Controller stayArounds] addObject:self];

	[self setErrorForTab:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedToLoad:) name:[self notificationName] object:nil];
	
	return self;
}

- (NSString *)notificationName {
	// Override this in your controller
	return @"AddNotificationNameHere";
}

- (BOOL)postsDoneNotificationAutomatically {
	// you may override this in your controller
	return true;
}

- (BOOL)threadedLoad {
	// you may override this in your controller
	return true;
}


- (void)notifiedToLoad:(NSNotification *)notification {
	[self tabBecameVisible];
	NSString *gamertag = [[[notification object] copy] autorelease];
	@try{
		if (![gamertag isEqual:lastFetchTag] && gamertag != nil) {
			[self setLastFetchTag:gamertag];
			[self clearErrorForTab];
			[self clearTab];
			if ([self threadedLoad]) {
				NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(tabLoadThread:) object:gamertag];
				[[[NSApp delegate] operationQueue] addOperation:theOp];	
				//[NSThread detachNewThreadSelector:@selector(tabLoadThread:) toTarget:self withObject:gamertag];
			}
			else {
				[self displayGamerInfo:gamertag];
				if ([self postsDoneNotificationAutomatically])
					[self loadingComplete];
			}
		}
		else {
			if ([self errorForTab]) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"GIRequestFailed" object:[self errorForTab]];
				return;
			}

			[self loadingComplete];
		}
	}
	@catch(NSException *exception) {
		NSLog(@"GITabController caught exception");
		NSLog(@"%@", [exception reason]);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GIRequestFailed" object:nil];
	}	
}

- (void)loadingComplete {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GIPaneDoneLoading" object:nil];
}

- (void)tabLoadThread:(NSString *)gamertag  {
	[self displayGamerInfo:gamertag];

	if ([self postsDoneNotificationAutomatically])
		[self loadingComplete];
}

- (NSString *)errorForTab {
    return errorForTab;
}
 
- (void)setErrorForTab:(NSString *)newValue {
    if (newValue != errorForTab) {
        errorForTab = [newValue copy];
		if ([self errorForTab])
			[[NSNotificationCenter defaultCenter] postNotificationName:@"GIRequestFailed" object:[self errorForTab]];
    }
}

- (void)clearErrorForTab {
	errorForTab = nil;
}


- (void)displayGamerInfo:(NSString *)gamertag {

}

- (void)clearTab {

}

- (void)tabBecameVisible {

}


@end
