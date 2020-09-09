#!/bin/sh

Rscript /relquant/pp_phospho.R \
-i /data/test_phospho/ascore_output \
-j /data/test_phospho/masic_output \
-f /data/ID_007275_FB1B42E8.fasta \
-s /relquant/study_design_phospho \
-o /data/test_phospho/plexedpiper_output