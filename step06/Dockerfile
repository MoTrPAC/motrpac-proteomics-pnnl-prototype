# ascore: mzid2tsv, phrp

FROM mono:latest
MAINTAINER DavidJM <biodavidjm@gmail.com>

RUN apt-get update
RUN apt-get -y install wget
RUN apt-get -y install unzip
RUN wget -P /app/phrp/ https://github.com/PNNL-Comp-Mass-Spec/PHRP/releases/download/v1.5.7130/PeptideHitResultsProcessor.zip
RUN cd /app/phrp/ && unzip PeptideHitResultsProcessor*.zip
