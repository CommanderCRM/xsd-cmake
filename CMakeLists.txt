cmake_minimum_required(VERSION 3.10)

project(xsd-compiler)

include(ExternalProject)
include(ProcessorCount)

find_program(MAKE_EXE NAMES gmake nmake make)
find_package(Patch)
ProcessorCount(N)

# Dependency options
set(BUILD_GIT_REPO_LINK          "git://git.codesynthesis.com/build/build.git")
set(BUILD_GIT_REPO_TAG           "0.3.10")
set(LIBCUTL_GIT_REPO_LINK        "git://git.codesynthesis.com/libcutl/libcutl.git")
set(LIBCUTL_GIT_REPO_TAG         "1.10.0")
set(CLI_GIT_REPO_LINK            "git://git.codesynthesis.com/cli/cli.git")
set(CLI_GIT_REPO_TAG             "f8c61f71ebf44572c9e865a620dc053e94371beb") # 1.2.0-a2, supports "-I" option for xsd .cli file parsing
set(XERCES_C_REPO_LINK           "https://github.com/apache/xerces-c.git")
set(XERCES_C_GIT_REPO_TAG        "v3.0.0")
set(LIBXSD_FRONTEND_REPO_LINK    "git://git.codesynthesis.com/libxsd-frontend/libxsd-frontend.git")
set(LIBXSD_FRONTEND_GIT_REPO_TAG "2.0.0")
set(XSD_REPO_LINK                "git://git.codesynthesis.com/xsd/xsd.git")
set(XSD_GIT_REPO_TAG             "4.0.0")

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

# Note: build system is used via makeflags in BUILD_COMMAND.
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
  # Needs to be accessible as a binary, yet we don't want sudoing cmake
  INSTALL_COMMAND   ${MAKE_EXE} install install_prefix=$ENV{HOME}
  DEPENDS           build libcutl
)

ExternalProject_Add(xerces-c
  GIT_REPOSITORY    ${XERCES_C_REPO_LINK}
  GIT_TAG           ${XERCES_C_GIT_REPO_TAG}
  BUILD_IN_SOURCE   TRUE
  CONFIGURE_COMMAND autoreconf -si && "<SOURCE_DIR>/configure" --disable-dependency-tracking --enable-static --disable-shared --disable-network --without-icu --prefix=${CMAKE_CURRENT_LIST_DIR}/xerces-c
  BUILD_COMMAND     ${MAKE_EXE} -j${N}
  INSTALL_COMMAND   ${MAKE_EXE} install
)

ExternalProject_Add(libxsd-frontend
  GIT_REPOSITORY    ${LIBXSD_FRONTEND_REPO_LINK}
  GIT_TAG           ${LIBXSD_FRONTEND_GIT_REPO_TAG}
  BUILD_IN_SOURCE   TRUE
  CONFIGURE_COMMAND ""
  # Handles interactive inputs for custom configure, takes libcutl and xerces-c root
  BUILD_COMMAND     ${CMAKE_COMMAND} -E env MAKEFLAGS="-I ${BUILD_SYSTEM_INSTALL_PREFIX}/include" ${SCRIPT_DIR}/libxsd-frontend.sh ${N} ${CMAKE_CURRENT_LIST_DIR}/libcutl-prefix/src/libcutl ${CMAKE_CURRENT_LIST_DIR}/xerces-c-prefix/src/xerces-c
  # Only lib is copied, makefile doesn't have install target
  INSTALL_COMMAND   ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_LIST_DIR}/libxsd-frontend && ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/libxsd-frontend-prefix/src/libxsd-frontend/xsd-frontend/libxsd-frontend.a ${CMAKE_CURRENT_LIST_DIR}/libxsd-frontend
  DEPENDS           build libcutl xerces-c
)

ExternalProject_Add(xsd
  GIT_REPOSITORY    ${XSD_REPO_LINK}
  GIT_TAG           ${XSD_GIT_REPO_TAG}
  BUILD_IN_SOURCE   TRUE
  CONFIGURE_COMMAND ""
  # Disable tests and documentation
  PATCH_COMMAND     ${Patch_EXECUTABLE} -N -p0 < ${PATCH_DIR}/xsd.patch || true
  # Handles interactive inputs for custom configure, takes xerces-c, xsd-frontend, libcutl root
  BUILD_COMMAND     ${CMAKE_COMMAND} -E env MAKEFLAGS="-I ${BUILD_SYSTEM_INSTALL_PREFIX}/include" ${SCRIPT_DIR}/xsd.sh ${N} ${CMAKE_CURRENT_LIST_DIR}/xerces-c-prefix/src/xerces-c ${CMAKE_CURRENT_LIST_DIR}/libxsd-frontend-prefix/src/libxsd-frontend ${CMAKE_CURRENT_LIST_DIR}/libcutl-prefix/src/libcutl
  INSTALL_COMMAND   ${MAKE_EXE} install install_prefix=${CMAKE_CURRENT_LIST_DIR}/xsd
)
