#!/bin/sh

# Execute in docker
java -Xmx4000M \
-jar /app/MSGFPlus.jar \
-s /data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02_FIXED.mzML \
-o /data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02_final.mzid \
-d /data/ID_007275_FB1B42E8.fasta \
-conf /parameters/MSGFPlus_Tryp_DynSTYPhos_Stat_CysAlk_TMT_6Plex_Protocol1_20ppmParTol.txt > /data/test_phospho/step04.log

java -Xmx4000M \
-jar /app/MSGFPlus.jar \
-s /data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_09_24Oct17_Elm_AQ-17-09-02_FIXED.mzML \
-o /data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_09_24Oct17_Elm_AQ-17-09-02_final.mzid \
-d /data/ID_007275_FB1B42E8.fasta \
-conf /parameters/MSGFPlus_Tryp_DynSTYPhos_Stat_CysAlk_TMT_6Plex_Protocol1_20ppmParTol.txt >> /data/test_phospho/step04.log
