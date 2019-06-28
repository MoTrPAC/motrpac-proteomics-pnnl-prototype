#!/bin/sh

mono /app/phrp/PeptideHitResultsProcRunner.exe \
-I:/data/test_phospho/ascore_ouput/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02.tsv \
-M:/parameters/MSGFPlus_PartTryp_DynMetOx_Stat_CysAlk_TMT_6Plex_20ppmParTol_ModDefs.txt \
-T:/parameters/Mass_Correction_Tags.txt \
-N:/parameters/MSGFPlus_PartTryp_DynMetOx_Stat_CysAlk_TMT_6Plex_20ppmParTol.txt \
-SynPvalue:0.2 -SynProb:0.05 \
-L:/data/test_phospho/ascore_ouput/PHRP_LogFile.txt \
-ProteinMods \
-F:/data/ID_007275_FB1B42E8.fasta > /data/test_phospho/step06_phrp_phospho.log


mono /app/phrp/PeptideHitResultsProcRunner.exe \
-I:/data/test_phospho/ascore_ouput/MoTrPAC_Pilot_TMT_P_S1_08_24Oct17_Elm_AQ-17-09-02.tsv \
-M:/parameters/MSGFPlus_PartTryp_DynMetOx_Stat_CysAlk_TMT_6Plex_20ppmParTol_ModDefs.txt \
-T:/parameters/Mass_Correction_Tags.txt \
-N:/parameters/MSGFPlus_PartTryp_DynMetOx_Stat_CysAlk_TMT_6Plex_20ppmParTol.txt \
-SynPvalue:0.2 -SynProb:0.05 \
-L:/data/test_phospho/ascore_ouput/PHRP_LogFile.txt \
-ProteinMods \
-F:/data/ID_007275_FB1B42E8.fasta >> /data/test_phospho/step06_phrp_phospho.log