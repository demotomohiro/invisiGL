import oldwinapi.windows

type
    inglContextObj* = object
        hWnd:   HWND
        hdc:    HDC
        hglrc:  HGLRC

proc inglInit*(majorVer: int32, minorVer: int32): inglContextObj {.raises: [inglContextError].} =
    var hWnd = CreateWindowEx(WS_EX_APPWINDOW, "STATIC", "", WS_POPUP, 0, 0, 640, 480, 0, 0, GetModuleHandle(nil), nil)
    if hWnd == 0:
        raise newCntxtErr "Failed to CreateWindowEx"
    defer:
        if hWnd != 0:
            discard DestroyWindow(hWnd)

    var hdc = GetDC(hWnd)
    if hdc == 0:
        raise newCntxtErr "Failed to GetDC"
    defer:
        if hdc != 0:
            assert(hWnd != 0)
            discard ReleaseDC(hWnd, hdc)

    var pfd = PIXELFORMATDESCRIPTOR(
        nSize:      int16(sizeof(PIXELFORMATDESCRIPTOR)),
        nVersion:   1,
        dwFlags:    cast[int32](PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER_DONTCARE or PFD_STEREO_DONTCARE),
        iPixelType: PFD_TYPE_RGBA,
        iLayerType: PFD_MAIN_PLANE)

    let iPixelFormat = ChoosePixelFormat(hdc, addr(pfd))
    if iPixelFormat == 0:
        raise newCntxtErr "Failed to ChoosePixelFormat"

    if SetPixelFormat(hdc, iPixelFormat, addr(pfd)) == 0:
        raise newCntxtErr "Failed to SetPixelFormat"

    var tmpCntxt = wglCreateContext(hdc)
    if tmpCntxt == 0:
        raise newCntxtErr "Failed to wglCreateContext"
    defer:
        if tmpCntxt != 0:
            discard wglMakeCurrent(0, 0)
            discard wglDeleteContext(tmpCntxt)

    if wglMakeCurrent(hdc, tmpCntxt) == 0:
        raise newCntxtErr "Failed to wglMakeCurrent(hdc, tmpCntxt)"

    type
        PFNwglCreateContextAttribsARB = proc (hDC: HDC, hShareContext: HGLRC, attribList: ptr int32): HGLRC {.stdcall.}
    let wglCreateContextAttribsARB = cast[PFNwglCreateContextAttribsARB](wglGetProcAddress("wglCreateContextAttribsARB"))

    try:
        if wglCreateContextAttribsARB == nil:
            raise newCntxtErr "wglCreateContextAttribsARB is not available"
    except inglContextError:
        raise
    except Exception:
        assert(false, "unexpected exception")

    const WGL_CONTEXT_MAJOR_VERSION_ARB = 0x2091i32
    const WGL_CONTEXT_MINOR_VERSION_ARB = 0x2092i32
    const WGL_CONTEXT_FLAGS_ARB         = 0x2094i32
    const WGL_CONTEXT_PROFILE_MASK_ARB  = 0x9126i32

#    const WGL_CONTEXT_DEBUG_BIT_ARB              = 0x0001i32
    const WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB = 0x0002i32
    const WGL_CONTEXT_CORE_PROFILE_BIT_ARB       = 0x00000001i32

    var attribList = [
        WGL_CONTEXT_MAJOR_VERSION_ARB,   majorVer,
        WGL_CONTEXT_MINOR_VERSION_ARB,   minorVer,
        WGL_CONTEXT_FLAGS_ARB,           WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB,
        WGL_CONTEXT_PROFILE_MASK_ARB,    WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
        0]

    var hglrc: HGLRC
    try:
        hglrc = wglCreateContextAttribsARB(hdc, 0, addr(attribList[0]))
    except Exception:
        assert(false, "unexpected exception")

    if hglrc == 0:
        raise newCntxtErr "Failed to wglCreateContextAttribsARB"

    discard wglMakeCurrent(0, 0)
    discard wglDeleteContext(tmpCntxt)
    tmpCntxt = 0

    swap(hWnd,  result.hWnd)
    swap(hdc,   result.hdc)
    swap(hglrc, result.hglrc)

proc inglMakeCurrent*(context: inglContextObj) {.raises: [inglContextError].} =
    if wglMakeCurrent(context.hdc, context.hglrc) == 0:
        raise newCntxtErr "Failed to wglCreateContext(hdc, hglrc)"

proc inglMakeCurrentNone*() =
    discard wglMakeCurrent(0, 0)

proc inglCleanup*(context: inglContextObj) =
    discard wglMakeCurrent(0, 0)
    let hglrc = context.hglrc
    if hglrc != 0:
        discard wglDeleteContext(hglrc)

    let hdc = context.hdc
    let hWnd = context.hWnd
    if hdc != 0:
        discard ReleaseDC(hWnd, hdc)

    if hWnd != 0:
        discard DestroyWindow(hWnd)

