#!/bin/sh

# Execute in docker
java -Xmx4000M \
-jar /app/MSGFPlus.jar \
-s /data/test_phospho/msgfplus_tryptic_input/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02.mzML \
-o /data/test_phospho/msgfplus_tryptic_output/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02.mzid \
-d /data/ID_007275_FB1B42E8.fasta \
-conf /parameters/MzRef_StatCysAlk_S_Phospho_Dyn_TY_Phospho_TMT_6plex.txt > /data/test_phospho/step02_phospho.log

java -Xmx4000M \
-jar /app/MSGFPlus.jar \
-s /data/test_phospho/msgfplus_tryptic_input/MoTrPAC_Pilot_TMT_P_S1_09_24Oct17_Elm_AQ-17-09-02.mzML \
-o /data/test_phospho/msgfplus_tryptic_output/MMoTrPAC_Pilot_TMT_P_S1_09_24Oct17_Elm_AQ-17-09-02.mzid \
-d /data/ID_007275_FB1B42E8.fasta \
-conf /parameters/MzRef_StatCysAlk_S_Phospho_Dyn_TY_Phospho_TMT_6plex.txt >> /data/test_phospho/step02_phospho.log
