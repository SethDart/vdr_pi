# ~~~
# Summary:      Local, non-generic plugin setup
# Copyright (c) 2020-2021 Mike Rossiter
# License:      GPLv3+
# ~~~
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.


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


#
#
# -------  Plugin setup --------
#
set(PKG_NAME vdr_pi)
set(PKG_VERSION  1.3.24.0)
set(PKG_PRERELEASE "")  # Empty, or a tag like 'beta'

set(DISPLAY_NAME VDR)    # Dialogs, installer artifacts, ...
set(PLUGIN_API_NAME VDR) # As of GetCommonName() in plugin API
set(PKG_SUMMARY "Voyage Data Recorder")
set(PKG_DESCRIPTION [=[
A Voyage Data Recorder (VDR) to record and play NMEA files.
Save NMEA stream to a file.  Replay NMEA stream previously saved. Used to test plugins.
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


set(PKG_API_LIB api-16)  #  A directory in libs/ e. g., api-17 or api-16

macro(late_init)
  # Perform initialization after the PACKAGE_NAME library, compilers
  # and ocpn::api is available.
  if (VDR_USE_SVG)
    target_compile_definitions(${PACKAGE_NAME} PUBLIC VDR_USE_SVG)
  endif ()
endmacro ()

macro(add_plugin_libraries)
  # Add libraries required by this plugin
#  add_subdirectory("${CMAKE_SOURCE_DIR}/opencpn-libs/tinyxml")
#  target_link_libraries(${PACKAGE_NAME} ocpn::tinyxml)

#  add_subdirectory("${CMAKE_SOURCE_DIR}/opencpn-libs/wxJSON")
#  target_link_libraries(${PACKAGE_NAME} ocpn::wxjson)

#  add_subdirectory("${CMAKE_SOURCE_DIR}/opencpn-libs/plugingl")
#  target_link_libraries(${PACKAGE_NAME} ocpn::plugingl)

#  add_subdirectory("${CMAKE_SOURCE_DIR}/opencpn-libs/jsoncpp")
#  target_link_libraries(${PACKAGE_NAME} ocpn::jsoncpp)

  # The wxsvg library enables SVG overall in the plugin
#  add_subdirectory("${CMAKE_SOURCE_DIR}/opencpn-libs/wxsvg")
#  target_link_libraries(${PACKAGE_NAME} ocpn::wxsvg)

endmacro ()
