#!/bin/sh

# STEP 3A
docker run \
--rm \
-e WINEDEBUG=-all \
-v $PWD/data:/data:rw \
chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
wine msconvert /data/test_phospho/msgfplus_input/MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03.mzML \
-o /data/test_phospho/mzrefiner_output/ \
--outfile /data/test_phospho/mzrefiner_output/MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03_FIXED.mzML \
--filter "mzRefiner /data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03.mzid thresholdValue=-1e-10 thresholdStep=10 maxSteps=2" \
--32 --mzML | tee data/test_phospho/step03.log


docker run \
--rm \
-e WINEDEBUG=-all \
-v $PWD/data:/data \
chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
wine msconvert /data/test_phospho/msgfplus_input/MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03.mzML \
-o /data/test_phospho/mzrefiner_output/ \
--outfile /data/test_phospho/mzrefiner_output/MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03_FIXED.mzML \
--filter "mzRefiner /data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03.mzid thresholdValue=-1e-10 thresholdStep=10 maxSteps=2" \
--32 --mzML | tee -a data/test_phospho/step03.log

cp data/test_phospho/mzrefiner_output/MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03_FIXED.mzML data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03.mzML
cp data/test_phospho/mzrefiner_output/MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03_FIXED.mzML data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03.mzML