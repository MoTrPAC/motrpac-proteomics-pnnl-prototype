#!/bin/sh

Rscript /relquant/pp_phospho.R \
-i /data/test_phospho/phrp_output \
-a /data/test_phospho/ascore_output \
-j /data/test_phospho/masic_output \
-g /data/test_global/plexedpiper_output/results_ratio.txt \
-f /data/ID_007275_FB1B42E8.fasta \
-s /relquant/study_design_phospho \
-o /data/test_phospho/plexedpiper_output