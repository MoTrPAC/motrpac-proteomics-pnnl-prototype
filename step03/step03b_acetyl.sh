#!/bin/sh

mkdir /data/test_acetyl/ppm_errorcharter/

mono /app/PPMErrorCharterPython.exe \
-I:/data/test_acetyl/msgfplus_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02.mzid \
-F:/data/test_acetyl/mzrefiner_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02_FIXED.mzML \
-EValue:1E-10 \
-O:/data/test_acetyl/ppm_errorcharter/ | tee /data/test_acetyl/step03b.log
