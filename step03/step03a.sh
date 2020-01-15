#!/bin/sh

# STEP 3a

docker run --rm \
-e WINEDEBUG=-all \
-v $PWD/data:/data:rw \
chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
wine msconvert /data/test_global/msgfplus_input/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzML \
-o /data/test_global/msgfplus_output/ \
--outfile msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_FIXED.mzML \
--filter "mzRefiner /data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzid thresholdValue=-1e-10 thresholdStep=10 maxSteps=2" \
--32 --mzML | tee data/test_global/step03a.log


docker run --rm \
-e WINEDEBUG=-all \
-v $PWD/data:/data:rw \
chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
wine msconvert /data/test_global/msgfplus_input/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.mzML \
-o /data/test_global/msgfplus_output/ \
--outfile MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02_FIXED.mzML \
--filter "mzRefiner /data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.mzid thresholdValue=-1e-10 thresholdStep=10 maxSteps=2" \
--32 --mzML | tee -a data/test_global/step03a.log

