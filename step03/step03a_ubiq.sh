#!/bin/sh

# STEP 3A
docker run \
--rm \
-e WINEDEBUG=-all \
-v $PWD/data:/data:rw \
chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
wine msconvert /data/test_ubiq/msgfplus_input/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02.mzML \
-o /data/test_ubiq/mzrefiner_output/ \
--outfile /data/test_ubiq/mzrefiner_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02_FIXED.mzML \
--filter "mzRefiner /data/test_ubiq/msgfplus_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02.mzid thresholdValue=-1e-10 thresholdStep=10 maxSteps=2" \
--32 --mzML | tee data/test_ubiq/step03.log

cp data/test_ubiq/mzrefiner_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02_FIXED.mzML data/test_ubiq/msgfplus_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02.mzML
