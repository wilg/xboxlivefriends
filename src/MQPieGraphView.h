#import <Cocoa/Cocoa.h>

@class MQSlice;
@interface MQPieGraphView : NSView {
    id delegate;
    NSColor *backgroundColor;
    NSMutableArray *slices;
    float padding, fadeFactor;
	int currentIdentifier, highlightedSliceIdentifier;
}

@property(assign) id delegate;
@property(assign) NSColor *backgroundColor;
@property(assign) NSMutableArray *slices;
@property(assign) float padding;
@property(assign) float fadeFactor;

- (void)clearSelection;

- (void)sort;

- (MQSlice *)lastClickedSlice;
- (MQSlice *)sliceWithIdentifier:(int)i;
- (MQSlice *)sliceForPoint:(NSPoint)point;

- (void)addSlice:(MQSlice *)slice;
- (void)removeSliceAtIndex:(int)index;
- (void)clearSlices;


- (void)recalibrateSliceSizes;

@end
