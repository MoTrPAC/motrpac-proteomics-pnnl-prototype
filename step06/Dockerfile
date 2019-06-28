# ascore: mzid2tsv, phrp

FROM mono:latest
MAINTAINER DavidJM <biodavidjm@gmail.com>

RUN apt-get update
RUN apt-get -y install wget
RUN apt-get -y install unzip
RUN wget -P /app/mzid2tsv/ https://github.com/PNNL-Comp-Mass-Spec/Mzid-To-Tsv-Converter/releases/download/v1.3.2/MzidToTsvConverter.zip
RUN cd /app/mzid2tsv/ && unzip MzidToTsvConverter.zip
RUN wget -P /app/phrp/ https://github.com/PNNL-Comp-Mass-Spec/PHRP/releases/download/v1.5.7113/PeptideHitResultsProcessor_v1.5.7113.zip
RUN cd /app/phrp/ && unzip PeptideHitResultsProcessor*.zip