#!/bin/sh

# Execute in docker
java -Xmx4000M \
-jar /app/MSGFPlus.jar \
-s /data/test_ubiq/msgfplus_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02.mzML \
-o /data/test_ubiq/msgfplus_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02_final.mzid \
-d /data/ID_007275_FB1B42E8.fasta \
-conf /parameters/MSGFPlus_PartTryp_MetOx_TMT_6Plex_Ubiq_20ppmParTol.txt | tee /data/test_ubiq/step04_msgfplus.log
