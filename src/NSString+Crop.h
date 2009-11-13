//
//  NSString+Crop.h
//  Xbox Live Friends
//
//  Created by Wil Gieseler on 6/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSString (MQCropExtension)

- (NSString *) cropFrom:(NSString *)start to:(NSString *)end;
- (NSArray *) cropRowsMatching:(NSString *)start rowEnd:(NSString *)end;
- (NSString *) replace:(NSString *)string with:(NSString *)replacement;
- (BOOL) contains:(NSString *)string;

@end
