#!/bin/sh

# Execute in docker
java -Xmx4000M \
-jar /app/MSGFPlus.jar \
-s /data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_FIXED.mzML \
-o /data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_final.mzid \
-d /data/ID_007275_FB1B42E8.fasta \
-conf /parameters/MSGFPlus_PartTryp_DynMetOx_Stat_CysAlk_TMT_6Plex_20ppmParTol.txt > /data/test_global/step04.log

java -Xmx4000M \
-jar /app/MSGFPlus.jar \
-s /data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02_FIXED.mzML \
-o /data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02_final.mzid \
-d /data/ID_007275_FB1B42E8.fasta \
-conf /parameters/MSGFPlus_PartTryp_DynMetOx_Stat_CysAlk_TMT_6Plex_20ppmParTol.txt >> /data/test_global/step04.log
