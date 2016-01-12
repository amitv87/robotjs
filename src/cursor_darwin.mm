#include <ApplicationServices/ApplicationServices.h>
#import <Foundation/Foundation.h>
#import <AppKit/Appkit.h>
#include "mouse.h"
MMInfo m;

NSAutoreleasePool *nsPool = [[NSAutoreleasePool alloc] init];
NSApplication *app = [NSApplication sharedApplication];
// NSEvent *event = [app nextEventMatchingMask: NSAnyEventMask
	// untilDate: nil inMode: NSDefaultRunLoopMode dequeue: 1];
CFDataRef prevData;
MMInfo getCursorInfo(bool force){
	NSCursor *cursor = [NSCursor currentSystemCursor];
	NSPoint hotSpot = [cursor hotSpot];
	NSImage *nsImage = [cursor image];
	NSSize size = [nsImage size];

	CGImage *cgImage = [nsImage CGImageForProposedRect: nil context: nil hints: nil];
	CFDataRef curData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
	if(!force && (prevData != nil && CFEqual(curData, prevData))){
		m.size = 0;
		[curData release];
		[cgImage release];
		[nsImage release];
		[cursor release];
		return m;
	}

	[prevData release];
	prevData = curData;

	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage: cgImage];
	NSData* pngData = [imageRep representationUsingType: NSPNGFileType properties: nil];

	NSString *base64png = [pngData base64EncodedStringWithOptions:0];

	m.left = hotSpot.x;
	m.top = hotSpot.y;
	m.width = size.width;
	m.height = size.height;
	m.size = [base64png length];
	m.hidden = !CGCursorIsVisible();
	m.bytes = (char *)[base64png UTF8String];

	return m;
}
