#!/bin/sh

# Build containers, tag, and push to the registry

docker build -t "motrpac-prot-masic:v1.2_20200901" -f step00/Dockerfile_masic .
docker tag motrpac-prot-masic:v1.2_20200901 gcr.io/motrpac-portal-dev/motrpac-prot-masic:v1.2_20200901
docker push gcr.io/motrpac-portal-dev/motrpac-prot-masic:v1.2_20200901

docker build -t "motrpac-prot-msgfplus:v1.2_20200901" -f step02/Dockerfile_msgfplus .
docker tag motrpac-prot-msgfplus:v1.2_20200901 gcr.io/motrpac-portal-dev/motrpac-prot-msgfplus:v1.2_20200901
docker push gcr.io/motrpac-portal-dev/motrpac-prot-msgfplus:v1.2_20200901

docker build -t "motrpac-prot-ppmerror:v1.2_20200901" -f step03/Dockerfile_ppmerror .
# gcr.io
docker tag motrpac-prot-ppmerror:v1.2_20200901 gcr.io/motrpac-portal-dev/motrpac-prot-ppmerror:v1.2_20200901
docker push gcr.io/motrpac-portal-dev/motrpac-prot-ppmerror:v1.2_20200901

#docker hub
docker tag motrpac-prot-ppmerror:v1.2_20200901 docker.io/biodavidjm/motrpac-prot-ppmerror:v1.2_20200901
docker push docker.io/biodavidjm/motrpac-prot-ppmerror:v1.2_20200901


docker build -t "motrpac-prot-mzid2tsv:v1.2_20200901" -f step05/Dockerfile_mzid2tsv .
docker tag motrpac-prot-mzid2tsv:v1.2_20200901 gcr.io/motrpac-portal-dev/motrpac-prot-mzid2tsv:v1.2_20200901
docker push gcr.io/motrpac-portal-dev/motrpac-prot-mzid2tsv:v1.2_20200901

docker build -t "motrpac-prot-phrp:v1.2_20200901" -f step06/Dockerfile_phrp .
docker tag motrpac-prot-phrp:v1.2_20200901 gcr.io/motrpac-portal-dev/motrpac-prot-phrp:v1.2_20200901
docker push gcr.io/motrpac-portal-dev/motrpac-prot-phrp:v1.2_20200901

docker build -t "motrpac-prot-ascore:v1.2_20200901" -f step07/Dockerfile_ascore .
docker tag motrpac-prot-ascore:v1.2_20200901 gcr.io/motrpac-portal-dev/motrpac-prot-ascore:v1.2_20200901
docker push gcr.io/motrpac-portal-dev/motrpac-prot-ascore:v1.2_20200901

docker build -t "motrpac-prot-plexedpiper:v1.2_20200901" -f relquant/Dockerfile_plexedpiper .
docker tag motrpac-prot-ascore:v1.2_20200901 gcr.io/motrpac-portal-dev/motrpac-prot-ascore:v1.2_20200901
docker push gcr.io/motrpac-portal-dev/motrpac-prot-ascore:v1.2_20200901

# Pull images not build in house
docker pull chambm/pwiz-skyline-i-agree-to-the-vendor-licenses
docker pull docker.io/chambm/pwiz-skyline-i-agree-to-the-vendor-licenses:latest





