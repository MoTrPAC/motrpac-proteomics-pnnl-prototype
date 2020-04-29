# Dockerfile MASIC

FROM mono:latest
MAINTAINER DavidJM <biodavidjm@gmail.com>

RUN apt-get update
RUN apt-get -y install wget
RUN apt-get -y install unzip
RUN wget -P /app/masic/ https://github.com/PNNL-Comp-Mass-Spec/MASIC/releases/download/v3.0.7235/MASIC_Console_Program.zip
RUN cd /app/masic/ && unzip MASIC_Console_Program.zip


