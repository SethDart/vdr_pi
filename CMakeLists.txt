# ===========================================================================
# Author:      Jean-Eudes Onfray
# ---------------------------------------------------------------------------
# - Copyright (C) 2010 by Jean-Eudes Onfray                                *
# - This program is free software; you can redistribute it and/or modify  *
# - it under the terms of the GNU General Public License as published by  *
# - the Free Software Foundation; either version 2 of the License, or     *
# - (at your option) any later version.                                   *
# - *
# - This program is distributed in the hope that it will be useful,       *
# - but WITHOUT ANY WARRANTY; without even the implied warranty of        *
# - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
# - GNU General Public License for more details.                          *
# - *
# - You should have received a copy of the GNU General Public License     *
# - along with this program; if not, write to the                         *
# - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx,                                       *
# - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*


# -------- Cmake setup ---------
#
cmake_minimum_required(VERSION 3.12.0)

cmake_policy(SET CMP0042 NEW)

if (POLICY CMP0072)
  cmake_policy(SET CMP0072 NEW)
endif ()

if (POLICY CMP0077)
  cmake_policy(SET CMP0077 NEW)
endif ()

# Locations where cmake looks for cmake modules.
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/build ${CMAKE_SOURCE_DIR}/cmake)

if (WIN32)
  list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/buildwin)
endif ()
message(STATUS "Cmake version: ${CMAKE_VERSION}.")

# -------- Build setup (mostly in PluginCompiler) --------
#
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)
message(STATUS "Building: ${BUILD_TYPE}")

# -------- Options ----------

set(OCPN_TEST_REPO
    "opencpn/vdr-alpha"
    CACHE STRING "Default repository for untagged builds"
)
set(OCPN_BETA_REPO
    "opencpn/vdr-beta"
    CACHE STRING "Default repository for tagged builds matching 'beta'"
)
set(OCPN_RELEASE_REPO
    "opencpn/vdr-prod"
    CACHE STRING "Default repository for tagged builds not matching 'beta'"
)
option(VDR_USE_SVG "Use SVG graphics" ON)

set(OCPN_TARGET_TUPLE
    ""
    CACHE STRING "Target spec: \"platform;version;arch\""
)

string(TOLOWER "${OCPN_TARGET_TUPLE}" _lc_target)
if ("${_lc_target}" MATCHES "android*")
  set(QT_ANDROID ON)
  # Until we have a proper toolchain file:
  set(CMAKE_CROSSCOMPILING ON)
else ()
  set(QT_ANDROID OFF)
  add_definitions(-D__OCPN_USE_CURL__)
endif ()

#
# -------  Plugin setup --------
#
project(vdr_pi VERSION 1.3.5.4)
set(PKG_PRERELEASE "") # Empty, or a tag like 'beta'

set(DISPLAY_NAME VDR) # Dialogs, installer artifacts, ...
set(PLUGIN_API_NAME VDR) # As of GetCommonName() in plugin API
set(CPACK_PACKAGE_CONTACT "Jean-Eudes Onfray")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Voyage Data Recorder")
set(CPACK_PACKAGE_DESCRIPTION [=[
Record/Playback vessels nmea and movements.
]=])

set(PKG_AUTHOR "Rick Gleason")
set(PKG_IS_OPEN_SOURCE "yes")
set(CPACK_PACKAGE_HOMEPAGE_URL https://github.com/rgleason/vdr_pi)
set(PKG_INFO_URL https://opencpn.org/OpenCPN/plugins/vdr.html)

set(SRC
  src/icons.h 
  src/icons.cpp 
  src/vdr_pi.h 
  src/vdr_pi.cpp 
)

# -------- Setup completed, build the plugin --------
#
add_library(${CMAKE_PROJECT_NAME} SHARED ${SRC})
include_directories(BEFORE ${CMAKE_BINARY_DIR}/include)

add_subdirectory("libs/api-16")
target_link_libraries(${CMAKE_PROJECT_NAME} ocpn::api)

set(VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(VERSION_PATCH ${PROJECT_VERSION_PATCH})

set(PACKAGE_NAME ${CMAKE_PROJECT_NAME})

# Create the minimim ocpn version id string like ov50
string(REGEX REPLACE "\([0-9]\)\.\([0-9]\).*" "ov\\1\\2"
       OCPN_MIN_VERSION ${API_OCPN_MIN_VERSION})

if (VDR_USE_SVG)
  add_definitions(-DVDR_USE_SVG)
endif ()

# Set up targets. Targets sets up a recursive call with BUILD_TYPE set to
# 'flatpak', 'pkg' or 'tarball'. The initial call without BUILD_TYPE ends here.
#
include(Targets)
create_targets(
  ${PROJECT_SOURCE_DIR}/flatpak/org.opencpn.OpenCPN.Plugin.vdr.yaml
)
if ("${BUILD_TYPE}" STREQUAL "")
  return()
endif ()

if (NOT ${BUILD_TYPE} STREQUAL "flatpak")
  # Build package as required (flatpak already dealt with).
  include(PluginCompiler)
  include(PluginInstall)
  include(PluginPackage)
  if (QT_ANDROID)
    include(libs/AndroidLibs.cmake)
  else ()
    include(PluginLibs)
  endif ()
  include(PluginLocalization)

  include_directories(BEFORE ${CMAKE_BINARY_DIR}/include)

  add_subdirectory("libs/jsoncpp")
  target_link_libraries(${PACKAGE_NAME} ocpn::jsoncpp)
  
  add_subdirectory("libs/tinyxml")
  target_link_libraries(${PACKAGE_NAME} ocpn::tinyxml)
  
  add_subdirectory("libs/wxJSON")
  target_link_libraries(${PACKAGE_NAME} ocpn::wxjson)
endif ()

configure_file(
  ${CMAKE_SOURCE_DIR}/config.h.in ${CMAKE_BINARY_DIR}/include//config.h @ONLY
)

configure_file(
  # The cloudsmith upload script
  ${CMAKE_SOURCE_DIR}/ci/upload.sh.in ${CMAKE_BINARY_DIR}/upload.sh @ONLY
)
configure_file(
  # The cloudsmith upload script, windows bat file.
  ${CMAKE_SOURCE_DIR}/ci/upload.bat.in ${CMAKE_BINARY_DIR}/upload.bat @ONLY
)

set(checksum "@checksum@")
configure_file(
  # The XML metadata file
  ${CMAKE_SOURCE_DIR}/vdr-plugin.xml.in
  ${CMAKE_BINARY_DIR}/${pkg_displayname}.xml.in @ONLY
)