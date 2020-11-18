#!/bin/sh

# STEP 3A
docker run \
--rm \
-e WINEDEBUG=-all \
-v $PWD/data:/data:rw \
chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
wine msconvert /data/test_ubiq/msgfplus_input/MS2_KggTMT_LenMM1S_MethodComparison_1mg_01.mzML \
-o /data/test_ubiq/mzrefiner_output/ \
--outfile /data/test_ubiq/mzrefiner_output/MS2_KggTMT_LenMM1S_MethodComparison_1mg_01_FIXED.mzML \
--filter "mzRefiner /data/test_ubiq/msgfplus_output/MS2_KggTMT_LenMM1S_MethodComparison_1mg_01.mzid thresholdValue=-1e-10 thresholdStep=10 maxSteps=2" \
--zlib | tee data/test_ubiq/step03.log

cp data/test_ubiq/mzrefiner_output/MS2_KggTMT_LenMM1S_MethodComparison_1mg_01_FIXED.mzML data/test_ubiq/msgfplus_output/MS2_KggTMT_LenMM1S_MethodComparison_1mg_01.mzML
