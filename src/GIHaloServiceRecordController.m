//
//  GIHaloServiceRecordController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GITabController.h"
#import "GIServiceRecordParser.h"
#import "GIHaloServiceRecordController.h"
#import "GIHalo3RecentGamesParser.h"


@implementation GIHaloServiceRecordController

- (NSString *)notificationName {
	return @"GIHaloServiceRecordLoadNotification";
}


- (void)displayGamerInfo:(NSString *)gamertag
{
	[recentGamesTable setDelegate:self];
	[recentGamesTable setDataSource:self];
	[recentGamesTable setDoubleAction: @selector(doubleAction:)];
	[recentGamesTable setTarget: self];

	NSDictionary *dict = [GIServiceRecordParser fetchWithTag:gamertag];
	if (!dict)  {
		//[self setErrorForTab:@"No Service Record"];
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GIShowErrorTab" object:@"No Service Record"]];
		return;
	}
	
	[self displayServiceRecord:dict];
	[self displayRecentGames:[GIHalo3RecentGamesParser fetchWithTag:gamertag]];
}

- (void)clearTab {
	[rankImageView setImage:nil];
	[serviceTagField setStringValue:@""];
	[experienceField setStringValue:@""];
	[skillField setStringValue:@""];
	[promotionField setStringValue:@""];
	[rankTitleField setStringValue:@""];
	
	tableViewRecords = nil;
	[recentGamesTable reloadData];
}

- (void)displayServiceRecord:(NSDictionary *)serviceRecord
{

	[rankImageView setImage:[[NSImage alloc] initWithContentsOfURL:[serviceRecord objectForKey:@"rankImageURL"]]];
	[serviceTagField setStringValue:[serviceRecord objectForKey:@"serviceTag"]];
	[experienceField setStringValue:[@"Experience: " stringByAppendingString:[serviceRecord objectForKey:@"xp"]]];
	[skillField setStringValue:[@"Skill: " stringByAppendingString:[serviceRecord objectForKey:@"skill"]]];
	[promotionField setStringValue:[@"Promotion at " stringByAppendingString:[serviceRecord objectForKey:@"nextRankAt"]]];
	[rankTitleField setStringValue:[serviceRecord objectForKey:@"rankTitle"]];

	[serviceRecord release];
}

- (void)displayRecentGames:(NSArray *)recentGames
{

	tableViewRecords = [recentGames copy];
	[recentGamesTable reloadData];

}


#pragma mark TableView

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
    id theRecord, theValue;
 
    if (rowIndex >= 0 && rowIndex < [tableViewRecords count]) {
		theRecord = [tableViewRecords objectAtIndex:rowIndex];
		theValue = [theRecord objectForKey:[aTableColumn identifier]];
	}
	else {
		return nil;
	}
	
    return theValue;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if (!tableViewRecords)
		return 0;
    return [tableViewRecords count];
}

- (void)doubleAction:(id)sender
{
	int theRow = [recentGamesTable selectedRow];
	if (theRow != -1){
		[[NSWorkspace sharedWorkspace] openURL:[[tableViewRecords objectAtIndex:theRow] objectForKey:@"link"]];
	}

}




@end
