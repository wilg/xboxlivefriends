//
//  GrowlController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GrowlController.h"

@implementation GrowlController

- (id)init;
{
	if (![super init])
	return nil;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(growlWithNotification:) name:@"GrowlNotify" object:nil];

	[GrowlApplicationBridge setGrowlDelegate:self];

	NSLog(@"growl init");

	return self;
}


- (NSDictionary *)registrationDictionaryForGrowl {
	NSArray *objects = [NSArray arrayWithObjects:@"Friend Signed In", @"Friend Signed Out", @"Friend Is Joinable", @"New Friend Request", @"New Message", @"Friend Switched Game", nil];
	NSDictionary *growlReg = [NSDictionary dictionaryWithObjectsAndKeys: @"Xbox Live Friends", GROWL_APP_NAME, objects, GROWL_NOTIFICATIONS_ALL, objects, GROWL_NOTIFICATIONS_DEFAULT, nil];
	return growlReg;
}


- (void)notifyWithTitle:(NSString *)title description:(NSString *)description notificationName:(NSString *)notificationName iconImage:(NSImage *)iconImage  clickContext:(id)clickContext
{

	[GrowlApplicationBridge notifyWithTitle:title description:description notificationName:notificationName iconData:[iconImage TIFFRepresentation] priority:0 isSticky:YES clickContext:clickContext];

}

- (void)notifyWithDictionary:(NSDictionary *)dick
{
	NSLog(@"notifyWithDictionary growl");
	//[GrowlApplicationBridge notifyWithDictionary:dick];
	
	[GrowlApplicationBridge notifyWithTitle:[dick objectForKey:@"GROWL_NOTIFICATION_TITLE"] description:[dick objectForKey:@"GROWL_NOTIFICATION_DESCRIPTION"] notificationName:[dick objectForKey:@"GROWL_NOTIFICATION_NAME"] iconData:[dick objectForKey:@"GROWL_NOTIFICATION_ICON"] priority:0 isSticky:NO clickContext:nil];

}

- (void)growlWithNotification:(NSNotification *)notification {
	NSLog(@"growlWithNotification");
	[self notifyWithDictionary:[notification object]];
}


@end
