//
//  GIBreakdownChartController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/12/07.
//  Copyright 2007 mindquirk. All rights reserved.
//

#include "MQSlice.h"
#include "MQPieGraphView.h"

#include "GITabController.h"
#import "ClickableAttachedWindow.h"

#import "Xbox Live Friends.h"
#import "GIBreakdownChartController.h"
#import "XBGamesPlayedParser.h"
#import "ColorizeImage.h"

#define round(x) ((x)>=0?(long)((x)+0.5):(long)((x)-0.5))

@implementation GIBreakdownChartController

- (void)awakeFromNib {
    [pieGraph setDelegate:self];
	[pieGraph setPadding:15.0];
	[pieGraph setBackgroundColor:[NSColor colorWithCalibratedHue:1.0 saturation:0.0 brightness:0.2 alpha:1.0]];
	[pieGraph setNeedsDisplay:YES];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabWillChange:) name:@"GamerInfoTabWillChange" object:nil];
}

- (NSString *)notificationName {
	return @"GIBreakdownChartLoadNotification";
}

- (void)clearTab {
    [pieGraph clearSlices];
    [pieGraph setNeedsDisplay:YES];
}


- (void)displayGamerInfo:(NSString *)gamertag {
	NSArray *theInfo = [XBGamesPlayedParser fetchWithTag:gamertag];
	if (theInfo) {
		[self displayPieChart:theInfo];
	}
	else {
		[self setErrorForTab:@"An Error Occurred"];
	}
}


- (void)displayPieChart:(NSArray *)gameList {

	[self doInfoPopAt:NSZeroPoint withSlice:nil];
	[gameList retain];

	NSImage *textureImage = [NSImage imageNamed:@"pie_texture.jpg"];
	
	float totalScore = 0.0;
	float otherScore = 0.0;
	
	lastColorUsed = 0;
	
	if([gameList count] != 0) {
	
		for (XBGame *game in gameList) {
			if (game.isJustMe)
				totalScore += [[game yourScore] floatValue];
			else
				totalScore += [[game theirScore] floatValue];
		}
		
		for (XBGame *thisGame in gameList) {
		
			NSString *score;
			if (thisGame.isJustMe)
				score = [thisGame yourScore];
			else
				score = [thisGame theirScore];
			
			float floatScore = [score floatValue];

			BOOL shouldDisplaySlice = YES;
			float percent = floatScore / totalScore * 100.0;
			
			if ([gameList count] > 18 && percent < 1)
				shouldDisplaySlice = NO;

			if (floatScore <= 0)
				shouldDisplaySlice = NO;
				
			if (shouldDisplaySlice) {
				NSImage *gameIcon = [[NSImage alloc] initWithContentsOfURL:[thisGame tileURL]];

				NSMutableDictionary *dict = [NSMutableDictionary dictionary];
				[dict setObject:score forKey:@"score"];
				[dict setObject:[NSString stringWithFormat:@"%i%%", round(percent)] forKey:@"percent"];
				[dict setObject:gameIcon forKey:@"image"];
				[dict setObject:[MQFunctions flattenHTML:[thisGame name]] forKey:@"title"];
				
				
				MQSlice *slice = [MQSlice slice];
				[slice setColor:[NSColor colorWithPatternImage:[ColorizeImage colorizeImage:textureImage withColor:[self colorForSlice]]]];
				[slice setSize:floatScore];
				[slice setMessage:[thisGame name]];
				[slice setCaptionData:[dict copy]];
				[slice setShouldDisplay:shouldDisplaySlice];
				
				[pieGraph addSlice:slice];
			}
			else
				otherScore += floatScore;
			
		}		
		
	}
	
	// if (otherScore > 0.0)
	// [pieGraph addSlice:[MQSlice sliceWithColor:[MQFunctions colorFromHexRGB:@"666666"] slice:otherScore message:@"Other Games"]];
	
	[pieGraph sort];
	[pieGraph recalibrateSliceSizes];
	[pieGraph setNeedsDisplay:YES];
	
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

	MQSlice *slice = [pieGraph lastClickedSlice];
	
	if (slice && slice != lastSlice) {
		NSDictionary *data = [slice captionData];
		[sliceCaption setStringValue:[data objectForKey:@"score"]];
		[sliceTitle setStringValue:[data objectForKey:@"title"]];
		[percentField setStringValue:[data objectForKey:@"percent"]];
		[sliceImage setImage:[data objectForKey:@"image"]];
		lastSlice = slice;
	}
	
	[self doInfoPopAt:[[pieGraph window] convertBaseToScreen:[event locationInWindow]] withSlice:slice];
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
    }
	else
		[self closeInfoPop];

}

- (void) closeInfoPop {
	if (infoPop) {
		[[pieGraph window] removeChildWindow:infoPop];
		[infoPop orderOut:self];
		[infoPop release];
		infoPop = nil;
	}
}

- (void)tabBecameVisible {
	if ([pieGraph window])
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedToCloseInfoPop:) name:NSWindowDidResizeNotification object:[pieGraph window]];
}

- (void)tabWillChange:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:[pieGraph window]];
	if (infoPop) {
		[self closeInfoPop];
		[pieGraph clearSelection];
	}
}


- (void)notifiedToCloseInfoPop:(NSNotification *)notification {
	if (infoPop) {
		[self closeInfoPop];
		[pieGraph clearSelection];
	}
}


@end
