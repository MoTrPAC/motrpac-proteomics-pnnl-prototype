#! /bin/sh

mono /app/mzid2tsv/net462/MzidToTsvConverter.exe \
-mzid:/data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_final.mzid \
-tsv:/data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.tsv \
-unroll -showDecoy | tee /data/test_global/step05_mzid2tsv.log

mono /app/mzid2tsv/net462/MzidToTsvConverter.exe \
-mzid:/data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02_final.mzid \
-tsv:/data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.tsv \
-unroll -showDecoy | tee -a /data/test_global/step05_mzid2tsv.log