cmake_minimum_required(VERSION 3.5)

project(xsd-compiler)

include(ExternalProject)
include(ProcessorCount)

find_program(MAKE_EXE NAMES gmake nmake make)
ProcessorCount(N)

set(BUILD_SYSTEM_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}/build_0.3")

ExternalProject_Add(build
  GIT_REPOSITORY    git://git.codesynthesis.com/build/build.git
  GIT_TAG           0.3.10
  BUILD_IN_SOURCE   TRUE
  CONFIGURE_COMMAND ""
  BUILD_COMMAND     ""
  INSTALL_COMMAND   ${MAKE_EXE} install install_prefix=${BUILD_SYSTEM_INSTALL_PREFIX}
)

ExternalProject_Add(libcutl
  GIT_REPOSITORY    git://git.codesynthesis.com/libcutl/libcutl.git
  GIT_TAG           1.10.0
  BUILD_IN_SOURCE   TRUE
  # C++ 17 compatibility
  PATCH_COMMAND     patch -p0 < ${CMAKE_CURRENT_LIST_DIR}/libcutl.patch 
  CONFIGURE_COMMAND ""
  # The bash script handles configure inputs, as it's called by xsd's custom build system.
  BUILD_COMMAND     ${CMAKE_COMMAND} -E env MAKEFLAGS="-I ${BUILD_SYSTEM_INSTALL_PREFIX}/include" ${CMAKE_CURRENT_LIST_DIR}/libcutl.sh ${N}
  INSTALL_COMMAND   ${MAKE_EXE} install install_prefix=${CMAKE_CURRENT_LIST_DIR}/libcutl
)
