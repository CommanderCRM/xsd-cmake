# xsd-cmake
XSD CMake is an adaptation of CMake build system for CodeSynthesis' XSD project and its various dependencies.

## Prerequisites
* cmake >= 3.5
* gcc >= 8
* GNU make >= 3.81 
* GNU bash >= 2.05a

## How to build
Use standard CMake configuration and build commands:
`cmake DIR` and `cmake --build DIR`, where `DIR` is the directory containing this repository.

## What will be built
Only `build` and `libcutl` are supported for now. `libcutl` is built as a static library by default, using the `libcutl.sh` heredoc input.

## Reasoning behind this project
This is for all the ones who, like me, use `CMake` during the build process and don't want to learn/integrate new build systems. People at `CodeSynthesis` have decided to create `build` and then `build2` - their choice, but `CMake` is de-facto standard for now.
