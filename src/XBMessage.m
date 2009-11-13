//
//  XBTextMessage.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "XBMessage.h"


@implementation XBMessage

@synthesize isRead, sender, date, type, contents, subject, expirationDate, identifier;

+ (XBMessage *)message {
	return [[XBMessage alloc] init];
}

- (NSDictionary *)tableViewRecord {
	NSMutableDictionary *record = [NSMutableDictionary dictionary];
	
	if (self.isRead)
		[record setObject:[NSImage imageNamed:@"empty"] forKey:@"bead"];
	else
		[record setObject:[NSImage imageNamed:@"blue_bead"] forKey:@"bead"];
		

	[record setObject:self.sender forKey:@"from"];
	[record setObject:self.subject forKey:@"message"];
	[record setObject:[MQFunctions humanReadableDate:self.date] forKey:@"date"];
	
	if ([self type] == XBVoiceMessageType){
		[record setObject:[NSImage imageNamed:@"speaker"] forKey:@"attachment"];
		[record setObject:@"Voice Message" forKey:@"message"];
	}
	else
		[record setObject:[NSImage imageNamed:@"empty"] forKey:@"attachment"];

	return record;
}

- (NSString *)contents {
	if (!contents)
		[self parseFullMessage];
	return contents;
}

- (NSString *)expirationDate {
	if (!expirationDate)
		expirationDate = @"Unknown";
	return expirationDate;
}

- (void)parseFullMessage {

	NSURL *theURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://live.xbox.com/en-US/profile/MessageCenter/ViewMessage.aspx?mx=", [self identifier]]];
	NSString *theSource = [NSString stringWithContentsOfURL:theURL];
		
	NSString *parsedMessage = [theSource cropFrom:@"<div class=\"XbcMessageTextPanel\">" to:@"</div>"];
	if (parsedMessage)
		self.contents = parsedMessage;
	else
		self.contents = @"This is a voice message. Voice messages cannot be played on the computer. Please check this message on your Xbox.";

	NSString *parsedExpiry = [theSource cropFrom:@"Expires in " to:@"</p>"];
	if (parsedExpiry)
		self.expirationDate = parsedExpiry;
	else
		self.expirationDate = @"Unknown";
	
}

@end
