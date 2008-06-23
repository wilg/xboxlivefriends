//
//  XBMessageSender.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 10/1/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XBMessageSender.h"
#import "Xbox Live Friends.h"

NSString* addRecipientsURL = @"http://live.xbox.com/en-US/profile/MessageCenter/SendMessage.aspx";


@implementation XBMessageSender

+ (NSString *)sendMessage:(NSString *)theMsg toTag:(NSString *)theTag
{
	
	NSString *addRecipientsSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:addRecipientsURL]];
	
	NSMutableString *addRecipientsMutableSource = [addRecipientsSource mutableCopy];
	NSString *viewStateString;
	
	if ([addRecipientsMutableSource rangeOfString:@"type=\"hidden\" name=\"__VIEWSTATE\" value=\""].location != NSNotFound )	{
		NSRange range;
		int offset;

		range = [addRecipientsMutableSource rangeOfString:@"type=\"hidden\" name=\"__VIEWSTATE\" value=\""];
		offset = range.location + range.length;

		range = [addRecipientsMutableSource rangeOfString:@"\" />" options:0 range:NSMakeRange(offset, [addRecipientsMutableSource length] - offset)];

		viewStateString = [addRecipientsMutableSource substringWithRange:NSMakeRange(offset, range.location - offset)];
		viewStateString = [viewStateString stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];
	}
	else
		return @"step 1: failed to find __VIEWSTATE";

	NSLog(@"step one finished");

	//NSURL *addThisFriendURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/MessageCenter/SendMessage.aspx?__VIEWSTATE=%@&ScrollX=0&ScrollY=0&editRecipientsControl%3AgamertagTextbox=%@&editRecipientsControl%3AaddNonFriendButton=Add%3E", viewStateString, theTag]];
	
		//[[Controller sharedInstance] fillSourceText:[addThisFriendURL absoluteString]];

	//NSString *friendAddedSource = [NSString stringWithContentsOfURL:addThisFriendURL];
	//NSString *friendAddedSource = [MQFunctions httpPOST:[NSString stringWithFormat:@"__VIEWSTATE=%@&ScrollX=0&ScrollY=0&editRecipientsControl%3AgamertagTextbox=%@&editRecipientsControl%3AaddNonFriendButton=Add%3E", viewStateString, theTag] toURL:@"http://live.xbox.com/en-US/profile/MessageCenter/SendMessage.aspx"];
	
	/*[[Controller sharedInstance] fillSourceText:friendAddedSource];
	

	NSMutableString *friendAddedMutableSource = [friendAddedSource mutableCopy];
	NSString *viewStateString2;
	
	if ([friendAddedSource rangeOfString:@"Please enter a valid gamertag"].location != NSNotFound )	{
		//return @"Invalid gamertag";
	}
	if ([friendAddedMutableSource rangeOfString:@"type=\"hidden\" name=\"__VIEWSTATE\" value=\""].location != NSNotFound )	{
		NSRange range;
		int offset;

		range = [friendAddedMutableSource rangeOfString:@"type=\"hidden\" name=\"__VIEWSTATE\" value=\""];
		offset = range.location + range.length;

		range = [friendAddedMutableSource rangeOfString:@"\" />" options:0 range:NSMakeRange(offset, [friendAddedMutableSource length] - offset)];

		viewStateString2 = [friendAddedMutableSource substringWithRange:NSMakeRange(offset, range.location - offset)];
						
	}
	else
		return @"step 2: failed to find __VIEWSTATE";
	NSLog(@"step two finished");

	//NSURL *composePageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/MessageCenter/SendMessage.aspx?__VIEWSTATE=%@&ScrollX=0&ScrollY=0&editRecipientsControl%3AgamertagTextbox=&editRecipientsControl%3AcomposeMessageButton=Compose+Message+%3E", viewStateString2]];
	//NSString *composePageSource = [NSString stringWithContentsOfURL:composePageURL];
	NSString *composePageSource = [MQFunctions httpPOST:[NSString stringWithFormat:@"__VIEWSTATE=%@&ScrollX=0&ScrollY=0&editRecipientsControl%3AgamertagTextbox=&editRecipientsControl%3AcomposeMessageButton=Compose+Message+%3E", viewStateString2] toURL:@"http://live.xbox.com/en-US/profile/MessageCenter/SendMessage.aspx"];

	NSMutableString *composePageMutableSource = [composePageSource mutableCopy];
	NSString *viewStateString3;
	
	if ([composePageMutableSource rangeOfString:@"type=\"hidden\" name=\"__VIEWSTATE\" value=\""].location != NSNotFound )	{
		NSRange range;
		int offset;

		range = [composePageMutableSource rangeOfString:@"type=\"hidden\" name=\"__VIEWSTATE\" value=\""];
		offset = range.location + range.length;

		range = [composePageMutableSource rangeOfString:@"\" />" options:0 range:NSMakeRange(offset, [composePageMutableSource length] - offset)];

		viewStateString3 = [composePageMutableSource substringWithRange:NSMakeRange(offset, range.location - offset)];
						
	}
	else
		return @"step 3: failed to find __VIEWSTATE";
	NSLog(@"step three finished");

	//NSURL *sendURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/MessageCenter/SendMessage.aspx?__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=%@&ScrollX=0&ScrollY=0&composeMessageControl%3AmessageTextBox=%@%0D%0A&composeMessageControl%3AsendMessageButton=Send", viewStateString3, theMsg]];

	//NSString *sent = [NSString stringWithContentsOfURL:sendURL];
	NSString *sent = [MQFunctions httpPOST:[NSString stringWithFormat:@"__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=%@&ScrollX=0&ScrollY=0&composeMessageControl%3AmessageTextBox=%@%0D%0A&composeMessageControl%3AsendMessageButton=Send", viewStateString3, theMsg] toURL:@"http://live.xbox.com/en-US/profile/MessageCenter/SendMessage.aspx"];

	NSLog(@"step four finished");
	//[[Controller sharedInstance] fillSourceText:[sendURL absoluteString]];
	NSLog(sent);
	*/
	return nil;
}



@end
