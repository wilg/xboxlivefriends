/**
    INSTRUCTIONS
    
    DO NOT CALL drawRect: or drawLegend:i: manually
    updateView will handle both
    
    Custom view, set custom class to this obviously.
    Whatever class has a connection to the view, make sure its header has an @class MQPieGraphView above the @interface line.
    And in its main file add #import "MQPieGraphView.h" to its list
    
    Also good idea to do the same for MQSlice wherever your going to be creating instances of it.
    
    
    The rest of the instructions are next to the method prototypes below
    Also it should handle resizeing autoomagically
*/
#import <Cocoa/Cocoa.h>

@class MQSlice;
@interface MQPieGraphView : NSView {
    id delegate;
    NSColor *backgroundColor;
    NSMutableArray *slices;
    MQSlice *clickedSlice, *overSlice;
    float padding, fadeFactor;
}

@property(assign) id delegate;
@property(copy) NSColor *backgroundColor;
@property(retain) NSMutableArray *slices;
@property(assign) MQSlice *clickedSlice;
@property(assign) MQSlice *overSlice;
@property(assign) float padding;
@property(assign) float fadeFactor;

- (MQSlice *)sliceForPoint:(NSPoint)p;

- (void)clearSelection;

- (void)sort;
- (void)reverseSort;

- (MQSlice *)sliceAtIndex:(int)index;
- (void)addSlice:(MQSlice *)slice;
- (void)removeSliceAtIndex:(int)index;
- (void)clearSlices;


- (void)updateView;
- (void)recalibrateSliceSizes;

@end
