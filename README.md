# MouseUp Event with DraggingSession

## The problem:

The NSEventTypeLeftMouseUp event is never sent to the NSView when there is an active NSDraggingSession. NSEventTypeLeftMouseDragged events are sent and processed just fine, but the mouse up event is never sent.


## Steps to reproduce:

1. Build and run the app
2. Click and drag from anywhere in the window to anywhere in the window
3. View the Console in Xcode
4. Notice that "mouseup" is never printed to the console

## Expected behavior

After running above repro steps, the console should show:
1. "mousedown" once
2. "mousedragged" multiple times during the drag
3. "mouseup" when the drag is complete
