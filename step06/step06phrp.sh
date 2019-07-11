#!/bin/sh

mono /app/phrp/PeptideHitResultsProcRunner.exe \
-I:/data/test_global/ascore_output/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.tsv \
-M:/parameters/MSGFPlus_PartTryp_DynMetOx_Stat_CysAlk_TMT_6Plex_20ppmParTol_ModDefs.txt \
-T:/parameters/Mass_Correction_Tags.txt \
-N:/parameters/MSGFPlus_PartTryp_DynMetOx_Stat_CysAlk_TMT_6Plex_20ppmParTol.txt \
-SynPvalue:0.2 -SynProb:0.05 \
-L:/data/test_global/ascore_output/PHRP_LogFile.txt \
-ProteinMods \
-F:/data/ID_007275_FB1B42E8.revcat.fasta > /data/test_global/step06_phrp.log


mono /app/phrp/PeptideHitResultsProcRunner.exe \
-I:/data/test_global/ascore_output/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.tsv \
-M:/parameters/MSGFPlus_PartTryp_DynMetOx_Stat_CysAlk_TMT_6Plex_20ppmParTol_ModDefs.txt \
-T:/parameters/Mass_Correction_Tags.txt \
-N:/parameters/MSGFPlus_PartTryp_DynMetOx_Stat_CysAlk_TMT_6Plex_20ppmParTol.txt \
-SynPvalue:0.2 -SynProb:0.05 \
-L:/data/test_global/ascore_output/PHRP_LogFile.txt \
-ProteinMods \
-F:/data/ID_007275_FB1B42E8.revcat.fasta >> /data/test_global/step06_phrp.log