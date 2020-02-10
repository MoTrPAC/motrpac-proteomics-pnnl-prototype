#!/bin/sh

# Build containers Locally
docker build -t "motrpac-prot-masic:v1.0_20200115" -f step00/Dockerfile .
docker build -t "motrpac-prot-msgfplus:v1.0_20200115" -f step02/Dockerfile .
docker build -t "motrpac-prot-ppmerror:v1.0_20200115" -f step03/Dockerfile .
docker build -t "motrpac-prot-mzid2tsv:v1.0_20200115" -f step05/Dockerfile .
docker build -t "motrpac-prot-phrp:v1.0_20200115" -f step06/Dockerfile .

# Pull images not build in house
docker pull chambm/pwiz-skyline-i-agree-to-the-vendor-licenses

# Cloud Container Registry

## Tag
docker tag motrpac-prot-masic:v1.0_20200122 gcr.io/motrpac-portal-dev/motrpac-prot-masic:v1.0_20200122
docker tag motrpac-prot-msgfplus:v1.0_20200115 gcr.io/motrpac-portal-dev/motrpac-prot-msgfplus:v1.0_20200115
docker tag motrpac-prot-ppmerror:v1.0_20200115 gcr.io/motrpac-portal-dev/motrpac-prot-ppmerror:v1.0_20200115
docker tag motrpac-prot-mzid2tsv:v1.0_20200115 gcr.io/motrpac-portal-dev/motrpac-prot-mzid2tsv:v1.0_20200115
docker tag motrpac-prot-phrp:v1.0_20200115 gcr.io/motrpac-portal-dev/motrpac-prot-phrp:v1.0_20200115

## push
docker push gcr.io/motrpac-portal-dev/motrpac-prot-masic:v1.0_20200122
docker push gcr.io/motrpac-portal-dev/motrpac-prot-msgfplus:v1.0_20200115
docker push gcr.io/motrpac-portal-dev/motrpac-prot-ppmerror:v1.0_20200115
docker push gcr.io/motrpac-portal-dev/motrpac-prot-mzid2tsv:v1.0_20200115
docker push gcr.io/motrpac-portal-dev/motrpac-prot-phrp:v1.0_20200115

## Pull containers from the registry
docker pull gcr.io/motrpac-portal-dev/motrpac-prot-masic:v1.0_20200122
