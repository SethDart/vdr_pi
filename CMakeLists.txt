##---------------------------------------------------------------------------
## Author:      Jean-Eudes Onfray
## Copyright:   
## License:     wxWidgets License
##---------------------------------------------------------------------------

# define minimum cmake version
CMAKE_MINIMUM_REQUIRED(VERSION 2.6.2)

PROJECT(vdr_pi)

SET(PACKAGE_NAME vdr_pi)
SET(VERBOSE_NAME VDR)
SET(TITLE_NAME VDR)
SET(CPACK_PACKAGE_CONTACT "Jean-Eudes Onfray")

SET(VERSION_MAJOR "0")
SET(VERSION_MINOR "3")

#SET(CMAKE_BUILD_TYPE Debug)

INCLUDE("cmake/PluginConfigure.cmake")


SET(SRC_VDR
            src/icons.h
            src/icons.cpp
            src/vdr_pi.h
            src/vdr_pi.cpp
 	)

ADD_LIBRARY(${PACKAGE_NAME} SHARED ${SRC_VDR} )

INCLUDE("cmake/PluginInstall.cmake")
INCLUDE("cmake/PluginCurl.cmake")
INCLUDE("cmake/PluginLocalization.cmake")
INCLUDE("cmake/PluginPackage.cmake")