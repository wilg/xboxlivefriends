//
//  GIHaloScreenshotsController.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface MyImageObject : NSObject{
    NSString * mPath;
}

- (void) setPath:(NSString *) path;

@end


@interface GIHaloScreenshotsController : GITabController {

    // my images to display and browse (ie my data source) 
    NSMutableArray*	_myImages;
    NSMutableArray*	myImageSSIDs;
    NSMutableArray*	myImageTitles;
    NSMutableArray*	myImageDescriptions;

    // my browser (connected in the nib file)
    IBOutlet id mImageBrowser;
    NSMutableArray * mImages;
	NSMutableArray * mImportedImages;
	
	
	MAAttachedWindow *infoPop;
	IBOutlet NSView *infoWindowView;
	IBOutlet NSTextField *infoPopTitle;
	IBOutlet NSTextField *infoPopDescription;

    IBOutlet NSTextField *counter;

	BOOL quickLookAvailable;

}

- (IBAction) quickLookButton:(id) sender;
- (void)quickLookSelectedItems;

-(void)thumbDownload:(NSDictionary *)info;
- (void) updateDatasource;
- (void)doInfoPop;
- (void)closeInfoPop;

- (IBAction) zoomed:(id) sender;
- (void) addAnImageWithPath:(NSString *) path;
- (IBAction) addImageButtonClicked:(id) sender;


@end
