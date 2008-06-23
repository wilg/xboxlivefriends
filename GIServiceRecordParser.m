//
//  GIServiceRecordParser.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MQFunctions.h"
#import "GIServiceRecordParser.h"


@implementation GIServiceRecordParser


+ (NSDictionary *)fetchWithTag:(NSString *)tag {
	NSMutableString *mutableGamerTag = [[tag mutableCopy] autorelease];
	[mutableGamerTag replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutableGamerTag length])];
	return [self fetchWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://www.bungie.net/Stats/Halo3/Default.aspx?player=", mutableGamerTag]]];
}



+ (NSDictionary *)fetchWithURL:(NSURL *)URL {

	NSString *pageSource = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];

	NSMutableDictionary *serviceRecord = [NSMutableDictionary dictionary];

	NSString *xp = [MQFunctions cropString:pageSource between:@"ctl00_mainContent_identityStrip_lblTotalRP\">" and:@"</span>"];
	if (!xp) {
		return nil;
	}
	
	[serviceRecord setObject:xp forKey:@"xp"];
	[serviceRecord setObject:[MQFunctions cropString:pageSource between:@"ctl00_mainContent_identityStrip_lblSkill\">" and:@"</span>"] forKey:@"skill"];
	[serviceRecord setObject:[MQFunctions cropString:pageSource between:@"ctl00_mainContent_identityStrip_lblRank\">" and:@"</span>"] forKey:@"rankTitle"];
	[serviceRecord setObject:[MQFunctions cropString:pageSource between:@"ctl00_mainContent_identityStrip_lblServiceTag\">" and:@"</span>"] forKey:@"serviceTag"];

	NSString *rankImageArea = [MQFunctions cropString:pageSource between:@"<img id=\"ctl00_mainContent_identityStrip_imgRank\"" and:@"/>"];
	if (rankImageArea)
		[serviceRecord setObject:[NSURL URLWithString:[@"http://www.bungie.net/" stringByAppendingString:[MQFunctions cropString:rankImageArea between:@"src=\"" and:@"\""]]] forKey:@"rankImageURL"];

	NSString *nextRankArea = [MQFunctions cropString:pageSource between:@"ctl00_mainContent_identityStrip_hypNextRank" and:@"</li>"];
	if (nextRankArea)
		[serviceRecord setObject:[MQFunctions cropString:nextRankArea between:@"\">" and:@"<"] forKey:@"nextRankAt"];

	
	return [serviceRecord copy];
}



@end
