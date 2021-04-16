#!/bin/sh

Rscript /relquant/pp_ubiq.R \
-i /data/test_ubiq/phrp_output \
-j /data/test_ubiq/masic_output \
-g /data/test_global/plexedpiper_output/results_ratio.txt \
-f /data/ID_007275_FB1B42E8.fasta \
-s /relquant/study_design_ubiq \
-o /data/test_ubiq/plexedpiper_output