#!/bin/sh

mono AScore_Console.exe \
-T:msgfplus \
-F:MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03_syn.txt \
-D:MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03_FIXED.mzML \
-P:AScore_CID_0.5Da_ETD_0.5Da_HCD_0.05Da.xml \
-U:MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03_syn_plus_ascore.txt \
-L:/data/test_global/ascore_output/AScore_LogFile.txt
-Fasta:/data/ID_007275_FB1B42E8.fasta > /data/test_phospho/step07_ascore.log

mono AScore_Console.exe \
-T:msgfplus \
-F:MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03_syn.txt \
-D:MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03_FIXED.mzML \
-P:AScore_CID_0.5Da_ETD_0.5Da_HCD_0.05Da.xml \
-U:MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03_syn_plus_ascore.txt \
-L:/data/test_global/ascore_output/AScore_LogFile.txt
-Fasta:/data/ID_007275_FB1B42E8.fasta >> /data/test_phospho/step07_ascore.log