//
//  XBMessageList.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "XBMessagesParser.h"

NSString* messageCenterURL = @"http://live.xbox.com/en-US/profile/MessageCenter/ViewMessages.aspx";

@implementation XBMessagesParser

+ (NSArray *)messages {
	NSString *theSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:messageCenterURL]];

	NSMutableArray *allMessages = [NSMutableArray array];
	
	theSource = [theSource cropFrom:@"/thead" to:@"</table>"];
	
	NSArray *rows = [theSource cropRowsMatching:@"<tbody" rowEnd:@"</tbody>"];
	
	
//	BOOL demoMode = YES;
//	
//	XBMessage *x;
//	if (demoMode) {
//		//demo mode shit
//		x = [XBMessage messageWithSender:@"Foot Kablamo" date:[NSDate dateWithTimeIntervalSinceNow:-2344] type:XBTextMessageType subject:@"do you want to pl..." expirationDate:@"30 days" isRead:NO identifier:@"ewfnoewa"];
//		[x setContents:@"<p>do you want to play halo later?</p>"];
//		[allMessages addObject:x];
//		
//		x = [XBMessage messageWithSender:@"durrik" date:[NSDate dateWithTimeIntervalSinceNow:-4393] type:XBTextMessageType subject:@"hey have you seen the new..." expirationDate:@"30 days" isRead:NO identifier:@"ewfnoewa"];
//		[x setContents:@"<p>hey have you seen the new crazy shit on my page?</p>"];
//		[allMessages addObject:x];
//
//
//		x = [XBMessage messageWithSender:@"RxE xMoNoToNiCx" date:[NSDate dateWithTimeIntervalSinceNow:-10393] type:XBTextMessageType subject:@"i sure love mindquir..." expirationDate:@"30 days" isRead:NO identifier:@"ewfnoewa"];
//		[x setContents:@"<p>WTF?!?!?</p><p>Infinitly ridiculous! Someone referred to me, an upstanding citizen, in an untoward manner inside of the online community of &quot;Halo the Third&quot;!</p><p>I, for one, was apalled!</p><p>However, this is clearly a singular occurance, and I will not let it dissuade me from playing on-line in the Xbox Live community.</p><p>I bid you good-day, ladies and gentlemen.</p>"];
//		[allMessages addObject:x];
//
//	}
	
	for (NSString *row in rows) {
		NSString *gamertag = [row cropFrom:@"headers=\"GamerTag\">" to:@"/a>"];
		gamertag = [gamertag cropFrom:@"\">" to:@"<"];
		NSString *identifier = [row cropFrom:@"http://live.xbox.com/en-US/profile/MessageCenter/ViewMessage.aspx?mx=" to:@"\""];
		
		NSString *tbodyClass = [row cropFrom:@"class=\"" to:@"\""];
		BOOL isRead = YES;
		if ([tbodyClass isEqual:@"XbcMessageUnread"])
			isRead = NO;
		
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

		NSString *subject = [row cropFrom:@"headers=\"Summary\">" to:@"<"];
		subject = [MQFunctions flattenHTML:subject];
		
		int theType;
		if ([subject isEqual:@"Wants to be your friend."])
			theType = XBFriendRequestMessageType;
		else if ([subject isEqual:@"Sent you a voice message"])
			theType = XBVoiceMessageType;
		else
			theType = XBTextMessageType;


		XBMessage *thisMessage = [XBMessage messageWithSender:gamertag date:sentDate type:theType subject:subject expirationDate:nil isRead:isRead identifier:identifier];
		
		if (theType != XBFriendRequestMessageType)
			[allMessages addObject:thisMessage];
		

	}
		
	return [[allMessages copy] autorelease];

}

+ (BOOL)isGoldMember {
	NSString *theSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://live.xbox.com/en-US/profile/MessageCenter/SendMessage.aspx"]];
	return ![theSource contains:@"You must be an Xbox LIVE Gold member to send messages."];
}


@end
