#!/bin/sh

mono /app/phrp/PeptideHitResultsProcRunner.exe \
-I:/data/test_ubiq/msgfplus_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02.tsv \
-O:/data/test_ubiq/phrp_output/ \
-M:/parameters/MSGFPlus_PartTryp_MetOx_TMT_6Plex_Ubiq_20ppmParTol_ModDefs.txt \
-T:/parameters/Mass_Correction_Tags.txt \
-N:/parameters/MSGFPlus_PartTryp_MetOx_TMT_6Plex_Ubiq_20ppmParTol.txt \
-SynPvalue:0.2 -SynProb:0.05 \
-L:/data/test_ubiq/phrp_output/PHRP_LogFile.txt \
-ProteinMods \
-F:/data/ID_007275_FB1B42E8.revCat.fasta | tee /data/test_ubiq/step06_phrp.log
