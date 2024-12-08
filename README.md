# xsd-cmake
XSD CMake is an adaptation of CMake build system for Code Synthesis' XSD code generator and its various dependencies.
It is using ExternalProject as a main driver to handle dependencies.

## Prerequisites
Linux distribution with:
* cmake >= 3.10
* gcc >= 8
* make, bash
* autotools (e.g. autotools-dev, autoconf packages on Ubuntu)

## How to build
Use standard CMake configuration and build commands:
`cmake DIR` and `cmake --build DIR`, where `DIR` is the root directory.
The resulting `xsd` binary will be in `DIR/xsd`.

## What will be built
`xsd` and its dependencies: `build`, `libcutl`, `cli`, `libxsd-frontend`. `libcutl` is built as a static library by default, using the `libcutl.sh` heredoc input. `cli` is using the install directory of `libcutl` and its build information. `xerces-c` is built as static library without network and ICU. `libxsd-frontend` is built as static library and depends on `libcutl` and `xerces-c`. `xsd` depends on everything and is built as a binary.

## Reasoning behind this project
This is for all who use `CMake` during the build process. Code Synthesis has decided to create `build` and then `build2` and has never supported `CMake`.

## Acknowledgements
Boris Kolpackov - Code Synthesis founder, creator of XSD project. GitHub [profile](https://github.com/boris-kolpackov).
