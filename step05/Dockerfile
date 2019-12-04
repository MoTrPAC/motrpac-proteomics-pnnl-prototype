# Dockerfile mzid2tsv

FROM mono:latest
MAINTAINER DavidJM <biodavidjm@gmail.com>

RUN apt-get update
RUN apt-get -y install wget
RUN apt-get -y install unzip
RUN wget -P /app/mzid2tsv/ https://github.com/PNNL-Comp-Mass-Spec/Mzid-To-Tsv-Converter/releases/download/v1.3.3/MzidToTsvConverter.zip
RUN cd /app/mzid2tsv/ && unzip MzidToTsvConverter.zip