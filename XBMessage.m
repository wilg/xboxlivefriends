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

@synthesize isRead;

- (id)initWithSender:(NSString *)aSender date:(NSDate *)dateString type:(int)atype subject:(NSString *)asubj expirationDate:(NSString *)anExpiration isRead:(BOOL)aRead identifier:(NSString *)theident
{
	if (![super init])
	return nil;

	sender = aSender;
	date = dateString;
	type = atype;
	subject = asubj;
	expirationDate = anExpiration;
	identifier = theident;
	contents = nil;

	isRead = aRead;
	
	
	[sender retain];
	[date retain];
	[contents retain];
	[subject retain];
	[expirationDate retain];
	[identifier retain];

	return self;
}

-(void)dealloc {
	[sender release];
	[date release];
	[contents release];
	[subject release];
	[expirationDate release];
	[identifier release];


	[super dealloc];
}

- (NSDictionary *)tableViewRecord
{
	NSMutableDictionary *record = [NSMutableDictionary dictionary];
	
	if ([self isRead])
		[record setObject:[NSImage imageNamed:@"empty"] forKey:@"bead"];
	else
		[record setObject:[NSImage imageNamed:@"blue_bead"] forKey:@"bead"];
		

	[record setObject:[self sender] forKey:@"from"];
	[record setObject:[self subject] forKey:@"message"];
	[record setObject:[MQFunctions humanReadableDate:[self date]] forKey:@"date"];
	
	if ([self type] == XBVoiceMessageType){
		[record setObject:[NSImage imageNamed:@"speaker"] forKey:@"attachment"];
		[record setObject:@"Voice Message" forKey:@"message"];
	}
	else
		[record setObject:[NSImage imageNamed:@"empty"] forKey:@"attachment"];

	return record;
}


- (NSString *)sender
{
	return sender;
}

- (NSDate *)date
{
	return date;
}

- (int)type
{
	return type;
}

- (void)setContents:(NSString *)cont {
	contents = cont;
}

- (NSString *)contents
{
	if (!contents)
		[self parseFullMessage];
	[contents retain];
	return contents;
}

- (NSString *)subject
{
	return subject;
}

- (NSString *)expirationDate
{
	if (expirationDate == nil)
		expirationDate = @"Unknown";
	[expirationDate retain];
	return expirationDate;
}

- (NSString *)identifier
{
	return identifier;
}

- (void)parseFullMessage
{
	NSURL *theURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://live.xbox.com/en-US/profile/MessageCenter/ViewMessage.aspx?mx=", [self identifier]]];
	NSString *theSource = [NSString stringWithContentsOfURL:theURL];
	
	NSLog([theURL absoluteString]);
	
	NSString *parsedMessage = [theSource cropFrom:@"<div class=\"XbcMessageTextPanel\">" to:@"</div>"];
	if (parsedMessage)
		contents = parsedMessage;
	else
		contents = @"This is a voice message. Voice messages cannot be played on the computer. Please check this message on your Xbox.";

	NSString *parsedExpiry = [theSource cropFrom:@"Expires in " to:@"</p>"];
	if (parsedExpiry)
		expirationDate = parsedExpiry;
	else
		expirationDate = @"Unknown";
	
	
}


+ (id)messageWithSender:(NSString *)aSender date:(NSDate *)dateString type:(int)atype subject:(NSString *)asubj expirationDate:(NSString *)anExpiration isRead:(BOOL)aRead identifier:(NSString *)theident
{
	return [[XBMessage alloc] initWithSender:aSender date:dateString type:atype subject:asubj expirationDate:anExpiration isRead:aRead identifier:theident];
}

@end
