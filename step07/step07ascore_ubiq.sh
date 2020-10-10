#!/bin/sh

mono /app/ascore/AScore_Console.exe \
-T:msgfplus \
-F:/data/test_ubiq/phrp_output/MS2_KggTMT_LenMM1S_MethodComparison_1mg_01_syn.txt \
-D:/data/test_ubiq/msgfplus_output/MS2_KggTMT_LenMM1S_MethodComparison_1mg_01.mzML \
-MS:/data/test_ubiq/phrp_output/MS2_KggTMT_LenMM1S_MethodComparison_1mg_01_syn_ModSummary.txt \
-P:/parameters/AScore_CID_0.5Da_ETD_0.5Da_HCD_0.05Da.xml \
-U:MS2_KggTMT_LenMM1S_MethodComparison_1mg_01_syn_plus_ascore.txt \
-O:/data/test_ubiq/ascore_output/ \
-L:/data/test_ubiq/ascore_output/AScore_LogFile.txt \
-Fasta:/data/ID_007275_FB1B42E8.fasta | tee /data/test_ubiq/step07_ascore.log
