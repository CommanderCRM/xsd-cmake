cmake_minimum_required(VERSION 3.5)

project(xsd-compiler)

include(ExternalProject)
include(ProcessorCount)

find_program(MAKE_EXE NAMES gmake nmake make)
ProcessorCount(N)

# Dependency options
set(BUILD_GIT_REPO_LINK         "git://git.codesynthesis.com/build/build.git")
set(BUILD_GIT_REPO_TAG          "0.3.10")
set(LIBCUTL_GIT_REPO_LINK       "git://git.codesynthesis.com/libcutl/libcutl.git")
set(LIBCUTL_GIT_REPO_TAG        "1.10.0")

# "Runtime" options
set(BUILD_SYSTEM_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}/build_0.3")

ExternalProject_Add(build
  GIT_REPOSITORY    ${BUILD_GIT_REPO_LINK}
  GIT_TAG           ${BUILD_GIT_REPO_TAG}
  BUILD_IN_SOURCE   TRUE
  CONFIGURE_COMMAND ""
  BUILD_COMMAND     ""
  INSTALL_COMMAND   ${MAKE_EXE} install install_prefix=${BUILD_SYSTEM_INSTALL_PREFIX}
)

ExternalProject_Add(libcutl
  GIT_REPOSITORY    ${LIBCUTL_GIT_REPO_LINK}
  GIT_TAG           ${LIBCUTL_GIT_REPO_TAG}
  BUILD_IN_SOURCE   TRUE
  # C++ 17 compatibility
  PATCH_COMMAND     patch -N -p0 < ${CMAKE_CURRENT_LIST_DIR}/libcutl.patch || true
  CONFIGURE_COMMAND ""
  # The bash script handles interactive inputs for custom configure.
  BUILD_COMMAND     ${CMAKE_COMMAND} -E env MAKEFLAGS="-I ${BUILD_SYSTEM_INSTALL_PREFIX}/include" ${CMAKE_CURRENT_LIST_DIR}/libcutl.sh ${N}
  INSTALL_COMMAND   ${MAKE_EXE} install install_prefix=${CMAKE_CURRENT_LIST_DIR}/libcutl
)
