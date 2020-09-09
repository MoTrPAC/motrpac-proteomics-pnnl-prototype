#!/bin/sh

mono /app/PPMErrorCharterPython.exe \
-I:/data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03.mzid \
-F:/data/test_phospho/mzrefiner_output/MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03_FIXED.mzML \
-EValue:1E-10 | tee /data/test_phospho/step03b.log

mono /app/PPMErrorCharterPython.exe \
-I:/data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03.mzid \
-F:/data/test_phospho/mzrefiner_output/MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03_FIXED.mzML \
-EValue:1E-10 | tee -a /data/test_phospho/step03b.log
