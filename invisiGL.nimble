# Package

version       = "0.2.0"
author        = "demotomohiro"
description   = "Minimal OpenGL context creation/destraction for GPGPU"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 0.17.2"
when hostOS == "windows":
    requires "winim"
elif hostOS == "linux":
    requires "egl"

skipDirs      = @["tests"]
task test, "Runs the test suite":
    exec "nim c -r tests/echoglver.nim"
    exec "nim c -r tests/debug_context.nim"
