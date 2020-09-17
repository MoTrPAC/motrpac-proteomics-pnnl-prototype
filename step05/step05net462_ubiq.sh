#! /bin/sh

mono /app/mzid2tsv/net462/MzidToTsvConverter.exe \
-mzid:/data/test_ubiq/msgfplus_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02_final.mzid \
-tsv:/data/test_ubiq/msgfplus_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02.tsv \
-unroll -showDecoy | tee /data/test_ubiq/step05_mzid2tsv.log
