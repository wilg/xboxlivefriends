//
//  NSString+Crop.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSString+Crop.h"


@implementation NSString (MQCropExtension)

- (NSString *)cropFrom:(NSString *)start to:(NSString *)end {
	NSString *fullString = self;
	@try {
		if ([fullString contains:start] && [fullString contains:end])	{

			NSRange range;
			int offset;
			
			range = [fullString rangeOfString:start];
			offset = range.location + range.length;
			range = [fullString rangeOfString:end options:0 range:NSMakeRange(offset, [fullString length] - offset)];
			
			return [fullString substringWithRange:NSMakeRange(offset, range.location - offset)];
		}
		else if ([self contains:start] && ![self contains:end]) {
			return [self substringFromIndex:[self rangeOfString:start].location + 1];
		}
		else if (![self contains:start] && [self contains:end]) {
			return [self substringToIndex:[self rangeOfString:end].location - 1];
		}
	}
	@catch(NSException *exception) {
	}
	return nil;
}

- (NSArray *)cropRowsMatching:(NSString *)start rowEnd:(NSString *)end {
	NSString *editString = self;
	NSMutableArray *theArray = [NSMutableArray array];

	while ([editString rangeOfString:start].location != NSNotFound )	{
		NSRange range;
		int offset;

		range = [editString rangeOfString:start];
		offset = range.location + range.length;

		range = [editString rangeOfString:end options:0 range:NSMakeRange(offset, [editString length] - offset)];

		[theArray addObject:[editString substringWithRange:NSMakeRange(offset, range.location - offset)]];
		
		editString = [editString substringFromIndex:range.location];
	}

	return [[theArray copy] autorelease];
}

- (NSString *) replace:(NSString *)string with:(NSString *)replacement {
	NSMutableString *mut = [[self mutableCopy] autorelease];
	[mut replaceOccurrencesOfString:string withString:replacement options:0 range:NSMakeRange(0, [mut length])];
	return [[mut copy] autorelease];
}

- (BOOL) contains:(NSString *)string {
	if (string && [self rangeOfString:string].location != NSNotFound ) {
		return YES;
	}
	return NO;
}



@end
