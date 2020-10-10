#!/bin/sh

mono /app/ascore/AScore_Console.exe \
-T:msgfplus \
-F:/data/test_acetyl/phrp_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02_syn.txt \
-D:/data/test_acetyl/msgfplus_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02.mzML \
-MS:/data/test_acetyl/phrp_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02_syn_ModSummary.txt \
-P:/parameters/AScore_CID_0.5Da_ETD_0.5Da_HCD_0.05Da.xml \
-U:P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02_syn_plus_ascore.txt \
-O:/data/test_acetyl/ascore_output/ \
-L:/data/test_acetyl/ascore_output/AScore_LogFile.txt \
-Fasta:/data/ID_007275_FB1B42E8.fasta | tee /data/test_acetyl/step07_ascore.log
