#!/bin/sh

# STEP 3A
docker run \
--rm \
-e WINEDEBUG=-all \
-v $PWD/data:/data:rw \
chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
wine msconvert /data/test_acetyl/msgfplus_input/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02.mzML \
-o /data/test_acetyl/mzrefiner_output/ \
--outfile /data/test_acetyl/mzrefiner_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02_FIXED.mzML \
--filter "mzRefiner /data/test_acetyl/msgfplus_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02.mzid thresholdValue=-1e-10 thresholdStep=10 maxSteps=2" \
--zlib | tee data/test_acetyl/step03.log

cp data/test_acetyl/mzrefiner_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02_FIXED.mzML data/test_acetyl/msgfplus_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02.mzML
