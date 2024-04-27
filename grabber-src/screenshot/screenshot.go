package screenshot
// a bit rewritten ver of the lib of : github.com/kbinani/screenshot
// this ver is wayy faster and takes less than 1s -> old one like 5 / 6s
import (
	"image"
	"os"
	"syscall"
	"unsafe"
	"image/png"
	win "github.com/lxn/win"
)

var (
	lUS32, _               = syscall.LoadLibrary("user32.dll")
	fgdw, _    = syscall.GetProcAddress(syscall.Handle(lUS32), "GetDesktopWindow")
	fedm, _ = syscall.GetProcAddress(syscall.Handle(lUS32), "EnumDisplayMonitors")
	fgmi, _      = syscall.GetProcAddress(syscall.Handle(lUS32), "GetMonitorInfoW")
	feds, _ = syscall.GetProcAddress(syscall.Handle(lUS32), "EnumDisplaySettingsW")
)

func Capture(x, y, width, height int) (*image.RGBA, error) {
	rect := image.Rect(0, 0, width, height)
	img := CreateImage(rect)


	hwnd := getDesktopWindow()
	hdc := win.GetDC(hwnd)
	if hdc == 0 {
		return nil, nil
	}
	defer win.ReleaseDC(hwnd, hdc)

	memory_device := win.CreateCompatibleDC(hdc)
	if memory_device == 0 {
		return nil, nil
	}
	defer win.DeleteDC(memory_device)

	bitmap := win.CreateCompatibleBitmap(hdc, int32(width), int32(height))
	if bitmap == 0 {
		return nil, nil
	}
	defer win.DeleteObject(win.HGDIOBJ(bitmap))

	var header win.BITMAPINFOHEADER
	header.BiSize = uint32(unsafe.Sizeof(header))
	header.BiPlanes = 1
	header.BiBitCount = 32
	header.BiWidth = int32(width)
	header.BiHeight = int32(-height)
	header.BiCompression = win.BI_RGB
	header.BiSizeImage = 0

	bitmapDataSize := uintptr(((int64(width)*int64(header.BiBitCount) + 31) / 32) * 4 * int64(height))
	hmem := win.GlobalAlloc(win.GMEM_MOVEABLE, bitmapDataSize)
	defer win.GlobalFree(hmem)
	memptr := win.GlobalLock(hmem)
	defer win.GlobalUnlock(hmem)

	old := win.SelectObject(memory_device, win.HGDIOBJ(bitmap))
	defer win.SelectObject(memory_device, old)

	if !win.BitBlt(memory_device, 0, 0, int32(width), int32(height), hdc, int32(x), int32(y), win.SRCCOPY) {
		return nil, nil
	}

	if win.GetDIBits(hdc, bitmap, 0, uint32(height), (*uint8)(memptr), (*win.BITMAPINFO)(unsafe.Pointer(&header)), win.DIB_RGB_COLORS) == 0 {
		return nil, nil
	}

	src := (*[1 << 30]uint8)(unsafe.Pointer(memptr))[:width*height*4:width*height*4]

	for i := 0; i < len(src); i += 4 {
		v0 := src[i]
		v1 := src[i+1]
		v2 := src[i+2]
	
		img.Pix[i] = v2 
		img.Pix[i+1] = v1 
		img.Pix[i+2] = v0  
		img.Pix[i+3] = 255 
	}
	
	return img, nil
}

func CreateImage(rect image.Rectangle) *image.RGBA {
	return image.NewRGBA(rect)
}

func getDesktopWindow() win.HWND {
	ret, _, _ := syscall.Syscall(fgdw, 0, 0, 0, 0)
	return win.HWND(ret)
}

func NumActiveDisplays() int {
	var count int = 0
	enumDisplayMonitors(win.HDC(0), nil, syscall.NewCallback(countupMonitorCallback), uintptr(unsafe.Pointer(&count)))
	return count
}

func GetDisplayBounds(displayIndex int) image.Rectangle {
	var ctx getMonitorBoundsContext; enumDisplayMonitors(win.HDC(0), nil, syscall.NewCallback(func(hMonitor win.HMONITOR, hdcMonitor win.HDC, lprcMonitor *win.RECT, dwData uintptr) uintptr {
		if ctx.Count == displayIndex {ctx.Count++;if realSize := getMonitorRealSize(hMonitor); realSize != nil {ctx.Rect = *realSize} else {ctx.Rect = *lprcMonitor}} else {ctx.Count++}; return 1}), uintptr(unsafe.Pointer(&ctx))); return image.Rect(int(ctx.Rect.Left), int(ctx.Rect.Top), int(ctx.Rect.Right), int(ctx.Rect.Bottom))
}


func enumDisplayMonitors(hdc win.HDC, lprcClip *win.RECT, lpfnEnum uintptr, dwData uintptr) bool {
	ret, _, _ := syscall.Syscall6(fedm, 4,
		uintptr(hdc),
		uintptr(unsafe.Pointer(lprcClip)),
		lpfnEnum,
		dwData,
		0,
		0)
	return int(ret) != 0
}

func countupMonitorCallback(hMonitor win.HMONITOR, hdcMonitor win.HDC, lprcMonitor *win.RECT, dwData uintptr) uintptr {
	*(*int)(unsafe.Pointer(dwData))++
	return 1
}


type getMonitorBoundsContext struct {
	Index int
	Rect  win.RECT
	Count int
}

func getMonitorBoundsCallback(hMonitor win.HMONITOR, hdcMonitor win.HDC, lprcMonitor *win.RECT, dwData uintptr) uintptr {
	ctx := (*getMonitorBoundsContext)(unsafe.Pointer(dwData))

	if ctx.Count != ctx.Index {
		ctx.Count++
		return 1
	}

	if realSize := getMonitorRealSize(hMonitor); realSize != nil {
		ctx.Rect = *realSize
	} else {
		ctx.Rect = *lprcMonitor
	}

	return 0
}


func getMonitorRealSize(hMonitor win.HMONITOR) *win.RECT {
	info := _MONITORINFOEX{}
	info.CbSize = uint32(unsafe.Sizeof(info))
	ret, _, _ := syscall.Syscall(fgmi, 2, uintptr(hMonitor), uintptr(unsafe.Pointer(&info)), 0)
	if ret == 0 {
		return nil
	}

	devMode := _DEVMODE{}
	devMode.DmSize = uint16(unsafe.Sizeof(devMode))

	if ret, _, _ := syscall.Syscall(feds, 3, uintptr(unsafe.Pointer(&info.DeviceName[0])), _ENUM_CURRENT_SETTINGS, uintptr(unsafe.Pointer(&devMode))); ret == 0 {
		return nil
	}

	return &win.RECT{
		Left:   devMode.DmPosition.X,
		Right:  devMode.DmPosition.X + int32(devMode.DmPelsWidth),
		Top:    devMode.DmPosition.Y,
		Bottom: devMode.DmPosition.Y + int32(devMode.DmPelsHeight),
	}
}

type _MONITORINFOEX struct {
	win.MONITORINFO
	DeviceName [win.CCHDEVICENAME]uint16
}

const _ENUM_CURRENT_SETTINGS = 0xFFFFFFFF

type _DEVMODE struct {
	_            [68]byte
	DmSize       uint16
	_            [6]byte
	DmPosition   win.POINT
	_            [86]byte
	DmPelsWidth  uint32
	DmPelsHeight uint32
	_            [40]byte
}

func main() {
	he, _ := Capture(0, 0, 1920, 1080)

	file, _ := os.Create("ss.png")
	defer file.Close()

	_ = png.Encode(file, he)
}
