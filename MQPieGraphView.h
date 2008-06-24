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
    BOOL autosize, drawLegend;
    NSColor *backgroundColor;
    NSColor *lineColor;
    NSColor *textColor;
    NSMutableArray *slices;
    MQSlice *clickedSlice, *overSlice;
    int size;
    float padding, fadeFactor;
}

@property(assign) id delegate;
@property(copy) NSColor *backgroundColor;
@property(assign) NSColor *lineColor;
@property(assign) NSColor *textColor;
@property(assign) NSMutableArray *slices;
@property(assign) MQSlice *clickedSlice;
@property(assign) MQSlice *overSlice;
@property(assign) int size;
@property(assign) float padding;
@property(assign) float fadeFactor;

//returns a slice depending on the point
- (MQSlice *)sliceForPoint:(NSPoint)p;

- (void)clearSelection;

//sorts the slices in order of size
- (void)sort;
- (void)reverseSort;

//adds specified slice to draw list
- (void)addSlice:(MQSlice *)slice;
//removes slice at index to draw list
- (void)removeSliceAtIndex:(int)index;
//gets a slice at index
- (MQSlice *)sliceAtIndex:(int)index;
- (void)clearSlices;


//call this to update the view after significant changes to data
- (void)updateView;
//called by update
- (void)recalibrateSliceSizes;

//mouse stuff
- (void)mouseMoved:(NSEvent *)event;
@end
