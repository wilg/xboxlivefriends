//
//  GIBreakdownChartController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#include "MQSlice.h"
#include "MQPieGraphView.h"

#include "GITabController.h"
#import "ClickableAttachedWindow.h"

#import "Xbox Live Friends.h"
#import "GIBreakdownChartController.h"
#import "XBGamesPlayedParser.h"


@implementation GIBreakdownChartController

- (void)awakeFromNib
{
    [pieGraph setDelegate:self];
	[pieGraph setPadding:15.0];
	[pieGraph setBackground:[NSColor colorWithCalibratedHue:1.0 saturation:0.0 brightness:0.2 alpha:1.0]];
	[pieGraph setDrawsLegend:NO];
	[pieGraph updateView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabSelectionWillChange:) name:@"GamerInfoTabWillChange" object:nil];
}

- (NSString *)notificationName {
	return @"GIBreakdownChartLoadNotification";
}


- (void)displayGamerInfo:(NSString *)gamertag
{
	NSArray *theInfo = [XBGamesPlayedParser fetchWithTag:gamertag];
//	[self setLastFetch:[theInfo copy]];
	[self displayPieChart:theInfo];
}


- (void)displayPieChart:(NSArray *)gameList
{
	[self doInfoPopAt:NSZeroPoint withSlice:nil];
	[gameList retain];
	[pieGraph clearSlices];
	NSImage *textureImage = [NSImage imageNamed:@"pie_texture.jpg"];
	
	float totalScore = 0.0;
	float otherScore = 0.0;
	
	if([gameList count] != 0){
	
		for (XBGame *thisGameCount in gameList) {
			totalScore += [[thisGameCount theirScore] floatValue];
		}
		
		for (XBGame *thisGame in gameList) {
		
			float ts = [[thisGame theirScore] floatValue];

			BOOL shouldDisplaySlice = YES;
			float percent = ts / totalScore * 100.0;
			
			if ([gameList count] > 18 && percent < 0.8)
				shouldDisplaySlice = NO;

			if (ts <= 0)
				shouldDisplaySlice = NO;
				
			if (shouldDisplaySlice) {
				NSImage *gameIcon = [[NSImage alloc] initWithContentsOfURL:[thisGame tileURL]];

				NSMutableDictionary *dict = [NSMutableDictionary dictionary];
				[dict setObject:[thisGame theirScore] forKey:@"score"];
				[dict setObject:[NSString stringWithFormat:@"%i%%", (int)percent] forKey:@"percent"];
				[dict setObject:gameIcon forKey:@"image"];
				[dict setObject:[MQFunctions flattenHTML:[thisGame name]] forKey:@"title"];
				[pieGraph addSlice:[MQSlice sliceWithColor:[self colorForSlice] texture:textureImage slice:ts message:[thisGame name] captionData:[dict copy]]];
			}
			else
				otherScore = otherScore + ts;
			
		}		
		
	}
	else
		NSLog(@"empty list");
	
	// if (otherScore > 0.0)
	// [pieGraph addSlice:[MQSlice sliceWithColor:[MQFunctions colorFromHexRGB:@"666666"] slice:otherScore message:@"Other Games"]];
	
	[pieGraph sort];
	[pieGraph updateView];

}

- (NSColor *)colorForSlice
{


	NSColor *theColor;

	NSArray *colors = [NSArray arrayWithObjects: @"6FA1FF", @"835C11", @"D09F46", @"9D3725", @"524E69", @"1F4283", @"4E9D25", @"D75E88", @"D0911C", @"4676D0", @"372F22", nil];
	
	if (lastColorUsed >= [colors count]) {
		float hue = (float)rand() / (float)RAND_MAX;
		float sat = (float)rand() / (float)RAND_MAX;
		if (sat < 0.3)
			sat = 0.4;
		theColor = [NSColor colorWithCalibratedHue:hue saturation:sat brightness:0.7 alpha:1.0];
	}
	else {
		theColor = [MQFunctions colorFromHexRGB:[colors objectAtIndex:lastColorUsed]];
		lastColorUsed++;
	}
	
	
	return theColor;
}

- (void)mouseDown:(NSEvent *)event
{
	// if this is the mousedown in the infopop
	if ([event window] == infoPop) {
		[self closeInfoPop];
		[pieGraph clearSelection];
	}


	MQSlice *slice = [pieGraph getLastClicked];
	
	if (slice && slice != lastSlice) {
		NSDictionary *data = [slice getCaptionData];
		[sliceCaption setStringValue:[data objectForKey:@"score"]];
		[sliceTitle setStringValue:[data objectForKey:@"title"]];
		[percentField setStringValue:[data objectForKey:@"percent"]];
		[sliceImage setImage:[data objectForKey:@"image"]];
		lastSlice = slice;
	}
	
	[self doInfoPopAt:[[pieGraph window] convertBaseToScreen:[event locationInWindow]] withSlice:slice];
}

- (void)mouseMoved:(NSEvent *)event
{
}

- (void)doInfoPopAt:(NSPoint)position withSlice:(MQSlice *)slice {


    if (slice) {
	
	
		if (!infoPop) {
		
			infoPop = [[ClickableAttachedWindow alloc] initWithView:infoView attachedToPoint:position onSide:MAPositionTop];
			[infoPop setDelegate:self];
			[infoPop setViewMargin:10.0];
			[infoPop setBackgroundColor:[NSColor colorWithCalibratedWhite:0 alpha:0.7]];
			[[pieGraph window] addChildWindow:infoPop ordered:NSWindowAbove];

		}
				

		[infoPop setPoint:position side:MAPositionTop];
	

		
		
    } else {
		[self closeInfoPop];
    }

}

- (void) closeInfoPop {
	if (infoPop) {
		[[pieGraph window] removeChildWindow:infoPop];
		[infoPop orderOut:self];
		[infoPop release];
		infoPop = nil;
	}
}

-(void)tabSelectionWillChange:(NSNotification *)notification {
	[self closeInfoPop];
	[pieGraph clearSelection];
}



- (void)tabBecameVisible {
	[[pieGraph window] makeFirstResponder:pieGraph];
}


@end