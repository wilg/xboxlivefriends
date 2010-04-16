//
//  XBTextMessage.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	XBTextMessageType = 0,
	XBVoiceMessageType = 1,
    XBGameMessageType = 2,
	XBFriendRequestMessageType = 3,
} XBMessageType;


@interface XBMessage : NSObject {

	NSString *sender;
	NSDate *date;
	XBMessageType type;
	NSString *contents;
	NSString *subject;
	NSString *expirationDate;
	NSString *identifier;
	NSString *dateString;
	BOOL isRead;

}

@property(assign) BOOL isRead;

@property(assign) NSString *sender;
@property(assign) NSDate *date;
@property(assign) XBMessageType type;
@property(assign) NSString *contents;
@property(assign) NSString *subject;
@property(assign) NSString *expirationDate;
@property(assign) NSString *identifier;
@property(assign) NSString *dateString;

+ (XBMessage *)message;

- (void)parseFullMessage;
- (NSDictionary *)tableViewRecord;

@end
