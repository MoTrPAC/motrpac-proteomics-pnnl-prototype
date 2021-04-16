#!/bin/sh

Rscript /relquant/pp_acetyl.R \
-i /data/test_acetyl/phrp_output \
-j /data/test_acetyl/masic_output \
-g /data/test_global/plexedpiper_output/results_ratio.txt \
-f /data/ID_007275_FB1B42E8.fasta \
-s /relquant/study_design_acetyl \
-o /data/test_acetyl/plexedpiper_output