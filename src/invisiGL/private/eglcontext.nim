import egl
{.passL: "-lEGL".}

type
    inglContextObj* = object
        display: EGLDisplay
        context: EGLContext

proc inglInit*(majorVer: int32, minorVer: int32, isDebug: bool): inglContextObj {.raises: [inglContextError].} =
    var display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if display == EGL_NO_DISPLAY:
        raise newCntxtErr "Failed to eglGetDisplay(EGL_DEFAULT_DISPLAY)"

    var egl_major_ver, egl_minor_ver: EGLint
    if eglInitialize(display, addr egl_major_ver, addr egl_minor_ver) == EGL_FALSE:
        raise newCntxtErr "Failed to eglInitialize, " & (
            case eglGetError()
            of EGL_BAD_DISPLAY:
                "display is not an EGL display connection"
            of EGL_NOT_INITIALIZED:
                "display cannot be initialized"
            else:
                "Unknown error")
    defer:
        if display != EGL_NO_DISPLAY:
            discard eglTerminate(display)
    echo "EGL version: ",  egl_major_ver, ".", egl_minor_ver

    let client_apis: cstring = eglQueryString(display, EGL_CLIENT_APIS);
    if client_apis == nil:
        raise newCntxtErr "Failed to eglQueryString(display, EGL_CLIENT_APIS)"
    echo "Supported client rendering APIs: ", client_apis

    var config: EGLConfig
    var num_config: EGLint
    var attrib_list = [
        cast[EGLint](EGL_SURFACE_TYPE),       EGL_PBUFFER_BIT,
        EGL_RENDERABLE_TYPE,    EGL_OPENGL_BIT,
        EGL_NONE
    ]
    if eglChooseConfig(display, addr attrib_list[0], addr config, 1, addr num_config) == EGL_FALSE:
        raise newCntxtErr "Failed to eglChooseConfig, " & (
            case eglGetError():
            of EGL_BAD_ATTRIBUTE:
                "attribute_list contains an invalid frame buffer configuration attribute or an attribute value that is unrecognized or out of range"
            else:
                "Unknown error")
    if num_config < 1:
        raise newCntxtErr "No matching EGL frame buffer configuration"

    if eglBindAPI(EGL_OPENGL_API) == EGL_FALSE:
        raise newCntxtErr "Failed to eglBindAPI(EGL_OPENGL_API)"

    const EGL_CONTEXT_FLAGS_KHR: EGLint  = 0x30FC
    const EGL_CONTEXT_OPENGL_DEBUG_BIT_KHR: EGLint              = 0x00000001
    const EGL_CONTEXT_OPENGL_FORWARD_COMPATIBLE_BIT_KHR: EGLint = 0x00000002

    var context_attrib = [
        cast[EGLint](EGL_CONTEXT_MAJOR_VERSION),          majorVer,
        EGL_CONTEXT_MINOR_VERSION,          minorVer,
        EGL_CONTEXT_OPENGL_PROFILE_MASK,    EGL_CONTEXT_OPENGL_CORE_PROFILE_BIT,
        EGL_CONTEXT_FLAGS_KHR,              EGL_CONTEXT_OPENGL_FORWARD_COMPATIBLE_BIT_KHR or (if isDebug: EGL_CONTEXT_OPENGL_DEBUG_BIT_KHR else: 0),
        EGL_NONE
    ]

    var context = eglCreateContext(display, config, EGL_NO_CONTEXT, addr context_attrib[0])
    if context == EGL_NO_CONTEXT:
        raise newCntxtErr "Failed to eglCreateContext," & (
            case eglGetError()
            of EGL_BAD_CONFIG:
                "config is not an EGL frame buffer configuration, or does not support the current rendering API"
            of EGL_BAD_ATTRIBUTE:
                "attrib_list contains an invalid context attribute or if an attribute is not recognized or out of range"
            else:
                "Unknown error")

    swap(display, result.display)
    swap(context, result.context)

proc inglMakeCurrent*(context: inglContextObj) {.raises: [inglContextError].} =
    if eglMakeCurrent(context.display, EGL_NO_SURFACE, EGL_NO_SURFACE, context.context) == EGL_FALSE:
        raise newCntxtErr "Failed to eglMakeCurrent"

proc inglMakeCurrentNone*() =
    let display = eglGetCurrentDisplay()
    if display == EGL_NO_DISPLAY:
        return
    discard eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT)

proc inglCleanup*(context: inglContextObj) =
    discard eglTerminate(context.display)
