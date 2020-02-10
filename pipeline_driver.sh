#!/bin/sh

# Check that the containers are available

[ ! -z $(docker images -q motrpac-prot-masic) ] || echo "docker container < motrpac-prot-masic > does not exist"
[ ! -z $(docker images -q chambm/pwiz-skyline-i-agree-to-the-vendor-licenses ) ] || echo "docker image < msconvert > does not exist"
[ ! -z $(docker images -q motrpac-prot-msgfplus) ] || echo "docker container < motrpac-prot-msgfplus > does not exist"
[ ! -z $(docker images -q motrpac-prot-ppmerror) ] || echo "docker container < motrpac-prot-ppmerror > does not exist"
[ ! -z $(docker images -q motrpac-prot-mzid2tsv) ] || echo "docker container < motrpac-prot-mzid2tsv > does not exist"
[ ! -z $(docker images -q motrpac-prot-phrp) ] || echo "docker container < motrpac-prot-phrp > does not exist"

# Step 00
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step00:/step00:rw \
motrpac-prot-masic bash step00/step00masic.sh

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
motrpac-prot-msgfplus bash step02/step02msgfplus_tryptic.sh

# Step 03a
sh step03/step03a.sh

# Step 03b
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step03:/step03:rw \
motrpac-prot-ppmerror bash step03/step03b.sh

# Step 04
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step04:/step04:rw \
motrpac-prot-msgfplus bash step04/step04msgfplus.sh

# Step 05
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step05:/step05:rw \
motrpac-prot-mzid2tsv bash step05/step05net462.sh

# Step 06
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step06:/step06:rw \
motrpac-prot-phrp bash step06/step06phrp.sh



