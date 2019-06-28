#!/bin/sh

mono /app/phrp/PeptideHitResultsProcRunner.exe \
-I:/data/test_global/ascore_ouput/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.tsv \
-M:/data/test_global/ascore_ouput/MSGFDB_Tryp_DynSTYPhos_Stat_CysAlk_20ppmParTol_ModDefs.txt \
-T:/data/test_global/ascore_ouput/Mass_Correction_Tags.txt \
-N:/data/test_global/ascore_ouput/MSGFDB_Tryp_DynSTYPhos_Stat_CysAlk_20ppmParTol.txt \
-SynPvalue:0.2 -SynProb:0.05 \
-L:/data/test_global/ascore_ouput/PHRP_LogFile.txt \
-ProteinMods \
-F:/data/ID_007275_FB1B42E8.fasta > /data/test_global/step06.phrp.log


mono /app/phrp/PeptideHitResultsProcRunner.exe \
-I:/data/test_global/ascore_ouput/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.tsv \
-M:/data/test_global/ascore_ouput/MSGFDB_Tryp_DynSTYPhos_Stat_CysAlk_20ppmParTol_ModDefs.txt \
-T:/data/test_global/ascore_ouput/Mass_Correction_Tags.txt \
-N:/data/test_global/ascore_ouput/MSGFDB_Tryp_DynSTYPhos_Stat_CysAlk_20ppmParTol.txt \
-SynPvalue:0.2 -SynProb:0.05 \
-L:/data/test_global/ascore_ouput/PHRP_LogFile.txt \
-ProteinMods \
-F:/data/ID_007275_FB1B42E8.fasta >> /data/test_global/step06.phrp.log