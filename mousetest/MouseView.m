//
//  MouseView.m
//  mousetest
//
//  Created by Adam Wulf on 10/16/17.
//  Copyright © 2017 Adam Wulf. All rights reserved.
//

#import "MouseView.h"

@interface MouseView () <NSDraggingSource>

@end

@implementation MouseView{
    NSDraggingSession* _activeSession;
}


// use the tracking loop method for mouse dragging.
// somehow, drag events can get stolen by other views than the originating view,
// which causes the drag to essentially disengage.
//
// another user had a similar issue: https://stackoverflow.com/questions/7451643/mousedragged-events-get-stolen-by-another-view
// in that case, they found switching from method based to event loop based drags solved the issue.
//
// that same fix happens here - using the event loop keeps the drag event from getting stolen
// and means we don't need to have a custom [hitTest:] method.
- (void)mouseDown:(NSEvent *)event
{
    BOOL dragActive = YES;
    BOOL isInside = YES;
    NSPoint mouseLoc;
    
    while (dragActive) {
        event = [[self window] nextEventMatchingMask:NSEventMaskLeftMouseDragged | NSEventMaskLeftMouseUp | NSEventMaskSystemDefined untilDate:[NSDate distantFuture] inMode:NSEventTrackingRunLoopMode dequeue:YES];
        mouseLoc = [self convertPoint:[event locationInWindow] fromView:nil];
        isInside = [self mouse:mouseLoc inRect:[self bounds]];
        
        NSLog(@"mousedown");
        
        switch ([event type]) {
            case NSEventTypeLeftMouseDragged:
                NSLog(@"mousedragged");
                
                [self processMouseDragged:event];
                
                
                break;
            case NSEventTypeLeftMouseUp:
                NSLog(@"mouseup");
                dragActive = NO;
                break;
            default:
                NSLog(@"other");
                /* Ignore any other kind of event. */
                break;
        }
    };
    
    // When clicking and dragging in the window, the MouseUp event is never sent.
    // The drag session seems to cause the issue. If [beginDraggingSessionWithItems:event:source:]
    // is never called, then the MouseUp event is processed just fine.
    NSLog(@"mouse is done");
}

-(void) processMouseDragged:(NSEvent*)event{
    NSPoint locationInView = [self convertPoint:[event locationInWindow] fromView:nil];
    NSPasteboardItem *pasteboardItem = [[NSPasteboardItem alloc] init];
    NSDraggingItem *draggingItem = [[NSDraggingItem alloc] initWithPasteboardWriter:pasteboardItem];
    NSSize draggingSize = NSMakeSize(100, 100);
    NSRect draggingFrame = NSMakeRect(locationInView.x, locationInView.y - draggingSize.height / 2, draggingSize.width, draggingSize.height);
    
    [draggingItem setDraggingFrame:draggingFrame contents:nil];
    
    _activeSession = [self beginDraggingSessionWithItems:@[draggingItem] event:event source:self];
    
    [_activeSession setDraggingFormation:NSDraggingFormationNone];

    NSLog(@"dragging session began");
}

#pragma mark - NSDraggingSource

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context{
    return NSDragOperationEvery;
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation{
    // noop
    NSLog(@"dragging session complete.");
    
    _activeSession = nil;
}

@end
