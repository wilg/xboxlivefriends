//
//  XBFriendDefaultsManager.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/15/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "XBFriendDefaultsManager.h"
#import <AddressBook/AddressBook.h>


@implementation XBFriendDefaultsManager

+ (NSImage *)addressBookImageForPerson:(NSString *)theName {
	NSImage *theOutput;
	@try{
		NSArray *nameParts = [theName componentsSeparatedByString:@" "];
		NSString *inputFirst = [nameParts objectAtIndex:0];
		NSString *inputLast = [nameParts objectAtIndex:1];
		
		ABAddressBook *AB = [ABAddressBook sharedAddressBook];
		ABSearchElement *lastName = [ABPerson searchElementForProperty:kABLastNameProperty label:nil key:nil value:inputLast comparison:kABEqualCaseInsensitive];
		ABSearchElement *firstName = [ABPerson searchElementForProperty:kABFirstNameProperty label:nil key:nil value:inputFirst comparison:kABEqualCaseInsensitive];
		ABSearchElement *fullName = [ABSearchElement searchElementForConjunction:kABSearchAnd children:[NSArray arrayWithObjects:lastName, firstName, nil]];
		NSArray *peopleFound = [AB recordsMatchingSearchElement:fullName];
		
		if ([peopleFound count] == 0)
			return nil;
		ABPerson *thePerson = [peopleFound objectAtIndex:0];
		
		NSData *theData = [thePerson imageData];
		theOutput = [[[NSImage alloc] initWithData:theData] autorelease];
		
	}
	@catch (NSException *exception) {
		theOutput = nil;
	}
	return theOutput;
}

+ (void)setRealName:(NSString *)realName forTag:(NSString *)theTag
{
	NSMutableDictionary *dict = [self prefsDictionaryForTag:theTag];
	[dict setObject:realName forKey:@"realName"];
	[self setPrefsDictionary:dict forTag:theTag];
}

+ (NSString *)realNameForTag:(NSString *)theTag
{
	return [[self prefsDictionaryForTag:theTag] objectForKey:@"realName"];
}

+ (void)setIconStyle:(int)style forTag:(NSString *)theTag
{
	NSMutableDictionary *dict = [self prefsDictionaryForTag:theTag];
	[dict setObject:[NSNumber numberWithInt:style] forKey:@"iconStyle"];
	[self setPrefsDictionary:dict forTag:theTag];
}

+ (int)iconStyleForTag:(NSString *)theTag
{
	NSNumber *styleNum = [[self prefsDictionaryForTag:theTag] objectForKey:@"iconStyle"];
	if (styleNum == nil)
		return XBGamerPictureIconStyle;
	return [styleNum intValue];
}

+ (void)setShouldShowNotifications:(BOOL)theBool forTag:(NSString *)theTag
{
	NSMutableDictionary *dict = [self prefsDictionaryForTag:theTag];
	[dict setValue:[NSNumber numberWithBool:theBool] forKey:@"shouldShowNotifications"];
	[self setPrefsDictionary:dict forTag:theTag];
}

+ (BOOL)shouldShowNotificationsForTag:(NSString *)theTag
{
	NSNumber *theNum = [[self prefsDictionaryForTag:theTag] objectForKey:@"shouldShowNotifications"];
	if (theNum == nil)
		theNum = [NSNumber numberWithBool:YES];
	return [theNum boolValue];
}

+ (NSMutableDictionary *)prefsDictionaryForTag:(NSString *)theTag
{
	NSDictionary *realNamePrefs = [[NSUserDefaults standardUserDefaults] objectForKey:@"GamerPreferences"];
	if (realNamePrefs == nil)
		realNamePrefs = [NSDictionary dictionary];
	NSDictionary *myDict = [realNamePrefs objectForKey:theTag];
	if (myDict == nil)
		myDict = [NSDictionary dictionary];
	return [myDict mutableCopy];
}

+ (void)setPrefsDictionary:(NSMutableDictionary *)dict forTag:(NSString *)theTag
{
	NSDictionary *realNamePrefs = [[NSUserDefaults standardUserDefaults] objectForKey:@"GamerPreferences"];
	if (realNamePrefs == nil)
		realNamePrefs = [NSDictionary dictionary];
	NSMutableDictionary *prefsMut = [realNamePrefs mutableCopy];
	[prefsMut setObject:[dict copy] forKey:theTag];
	[[NSUserDefaults standardUserDefaults] setObject:[prefsMut copy] forKey:@"GamerPreferences"];
	[prefsMut release];
}


+ (void)setupDefaults
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
        dictionaryWithObject:[NSDictionary dictionary] forKey:@"GamerPreferences"];
 	
    [defaults registerDefaults:appDefaults];

}
@end
