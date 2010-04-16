//
//  LoginController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Xbox Live Friends.h"
#import "LoginController.h"

#define FRIENDS_PAGE @"http://live.xbox.com/en-US/profile/Friends.aspx"

NSString* signInURL = @"http://live.xbox.com/en-US/profile/Friends.aspx";


@implementation LoginController

- (id)init {
	
	if (![super init]) {
		return nil;
	}
	
	keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"XboxLiveFriends" withUsername:@"XboxLive"];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkConnectionAndLogin:) name:@"FriendsListConnectionError" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkConnectionAndLogin:) name:@"DoSignIn" object:nil];
	
	currentMode = @"";
	
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewLoadingStart:) name:WebViewProgressStartedNotification object:webView];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewLoadingEnd:) name:WebViewProgressFinishedNotification object:webView];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewLoadingChange:) name:WebViewProgressEstimateChangedNotification object:webView];

	return self;
}

- (void)awakeFromNib {
	[webView setFrameLoadDelegate:self];
	
	// The first time we open the app, a new keychain will be created to save our password.
	if (keychainItem) {
		[password setStringValue:keychainItem.password];
		NSLog(@"%@", keychainItem.username);
	} else {
		[EMGenericKeychainItem addGenericKeychainItemForService:@"XboxLiveFriends" withUsername:@"XboxLive" password:@"nopass"];
		NSLog(@"Creating Keychain item");
	}
	
	//[self loginToPassportWithEmail:[email stringValue] password:[password stringValue]];
}

- (void)checkConnectionAndLogin:(NSNotification *)notification
{
	NSLog(@"FriendsListConnectionError");
	[self loadURL:[NSURL URLWithString:FRIENDS_PAGE]];
	//[self performSelectorOnMainThread:@selector(OpenSignIn:) withObject:nil waitUntilDone:NO];
}

- (IBAction)newSignInButtonClicked:(id)sender {
	
	if (![[email stringValue] contains:@"@"] || [[password stringValue] isEqualToString:@""]) {
		NSBeep();
		return;
	}
	
	// Check against the current keychain
	EMGenericKeychainItem *tempKeys = [EMGenericKeychainItem genericKeychainItemForService:@"XboxLiveFriends" withUsername:@"XboxLive"];
	NSString *temppw = tempKeys.password;
	if (temppw != [password stringValue]) {
		tempKeys.password = [password stringValue];
	}
	
	currentMode = @"signInFormSubmitted";
	
	[self loadURL:[NSURL URLWithString:signInURL]];
	//[self loginToPassportWithEmail:[email stringValue] password:[password stringValue]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeFriendsListMode" object:@"loading"];
}

- (BOOL)loginToPassportWithEmail:(NSString *)emailAddress password:(NSString *)loginPass {
	
	NSString* script = [NSString stringWithFormat: 
	@"document.getElementsByName(\"login\")[0].value = decodeURIComponent('%@');document.getElementsByName(\"passwd\")[0].value = decodeURIComponent('%@');document.getElementById('i0136').click();document.getElementsByName('SI')[0].click();",
	[emailAddress stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding], [loginPass stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];

	[[webView windowScriptObject] evaluateWebScript:script];
	
	return YES;

}


- (IBAction)OpenSignIn:(id)sender{
	currentMode = @"loadingSignIn";
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"InSignInMode"];
	[self performSelectorOnMainThread:@selector(loadURL:) withObject:[NSURL URLWithString:signInURL] waitUntilDone:YES];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeFriendsListMode" object:@"sign_in"];

//	[signInWindow center];
//	[signInWindow makeKeyAndOrderFront:nil];

}

- (IBAction)retryLoadingPage:(id)sender{

	[self loadURL:[NSURL URLWithString:signInURL]];

}

- (IBAction)CloseSignIn:(id)sender{
	
	[signInWindow close];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
	
}


- (void)webViewErrorMessage:(NSString *)msg title:(NSString *)title
{
	NSString *theBody = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/error_message.htm"] encoding:NSMacOSRomanStringEncoding error:NULL];

	NSMutableString *theBodyMut = [theBody mutableCopy];

	[theBodyMut replaceOccurrencesOfString:@"$title" withString:title options:0 range:NSMakeRange(0, [theBodyMut length])];
	[theBodyMut replaceOccurrencesOfString:@"$subtitle" withString:msg options:0 range:NSMakeRange(0, [theBodyMut length])];

	[[webView mainFrame] loadHTMLString:theBodyMut baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
	[theBodyMut release];
}


#pragma mark -
#pragma mark WebView-Related Methods

- (void)loadURL:(NSURL *)URL {
	NSString *attemp = [URL absoluteString];
	NSLog(@"Attemping to load: %@", attemp);
	[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {

	if (frame != [sender mainFrame])
		return;

	[webViewProgressSpinner startAnimation:nil];
	[webViewProgress setDoubleValue:0.0];
	[webViewProgress setHidden:false];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {

	if (frame != [sender mainFrame])
		return;

	[webViewProgressSpinner stopAnimation:nil];
	[webViewProgress setHidden:true];
	if ([self isSignedIn]) {
		[self doneWithSignIn];
		//[self loadURL:[NSURL URLWithString:signInURL]];
	} else {
		[self loginToPassportWithEmail:[email stringValue] password:[password stringValue]];
		/*
		NSLog(@"%@", currentMode);
		if (currentMode == @"signInFormSubmitted") {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeFriendsListMode" object:@"sign_in"];
		}
		else if (currentMode == @"loadingSignIn") {
			currentMode = @"signInForm";
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeFriendsListMode" object:@"sign_in"];
		}
		else if (currentMode == @"signInForm") {
		
		}
		 */
	}
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	if (frame != [sender mainFrame])
		return;
		

	[webViewProgressSpinner stopAnimation:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DisplayFriendsListError" object:@"Couldn't Connect"];
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	if (frame != [sender mainFrame])
		return;

	if (currentMode == @"signInFormSubmitted") {
		return;
	}

	[webViewProgressSpinner stopAnimation:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DisplayFriendsListError" object:@"Couldn't Load"];
}

- (void)webViewLoadingChange:(NSNotification *)aNotification {
	[webViewProgress setDoubleValue:[webView estimatedProgress]];
}


- (void)webViewWithRequest:(NSURLRequest *)request
{
	[[webView mainFrame] loadRequest:request];
}

#pragma mark -
#pragma mark Check if we're signed in


- (BOOL)isSignedIn
{
	NSLog(@"Are we signed in?");
	
	NSString *loginSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:FRIENDS_PAGE] encoding:NSUTF8StringEncoding error:nil];
	
	if (!loginSource) {
		return NO;
	}
	
	if ([loginSource rangeOfString:@"Sign out"].location != NSNotFound) {
		NSLog(@"We are signed in");
		return YES;
	}
	/*
	 if ([loginSource contains:@"Sign out"]) {
	 NSLog(@"We Are signed in");
	 return YES;
	 }
	 */
	NSLog(@"We are not signed in");
	return NO;

	/*
	NSString *webViewSource;
	WebDataSource *dataSource = [[webView mainFrame] dataSource];
	if ([[dataSource representation] canProvideDocumentSource]) {
		webViewSource = [[dataSource representation] documentSource];
	}
	else {
		return false;
	}
		
	if ([webViewSource rangeOfString:@"<title>Xbox.com | Home Page - My Xbox</title>"].location != NSNotFound) {
		
		if ([webViewSource rangeOfString:@"<span class=\"text\">View Friends</span>"].location == NSNotFound) {
			return false;
		}
		
		friendsListSource1 = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://live.xbox.com/en-US/profile/Friends.aspx"] encoding:NSUTF8StringEncoding error:nil];
		
		if([friendsListSource1 rangeOfString:@"The service is unavailable at this time."].location != NSNotFound) {
			[self webViewErrorMessage:@"Apparently this portion of Xbox.com is unavailable right now. Please try again later." title:@"Friends List Data Unavailable"];
			return false;
		}
		else
			return true;
	
	}
	
	if ([webViewSource rangeOfString:@"<title>Continue</title>"].location != NSNotFound) 
		return false;
	if ([webViewSource rangeOfString:@"<title>Sign In</title>"].location != NSNotFound)
		return false;
	if ([webViewSource rangeOfString:@"<title>Xbox.com | Page unavailable</title>"].location != NSNotFound)
		return false;
			
	return false;
	 */
}

- (void)doneWithSignIn {
	NSLog(@"doneWithSignIn");
	currentMode = nil;
	[signInWindow close];
	
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"InSignInMode"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"InitialSignIn" object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"StartRefreshTimer" object:nil];
	/*
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsListNeedsRefresh" object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowFriendsList" object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeFriendsListMode" object:@"friends"];
	 */
	
	
}

+ (BOOL)isLoggedIn
{
	// Need to speed this up somehow ...
	NSLog(@"Are we signed in?");
	
	NSString *loginSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:FRIENDS_PAGE] encoding:NSUTF8StringEncoding error:nil];
	
	if (!loginSource) {
		return NO;
	}
	
	if ([loginSource rangeOfString:@"Sign out"].location != NSNotFound) {
		NSLog(@"We are signed in");
		return YES;
	}
	/*
	 if ([loginSource contains:@"Sign out"]) {
	 NSLog(@"We Are signed in");
	 return YES;
	 }
	 */
	NSLog(@"We are not signed in");
	return NO;
	
	/*
	 NSString *webViewSource;
	 WebDataSource *dataSource = [[webView mainFrame] dataSource];
	 if ([[dataSource representation] canProvideDocumentSource]) {
	 webViewSource = [[dataSource representation] documentSource];
	 }
	 else {
	 return false;
	 }
	 
	 if ([webViewSource rangeOfString:@"<title>Xbox.com | Home Page - My Xbox</title>"].location != NSNotFound) {
	 
	 if ([webViewSource rangeOfString:@"<span class=\"text\">View Friends</span>"].location == NSNotFound) {
	 return false;
	 }
	 
	 friendsListSource1 = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://live.xbox.com/en-US/profile/Friends.aspx"] encoding:NSUTF8StringEncoding error:nil];
	 
	 if([friendsListSource1 rangeOfString:@"The service is unavailable at this time."].location != NSNotFound) {
	 [self webViewErrorMessage:@"Apparently this portion of Xbox.com is unavailable right now. Please try again later." title:@"Friends List Data Unavailable"];
	 return false;
	 }
	 else
	 return true;
	 
	 }
	 
	 if ([webViewSource rangeOfString:@"<title>Continue</title>"].location != NSNotFound) 
	 return false;
	 if ([webViewSource rangeOfString:@"<title>Sign In</title>"].location != NSNotFound)
	 return false;
	 if ([webViewSource rangeOfString:@"<title>Xbox.com | Page unavailable</title>"].location != NSNotFound)
	 return false;
	 
	 return false;
	 */
}

@end