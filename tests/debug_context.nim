import invisiGL
import opengl

proc mainTest() =
    inglInitAuto(4, 3, true)
    defer:
        inglCleanup()
    loadExtensions()

    var contextFlags: GLint
    glGetIntegerv(GL_CONTEXT_FLAGS, addr contextFlags)
    doAssert((contextFlags and cast[GLint](GL_CONTEXT_FLAG_DEBUG_BIT)) != 0, "Debug context is not created")
    #According to Chapter 20 Debug Output in OpenGL Specification version 4.6,
    #if the context is a debug context, the initial value of DEBUG_OUTPUT is TRUE
    doAssert(glIsEnabled(GL_DEBUG_OUTPUT) == GL_TRUE)

mainTest()

