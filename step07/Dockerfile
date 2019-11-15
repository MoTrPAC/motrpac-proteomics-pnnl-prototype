# DOCKERFILE AScore
FROM mono:latest
MAINTAINER DavidJM <biodavidjm@gmail.com>

RUN apt-get update
RUN apt-get -y install wget
RUN apt-get -y install unzip
RUN apt-get update
RUN apt-get -y install gcc
RUN wget -P /app/sqlite/ https://github.com/AshleyLab/motrpac-proteomics-pnnl-prototype/raw/master/step06/sqlite-netFx-full-source-1.0.111.0.zip
RUN cd /app/sqlite/ && unzip sqlite-netFx-full-source-1.0.111.0.zip
RUN chmod +x /app/sqlite/Setup/compile-interop-assembly-release.sh
RUN /app/sqlite/Setup/compile-interop-assembly-release.sh
RUN wget -P /app/ascore/ https://github.com/PNNL-Comp-Mass-Spec/AScore/releases/download/v1.0.7257/AScore_Program_Debian.zip
RUN cd /app/ascore/ && unzip AScore_Program_Debian.zip
RUN cp /app/sqlite/bin/2013/Release/bin/libSQLite.Interop.so /app/ascore/
RUN chmod -x /app/ascore/libSQLite.Interop.so
