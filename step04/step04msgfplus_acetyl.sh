#!/bin/sh

# Execute in docker
java -Xmx4000M \
-jar /app/MSGFPlus.jar \
-s /data/test_acetyl/msgfplus_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02.mzML \
-o /data/test_acetyl/msgfplus_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02_final.mzid \
-d /data/ID_007275_FB1B42E8.fasta \
-conf /parameters/MSGFPlus_Tryp_DynMetOx_TMTExclusive_K_Acetyl_K_Carbamyl_N_Deamid_Stat_CysAlk_TMT_6Plex_20ppmParTol_PlusOne_IsotopeError.txt
