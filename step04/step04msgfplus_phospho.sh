#!/bin/sh

# Execute in docker
java -Xmx4000M \
-jar /app/MSGFPlus.jar \
-s /data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03.mzML \
-o /data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03_final.mzid \
-d /data/ID_007275_FB1B42E8.fasta \
-conf /parameters/MSGFPlus_Tryp_DynSTYPhos_Stat_CysAlk_TMT_6Plex_Protocol1_20ppmParTol.txt | tee /data/test_phospho/step04_msgfplus.log

java -Xmx4000M \
-jar /app/MSGFPlus.jar \
-s /data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03.mzML \
-o /data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03_final.mzid \
-d /data/ID_007275_FB1B42E8.fasta \
-conf /parameters/MSGFPlus_Tryp_DynSTYPhos_Stat_CysAlk_TMT_6Plex_Protocol1_20ppmParTol.txt | tee -a /data/test_phospho/step04_msgfplus.log
