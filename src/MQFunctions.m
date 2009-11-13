//
//  MQFunctions.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MQFunctions.h"
#import "Xbox Live Friends.h"


@implementation MQFunctions

BOOL debugLogOn = NO;

+ (void)startDebugLog
{
	debugLogOn = YES;
}

+ (void)debugLog:(NSString *)logText
{
	if (debugLogOn) {
		NSLog(logText);
	}
}

+ (NSString *)cropString:(NSString *)fullString between:(NSString *)beginString and:(NSString *)endString
{
	return [fullString cropFrom:beginString to:endString];
//	@try {
//		if ([fullString rangeOfString:beginString].location != NSNotFound && [fullString rangeOfString:endString].location != NSNotFound)	{
//
//			NSRange range;
//			int offset;
//			
//			range = [fullString rangeOfString:beginString];
//			offset = range.location + range.length;
//			range = [fullString rangeOfString:endString options:0 range:NSMakeRange(offset, [fullString length] - offset)];
//			
//			return [fullString substringWithRange:NSMakeRange(offset, range.location - offset)];
//		}
//	}
//	@catch(NSException *exception) {
//	}
//	return nil;
}

+ (NSString *)stringWithThousandSeperatorFromInt:(int)x {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSString *formatted = [numberFormatter stringFromNumber:[NSNumber numberWithInt:x]];
	[numberFormatter release];
	return formatted;
}


+ (NSString *) flattenHTML:(NSString *)theHTML
{
	NSString *result = theHTML;
	
	if (![theHTML isEqualToString:@""])	// if empty string, don't do this!  You get junk.
	{
		// HACK -- IF SHORT LENGTH, USE MACROMAN -- FOR SOME REASON UNICODE FAILS FOR "" AND "-" AND "CNN" ...

		int encoding = ([theHTML length] > 3) ? NSUnicodeStringEncoding : NSMacOSRomanStringEncoding;
		NSAttributedString *attrString;
		NSData *theData = [theHTML dataUsingEncoding:encoding];
		if (nil != theData)	// this returned nil once; not sure why; so handle this case.
		{
			NSDictionary *encodingDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:encoding] forKey:@"CharacterEncoding"];
			attrString = [[NSAttributedString alloc] initWithHTML:theData documentAttributes:&encodingDict];
			result = [[[attrString string] copy] autorelease];	// keep only this
			[attrString release];	// don't do autorelease since this is so deep down.
		}
	}
	return result;
}

+ (NSString *)humanReadableDate:(NSDate *)date
{
	NSString *theHumanReadableString;
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];

	NSCalendarDate *inDate = [date dateWithCalendarFormat:nil timeZone:nil];
	NSUserDefaults *theDefault = [NSUserDefaults standardUserDefaults];

	int today = [[NSCalendarDate calendarDate] dayOfCommonEra];
	int dateDay = [inDate dayOfCommonEra];
	
	NSString *theDayDesignation;
	if (dateDay == today) {

		theDayDesignation = [[[theDefault stringArrayForKey:@"NSThisDayDesignations"] objectAtIndex:0] capitalizedString];
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		theHumanReadableString = [NSString stringWithFormat:@"%@, %@", theDayDesignation, [dateFormatter stringFromDate:date]];

	}
	else if (dateDay == (today + 1)) {

		theDayDesignation = [[[theDefault stringArrayForKey:@"NSNextDayDesignations"] objectAtIndex:0] capitalizedString];
	   
	}
	else if (dateDay == (today - 1)) {

		theDayDesignation = [[[theDefault stringArrayForKey:@"NSPriorDayDesignations"] objectAtIndex:0] capitalizedString];
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		theHumanReadableString = [NSString stringWithFormat:@"%@, %@", theDayDesignation, [dateFormatter stringFromDate:date]];
	   
	}
	else {
		[dateFormatter setDateStyle:NSDateFormatterLongStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		theHumanReadableString = [dateFormatter stringFromDate:date];
	}
	

	return theHumanReadableString;

}

+ (NSString *)cURLWithURLString:(NSString *)theURL
{
	NSTask *cURLSession = [[NSTask alloc] init];
	NSPipe *shellOutput =[[NSPipe alloc] init];
	NSFileHandle *fileHandle;

	[cURLSession setLaunchPath:@"/usr/bin/curl"];

	[cURLSession setArguments:[NSArray
	arrayWithObjects:theURL, nil]];

	[cURLSession setStandardOutput:shellOutput];
	[cURLSession setStandardError:shellOutput];
	fileHandle = [shellOutput fileHandleForReading];

	[cURLSession launch];
	
	[cURLSession waitUntilExit];
	
	NSLog(@"Termination Status: %d",[cURLSession terminationStatus]);
	
	[shellOutput release];
	[cURLSession terminate];
	[cURLSession release];
	
	return [[NSString alloc] initWithData:[fileHandle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
}




+ (NSString *)httpPOST:(NSString *)message toURL:(NSString *)urlString
{
   /* NSAppleEventDescriptor *arguments = [[NSAppleEventDescriptor alloc] initListDescriptor];

    [arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:message] atIndex: 1];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:url] atIndex: 2];
	
	
	NSString *x = [MQScriptController stringFromScriptNamed:@"XLF" handler:@"http_post" arguments:arguments];
	return x;*/

	NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:[message dataUsingEncoding:NSASCIIStringEncoding]];
	
//	[[Controller sharedInstance] webViewWithRequest:urlRequest];

	return [NSString stringWithContentsOfURL:url];
}


+ (NSColor *) colorFromHexRGB:(NSString *) inColorString
{
	NSColor *result = nil;
	unsigned int colorCode = 0;
	unsigned char redByte, greenByte, blueByte;
	
	if (nil != inColorString)
	{
		NSScanner *scanner = [NSScanner scannerWithString:inColorString];
		(void) [scanner scanHexInt:&colorCode];	// ignore error
	}
	redByte		= (unsigned char) (colorCode >> 16);
	greenByte	= (unsigned char) (colorCode >> 8);
	blueByte	= (unsigned char) (colorCode);	// masks off high bits
	result = [NSColor
		colorWithCalibratedRed:		(float)redByte	/ 0xff
							green:	(float)greenByte/ 0xff
							blue:	(float)blueByte	/ 0xff
							alpha:1.0];
	return result;
}

+ (NSAttributedString *)stringWithShadowFrom:(NSString *)string
{

	return (NSAttributedString *)string;

	string = [self flattenHTML:string];
	//make it ellipsize
	static NSDictionary *info = nil;
	NSMutableParagraphStyle *breakStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[breakStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	info = [[NSDictionary alloc] initWithObjectsAndKeys:breakStyle, NSParagraphStyleAttributeName, nil];
	[breakStyle release];

	// the shadow
	NSShadow* theShadow = [[NSShadow alloc] init]; 
	[theShadow setShadowOffset:NSMakeSize(1.5, -1.5)]; 
	[theShadow setShadowBlurRadius:1.7]; 
	[theShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.2]]; 
	[theShadow set];

	NSMutableAttributedString *messageWithShadow = [[NSMutableAttributedString alloc] initWithString:string];
	[messageWithShadow beginEditing];
	[messageWithShadow addAttribute:NSShadowAttributeName value:theShadow range:NSMakeRange(0, [string length])];
	[messageWithShadow addAttribute:NSParagraphStyleAttributeName value:breakStyle range:NSMakeRange(0, [string length])];
	[messageWithShadow endEditing];
	
	return messageWithShadow;
}

@end

















