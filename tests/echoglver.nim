import invisiGL
import opengl

proc mainTest() =
    inglInitAuto(4, 0)
    defer:
        inglCleanup()
    loadExtensions()

    let pver = glGetString(GL_VERSION)
    if pver == nil:
        quit "glGetString returned nil. Failed to create OpenGL context?"
    echo cast[cstring](pver)

mainTest()
