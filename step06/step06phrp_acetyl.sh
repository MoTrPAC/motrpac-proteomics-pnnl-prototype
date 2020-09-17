#!/bin/sh

mono /app/phrp/PeptideHitResultsProcRunner.exe \
-I:/data/test_acetyl/msgfplus_output/P_MoTrPAC_1A_RM_Plex001_G_f06_01May19_Arwen_REP-19-04-r02.tsv \
-O:/data/test_acetyl/phrp_output/ \
-M:/parameters/MSGFPlus_PartTryp_DynMetOx_TMTExclusive_K_Acetyl_Stat_CysAlk_TMT_6Plex_20ppmParTol_ModDefs.txt \
-T:/parameters/Mass_Correction_Tags.txt \
-N:/parameters/MSGFPlus_PartTryp_DynMetOx_TMTExclusive_K_Acetyl_Stat_CysAlk_TMT_6Plex_20ppmParTol.txt \
-SynPvalue:0.2 -SynProb:0.05 \
-L:/data/test_acetyl/phrp_output/PHRP_LogFile.txt \
-ProteinMods \
-F:/data/ID_007275_FB1B42E8.revCat.fasta | tee /data/test_acetyl/step06_phrp.log
