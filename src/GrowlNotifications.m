//
//  GrowlNotifications.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/6/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "GrowlNotifications.h"
#import <Growl/Growl.h>

@implementation GrowlNotifications




- (NSDictionary *) registrationDictionaryForGrowl
{
	NSArray *theNotifications = [NSArray arrayWithObjects:@"Friend Signed In", @"Friend Signed Out", @"Friend Request Recieved", nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:theNotifications, theNotifications forKeys:@"GROWL_NOTIFICATIONS_ALL", @"GROWL_NOTIFICATIONS_DEFAULT"];	
	return dict;
}

@end

