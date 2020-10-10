#!/bin/sh

# Execute in docker
java -Xmx4000M \
-jar /app/MSGFPlus.jar \
-s /data/test_ubiq/msgfplus_input/MS2_KggTMT_LenMM1S_MethodComparison_1mg_01.mzML \
-o /data/test_ubiq/msgfplus_output/MS2_KggTMT_LenMM1S_MethodComparison_1mg_01.mzid \
-d /data/ID_007275_FB1B42E8.fasta \
-conf /parameters/MzRef_StatCysAlk_TMT_6plex.txt | tee /data/test_ubiq/step02.log
