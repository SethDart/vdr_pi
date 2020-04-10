##---------------------------------------------------------------------------
## Author:      Jean-Eudes Onfray
## Copyright:
## License:     wxWidgets License
##---------------------------------------------------------------------------
## *   Copyright (C) 2010 by ean-Eudes Onfray                                *
## *   This program is free software; you can redistribute it and/or modify  *
## *   it under the terms of the GNU General Public License as published by  *
## *   the Free Software Foundation; either version 2 of the License, or     *
## *   (at your option) any later version.                                   *
## *                                                                         *
## *   This program is distributed in the hope that it will be useful,       *
## *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
## *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
## *   GNU General Public License for more details.                          *
## *                                                                         *
## *   You should have received a copy of the GNU General Public License     *
## *   along with this program; if not, write to the                         *
## *   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx,                                       *
## *   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx          *
## ***************************************************************************			  
##    PLUGIN MANAGER FRONTEND OPTION #1     Version: 1.0    Date:3-17-2020   * 
## ***************************************************************************			  

# define minimum cmake version  (newer)
CMAKE_MINIMUM_REQUIRED(VERSION 3.1.1)
# This should be 2.8.0 to have FindGTK2 module
											  
IF (COMMAND cmake_policy)
  if (POLICY CMP0043)
    CMAKE_POLICY(SET CMP0043 NEW)
							   
  endif (POLICY CMP0043)
  if (POLICY CMP0077)
    CMAKE_POLICY(SET CMP0077 NEW)
  endif (POLICY CMP0077)
ENDIF (COMMAND cmake_policy)

# Prefer libGL.so to libOpenGL.so, see CMP0072
set(OpenGL_GL_PREFERENCE "LEGACY")

#================================================ 
# Plugin Specifics - Modify for plugin specifics
#================================================
PROJECT(vdr_pi)

SET(PACKAGE_NAME vdr_pi)
SET(VERBOSE_NAME VDR)  
# SET(PLUGIN_SOURCE_DIR .)
MESSAGE (STATUS "*** Building ${PACKAGE_NAME} ***")

#include("VERSION.cmake")
SET(VERSION_MAJOR "0")
SET(VERSION_MINOR "5")
SET(VERSION_PATCH "1")
SET(VERSION_DATE "04/10/2020")
SET(PACKAGE_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}" )

SET(PKG_RELEASE "3")
SET(PKG_API_VERSION "1.16")
SET(PKG_AUTHOR "Jean-Eudes Onfray ")
# NVR: <Name-version>[-release]					   
SET(PKG_NVR ${PACKAGE_NAME}-${PACKAGE_VERSION}-${PKG_RELEASE})
# ================================================
# Plugin Specifics  -End of Header
# ================================================

# The @keyword@ references are patched to actual values by upload script.
SET(TARBALL_URL "https://dl.cloudsmith.io/public/@pkg_repo@/raw")
SET(TARBALL_URL ${TARBALL_URL}/names/@name@/versions/@version@/@filename@)
# DO NOT SET CHANGE OR SET PATHS ABOVE!!
# Do this last after all scripts are working on Circleci, Appveyor & Travis-ci
# TO DEPLOY to Cloudsmith Repository URL's
# SET YOUR STABLE_REPO, UNSTABLE_REPO and PKG_REPO in
#     ci/appveyor.upload.sh
#     ci/circleci.upload.sh
#     ci/travis-build-raspbian-armhf.sh 
#
#Example: Plugins artifacts repository url
#
# STABLE_REPO=${CLOUDSMITH_STABLE_REPO:-'rick-gleason/opencpn-plugins-prod'}
# UNSTABLE_REPO=${CLOUDSMITH_UNSTABLE_REPO:-'rick-gleason/opencpn-plugins-beta'}
# PKG_REPO=${CLOUDSMITH_PKG_REPO:-'rick-gleason/opencpn-plugins-pkg'}
#
#=============================================================

SET(API_DIR "${CMAKE_SOURCE_DIR}/api-16")
SET(OCPN_USE_API_16 ON)
#OPTION(OCPN_USE_API_16 "Use plugin api 16 (default: api 13)." OFF)

SET(OCPN_MIN_VERSION "ov50")

# Turned on under flatpak build
OPTION(OCPN_FLATPAK "Build flatpak plugin" OFF)

set(PLUGIN_NAME ${PKG_NVR}_${PKG_TARGET}-${PKG_TARGET_VERSION})

IF( NOT CMAKE_BUILD_TYPE )
  SET( CMAKE_BUILD_TYPE Release CACHE STRING
       "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
       FORCE )
ENDIF( NOT CMAKE_BUILD_TYPE )

MESSAGE (STATUS "Build type: ${CMAKE_BUILD_TYPE}")

SET(CMAKE_VERBOSE_MAKEFILE ON)

IF (PREFIX)
 SET(CMAKE_INSTALL_PREFIX ${PREFIX})
ENDIF (PREFIX)

SET(PREFIX_BIN bin)
SET(PREFIX_INCLUDE include)
SET(PREFIX_DATA share)
SET(PREFIX_PKGDATA ${PREFIX_DATA}/${PACKAGE_NAME})

include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if (CMAKE_VERSION VERSION_LESS "3.1")
  if(COMPILER_SUPPORTS_CXX11)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
    message(STATUS "Setting C++11 standard via CXX flags")
  elseif(COMPILER_SUPPORTS_CXX0X)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
    message(STATUS "Setting C++0x standard via CXX FLAGS")
  else()
    message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
  endif()
else ()
  set (CMAKE_CXX_STANDARD 11)
  message(STATUS "Setting C++11 standard via cmake standard mechanism")
endif ()

IF (NOT WIN32)
  # default
  SET (ARCH "i386")
  IF (UNIX AND NOT APPLE)
    MESSAGE (STATUS "*** Will install to ${CMAKE_INSTALL_PREFIX}  ***")
    IF (EXISTS /etc/debian_version)
      MESSAGE (STATUS "*** Debian detected  ***")
      SET (PACKAGE_FORMAT "DEB")
      SET (PACKAGE_DEPS "libc6, libwxgtk3.0-0, libglu1-mesa (>= 7.0.0) curl")
      SET (LIB_INSTALL_DIR "lib")
      IF (CMAKE_SYSTEM_PROCESSOR MATCHES "arm*")
        IF (CMAKE_SIZEOF_VOID_P MATCHES "8")
          SET (ARCH "arm64")
          ADD_DEFINITIONS( -DOCPN_ARM64 )
        ELSE (CMAKE_SIZEOF_VOID_P MATCHES "8")
          SET (ARCH "armhf")
          ADD_DEFINITIONS( -DOCPN_ARMHF )
        ENDIF (CMAKE_SIZEOF_VOID_P MATCHES "8")
      ELSE (CMAKE_SYSTEM_PROCESSOR MATCHES "arm*")
        IF (CMAKE_SIZEOF_VOID_P MATCHES "8")
          SET (ARCH "amd64")
        ELSE (CMAKE_SIZEOF_VOID_P MATCHES "8")
          SET (ARCH "i386")
        ENDIF (CMAKE_SIZEOF_VOID_P MATCHES "8")
      ENDIF (CMAKE_SYSTEM_PROCESSOR MATCHES "arm*")
    ENDIF (EXISTS /etc/debian_version)
    IF(NOT DEFINED PACKAGE_FORMAT)
      IF (EXISTS /app)
        MESSAGE (STATUS "*** Flatpak detected  ***")
        SET (PACKAGE_FORMAT "TGZ")
        SET (ARCH "x86_64")
        SET (LIB_INSTALL_DIR "lib")
      ENDIF (EXISTS /app)
    ENDIF(NOT DEFINED PACKAGE_FORMAT)
    
    IF(NOT DEFINED PACKAGE_FORMAT)
     IF (EXISTS /etc/redhat-release)
      MESSAGE (STATUS "*** Redhat detected  ***")
      SET (PACKAGE_FORMAT "RPM")
      SET (PACKAGE_DEPS  "opencpn")
      IF (CMAKE_SIZEOF_VOID_P MATCHES "8")
        SET (ARCH "x86_64")
        SET (LIB_INSTALL_DIR "lib64")
      ELSE (CMAKE_SIZEOF_VOID_P MATCHES "8")
        SET (ARCH "i386")
        SET (LIB_INSTALL_DIR "lib")
      ENDIF (CMAKE_SIZEOF_VOID_P MATCHES "8")
     ENDIF (EXISTS /etc/redhat-release)
    ENDIF(NOT DEFINED PACKAGE_FORMAT)
 
    IF(NOT DEFINED PACKAGE_FORMAT)
     IF (EXISTS /etc/os-release OR EXISTS /etc/sysconfig/SuSEfirewall2.d OR EXISTS /etc/suse-release OR EXISTS /etc/SuSE-release)
      MESSAGE (STATUS "*** OpenSUSE detected  ***")
      SET (PACKAGE_FORMAT "RPM")
      SET (PACKAGE_DEPS  "opencpn")
      IF (CMAKE_SIZEOF_VOID_P MATCHES "8")
        SET (ARCH "x86_64")
        SET (LIB_INSTALL_DIR "lib")
      ELSE (CMAKE_SIZEOF_VOID_P MATCHES "8")
        SET (ARCH "i386")
        SET (LIB_INSTALL_DIR "lib")
      ENDIF (CMAKE_SIZEOF_VOID_P MATCHES "8")
     ENDIF (EXISTS /etc/os-release OR EXISTS /etc/sysconfig/SuSEfirewall2.d OR EXISTS /etc/suse-release OR EXISTS /etc/SuSE-release)
    ENDIF(NOT DEFINED PACKAGE_FORMAT)

  ENDIF (UNIX AND NOT APPLE)
endif(NOT WIN32)

IF (CMAKE_SYSTEM_PROCESSOR MATCHES "armhf")
  SET (ARCH "armhf")
  ADD_DEFINITIONS( -DARMHF )
ENDIF (CMAKE_SYSTEM_PROCESSOR MATCHES "armhf")

IF (CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
  SET (ARCH "arm64")
  ADD_DEFINITIONS( -DARMHF )
ENDIF (CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")

MESSAGE (STATUS "*** Build Architecture is ${ARCH}")
MESSAGE (STATUS "*** CMAKE_SYSTEM_PROCESSOR is ${CMAKE_SYSTEM_PROCESSOR}")
MESSAGE (STATUS "*** PACKAGE_FORMAT is ${PACKAGE_FORMAT}")

if (OCPN_FLATPAK)
    # Lie to PluginSetup that we have found wxWidgets so it don't barfs.
    set(wxWidgets_LIBRARIES FOOBAR)
    include("cmake/PluginSetup.cmake")
    configure_file(
      # Required in flatpak, done early.
      ${CMAKE_SOURCE_DIR}/pkg_version.sh.in
      ${CMAKE_CURRENT_BINARY_DIR}/pkg_version.sh
    )
    set(PLUGIN_NAME ${VERBOSE_NAME}-plugin-${PKG_TARGET}-${PKG_TARGET_VERSION})

    find_program(TAR NAMES gtar tar)
    if (NOT TAR)
        message(FATAL_ERROR "tar not found, required for OCPN_FLATPAK")
    endif ()
#=============================================================================
# Check the actual name of the existing file in flatpak directory
#
#         flatpak/org.opencpn.OpenCPN.Plugin.${VERBOSE_NAME}.yaml 
#
# Then edit the 3 instances in the file to use the text in plugin (VERBOSE_NAME)
#
# Then Determine the plugin "CommonName" which is found 
# by searching the file below for "GetCommonName" 
#
#         src/squiddio_pi.cpp 
#
# Record that name carefully, noting capitalization.
# Modify the name this Metadata.xml file in the root plugin directory 
#
#         <squiddio>_plugin.xml.in  
# 
# Then Text Edit the file carefully, without changing the html format.
# and enter the "CommonName" into this field
#
#         <name>Squiddio</name>  
#
#==============================================================================
    configure_file(
        ${CMAKE_SOURCE_DIR}/${VERBOSE_NAME}-plugin.xml.in
        ${CMAKE_CURRENT_BINARY_DIR}/${PLUGIN_NAME}.xml
    )
    add_custom_target(flatpak-build ALL
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/flatpak
        COMMAND flatpak-builder --force-clean
            ${CMAKE_CURRENT_BINARY_DIR}/app
            org.opencpn.OpenCPN.Plugin.${VERBOSE_NAME}.yaml
    )
    add_custom_target("package")
    add_custom_command(
        TARGET package
#=====================================================================		
# This Command has been configured to automatically change the name
#  of the package TAR to use the plugin's ${VERBOSE_NAME} 
#=====================================================================
        COMMAND ${TAR}
            -czf ${PKG_NVR}_${PKG_TARGET_NVR}.tar.gz
            --transform 's|.*/files/|${VERBOSE_NAME}_pi-flatpak-${PACKAGE_VERSION}/|'
            ${CMAKE_CURRENT_BINARY_DIR}/app/files
    )
    return ()
endif()


# =========================================================
#  To build for android, use this cmake invocation..
#  Note this is from a another plugin project, it may not work.
# =========================================================
#$cmake -DUSE_GARMINHOST=OFF -D_wx_selected_config=androideabi-qt
#-DCMAKE_TOOLCHAIN_FILE=../buildandroid/build_android.cmake
#-DwxQt_Build=build_android_55_intl -DwxQt_Base=/home/dsr/Projects/wxqt/wxWidgets
#-DQt_Base=/home/dsr/Projects/qt5bare -DQt_Build=build_release/qtbase ..

IF(DEFINED _wx_selected_config)

#  May be overridden
IF(NOT DEFINED Qt_Build)
  SET(Qt_Build "android_armv7")
ENDIF(NOT DEFINED Qt_Build)

MESSAGE (STATUS "selected config ${_wx_selected_config}")

IF(_wx_selected_config MATCHES "androideabi-qt")
  MESSAGE (STATUS "Building for wxQt-Android")
  MESSAGE (STATUS "Qt_Base/Build: " ${Qt_Base} "/" ${Qt_Build})
  MESSAGE (STATUS "wxQt_Base/Build: " ${wxQt_Base} "/" ${wxQt_Build})
  SET(QT_ANDROID "ON")
  SET(QT_LINUX "OFF")
  SET(QT "ON")
  ADD_DEFINITIONS("-Wno-inconsistent-missing-override -Wno-potentially-evaluated-expression")
  SET(CMAKE_SKIP_BUILD_RPATH  TRUE)
ENDIF(_wx_selected_config MATCHES "androideabi-qt")

ENDIF(DEFINED _wx_selected_config)

#===========================================================
# Check cmake/PluginConfigure.cmake  (no need to configure)
#===========================================================

INCLUDE("cmake/PluginConfigure.cmake")

#=============================================================
# Modify/configure 'Include' Directories below for the Plugin
#=============================================================
INCLUDE_DIRECTORIES(BEFORE ${PROJECT_SOURCE_DIR}/src/wxJSON)
INCLUDE_DIRECTORIES(BEFORE ${PROJECT_SOURCE_DIR}/src)
# Do not need to include dir src/cpl  for Oesenc
# Do not need to include dir src.dsa  for Oesenc
INCLUDE_DIRECTORIES(BEFORE ${PROJECT_SOURCE_DIR})

if (OCPN_USE_API_16) 
  INCLUDE_DIRECTORIES(BEFORE ${PROJECT_SOURCE_DIR}/api-16)
#else ()
#  INCLUDE_DIRECTORIES(BEFORE ${PROJECT_SOURCE_DIR}/api-13)
endif ()
#=============================================================

IF(NOT WIN32)
 ADD_DEFINITIONS( "-Wall -g -fexceptions -O2 -Wno-unused -fno-strict-aliasing ")

 IF(CMAKE_BUILD_TYPE MATCHES "Debug")
    ADD_DEFINITIONS( " -O0")
 ENDIF(CMAKE_BUILD_TYPE MATCHES "Debug")

 IF(NOT APPLE)
  SET(CMAKE_SHARED_LINKER_FLAGS "-Wl,-Bsymbolic ")
  IF(NOT QT_ANDROID)
   ADD_DEFINITIONS( "-rdynamic" )
  ENDIF(NOT QT_ANDROID)
 ELSE(NOT APPLE)
  SET(CMAKE_SHARED_LINKER_FLAGS "-Wl -undefined dynamic_lookup")
  ADD_DEFINITIONS( "-Wno-overloaded-virtual" )
 ENDIF(NOT APPLE)

ENDIF(NOT WIN32)


# Add some definitions to satisfy MS
IF(WIN32)
    ADD_DEFINITIONS(-D__MSVC__)
    ADD_DEFINITIONS(-D_CRT_NONSTDC_NO_DEPRECATE -D_CRT_SECURE_NO_DEPRECATE)
ENDIF(WIN32)

# Let cmake find additional modules private
LIST(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})


ADD_DEFINITIONS(-DTIXML_USE_STL)

#=================================================================
# For convenience we define the sources as a variable. You can add
# header files and cpp/c files and CMake will sort them out
#
# MODIFY these files configured to this plugin. 
# Listing of files and .h files.
# Copy from plugin's existing working CMakeLists.txt file
# or build it yourself.
#=================================================================

SET(SRC_VDR
            src/icons.h
            src/icons.cpp
            src/vdr_pi.h
            src/vdr_pi.cpp
 	)




INCLUDE_DIRECTORIES(src/wxJSON)
INCLUDE_DIRECTORIES(api-16)

OPTION(OCPN_USE_CURL "Use Curl libraries" ON)
ADD_DEFINITIONS(-D__OCPN_USE_CURL__)

IF(WIN32)
    OPTION(OCPN_USE_EXTERN_CURL "Use external libcurl" OFF)
ELSE(WIN32)
    SET(OCPN_USE_EXTERN_CURL ON)
ENDIF(WIN32)

IF(NOT QT_ANDROID)

    IF(OCPN_USE_EXTERN_CURL)
        FIND_PACKAGE(CURL REQUIRED)
        IF(CURL_FOUND)
            MESSAGE (STATUS "Using SYSTEM curl library...${CURL_LIBRARIES}...${CURL_INCLUDE_DIR}")
        ENDIF(CURL_FOUND)
        INCLUDE_DIRECTORIES(${CURL_INCLUDE_DIR})
    ELSE(OCPN_USE_EXTERN_CURL)
        INCLUDE("Curl.cmake")
        MESSAGE (STATUS "Using local curl library...")
    ENDIF(OCPN_USE_EXTERN_CURL)

 
    IF(WIN32) 
        SET(SRC_WXCURL
        src/wxcurl/base.cpp
        src/wxcurl/dav.cpp
        src/wxcurl/davtool.cpp
        src/wxcurl/dialog.cpp
        src/wxcurl/ftp.cpp
        src/wxcurl/ftpparse.cpp
        src/wxcurl/ftptool.cpp
        src/wxcurl/http.cpp
        src/wxcurl/panel.cpp
        src/wxcurl/telnet.cpp
        src/wxcurl/thread.cpp
        src/wxcurl/utils.cpp
        )
    ENDIF(WIN32)

#    ADD_LIBRARY(WXCURL ${SRC_WXCURL})
    INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/src/wxcurl)
    
    MESSAGE (STATUS "wxCurl configured...")

ENDIF(NOT QT_ANDROID)

IF(UNIX AND NOT APPLE)
 INCLUDE("cmake/FindTinyXML.cmake")
 FIND_PACKAGE(TinyXML QUIET)
ENDIF(UNIX AND NOT APPLE)

IF(TINYXML_FOUND)
 message (STATUS "oeSENCr_pi building with system tinyxml")
 INCLUDE_DIRECTORIES(${TINYXML_INCLUDE_DIR})
ELSE(TINYXML_FOUND)
 message (STATUS "Plugin is building with embedded tinyxml")
 INCLUDE_DIRECTORIES(src/tinyxml/)
ENDIF(TINYXML_FOUND)
ADD_DEFINITIONS(-DTIXML_USE_STL)


#===============================================================
#  MODIFY and adjust ADD_LIBRARY listing for the plugin
#===============================================================

ADD_LIBRARY(${PACKAGE_NAME} SHARED ${SRC_VDR} )
# ADD_LIBRARY(${PACKAGE_NAME} SHARED ${SRC_SQUIDDIO} ${SRC_NMEA0183} ${SRC_JSON} ${SRC_LTINYXML})

IF (QT_ANDROID )
    TARGET_LINK_LIBRARIES( ${PACKAGE_NAME} ${OCPN_Core_LIBRARIES} )
    TARGET_LINK_LIBRARIES( ${PACKAGE_NAME} "-lc++_shared")
    TARGET_LINK_LIBRARIES( ${PACKAGE_NAME} "-lz" )
    TARGET_LINK_LIBRARIES( ${PACKAGE_NAME}  ${Qt_Base}/${Qt_Build}/lib/libQt5Core.so )
    TARGET_LINK_LIBRARIES( ${PACKAGE_NAME} "${OCPN_Base}/${OCPN_Build}/libgorp.so" )
ENDIF(QT_ANDROID)


if (MINGW)
  SET(OPENCPN_IMPORT_LIB "${API_DIR}/mingw/libopencpn.dll.a")
elseif (WIN32)
  SET(OPENCPN_IMPORT_LIB "${API_DIR}/msvc/opencpn.lib")
endif ()

IF(WIN32)
  TARGET_LINK_LIBRARIES( ${PACKAGE_NAME} ${CURL_LIBRARIES})
  TARGET_LINK_LIBRARIES( ${PACKAGE_NAME} ${OPENCPN_IMPORT_LIB} )

ENDIF(WIN32)

IF(NOT APPLE)
TARGET_LINK_LIBRARIES( ${PACKAGE_NAME} ${wxWidgets_LIBRARIES} )
ENDIF(NOT APPLE)


#====================================================================
# Install any special data files or binary helpers here....
# The PlugIn library itself and any "data" directory (with contents) 
# gets installed in generic PluginInstall.cmake later
#====================================================================

IF(UNIX AND NOT APPLE)
SET(PARENT opencpn)
SET(PREFIX_PLUGINS ${LIB_INSTALL_DIR}/${PARENT})
SET(PREFIX_PARENTBIN bin)
SET(PREFIX_PARENTDATA ${PREFIX_DATA}/${PARENT})

#=================================================
# Oesenc Chart Catalog stuff - Not Needed
#=================================================

# IF (ARCH MATCHES "amd64" OR ARCH MATCHES "x86_64") 
#	INSTALL(FILES "buildlinux64/oeserverd/oeserverd"
#   etc, etc.
# ELSE (ARCH MATCHES "amd64" OR ARCH MATCHES "x86_64")
#   etc, etc.
# ENDIF (ARCH MATCHES "amd64" OR ARCH MATCHES "x86_64")
#
# IF(PACKAGE_FORMAT MATCHES "DEB")
#    etc etc
# ENDIF(PACKAGE_FORMAT MATCHES "DEB")
# INSTALL(FILES "src/rrc_eula_ChartSetsForOpenCPN-v16-12.txt"
#      PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
#      DESTINATION ${PREFIX_PARENTDATA}/plugins/${PACKAGE_NAME} )
# necessary endif
ENDIF(UNIX AND NOT APPLE)
#===========================================
#  Oesenc Chart permissions - Not needed 
#============================================
#IF(WIN32)
#    INSTALL(FILES "buildwin/oeserverd/oeserverd.exe"
#   etc, etc
# ENDIF(WIN32)
#IF(APPLE)
#INSTALL(FILES "buildosx/oeserverd/oeserverd"
# etc, etc
#ENDIF(APPLE)

#==============================================
# From Oesenc - Needed
#==============================================

IF(NOT WIN32)
SET(CPACK_SET_DESTDIR ON)
ENDIF(NOT WIN32)

SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "dsr")

#============================================
# Do not change, needed to build app
#=============================================
INCLUDE("cmake/PluginSetup.cmake")

configure_file(
  ${CMAKE_SOURCE_DIR}/pkg_version.sh.in
  ${CMAKE_CURRENT_BINARY_DIR}/pkg_version.sh
)

set(PLUGIN_NAME ${VERBOSE_NAME}-plugin-${PKG_TARGET}-${PKG_TARGET_VERSION})

#=============================================================
# Automatically configures file using ${VERBOSE_NAME}
#
#     <pluginname>-plugin.xml.in
#
# Modify/check these file names accordingly,  root directory 
#=============================================================
configure_file(
  ${CMAKE_SOURCE_DIR}/${VERBOSE_NAME}-plugin.xml.in
  ${CMAKE_CURRENT_BINARY_DIR}/${PLUGIN_NAME}.xml
)

#============================================
# Do not change, needed to build app
#=============================================
INCLUDE("cmake/PluginLocalization.cmake")
INCLUDE("cmake/PluginInstall.cmake")
INCLUDE("cmake/PluginPackage.cmake")