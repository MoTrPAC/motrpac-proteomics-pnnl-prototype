#!/bin/sh

mono /app/PPMErrorCharterPython.exe \
-I:/data/test_ubiq/msgfplus_output/MS2_KggTMT_LenMM1S_MethodComparison_1mg_01.mzid \
-F:/data/test_ubiq/mzrefiner_output/MS2_KggTMT_LenMM1S_MethodComparison_1mg_01_FIXED.mzML \
-EValue:1E-10 | tee /data/test_ubiq/step03b.log
