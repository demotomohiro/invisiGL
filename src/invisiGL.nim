type
    inglContextError* = object of OSError

proc newCntxtErr(message: string): ref inglContextError =
    return newException(inglContextError, message)

when hostOS == "windows":
    include invisiGL/private/wglcontext
elif hostOS == "linux":
    include invisiGL/private/eglcontext
else:
    {.error: "Unsupported OS".}

var defaultContext: inglContextObj

proc inglInitAuto*(majorVer: int32, minorVer: int32, isDebug: bool = false) {.raises: [inglContextError].} =
    defaultContext = inglInit(majorVer, minorVer, isDebug)
    defaultContext.inglMakeCurrent

proc inglCleanup*() =
    inglCleanup(defaultContext)

