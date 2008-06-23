//
//  XBReputationView.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 9/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XBReputationView : NSView {

	float reputationPercentage;

}

- (float)reputationPercentage;
- (void)setReputationPercentage:(float)percent;


@end
