#!/bin/sh

    # Execute in docker
    java -Xmx4000M \
    -jar /app/MSGFPlus.jar \
    -s /data/test_global/msgfplus_input/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzML \
    -o /data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzid \
    -d /data/ID_007275_FB1B42E8.fasta \
    -conf /parameters/MzRef_StatCysAlk_TMT_6plex.txt | tee /data/test_global/step02.log

    java -Xmx4000M \
    -jar /app/MSGFPlus.jar \
    -s /data/test_global/msgfplus_input/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.mzML \
    -o /data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.mzid \
    -d /data/ID_007275_FB1B42E8.fasta \
    -conf /parameters/MzRef_StatCysAlk_TMT_6plex.txt | tee -a /data/test_global/step02.log
