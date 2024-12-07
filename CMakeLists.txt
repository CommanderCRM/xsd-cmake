cmake_minimum_required(VERSION 3.10)

project(xsd-compiler)

include(ExternalProject)
include(ProcessorCount)

find_program(MAKE_EXE NAMES gmake nmake make)
find_package(Patch)
ProcessorCount(N)

# Dependency options
set(BUILD_GIT_REPO_LINK         "git://git.codesynthesis.com/build/build.git")
set(BUILD_GIT_REPO_TAG          "0.3.10")
set(LIBCUTL_GIT_REPO_LINK       "git://git.codesynthesis.com/libcutl/libcutl.git")
set(LIBCUTL_GIT_REPO_TAG        "1.10.0")
set(CLI_GIT_REPO_LINK           "git://git.codesynthesis.com/cli/cli.git")
set(CLI_GIT_REPO_TAG            "1.1.0")

# Directory tree options
set(BUILD_SYSTEM_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}/build_0.3")
set(SCRIPT_DIR "${CMAKE_CURRENT_LIST_DIR}/scripts")
set(PATCH_DIR "${CMAKE_CURRENT_LIST_DIR}/patches")

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
  PATCH_COMMAND     ${Patch_EXECUTABLE} -N -p0 < ${PATCH_DIR}/libcutl.patch || true
  CONFIGURE_COMMAND ""
  # Handles interactive inputs for custom configure
  BUILD_COMMAND     ${CMAKE_COMMAND} -E env MAKEFLAGS="-I ${BUILD_SYSTEM_INSTALL_PREFIX}/include" ${SCRIPT_DIR}/libcutl.sh ${N}
  INSTALL_COMMAND   ${MAKE_EXE} install install_prefix=${CMAKE_CURRENT_LIST_DIR}/libcutl
  DEPENDS           build
)

ExternalProject_Add(cli
  GIT_REPOSITORY    ${CLI_GIT_REPO_LINK}
  GIT_TAG           ${CLI_GIT_REPO_TAG}
  BUILD_IN_SOURCE   TRUE
  # Bug fixing
  PATCH_COMMAND     ${Patch_EXECUTABLE} -N -p0 < ${PATCH_DIR}/cli.patch || true
  CONFIGURE_COMMAND ""
  # Handles interactive inputs for custom configure, takes libcutl root
  # Build system needs to find how it was built and where it is stored
  BUILD_COMMAND     ${CMAKE_COMMAND} -E env MAKEFLAGS="-I ${BUILD_SYSTEM_INSTALL_PREFIX}/include" ${SCRIPT_DIR}/cli.sh ${N} ${CMAKE_CURRENT_LIST_DIR}/libcutl-prefix/src/libcutl
  INSTALL_COMMAND   ${MAKE_EXE} install install_prefix=${CMAKE_CURRENT_LIST_DIR}/cli
  DEPENDS           build libcutl
)
