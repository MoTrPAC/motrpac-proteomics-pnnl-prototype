#!/bin/sh

# Check that the containers are available

[ ! -z $(docker images -q motrpac-prot-masic:v1.0_20200115) ] || echo "docker container < motrpac-prot-masic:v1.0_20200115 > does not exist"
[ ! -z $(docker images -q chambm/pwiz-skyline-i-agree-to-the-vendor-licenses ) ] || echo "docker image < msconvert > does not exist"
[ ! -z $(docker images -q motrpac-prot-msgfplus:v1.1_20200314) ] || echo "docker container < motrpac-prot-msgfplus:v1.1_20200314 > does not exist"
[ ! -z $(docker images -q motrpac-prot-ppmerror) ] || echo "docker container < motrpac-prot-ppmerror > does not exist"
[ ! -z $(docker images -q motrpac-prot-mzid2tsv) ] || echo "docker container < motrpac-prot-mzid2tsv > does not exist"
[ ! -z $(docker images -q motrpac-prot-phrp) ] || echo "docker container < motrpac-prot-phrp > does not exist"
[ ! -z $(docker images -q motrpac-relquant) ] || echo "docker container < motrpac-relquant > does not exist"

# Step 00
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step00:/step00:rw \
motrpac-prot-masic:v1.0_20200115 bash step00/step00masic.sh

# Step 01
docker run --rm \
-e WINEDEBUG=-all \
-v $PWD/data:/data:rw \
chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
wine msconvert /data/test_global/raw/*.raw \
-o /data/test_global/msgfplus_input/

# Step 02
docker run \
-v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step02:/step02:rw \
motrpac-prot-msgfplus:v1.1_20200314 bash step02/step02msgfplus_tryptic.sh

# Step 03a
sh step03/step03a.sh

# Step 03b
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step03:/step03:rw \
motrpac-prot-ppmerror:v1.0_20200115 bash step03/step03b.sh

# Step 04
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step04:/step04:rw \
motrpac-prot-msgfplus:v1.1_20200314 bash step04/step04msgfplus.sh

# Step 05
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step05:/step05:rw \
motrpac-prot-mzid2tsv:v1.0_20200115 bash step05/step05net462.sh

# Step 06
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step06:/step06:rw \
motrpac-prot-phrp:v1.0_20200115 bash step06/step06phrp.sh

# Step 07
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step06:/step06:rw \
motrpac-prot-ascore:v1.0_20200115 bash step07/step07ascore_phospho.sh

# Relative quantification step
docker run -v $PWD/data:/data:rw \
-v $PWD/relquant:/relquant:rw \
motrpac-relquant:v1.0_20200731 bash relquant/relquant.sh



