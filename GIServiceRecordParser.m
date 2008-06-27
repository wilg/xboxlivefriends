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
	return [self fetchWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://www.bungie.net/Stats/Halo3/Default.aspx?player=", [tag replace:@" " with:@"+"]]]];
}



+ (NSDictionary *)fetchWithURL:(NSURL *)URL {

	NSString *pageSource = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];

	NSMutableDictionary *serviceRecord = [NSMutableDictionary dictionary];

	if (![pageSource contains:@"ctl00_mainContent_identityStrip_lblTotalRP"]) {
		return nil;
	}

	NSString *xp = [pageSource cropFrom:@"ctl00_mainContent_identityStrip_lblTotalRP\">" to:@"</span>"];
		
	[serviceRecord setObject:xp forKey:@"xp"];
	[serviceRecord setObject:[pageSource cropFrom:@"ctl00_mainContent_identityStrip_lblSkill\">" to:@"</span>"] forKey:@"skill"];
	[serviceRecord setObject:[pageSource cropFrom:@"ctl00_mainContent_identityStrip_lblRank\">" to:@"</span>"] forKey:@"rankTitle"];
	[serviceRecord setObject:[pageSource cropFrom:@"ctl00_mainContent_identityStrip_lblServiceTag\">" to:@"</span>"] forKey:@"serviceTag"];

	NSString *rankImageArea = [pageSource cropFrom:@"<img id=\"ctl00_mainContent_identityStrip_imgRank\"" to:@"/>"];
	if (rankImageArea)
		[serviceRecord setObject:[NSURL URLWithString:[@"http://www.bungie.net/" stringByAppendingString:[rankImageArea cropFrom:@"src=\"" to:@"\""]]] forKey:@"rankImageURL"];

	NSString *nextRankArea = [pageSource cropFrom:@"ctl00_mainContent_identityStrip_hypNextRank" to:@"</li>"];
	if (nextRankArea)
		[serviceRecord setObject:[pageSource cropFrom:@"\">" to:@"<"] forKey:@"nextRankAt"];

	
	return [serviceRecord copy];
}



@end
