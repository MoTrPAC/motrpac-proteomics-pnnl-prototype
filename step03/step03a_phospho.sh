#!/bin/sh

# STEP 3A

docker run -it \
--rm \
-e WINEDEBUG=-all \
-v $PWD/data:/data:rw \
chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
wine msconvert /data/msgfplus_input/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02.mzML \
--outfile /data/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02_FIXED.mzML \
--filter "mzRefiner /data/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02.mzid thresholdValue=-1e-10 thresholdStep=10 maxSteps=2" \
--32 --mzML > step03.log


docker run -it \
--rm \
-e WINEDEBUG=-all \
-v $PWD/data:/data \
chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
wine msconvert /data/msgfplus_input/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02.mzML \
--outfile /data/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02_FIXED.mzML \
--filter "mzRefiner /data/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02.mzid thresholdValue=-1e-10 thresholdStep=10 maxSteps=2" \
--32 --mzML >> step03.log
