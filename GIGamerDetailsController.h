//
//  GIGamerDetailsController.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 5/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GIGamerDetailsController : GITabController {

	IBOutlet NSTextField *name;
	IBOutlet NSTextField *location;
	IBOutlet NSTextField *bio;
	IBOutlet NSTextField *zone;
	IBOutlet NSImageView *avatar;

	IBOutlet XBReputationView *reputation;
}

@end
