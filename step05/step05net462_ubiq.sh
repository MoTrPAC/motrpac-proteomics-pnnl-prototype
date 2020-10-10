#! /bin/sh

mono /app/mzid2tsv/net462/MzidToTsvConverter.exe \
-mzid:/data/test_ubiq/msgfplus_output/MS2_KggTMT_LenMM1S_MethodComparison_1mg_01_final.mzid \
-tsv:/data/test_ubiq/msgfplus_output/MS2_KggTMT_LenMM1S_MethodComparison_1mg_01.tsv \
-unroll -showDecoy | tee /data/test_ubiq/step05_mzid2tsv.log
