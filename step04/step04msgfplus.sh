#!/bin/sh

# Execute in docker
java -Xmx4000M \
-jar /app/MSGFPlus.jar \
-s /data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzML \
-o /data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_final.mzid \
-d /data/ID_007275_FB1B42E8.fasta \
-conf /parameters/MSGFPlus_PartTryp_DynMetOx_Stat_CysAlk_TMT_6Plex_20ppmParTol.txt | tee /data/test_global/step04_msgfplus.log

java -Xmx4000M \
-jar /app/MSGFPlus.jar \
-s /data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.mzML \
-o /data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02_final.mzid \
-d /data/ID_007275_FB1B42E8.fasta \
-conf /parameters/MSGFPlus_PartTryp_DynMetOx_Stat_CysAlk_TMT_6Plex_20ppmParTol.txt | tee -a /data/test_global/step04_msgfplus.log
