//
//  SendMessage.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#include <WebKit/WebKit.h>
#import "SendMessage.h"
#import "MQFunctions.h"


@implementation SendMessage


+ (BOOL)sendMessage:(NSString *)message to:(NSString *)gamertag usingWebView:(WebView *)webView {

	NSStringEncoding encoding;
	gamertag = [gamertag replace:@" " with:@"+"];
	NSString *formURL = [NSString stringWithFormat:@"http://live.xbox.com/en-US/profile/MessageCenter/SendMessage.aspx?gt=%@", gamertag];
	NSString *formSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:formURL] usedEncoding:&encoding error:nil];
	
	NSString* script = [NSString stringWithFormat: 
	@"<script language='javascript' type='text/javascript'>function XLF() {document.getElementById('ctl00_MainContent_composeMessageControl_messageTextBox').value = decodeURIComponent('%@');document.getElementById('ctl00_MainContent_composeMessageControl_sendMessageButton').disabled = false;document.getElementById('ctl00_MainContent_composeMessageControl_sendMessageButton').click();}window.onload = XLF;</script></body>",
	[message stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];

	formSource = [formSource replace:@"</body>" with:script];

	[[webView mainFrame] loadHTMLString:formSource baseURL:[NSURL URLWithString:@"http://live.xbox.com/en-US/profile/MessageCenter/"]];
	
	return YES;

}


@end
