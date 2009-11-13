//
//  LoginController.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LoginController : NSObject {

	//sign in window
	IBOutlet NSWindow *signInWindow;
	IBOutlet NSProgressIndicator *webViewProgress;
	IBOutlet NSProgressIndicator *webViewProgressSpinner;
    IBOutlet WebView *webView;
	
	//new sign in
	IBOutlet NSTextField *email;
	IBOutlet NSTextField *password;

	NSString *currentMode;

}


- (IBAction)newSignInButtonClicked:(id)sender;
- (BOOL)loginToPassportWithEmail:(NSString *)emailAddress password:(NSString *)loginPass;

- (IBAction)OpenSignIn:(id)sender;
- (IBAction)CloseSignIn:(id)sender;
- (IBAction)retryLoadingPage:(id)sender;

- (void)loadURL:(NSURL *)URL;
- (void)webViewErrorMessage:(NSString *)msg title:(NSString *)title;
- (BOOL)isSignedIn;
- (void)doneWithSignIn;


@end
