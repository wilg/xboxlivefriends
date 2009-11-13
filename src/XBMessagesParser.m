//
//  XBMessageList.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#include "XBMessage.h"
#import "XBMessagesParser.h"

NSString* messageCenterURL = @"http://live.xbox.com/en-US/profile/MessageCenter/ViewMessages.aspx";

@implementation XBMessagesParser

+ (NSArray *)messages {

	NSMutableArray *allMessages = [NSMutableArray array];
	NSString *theSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:messageCenterURL]];

	theSource = [theSource cropFrom:@"/thead" to:@"</table>"];
	NSArray *rows = [theSource cropRowsMatching:@"<tbody" rowEnd:@"</tbody>"];
	
	
	BOOL demoMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"DebugDemoMode"];
	
	if (demoMode) {
	
		XBMessage *x = [XBMessage message];

		x.sender = @"Foot Kablamo";
		x.date = [NSDate dateWithTimeIntervalSinceNow:-2344];
		x.type = XBTextMessageType;
		x.subject = @"do you want to pl...";
		x.expirationDate = @"30 days";
		x.identifier = @"rewfiowenmfoewa";
		x.contents = @"<p>do you want to play halo later?</p>";
		
		[allMessages addObject:x];

		XBMessage *y = [XBMessage message];

		y.sender = @"durrik";
		y.date = [NSDate dateWithTimeIntervalSinceNow:-4393];
		y.type = XBTextMessageType;
		y.subject = @"hey have you seen the new...";
		y.expirationDate = @"30 days";
		y.identifier = @"fioejwfioaejwoifejawo";
		y.contents = @"<p>hey have you seen the new crazy shit on my page?</p>";
		
		[allMessages addObject:y];

		XBMessage *z = [XBMessage message];
		
		z.sender = @"RxE xMoNoToNiCx";
		z.date = [NSDate dateWithTimeIntervalSinceNow:-10393];
		z.type = XBTextMessageType;
		z.subject = @"WTF?!?!? Inf...";
		z.expirationDate = @"30 days";
		z.identifier = @"4398j834fn8wjf";
		z.contents = @"<p>WTF?!?!?</p><p>Infinitly ridiculous! Someone referred to me, an upstanding citizen, in an untoward manner inside of the online community of &quot;Halo the Third&quot;!</p><p>I, for one, was apalled!</p><p>However, this is clearly a singular occurance, and I will not let it dissuade me from playing on-line in the Xbox Live community.</p><p>I bid you good-day, ladies and gentlemen.</p>";
		
		[allMessages addObject:z];

	}
	
	for (NSString *row in rows) {
		XBMessage *rowMessage = [XBMessage message];
	
		NSString *gamertag = [row cropFrom:@"headers=\"GamerTag\">" to:@"/a>"];
		gamertag = [gamertag cropFrom:@"\">" to:@"<"];
		rowMessage.sender = gamertag;
		
		rowMessage.identifier = [row cropFrom:@"http://live.xbox.com/en-US/profile/MessageCenter/ViewMessage.aspx?mx=" to:@"\""];
		
		NSString *tbodyClass = [row cropFrom:@"class=\"" to:@"\""];
		BOOL isRead = YES;
		if ([tbodyClass isEqual:@"XbcMessageUnread"])
			isRead = NO;
			
		rowMessage.isRead = isRead;
		
		NSDate *sentDate = [NSDate date];
		@try {
			NSString *dateSent = [row cropFrom:@"_xbcDisplayDate(" to:@")"];
			dateSent = [NSString stringWithFormat:@"%@ GMT", dateSent];
			
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%m, %d, %Y, %H, %M %Z" allowNaturalLanguage:NO] autorelease];
			
			NSDate *theDate = [dateFormatter dateFromString:dateSent];
//			// for some reason microsoft fucking needs a month to be added to the date
			unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
			NSDateComponents *comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:theDate];
			[comps setMonth:[comps month] + 1];
			theDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
			
			if (theDate == nil)
				theDate = [NSDate date];
			
			sentDate = theDate;
		}
		@catch (NSException *err) {
		
		}
		
		rowMessage.date = sentDate;

		NSString *subject = [row cropFrom:@"headers=\"Summary\">" to:@"<"];
		subject = [MQFunctions flattenHTML:subject];
		
		int theType;
		if ([subject isEqual:@"Wants to be your friend."])
			theType = XBFriendRequestMessageType;
		else if ([subject isEqual:@"Sent you a voice message"])
			theType = XBVoiceMessageType;
		else
			theType = XBTextMessageType;

		rowMessage.type = theType;
		rowMessage.subject = subject;
		
		if (theType != XBFriendRequestMessageType)
			[allMessages addObject:rowMessage];
		

	}
		
	return allMessages;

}

+ (BOOL)isGoldMember {
	NSString *theSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://live.xbox.com/en-US/profile/MessageCenter/SendMessage.aspx"]];
	return ![theSource contains:@"You must be an Xbox LIVE Gold member to send messages."];
}


@end
