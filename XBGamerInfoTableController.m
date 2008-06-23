//
//  XBGamerInfoTableController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSVTextFieldCell.h"
#import "XBGamerInfoTableController.h"
#import <QuartzCore/QuartzCore.h>

@implementation XBGamerInfoTableController

- (id)init	{
	if (![super init])
	return nil;
	
		
	return self;
}

- (void)awakeFromNib {

	records = [[NSMutableArray alloc] init];

	[infoTable setDataSource:self];
	[infoTable setDelegate:self];
	[infoTable setTarget: self];

    NSVTextFieldCell *cell;
    cell = [[NSVTextFieldCell alloc] init];
    [cell setVerticalAlignment:YES];
    NSTableColumn *column = [infoTable tableColumnWithIdentifier:@"name"];
    [column setDataCell:cell];
    [cell release];
	
	
//	NSView *theView = [[gamerInfoContentView selectedTabViewItem] view];
    //[theContentView setWantsLayer:YES];
	[theContentView setAutoresizesSubviews:YES];

//    [gamerInfoContentView addSubview:[self currentView]];
//	CATransition *transition;
//
//    transition = [CATransition animation];
//    [transition setType:kCATransitionMoveIn];
//    [transition setSubtype:kCATransitionFromLeft];
//    
//    NSDictionary *ani = [NSDictionary dictionaryWithObject:transition forKey:@"subviews"];
//    [theContentView setAnimations:ani];

	
	
	

		
	//add items
	[records addObject:[self tableViewRecordForTab:@" XBOX LIVE" icon:[NSNull null] view:[NSNull null]]];
	[records addObject:[self tableViewRecordForTab:@"Achievements" icon:[NSImage imageNamed:@"achievement_tab"] view:gamerInfoAchievementView]];
	[records addObject:[self tableViewRecordForTab:@"Breakdown" icon:[NSImage imageNamed:@"pie_tab"] view:gamerInfoPieView]];
	[records addObject:[self tableViewRecordForTab:@"Details" icon:[NSImage imageNamed:@"details_tab"] view:gamerInfoDetailsView]];
	[records addObject:[self tableViewRecordForTab:@" HALO 3" icon:[NSNull null] view:[NSNull null]]];
	[records addObject:[self tableViewRecordForTab:@"Service Record" icon:[NSImage imageNamed:@"halo_service_record_tab"] view:gamerInfoHaloMultiplayerSRView]];
	[records addObject:[self tableViewRecordForTab:@"Screenshots" icon:[NSImage imageNamed:@"tab_halo_screenshot"] view:gamerInfoHaloScreenshotsView]];

	[infoTable reloadData];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GamerInfoTabChanged" object:[[records objectAtIndex:[infoTable selectedRow]] objectForKey:@"name"]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showErrorTab:) name:@"GIShowErrorTab" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showErrorTabModal:) name:@"GIShowErrorTabModal" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableSources:) name:@"GIEnableSources" object:nil];

}

- (void)setCurrentView:(NSView *)newView {

	[newView setFrameSize:[theContentView frame].size];
	[newView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];

    if (!currentView) {
		[theContentView addSubview:newView];
		currentView = newView;
        return;
    }

    [[theContentView animator] replaceSubview:currentView with:newView];
	
    currentView = newView;
}


- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{

	if (tableColumn == nil && [[records objectAtIndex:row] objectForKey:@"icon"] == [NSNull null]) {
		return [[NSTextFieldCell alloc] init];
	}
	
	return [tableColumn dataCellForRow:row];

}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
	if ([[records objectAtIndex:row] objectForKey:@"icon"] == [NSNull null])
		return YES;
	
	return NO;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	if ([[records objectAtIndex:rowIndex] objectForKey:@"icon"] == [NSNull null])
		return NO;
	
	return YES;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	if ([[records objectAtIndex:row] objectForKey:@"icon"] == [NSNull null])
		return 20.0;
	
	return 32.0;
}


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [records count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex 
{
	id theRecord, theValue;

	if (aTableColumn == nil && [[records objectAtIndex:rowIndex] objectForKey:@"icon"] == [NSNull null]) {
			theValue = [[records objectAtIndex:rowIndex] objectForKey:@"name"];
	}
	else {
		theRecord = [records objectAtIndex:rowIndex];
		theValue = [theRecord objectForKey:[aTableColumn identifier]];
	}
	
	if (theValue == [NSNull null])
		return nil;
		
	return theValue;
}


- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	int theRow = [infoTable selectedRow];
	if (theRow != -1){
		id theRecord;
		theRecord = [records objectAtIndex:theRow];
		if ([theRecord objectForKey:@"icon"] != [NSNull null]) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"GamerInfoTabWillChange" object:[theRecord objectForKey:@"name"]];
			[self setCurrentView:[theRecord objectForKey:@"view"]];
			//[[gamerInfoContentView selectedTabViewItem] setView:[theRecord objectForKey:@"view"]];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"GamerInfoTabChanged" object:[theRecord objectForKey:@"name"]];
		}
	}
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	return YES;
}

- (NSDictionary *)tableViewRecordForTab:(NSString *)tabName icon:(id)icon view:(id)view
{
	NSMutableDictionary *record = [NSMutableDictionary dictionary];
		
	[record setObject:icon forKey:@"icon"];
	[record setObject:tabName forKey:@"name"];
	[record setObject:view forKey:@"view"];

	return record;
}

- (void)showErrorTab:(NSNotification *)notification
{
	if ([notification object])
		[gamerInfoErrorText setStringValue:[notification object]];
	[self setCurrentView:gamerInfoTextView];
	//[[gamerInfoContentView selectedTabViewItem] setView:gamerInfoTextView];
}

- (void)showErrorTabModal:(NSNotification *)notification
{
	if ([notification object])
		[gamerInfoErrorText setStringValue:[notification object]];
	//[[gamerInfoContentView selectedTabViewItem] setView:gamerInfoTextView];
	[self setCurrentView:gamerInfoTextView];
	[infoTable setEnabled:NO];
}

- (void)enableSources:(NSNotification *)notification {
	[infoTable setEnabled:YES];
	[self tableViewSelectionDidChange:nil];
}


@end
