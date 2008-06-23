//
//  SendMessage.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SendMessage : NSObject {

}

+ (BOOL)sendMessage:(NSString *)message to:(NSString *)gamertag usingWebView:(WebView *)webView;

@end
