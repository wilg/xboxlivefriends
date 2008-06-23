//
//  GrowlController.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>


@interface GrowlController : NSObject <GrowlApplicationBridgeDelegate>  {

}

- (void)notifyWithDictionary:(NSDictionary *)dick;
- (void)growlWithNotification:(NSNotification *)notification;
- (NSDictionary *)registrationDictionaryForGrowl;

@end
