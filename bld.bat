cd build
cmake -T v141_xp ..
cmake --build . --target package --config release >output.txt
rem cd build
rem bash ./cloudsmith-upload.sh
