# invisiGL
Minimal OpenGL context creation/destraction for GPGPU.

## About
OpenGL functions require a OpenGL context, but it is created by platfrom specific APIs, WGL for windows, GLX for X Window System, and EGL for Mobile.
invisiGL is a nim library to create and destract a OpenGL context.
It does not make a OpenGL context for realtime rendering.
But you can do:
* Query OpenGL implementation information (e.g. glGetString(GL_VERSION))
* Create a frame buffer object and render to it, then copy it to a memory CPU can access
* GPGPU using compute shader
invisiGL keep simple code, easy to use and minimum dependency by not supporting proper default frame buffer.

## Requirement
* Nim
* OpenGL 3.2 or higher
### On Windows
* [oldwinapi](https://github.com/nim-lang/oldwinapi)
### On Linux
Linux support is under developtment.
It will use EGL and should work without X11.

## Example
```nim
import invisiGL, opengl

#Initialize OpenGL 4.0
inglInitAuto(4, 0)
loadExtensions()

#OpenGL functions are available now
let pver = glGetString(GL_VERSION)
echo cast[cstring](pver)

#Clean up OpenGL context
inglCleanup()
```

This software is released under the MIT License, see LICENSE.
