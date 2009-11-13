//
//  GIServiceRecordParser.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MQFunctions.h"
#import "GIHalo3RecentGamesParser.h"


@implementation GIHalo3RecentGamesParser


+ (NSArray *)fetchWithTag:(NSString *)tag {
	NSMutableString *mutableGamerTag = [[tag mutableCopy] autorelease];
	[mutableGamerTag replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutableGamerTag length])];
	return [self fetchWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://www.bungie.net/stats/PlayerStatsHalo3.aspx?player=", mutableGamerTag]]];
}



+ (NSArray *)fetchWithURL:(NSURL *)URL {

	NSString *pageSource = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];

	NSMutableArray *recentGames = [NSMutableArray array];

	NSString *editString = [pageSource cropFrom:@"</tfoot><tbody>" to:@"</tbody>"];
	
	
	NSArray *rows = [editString cropRowsMatching:@"<tr" rowEnd:@"</tr>"];
	for (NSString *row in rows) {
		NSMutableDictionary *thisGame = [NSMutableDictionary dictionary];
		int i = 0;
		for (NSString *td in [row cropRowsMatching:@"<td>" rowEnd:@"</td>"]) {
			if (i == 0) {
				[thisGame setObject:[td cropFrom:@">" to:@"<"] forKey:@"gametype"];
				NSString *stringLink = [td cropFrom:@"href=\"" to:@"\""];
				if (stringLink) {
					stringLink = [@"http://www.bungie.net" stringByAppendingString:stringLink];
					NSURL *theURL = [NSURL URLWithString:[[stringLink replace:@"&amp;" with:@"&"] replace:@" " with:@"%20"]];
					if (theURL)
						[thisGame setObject:theURL forKey:@"link"];
				}
			}
			else
				td = [td stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
			NSString *key = nil;
			if (i == 1) {
				key = @"date";
				td = [MQFunctions humanReadableDate:[NSDate dateWithNaturalLanguageString:td]];
			}
			else if (i == 2)
				key = @"map";
			else if (i == 3)
				key = @"playlist";
			else if (i == 4)
				key = @"place";
				
			if (key && td) {
				[thisGame setObject:td forKey:key];
			}
				
			i++;
		}
		
		[recentGames addObject:thisGame];
		
	}


	
	return [[recentGames copy] autorelease];
}



@end
