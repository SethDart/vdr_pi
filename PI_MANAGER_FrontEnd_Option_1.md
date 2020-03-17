# KEEP EXISTING DIRECTORIES AND FILES
-----------------------------------------------------
#### Important: 
1. Make these changes on a new branch "ci" (if possible).
1. Keep your currently working "master" branch intact. 
1. Rename CMakeLists.txt ----> CMakeLists.old.txt for reference
1. Keep any other specialized plugin directories
1. Keep these directories too:
- Include
- Data
- src
- po

# LIST of FOLDERS & FILES copied into SQUIDDIO
----------------------------------------------------
#### Add these Directories + Sub-directories + Files

- .circleci --> config.yml  Check branch designations!
- api-16
- buildosx InstallOSX/plugin_pi.pkgproj.in 
- buildwin Check your existing and compare, NSIS and a few others
- ci
- ci  circleci-upload.sh - modify for your Cloudsmith upload
- ci  appveyor-upload.sh - modify for your Cloudsmith upload
- ci  trusty-upload.sh - modify for your Cloudsmith upload
- ci  travis-build-raspbian-armhf.sh -modify for your Cloudsmith upload
- cmake
- debian
- flatpak
- mingw
- src/tinyXML Example: was not in squiddio, made cmakelists.txt adjustments
- src/curl Example: was not in squiddio, made cmakelists.txt adjustments

#### Files
- .gitignore   <---Check against current file
- .travis.yml 
- appveyor.yml
- CMakeLists.txt
- Curl.cmake
- pkg_version.sh.in
   - squiddio-plugin.xml.in
   - supload-conf.sh.in
- VERSION.cmake
  - INSTALL.md
  - README.md
	
# CHANGES REQUIRED
----------------------------------------------------------------
1. Rename CMakeLists.txt to CMakeLists.old.txt
1. Modify CMakeLists.txt file, following the in-line notes.
   - Modify Plugin Specifics about Ln 40.
   - Rename the file flatpak/org.opencpn.OpenCPN.Plugin.${VERBOSE_NAME}.yaml
    - Edit this file, 3 instances about Ln 230.
   - Determine CommonName and edit <squiddio>_plugin.xml.in
   - Modify/configure 'Include' Directories about Ln 317, use CMakeLists.old.txt
   - Modify/configure 'Set' Directories about Ln 362 use CMakeLists.old.txt
   - Modify/configure 'Add Library' listings for the plugin about Ln 550
   - Edit the file  <squiiddio>_pi.xml.in, about Ln 612
   - Edit the file  <squiddio>_pi.xml, about Ln 612
1. Modify buildosx/InstallOSX/<plugin>_pi.pkgproj.in filename.
   - PluginPackage.cmake Ln 184 has configure_file to make this file.
   - File inside is generic. Rename and change 7x's inside file.
1. Modify flatpak\org.opencpn.OpenCPN.Plugin.oesenc.yaml filename
   - Rename to "squiddio" and rename all 7 instances of "oesenc" to "squiddio"
1. Modify cmake/PluginConfigure.cmake: Ln 56 -Only if necessary (squiddio req'd) 
   - Change to SET(wxWidgets_USE_LIBS base core net xml html adv aui)
   - adding 'aui' due to errors for aui.
1. Modify src/squiddioPrefsDialogBase.h
   - Removed first line: #include "wxWTranslateCatalog.h" due to errors.
   - "cmake/wxWTranslateCatalog.h.in" is not working right now.
1. First get the ci/environment scripts working on Circleci, Appveyor and .travis-ci
1. Then get the uploads to Cloudsmith working. Also see CMakeLists.txt Ln 66
   - Example Cloudsmith path uploads
     - OCPN_STABLE_REPO=mauro-calvi/squiddio-stable
     - OCPN_UNSTABLE_REPO=mauro-calvi/squiddio-pi
     - OCPN_PKG_REPO=mauro-calvi/squiddio-manual
     - Mauro's repositories https://cloudsmith.io/~mauro-calvi/repos/
   - Script path for uploads
     - .travis.yml ---> ci/travis-build-raspbian-armhf.sh 
     - appveyor.yml ---> ci/appveyor-uploads.sh
     - circleci scripts --->ci/circleci-upload.sh generally except trusty.
   - Configure uploads to Cloudsmith
     - ci/circleci-upload.sh modify Cloudsmith destinations
     - ci/appveyor-uploads.sh modify Cloudsmith destinations
     - ci/trusty-upload.sh - modify Cloudsmith destinations
     - ci/travis-build-raspbian-armhf.sh -modify Cloudsmith destinations
