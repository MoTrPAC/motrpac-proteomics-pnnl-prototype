# Dockerfile PPMErrorCharter

FROM jonemo/pythonnet:python3.6.4-mono5.4.1.6-pythonnet2.4.0.dev0
MAINTAINER DavidJM <biodavidjm@gmail.com>
# Running this printf command first to solve a problem with apt-get update that follows...
RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get install unzip
RUN pip install --upgrade pip
RUN python3.6 -m pip install matplotlib
RUN python3.6 -m pip install pandas
RUN wget -P /app/ https://github.com/PNNL-Comp-Mass-Spec/PPMErrorCharter/releases/download/v1.2.7128/PPMErrorCharterPython_Program.zip
RUN cd /app && unzip PPMErrorCharterPython_Program.zip
RUN ln -s /usr/local/bin/python3 /usr/bin/python3
