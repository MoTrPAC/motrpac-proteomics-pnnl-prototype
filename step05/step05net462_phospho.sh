#! /bin/sh


mono /app/mzid2tsv/net462/MzidToTsvConverter.exe \
-mzid:/data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02_final.mzid \
-tsv:/data/test_phospho/ascore_ouput/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02.tsv \
-unroll -showDecoy > /data/test_phospho/step05.mzid2tsv.log

mono /app/mzid2tsv/net462/MzidToTsvConverter.exe \
-mzid:/data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02_final.mzid \
-tsv:/data/test_phospho/ascore_ouput/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02.tsv \
-unroll -showDecoy >> /data/test_phospho/step05.mzid2tsv.log