#!/bin/sh

docker run -it --rm \
-e WINEDEBUG=-all \
-v $PWD/data:/data:rw \
chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
wine msconvert /data/test_ubiq/raw/*.raw \
--zlib \
--filter "peakPicking true 2-" \
-o /data/test_ubiq/msgfplus_input/