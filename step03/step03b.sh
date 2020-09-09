#!/bin/sh

mono /app/PPMErrorCharterPython.exe \
-I:/data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzid \
-F:/data/test_global/mzrefiner_output/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_FIXED.mzML \
-EValue:1E-10 | tee /data/test_global/step03b.log

mono /app/PPMErrorCharterPython.exe \
-I:/data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.mzid \
-F:/data/test_global/mzrefiner_output/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02_FIXED.mzML \
-EValue:1E-10 | tee -a /data/test_global/step03b.log