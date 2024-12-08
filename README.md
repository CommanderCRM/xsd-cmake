# xsd-cmake
XSD CMake is an adaptation of CMake build system for Code Synthesis' XSD code generator and its various dependencies.
It is using ExternalProject as a main driver to handle dependencies.

## Prerequisites
* cmake >= 3.10
* gcc >= 8
* GNU make >= 3.81 
* GNU bash >= 2.05a

## How to build
Use standard CMake configuration and build commands:
`cmake DIR` and `cmake --build DIR`, where `DIR` is the root directory.

## What will be built
Only `build`, `libcutl` and `cli` are supported for now. `libcutl` is built as a static library by default, using the `libcutl.sh` heredoc input. `cli` is using the install directory of `libcutl` and its build information.

## Reasoning behind this project
This is for all who use `CMake` during the build process. Code Synthesis has decided to create `build` and then `build2` and has never supported `CMake`.

## Acknowledgements
Boris Kolpackov - Code Synthesis founder, creator of XSD project. GitHub [profile](https://github.com/boris-kolpackov).
