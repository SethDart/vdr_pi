REM As described in
REM https://github.com/Rasbats/managed_plugins/wiki/Local-Build

call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat"
set WXWIN=C:\wxWidgets-3.1.2
set wxWidgets_ROOT_DIR=%WXWIN%
set wxWidgets_LIB_DIR=%WXWIN%\lib\vc_dll
set wxWidgets_INCLUDE_DIRS=%WXWIN%\include

set PATH=%PATH%;%WXWIN%;%wxWidgets_LIB_DIR%;%wxWidgets_INCLUDE_DIRS%;C:\Program Files (x86)\Poedit\Gettexttools\bin;
set PATH=C:\Program Files\Cmake\bin;%PATH%

REM Example Only. Change rasbats/shipdriver_pi.git to match the repo you want to clone.
git clone  https://github.com/rasbats/shipdriver_pi.git
REM Example Only. Change shipdriver_pi to match the repo being used.
cd shipdriver_pi

mkdir  build
cd build
cmake -T v141_xp ..
cmake -G "Visual Studio 15 2017" -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
cmake --build . --target tarball --config RelWithDebInfo

cmd /k
