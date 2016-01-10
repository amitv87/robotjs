#include "mouse.h"
#if defined(IS_MACOSX)
	#include <ApplicationServices/ApplicationServices.h>
	#import <Foundation/Foundation.h>
	#import <AppKit/Appkit.h>
#elif defined(USE_X11)
	#include <X11/Xlib.h>
	#include <X11/extensions/XTest.h>
	#include <stdlib.h>
	#include "xdisplay.h"
#endif

MMInfo m;
#if defined(IS_WINDOWS)
	// typedef struct {
	//   DWORD   cbSize;
	//   DWORD   flags;
	//   HCURSOR hCursor;
	//   POINT   ptScreenPos;
	// } CURSORINFO, *PCURSORINFO, *LPCURSORINFO;

	// typedef struct _ICONINFO {
	//   BOOL    fIcon;
	//   DWORD   xHotspot;
	//   DWORD   yHotspot;
	//   HBITMAP hbmMask;
	//   HBITMAP hbmColor;
	// } ICONINFO, *PICONINFO;

	// typedef struct tagPOINT {
	//   LONG x;
	//   LONG y;
	// } POINT, *PPOINT;

	#using <mscorlib.dll>
	#using <System.Drawing.dll>
	#include <Windows.h>
	#include <memory>
	#include <vector>
	#include <vcclr.h>
	using namespace System;
	using namespace System::IO;
	using namespace System::Drawing;

	#define RAIIHDC(handle) std::unique_ptr<std::remove_pointer<HDC>::type, decltype(&::DeleteDC)>(handle, &::DeleteDC)
	#define RAIIHBITMAP(handle) std::unique_ptr<std::remove_pointer<HBITMAP>::type, decltype(&::DeleteObject)>(handle, &::DeleteObject)
	#define RAIIHANDLE(handle) std::unique_ptr<std::remove_pointer<HANDLE>::type, decltype(&::CloseHandle)>(handle, &::CloseHandle)

	CURSORINFO cursorInfo;
	int height = 0, width = 0;
	HCURSOR hCursor;

	gcroot<System::Drawing::Bitmap^> bmp;
	gcroot<MemoryStream^> ms = gcnew MemoryStream();
	gcroot<Icon^> icon;

	MMInfo getCursorInfo(){
		cursorInfo.cbSize = sizeof(cursorInfo);
		GetCursorInfo(&cursorInfo);

		if(hCursor == cursorInfo.hCursor){
			m.size = 0;
			return m;
		}
		else
			hCursor = cursorInfo.hCursor;

		ICONINFO ii;
		GetIconInfo(hCursor, &ii);
		icon = ::Icon::FromHandle((IntPtr)hCursor);
		auto colorbmp = RAIIHBITMAP(ii.hbmColor);
		auto maskbmp = RAIIHBITMAP(ii.hbmMask);

		bmp = icon->ToBitmap();
		icon->~Icon();
		bmp->Save(ms, Imaging::ImageFormat::Png);
		array<unsigned char>^ bytes = ms->GetBuffer();
		pin_ptr<unsigned char> p = &bytes[0];

		height = bmp->Height;
		width = bmp->Width;
		m.left = ii.xHotspot;
		m.top = ii.yHotspot;
		m.width = width;
		m.height = height;
		m.size = ms->Length;
		m.bytes = reinterpret_cast<char*>(p);

		ms->SetLength(0);
		delete bmp;
		delete icon;

		return m;
	}
#else
	NSAutoreleasePool *nsPool = [[NSAutoreleasePool alloc] init];
	NSApplication *app = [NSApplication sharedApplication];
	// NSEvent *event = [app nextEventMatchingMask: NSAnyEventMask
		// untilDate: nil inMode: NSDefaultRunLoopMode dequeue: 1];
	CFDataRef prevData;
	MMInfo getCursorInfo(){
		NSCursor *cursor = [NSCursor currentSystemCursor];
		NSPoint hotSpot = [cursor hotSpot];
		NSImage *nsImage = [cursor image];
		NSSize size = [nsImage size];

		CGImage *cgImage = [nsImage CGImageForProposedRect: nil context: nil hints: nil];
		CFDataRef curData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
		if(prevData != nil && CFEqual(curData, prevData)) {
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
		m.bytes = (char *)[base64png UTF8String];


		[imageRep release];
		[cgImage release];
		[nsImage release];
		[cursor release];
		[pngData release];
		[base64png release];
		return m;
	}
#endif
