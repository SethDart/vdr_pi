cd build
rem normal use
rem cmake -T v141_xp -G "Visual Studio 15 2017" ..
rem cmake --build . --target tarball --config RelWithDebInfo >output.txt

rem cmake -T v141_xp ..
rem cmake --build . --target package --config release >output.txt
rem cd build
rem bash ./cloudsmith-upload.sh


rem  - mkdir build
rem  - cd build
rem  - cmake -T v141_xp -G "Visual Studio 15 2017" 
rem  - cmake --build . --target tarball --config RelWithDebInfo
rem  - py ..\ci\windows-ldd
rem  - cmd: upload.bat
rem  - py ..\ci\git-push

cd build
cmake -T v141_xp ..
cmake -G "Visual Studio 15 2017" -DCMAKE_BUILD_TYPE=RelWithDebInfo  ..
cmake --build . --target tarball --config RelWithDebInfo

cmd /k
