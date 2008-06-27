//
//  GIHaloScreenshotsController.m
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MAAttachedWindow.h"
#import "GITabController.h"
#import "GIHaloScreenshotsController.h"
#import "Xbox Live Friends.h"
#import "QuickLook.h"
#import "HaloScreenshotParser.h"

#define QLPreviewPanel NSClassFromString(@"QLPreviewPanel")


static NSArray *openFiles()
{
    NSOpenPanel *panel;
 
    panel = [NSOpenPanel openPanel];
    [panel setFloatingPanel:YES];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    int i = [panel runModalForTypes:nil];
    if(i == NSOKButton){
        return [panel filenames];
    }
 
    return nil;
}

@implementation GIHaloScreenshotsController

- (id)init {
	if (![super init])
	return nil;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabSelectionChanged:) name:@"GamerInfoTabWillChange" object:nil];

	
	return self;
}


- (void) awakeFromNib
{

	// First, load the Quick Look framework and set the delegate
	quickLookAvailable = [[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/QuickLookUI.framework"] load];
	if(quickLookAvailable)
		[[[QLPreviewPanel sharedPreviewPanel] windowController] setDelegate:self];


    mImages = [[NSMutableArray alloc] init];
	myImageSSIDs = [[NSMutableArray alloc] init];
	myImageTitles = [[NSMutableArray alloc] init];
	myImageDescriptions = [[NSMutableArray alloc] init];

    mImportedImages = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewContentBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[mImageBrowser superview]];
}


- (NSString *)notificationName {
	return @"GIHaloScreenshotLoadNotification";
}


- (void)clearTab {
	[mImages removeAllObjects];
	[myImageSSIDs removeAllObjects];
	[myImageTitles removeAllObjects];
	[myImageDescriptions removeAllObjects];
}

- (void)displayGamerInfo:(NSString *)gamertag {
	NSDictionary *info = [HaloScreenshotParser parseScreenshotList:gamertag];
	if (info) {
		[self thumbDownload:info];
	}
	else {
		[self setErrorForTab:@"No Screenshots"];
	}
}

- (NSString *)screenshotPath {
	NSString *defaultPath = [NSTemporaryDirectory() stringByAppendingString:@"com.mindquirk.xlf/Halo3Screenshots"];
	if ([[NSFileManager defaultManager] contentsOfDirectoryAtPath:defaultPath error:nil] == nil) {
		[[NSFileManager defaultManager] createDirectoryAtPath:defaultPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	return defaultPath;
}

-(void)thumbDownload:(NSDictionary *)info {

	NSArray *largeSSIDs = [info objectForKey:@"ssids"];
	NSArray *titles = [info objectForKey:@"titles"];
	NSArray *descriptions = [info objectForKey:@"descriptions"];

	NSString *defaultPath =	[self screenshotPath];
	
	int i = 0;
	for (NSString *ssid in largeSSIDs) {
		bool success = NO;
	
		NSString *filePath = [NSString stringWithFormat:@"%@/%@_medium.jpg", defaultPath, ssid];
				
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.bungie.net/Stats/Halo3/Screenshot.ashx?size=medium&ssid=%@", ssid]];
			NSData *thisScreenshotData = [NSData dataWithContentsOfURL:imageURL];
			if ([thisScreenshotData writeToFile:filePath atomically:YES])
				success = YES;
		}
		else
			success = YES;
		
		if (success) {
			[self addAnImageWithPath: filePath];
			[myImageSSIDs addObject:ssid];

			[myImageTitles addObject:[titles objectAtIndex:i]];
			[myImageDescriptions addObject:[descriptions objectAtIndex:i]];
			[self performSelectorOnMainThread:@selector(updateDatasource) withObject:nil waitUntilDone:YES];
		}

		i++;
	}
	
	if ([mImages count] == 0) {
		[self setErrorForTab:@"No Screenshots"];
	}

	[self loadingComplete];

}




// This is the delegate method
// It should return the frame for the item represented by the URL
// If an empty frame is returned then the panel will fade in/out instead
- (NSRect)previewPanel:(NSPanel*)panel frameForURL:(NSURL*)URL
{
	if ([[mImageBrowser selectionIndexes] count] == 0)
		return NSMakeRect(0, 0, 0, 0);

	NSUInteger selectedIndex =  [[mImageBrowser selectionIndexes] firstIndex];
	
	NSRect frame = [mImageBrowser itemFrameAtIndex:selectedIndex];
	frame = [mImageBrowser convertRectToBase:frame];
	frame.origin = [[mImageBrowser window] convertBaseToScreen:frame.origin];
	
	return frame;
	
}

- (void)tabSelectionChanged:(NSNotification *)notification
{	
	[mImageBrowser setSelectionIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
}


- (IBAction) quickLookButton:(id) sender;
{
	if(quickLookAvailable)
	{
		// If the user presses space when the preview panel is open then we close it
		if([[QLPreviewPanel sharedPreviewPanel] isOpen])
			[[QLPreviewPanel sharedPreviewPanel] closeWithEffect:2];
		else
		{
			// Otherwise, set the current items
			[self quickLookSelectedItems];
			// And then display the panel
			[[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFrontWithEffect:2];
			// Restore the focus to our window to demo the selection changing, scrolling (left/right)
			// and closing (space) functionality
			[[mImageBrowser window] makeKeyWindow];
		}
	}

}

- (void)quickLookSelectedItems
{
	if(quickLookAvailable)
	{
	
		if ([[mImageBrowser selectionIndexes] count] == 0)
			return;
			
		NSUInteger selectedIndex =  [[mImageBrowser selectionIndexes] firstIndex];
		
		
		//download the big image
		NSString *ssid = [myImageSSIDs objectAtIndex:selectedIndex];
		NSString *defaultPath =	[self screenshotPath];
		NSString *filePath = [NSString stringWithFormat:@"%@/%@_full.jpg", defaultPath, ssid];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.bungie.net/Stats/Halo3/Screenshot.ashx?size=full&ssid=%@", ssid]];
			NSLog([imageURL absoluteString]);
			NSData *thisScreenshotData = [NSData dataWithContentsOfURL:imageURL];
			[thisScreenshotData writeToFile:filePath atomically:YES];
		}
				
		
		
		NSMutableArray* URLs = [NSMutableArray arrayWithCapacity:1];

		[URLs addObject:[NSURL fileURLWithPath:filePath]];

		// The code above just gathers an array of NSURLs representing the selected items,
		// to set here
		[[QLPreviewPanel sharedPreviewPanel] setURLs:URLs currentIndex:0 preservingDisplayState:YES];

	

	}
}


- (void) dealloc
{
    [mImages release];
	[myImageSSIDs release];
    [mImportedImages release];
    [super dealloc];
}

- (void) updateDatasource
{
    [mImages addObjectsFromArray:mImportedImages];
    [mImportedImages removeAllObjects];
    [mImageBrowser reloadData];
	
	if ([mImages count] == 0)
		[counter setStringValue:@"No Screenshots"];
	else if ([mImages count] != 1)
		[counter setStringValue:[NSString stringWithFormat:@"%i screenshots", [mImages count]]];
	else
		[counter setStringValue:@"1 screenshot"];
}

- (int) numberOfItemsInImageBrowser:(IKImageBrowserView *) view
{
    return [mImages count];
}
 
- (id) imageBrowser:(IKImageBrowserView *) view itemAtIndex:(int) index
{
    return [mImages objectAtIndex:index];
}

- (void) imageBrowser:(IKImageBrowserView *) aBrowser cellWasDoubleClickedAtIndex:(NSUInteger) index {
	[self quickLookButton:nil];
}

- (void) imageBrowserSelectionDidChange:(IKImageBrowserView *) aBrowser {
	if([[QLPreviewPanel sharedPreviewPanel] isOpen])
		[self quickLookSelectedItems];
	[self doInfoPop];
}


- (void)doInfoPop {


    if ([[mImageBrowser selectionIndexes] count] == 1) {
	
	
		if ([[mImageBrowser selectionIndexes] count] == 0)
			return;

		NSUInteger selectedIndex =  [[mImageBrowser selectionIndexes] firstIndex];

		NSRect frame = [mImageBrowser itemFrameAtIndex:selectedIndex];
		frame = [mImageBrowser convertRectToBase:frame];
		
		NSRect browserRect = [[mImageBrowser superview] frame];
		browserRect.origin = [[mImageBrowser window] convertBaseToScreen:browserRect.origin];
		
		NSPoint point = [[mImageBrowser window] convertBaseToScreen:frame.origin];
		point.x += frame.size.width;
		point.y += frame.size.height / 2;
		
		if (point.y > browserRect.origin.y + browserRect.size.height + [infoWindowView frame].size.height + 10 || point.y < browserRect.origin.y  + [infoWindowView frame].size.height + 10) {
		
			[self closeInfoPop];
			return;

		}

		if (!infoPop) {
		
			infoPop = [[MAAttachedWindow alloc] initWithView:infoWindowView attachedToPoint:point onSide:MAPositionRight];
			[[mImageBrowser window] addChildWindow:infoPop ordered:NSWindowAbove];
//			[infoPop setHidesOnDeactivate:YES];

		}
				
		[infoPopTitle setStringValue:[myImageTitles objectAtIndex:selectedIndex]];
		[infoPopDescription setStringValue:[myImageDescriptions objectAtIndex:selectedIndex]];

		[infoPop setPoint:point side:MAPositionRight];
	

		
		
    } else {
		[self closeInfoPop];
    }

}

- (void) closeInfoPop {
	if (infoPop) {
		[[mImageBrowser window] removeChildWindow:infoPop];
		[infoPop orderOut:self];
		[infoPop release];
		infoPop = nil;
	}
}

- (IBAction) zoomed:(id) sender {
	[mImageBrowser setZoomValue:[sender floatValue]];
	[self doInfoPop];
}

- (void)scrollViewContentBoundsDidChange:(NSNotification *)notification {
	[self doInfoPop];
}

- (IBAction) addImageButtonClicked:(id) sender
{
    NSArray *path = openFiles();
 
    if(!path){
        NSLog(@"No path selected, return...");
        return;
    }
   [NSThread detachNewThreadSelector:@selector(addImagesWithPaths:) toTarget:self withObject:path];
}

- (void) addAnImageWithPath:(NSString *) path
{
    MyImageObject *p;
 
    p = [[MyImageObject alloc] init];
    [p setPath:path];
    [mImportedImages addObject:p];
    [p release];
}

- (void) addImagesWithPath:(NSString *) path recursive:(BOOL) recursive
{
    int i, n;
    BOOL dir;
 
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dir];
    if(dir){
        NSArray *content = [[NSFileManager defaultManager]
                              directoryContentsAtPath:path];
        n = [content count];
       for(i=0; i<n; i++){
            if(recursive)
               [self addImagesWithPath:
                     [path stringByAppendingPathComponent:
                            [content objectAtIndex:i]]
                            recursive:NO];
            else
              [self addAnImageWithPath:
                     [path stringByAppendingPathComponent:
                           [content objectAtIndex:i]]];
        }
    }
    else
        [self addAnImageWithPath:path];
}


- (void) addImagesWithPaths:(NSArray *) paths
{
    int i, n;
 
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [paths  retain];
 
    n = [paths count];
    for(i=0; i<n; i++){
        NSString *path = [paths objectAtIndex:i];
        [self addImagesWithPath:path recursive:NO];
    }
 
    [self performSelectorOnMainThread:@selector(updateDatasource)
                           withObject:nil
                        waitUntilDone:YES];
 
    [paths release];
    [pool release];
}

@end

@implementation MyImageObject


- (void) dealloc
{
    [mPath release];
    [super dealloc];
}

- (void) setPath:(NSString *) path
{
    if(mPath != path){
        [mPath release];
        mPath = [path retain];
    }
}

- (NSString *)  imageRepresentationType
{
    return IKImageBrowserPathRepresentationType;
}
 
- (id)  imageRepresentation
{
    return mPath;
}
 
- (NSString *) imageUID
{
    return mPath;
}

@end
