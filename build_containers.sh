#!/bin/sh

# Build containers
docker build -t "motrpac:masic" -f step00/Dockerfile .
docker build -t "motrpac:msgfplus" -f step02/Dockerfile .
docker build -t "motrpac:ppmerror" -f step03/Dockerfile .
docker build -t "motrpac:mzid2tsv" -f step05/Dockerfile .
docker build -t "motrpac:phrp" -f step06/Dockerfile .

