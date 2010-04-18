//
//  HaloScreenshotParser.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MQFunctions.h"
#import "HaloScreenshotParser.h"


@implementation HaloScreenshotParser

+ (NSDictionary *)parseScreenshotList:(NSString *)gamertag {
	
	gamertag = [gamertag replace:@" " with:@"%20"];

	NSMutableArray *thumbSSIDs = [NSMutableArray array];
	NSMutableArray *largeSSIDs = [NSMutableArray array];
	NSMutableArray *titles = [NSMutableArray array];
	NSMutableArray *descriptions = [NSMutableArray array];

	NSString *pageSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.bungie.net/stats/halo3/screenshots.aspx?gamertag=%@", gamertag]] encoding:NSUTF8StringEncoding error:nil];
	
	int pageIndex = 0;
	NSString *thisPageSource = pageSource;
	while ([thisPageSource rangeOfString:@"Next</a>"].location != NSNotFound) {
		pageIndex++;
		NSLog(@"page index: %i", pageIndex);
		thisPageSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.bungie.net/stats/halo3/screenshots.aspx?gamertag=%@&page=%i", gamertag, pageIndex]] encoding:NSUTF8StringEncoding error:nil];
		pageSource = [pageSource stringByAppendingString:thisPageSource];
	}

	//do the gallery images too
	NSString *gallerySource = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.bungie.net/stats/halo3/screenshots.aspx?player=%20&mode=pinned", gamertag]] encoding:NSUTF8StringEncoding error:nil];
	pageSource = [pageSource stringByAppendingString:gallerySource];
	pageIndex = 0;
	thisPageSource = gallerySource;
	while ([thisPageSource rangeOfString:@"Next</a>"].location != NSNotFound) {
		pageIndex++;
		NSLog(@"gallery page index: %i", pageIndex);
		thisPageSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.bungie.net/stats/halo3/screenshots.aspx?gamertag=%@&page=%i", gamertag, pageIndex]] encoding:NSUTF8StringEncoding error:nil];
		pageSource = [pageSource stringByAppendingString:thisPageSource];
	}

	if (![pageSource contains:@".ashx?ssid="])
		return nil;

	NSLog(@"FACts of live");

	for (NSString *thisSSID in [pageSource cropRowsMatching:@".ashx?ssid=" rowEnd:@"\""]) {
		if (![thumbSSIDs containsObject:thisSSID])
			[thumbSSIDs addObject:thisSSID];
	}
	
	if ([thumbSSIDs count] == 0)
		return nil;
	
	for (NSString *thumbID in thumbSSIDs) {
		//NSString *thumbSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.bungie.net/stats/halo3/screenshot_viewer_popup.aspx?ssid=%@", thumbID]] encoding:NSUTF8StringEncoding error:nil];
		NSString *thumbSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.bungie.net/Online/Halo3UserContentDetails.aspx?h3fileid=%@", thumbID]] encoding:NSUTF8StringEncoding error:nil];
		
		NSString *thumbTitle = [thumbSource cropFrom:@"<div class=\"shareLeftHeader\">" to:@"<span>"];
		thumbTitle = [MQFunctions flattenHTML:thumbTitle];
		
		[titles addObject:thumbTitle];
		[descriptions addObject:[thumbSource cropFrom:@"<div class=\"shareMoreInfo\">" to:@"</div>"]];
		[largeSSIDs addObject: [thumbSource cropFrom:@"/Screenshot.ashx?size=full&amp;ssid=" to:@"\""]];
		
		/*
		[titles addObject:[[thumbSource cropFrom:@"screenshotTitle" to:@"/a>"] cropFrom:@">" to:@"<"]];
		[descriptions addObject:[thumbSource cropFrom:@"descriptionLabel\">" to:@"<"]];
		[largeSSIDs addObject: [thumbSource cropFrom:@"Screenshot.ashx?size=medium&amp;ssid=" to:@"\""]];
		 */
	}
	
	NSMutableDictionary *dickt = [NSMutableDictionary dictionary];
	[dickt setObject:largeSSIDs forKey:@"ssids"];
	[dickt setObject:titles forKey:@"titles"];
	[dickt setObject:descriptions forKey:@"descriptions"];

	return [[dickt copy] autorelease];
}


@end
