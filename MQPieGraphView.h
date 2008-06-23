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
    NSColor *bg;
    NSColor *lineColor;
    NSColor *textColor;
    NSMutableArray *slices;
    MQSlice *clickedSlice, *overSlice;
    int size;
    float padding, fadeFactor;
    
}
//returns a slice depending on the point
- (MQSlice *)getSliceForPoint:(NSPoint)p;

//delegate stuff, set [view delegate:self]; in the class you want to get events
- (void)setDelegate:(id)dele;
- (id)getDelegate;

//get last clicked stuff do this when you get events
- (MQSlice *)getLastClicked;
- (MQSlice *)getLastOver;
- (void)clearSelection;

//sorts the slices in order of size
- (void)sort;
- (void)reverseSort;

//factor of fading
- (void)setFadeFactor:(float)f;
- (float)getFadeFactor;

//sets and gets drawing of the legend default NO
- (BOOL)getDrawsLegend;
- (void)setDrawsLegend:(BOOL)s;

//sets and gets autoResize default YES
- (BOOL)getAutosizes;
- (void)setAutosizes:(BOOL)s;

//sets the lines between sections color default black
- (void)setLineColor:(NSColor *)newColor;
//gets the lines between sections color
- (NSColor *)getLineColor;

//set the radius
- (void)setSize:(int)s;
//get the radius (hook to a slider maybe?)
- (int)getSize;

//set padding
- (void)setPadding:(float)pad;
//get padding
- (float)getPadding;

//adds specified slice to draw list
- (void)addSlice:(MQSlice *)slice;
//removes slice at index to draw list
- (void)removeSliceAtIndex:(int)index;
//gets a slice at index
- (MQSlice *)getSliceAtIndex:(int)index;
- (void)clearSlices;

//set background color default white
- (void)setBackground:(NSColor *)newColor;
//get background color
- (NSColor *)getBackground;

//set text color default black
- (void)setTextColor:(NSColor *)newColor;
//get text color
- (NSColor *)getTextColor;

//call this to update the view after significant changes to data
- (void)updateView;
//called by update
- (void)recalibrateSliceSizes;
//DO NOT CALL THIS MANUALLY
- (void)drawLegend:(MQSlice *)slice i:(int)i;

//mouse stuff
- (void)mouseMoved:(NSEvent *)event;
@end
