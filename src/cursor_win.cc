#using <mscorlib.dll>
#using <System.Drawing.dll>

#include "mouse.h"
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

MMInfo m;
CURSORINFO cursorInfo;
int height = 0, width = 0;
HCURSOR hCursor;
ICONINFO ii;

gcroot<System::Drawing::Bitmap^> bmp;
gcroot<MemoryStream^> ms = gcnew MemoryStream();
gcroot<Icon^> icon;

MMInfo getCursorInfo(bool force){
	cursorInfo.cbSize = sizeof(cursorInfo);
	GetCursorInfo(&cursorInfo);

	if(!force && hCursor == cursorInfo.hCursor){
		m.size = 0;
		return m;
	}
	else
		hCursor = cursorInfo.hCursor;

	if(hCursor == NULL){
		m.size = 1;
		m.hidden = true;
		return m;
	}

	GetIconInfo(hCursor, &ii);
	icon = Icon::FromHandle((IntPtr)hCursor);
	auto colorbmp = RAIIHBITMAP(ii.hbmColor);
	auto maskbmp = RAIIHBITMAP(ii.hbmMask);

	bmp = icon->ToBitmap();
	icon->~Icon();
	bmp->Save(ms, Imaging::ImageFormat::Png);
	String^ base64 = Convert::ToBase64String(ms->GetBuffer(), 0, ms->Length);

	height = bmp->Height;
	width = bmp->Width;
	m.left = ii.xHotspot;
	m.top = ii.yHotspot;
	m.width = width;
	m.height = height;
	m.size = base64->Length;
	m.hidden = cursorInfo.flags == 0 ? true : false;
	m.bytes = (char*)(void*)Runtime::InteropServices::Marshal::StringToHGlobalAnsi(base64);

	ms->SetLength(0);
	delete bmp;
	delete icon;

	return m;
}

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
