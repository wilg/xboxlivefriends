//
//  MQCURLHandleWrapper.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 8/19/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MQCURLHandleWrapper.h"

#define DEFAULT_TIMEOUT 60

@implementation MQCURLHandleWrapper

#pragma mark Housekeeping Methods

- (id)init
{
    self = [super init];
	[CURLHandle curlHelloSignature:@"XxXx" acceptAll:YES];	// to get CURLHandle registered for handling URLs
	return self;
}

- (void)dealloc
{
	[CURLHandle curlGoodbye];	// to clean up
	[super dealloc];
}

+ (MQCURLHandleWrapper *)sharedInstance
{
	static MQCURLHandleWrapper *sharedInstance = nil;
	if (!sharedInstance)
		sharedInstance = [[self alloc] init];
	return sharedInstance;
}

#pragma mark -
/* @parameters:
				url  is a valid NSURL
   @result:
				returns the result of calling fetchURLtoString:withTimeout: passing DEFAULT_TIMEOUT				
*/
- (NSString *)fetchURLtoString:(NSURL *)url 
{
	return [self fetchURLtoString:url withTimeout:DEFAULT_TIMEOUT];
}

/* @parameters:
				url   is a valid NSURL
				secs  is the number of seconds before the request for url will be given up.
   @result:
				returns the data associated with the url.  Returns nil if there was an error.				
*/
- (NSString *)fetchURLtoString:(NSURL *)url withTimeout:(int)secs
{
	NSData *urlData     = [[self fetchURLtoData:url withTimeout:secs] retain];
	NSString *urlString = [[NSString alloc] initWithData:urlData encoding:NSASCIIStringEncoding];
	
	//[urlData release]; // JRC - I still don't understand release I guess...
	//NSLog(@"urlData count: %i",[urlData retainCount]);
	return [urlString autorelease];
}

#pragma mark -
/* @parameters:
				url  is a valid NSURL
   @result:
				returns the result of calling fetchURLtoData:withTimeout: passing DEFAULT_TIMEOUT				
*/
- (NSData *)fetchURLtoData:(NSURL *)url
{
	return [self fetchURLtoData:url withTimeout:DEFAULT_TIMEOUT];
}

/* @parameters:
				url   is a valid NSURL
				secs  is the number of seconds before the request for url will be given up.
   @result:
				returns the data associated with the url.  Returns nil if there was an error.				
*/
- (NSData *)fetchURLtoData:(NSURL *)url withTimeout:(int)secs 
{
	NSData *data; // data from the website
	mURLHandle = [(CURLHandle *)[url URLHandleUsingCache:NO] retain];
	
	[mURLHandle setFailsOnError:NO];		// don't fail on >= 300 code; I want to see real results.
	[mURLHandle setUserAgent: @"Mozilla/4.5 (compatible; OmniWeb/4.0.5; Mac_PowerPC)"];
	[mURLHandle setConnectionTimeout:secs];
	
	data = [[mURLHandle resourceData] retain];
	if (NSURLHandleLoadFailed == [mURLHandle status])
	{
		NSLog([mURLHandle failureReason]);
		return nil;
	}
	
	[mURLHandle release];
	return [data autorelease];
}

- (void)URLHandle:(NSURLHandle *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes
{

}

- (void)URLHandleResourceDidBeginLoading:(NSURLHandle *)sender
{

}

- (void)URLHandleResourceDidFinishLoading:(NSURLHandle *)sender
{

}

- (void)URLHandleResourceDidCancelLoading:(NSURLHandle *)sender
{

}

- (void)URLHandle:(NSURLHandle *)sender resourceDidFailLoadingWithReason:(NSString *)reason
{

}
@end
