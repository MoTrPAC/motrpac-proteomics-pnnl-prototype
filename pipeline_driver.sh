#!/bin/sh

# Check that the containers are available

[ ! -z $(docker images -q motrpac:masic) ] || echo "docker container < motrpac:masic > does not exist"
[ ! -z $(docker images -q chambm/pwiz-skyline-i-agree-to-the-vendor-licenses ) ] || echo "docker image < msconvert > does not exist"
[ ! -z $(docker images -q motrpac:msgfplus) ] || echo "docker container < motrpac:msgfplus > does not exist"
[ ! -z $(docker images -q motrpac:ppmerror) ] || echo "docker container < motrpac:ppmerror > does not exist"
[ ! -z $(docker images -q motrpac:mzid2tsv) ] || echo "docker container < motrpac:mzid2tsv > does not exist"
[ ! -z $(docker images -q motrpac:phrp) ] || echo "docker container < motrpac:phrp > does not exist"

# Step 00
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step00:/step00:rw \
motrpac:masic bash ls step00/step00masic.sh

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
motrpac:msgfplus bash step02/step02msgfplus_tryptic.sh

# Step 03a
sh step03/step03a.sh

# Step 03b
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step03:/step03:rw \
motrpac:ppmerror bash step03/step03b.sh

# Step 04
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step04:/step04:rw \
motrpac:msgfplus bash step04/step04msgfplus.sh

# Step 05
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step05:/step05:rw \
motrpac:mzid2tsv bash step05/step05net462.sh

# Step 06
docker run -v $PWD/data:/data:rw \
-v $PWD/parameters:/parameters:rw \
-v $PWD/step06:/step06:rw \
motrpac:phrp bash step06/step06phrp.sh



