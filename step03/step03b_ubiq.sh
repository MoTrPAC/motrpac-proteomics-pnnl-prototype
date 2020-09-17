#!/bin/sh

mono /app/PPMErrorCharterPython.exe \
-I:/data/test_ubiq/msgfplus_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02.mzid \
-F:/data/test_ubiq/mzrefiner_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02_FIXED.mzML \
-EValue:1E-10 | tee /data/test_ubiq/step03b.log
