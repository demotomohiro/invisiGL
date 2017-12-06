# Package

version       = "0.1.0"
author        = "demotomohiro"
description   = "Minimal OpenGL context creation/destraction for GPGPU"
license       = "MIT"

# Dependencies

requires "nim >= 0.17.2"
when hostOS == "windows":
    requires "oldwinapi"
elif hostOS == "linux":
    requires "egl"

skipDirs      = @["tests"]
task test, "Runs the test suite":
    exec "nim c -r tests/echoglver.nim"
