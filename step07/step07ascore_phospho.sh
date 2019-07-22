#!/bin/sh

mono /app/ascore/AScore_Console.exe \
-T:msgfplus \
-F:/data/test_phospho/phrp_output/MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03_syn.txt \
-D:/data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03_FIXED.mzML \
-P:/parameters/AScore_CID_0.5Da_ETD_0.5Da_HCD_0.05Da.xml \
-U:MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03_syn_plus_ascore.txt \
-O:/data/test_phospho/ \
-L:/data/test_phospho/ascore_output/AScore_LogFile.txt \
-Fasta:/data/ID_007275_FB1B42E8.fasta > /data/test_phospho/step07_ascore.log

mono /app/ascore/AScore_Console.exe \
-T:msgfplus \
-F:/data/test_phospho/phrp_output/MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03_syn.txt \
-D:/data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03_FIXED.mzML \
-P:/parameters/AScore_CID_0.5Da_ETD_0.5Da_HCD_0.05Da.xml \
-U:MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03_syn_plus_ascore.txt \
-O:/data/test_phospho/ \
-L:/data/test_phospho/ascore_output/AScore_LogFile2.txt \
-Fasta:/data/ID_007275_FB1B42E8.fasta >> /data/test_phospho/step07_ascore.log
