# Dockerfile

FROM openjdk:latest
MAINTAINER DavidJM <biodavidjm@gmail.com>
RUN yum install -y git
RUN yum install -y wget
RUN yum install -y unzip

RUN wget -P /app/ https://github.com/MSGFPlus/msgfplus/releases/download/v2019.04.18/MSGFPlus_v20190418.zip
RUN cd /app && unzip MSGFPlus_v20190418.zip

#RUN java -Xmx4000M -jar MSGFPlus.jar -s /data/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzML -o /data/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzid -d /data/ID_007275_FB1B42E8.fasta  -t 20ppm -m 0 -inst 3 -e 1 -ti -1,2 -ntt 1 -tda 1 -minLength 6 -maxLength 50 -minCharge 2 -maxCharge 5 -n 1 -protocol 1 -thread 7 -mod /data/MSGFPlus_Mods.txt -minNumPeaks 5 -addFeatures 1


