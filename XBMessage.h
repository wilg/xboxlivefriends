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
	int type;
	NSString *contents;
	NSString *subject;
	NSString *expirationDate;
	NSString *identifier;
	BOOL isRead;

}
@property(assign) BOOL isRead;

- (id)initWithSender:(NSString *)aSender date:(NSDate *)dateString type:(int)atype subject:(NSString *)asubj expirationDate:(NSString *)anExpiration isRead:(BOOL)aRead identifier:(NSString *)theident;

- (NSString *)sender;
- (NSDate *)date;
- (int)type;
- (NSString *)contents;
- (NSString *)subject;
- (NSString *)expirationDate;
- (BOOL)isRead;
- (NSString *)identifier;
- (void)parseFullMessage;

- (NSDictionary *)tableViewRecord;


+ (id)messageWithSender:(NSString *)aSender date:(NSDate *)dateString type:(int)atype subject:(NSString *)asubj expirationDate:(NSString *)anExpiration isRead:(BOOL)aRead identifier:(NSString *)theident;

@end
