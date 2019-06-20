Prototype of PNNL pipeline 
===

___Testing implementation of PNNL pipeline on BIC infrastructure___


Initial documents provided by the PNNL with details of the pipeline (converted to `md` format by the BIC) :

- [PIPELINE](docs/PIPELINE.md)
- [SOFTWARE_SOURCES](docs/SOFTWARE_SOURCES.md)
  
The [scripts](scripts/README.md) directory contains additional files and scripts.

## Notes

`Mono` is used to run `MASIC` on Linux:

```
mono MASIC.exe /I:MoTrPAC_Pilot_TMT_x.raw /P:TMT10_LTQ-FT_10ppm_ReporterTol0.003Da_2014-08-06.xml
```
 
For `MSConvert.exe`, the Linux version is available [here](http://proteowizard.sourceforge.net/download.html). Example command line they have using docker:

```
docker run -it --rm -e WINEDEBUG=-all -v /your/data:/data chambm/pwiz-skyline-i-agree-to-the-vendor-licenses wine msconvert /data/file.raw
```

Although all of our `C#`-based tools should work on Linux via `mono`, PNNL team has not thoroughly tested all of them (since they run the software on Windows).  The one exception is `MS-GF+`, which they do run on Linux (and Windows) in an automated fashion.


## Tests

Two `raw` files used for testing purposes from the pilot project global protein abundance dataset:

```
MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.raw
MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.raw
```

**Note**: None of these files (or any of the intermediate files) were committed.


### Step01: Convert raw

Convert the `.raw` files to `mzML` on a docker container

- Folder: `/data`
- OS: Mac OS X
- Command:

```
docker run -it --rm -e WINEDEBUG=-all \
-v $PWD/data:/data:rw chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
wine msconvert /data/*.raw
```

**TEST PASSED!**

---

### Step02: FULLY TRYPTIC SEARCH

Run MS-GF+ on Docker container

- MS-GF+ version available [here](https://github.com/MSGFPlus/msgfplus/releases/download/v2019.04.18/MSGFPlus_v20190418.zip)

- Test the docker container:

```
docker run -v $PWD/data:/data:rw -it openjdk  /bin/bash
```

- Created a Dockerfile available in folder [`step02`](step02/Dockerfile).  Build (only one time):

```
docker build -t "biodavidjm:msgfplus" .
```

- And start container:

```
docker run -v $PWD/data:/data:rw -it biodavidjm:msgfplus  /bin/bash
```

- Run in docker:

```
java -Xmx4000M -jar /app/MSGFPlus.jar \
-s /data/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzML \
-o /data/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzid \
-d /data/ID_007275_FB1B42E8.fasta  \
-t 20ppm -m 0 -inst 3 -e 1 -ti -1,2 -ntt 1 -tda 1 \
-minLength 6 -maxLength 50 -minCharge 2 -maxCharge 5 \
-n 1 -protocol 1 -thread 7 \
-mod /data/MSGFPlus_Mods.txt \
-minNumPeaks 5 -addFeatures 1

java -Xmx4000M -jar /app/MSGFPlus.jar \
-s /data/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.mzML \
-o /data/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.mzid \
-d /data/ID_007275_FB1B42E8.fasta  \
-t 20ppm -m 0 -inst 3 -e 1 -ti -1,2 -ntt 1 -tda 1 \
-minLength 6 -maxLength 50 -minCharge 2 -maxCharge 5 \
-n 1 -protocol 1 -thread 7 \
-mod /data/MSGFPlus_Mods.txt \
-minNumPeaks 5 -addFeatures 1
```

Output:

```
MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzid 
MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.mzid
```

**TEST PASSED!**

---

### Step03

#### A) MZ_REFINERY IN-SILICO MASS ERROR CORRECTION

```
docker run -it \
--rm \
-e WINEDEBUG=-all \
-v $PWD/data:/data:rw \
chambm/pwiz-skyline-i-agree-to-the-vendor-licenses wine msconvert MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzML \
--outfile MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_FIXED.mzML \
--filter "mzRefiner MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzid thresholdValue=-1e-10 thresholdStep=10 maxSteps=2" \
--32 --mzML


docker run -it \
--rm \
-e WINEDEBUG=-all \
-v $PWD/data:/data \
chambm/pwiz-skyline-i-agree-to-the-vendor-licenses wine msconvert MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.mzML \
--outfile MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02_FIXED.mzML \
--filter "mzRefiner MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.mzid thresholdValue=-1e-10 thresholdStep=10 maxSteps=2" \
--32 --mzML
```

**TEST PASSED!**

#### B) MZ_REFINERY ERROR CORRECTION CHARTS (Optional)

It requires mono.

- Test on Mac OS X

```
mono PPMErrorCharter.exe data/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzid 1E-10 
```

Output:

```
Validation error:

PSM results file not specified
```

- Test on docker

```
docker pull mono

docker run -v $PWD/data:/data:rw -it mono  /bin/bash

apt-get update
apt-get -y install wget
apt-get -y install unzip
wget https://github.com/PNNL-Comp-Mass-Spec/PPMErrorCharter/releases/download/v1.1.7068/PPMErrorCharter_Program.zip
unzip PPMErrorCharter_Program.zip

mono PPMErrorCharter.exe -I:/data/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzid -EValue:1E-10 -Python

```

Output

```
PPMErrorCharter, version 1.1.7068.23133 (May 9, 2019)
 
 
Using options:
 
PSM results file: /data/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzid
 
Spec EValue threshold: 1.0E-10
 
PPM Error histogram bin size: 0.5
 
Generating plots with Python
 
 
------------------------------------------------------------------------------
 
Error occurred in Program->Main: Could not load type of field 'PPMErrorCharter.IdentDataPlotter:<ErrorHistogramBitmap>k__BackingField' (0) due to: Could not load file or assembly 'PresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35' or one of its dependencies.
```

***!!!!!!!!!!!!!!!!!!!!!***

**Test DID NOT passed**

***!!!!!!!!!!!!!!!!!!!!!***


## Step 04: PROTEIN IDENTIFICATION AND QUANTIFICATION

Run the same docker container as in step02

```
docker run -v $PWD/data:/data:rw -it biodavidjm:msgfplus  /bin/bash
```

And run:

```
java -Xmx4000M \
-jar /app/MSGFPlus.jar \
-s /data/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_FIXED.mzML \
-o /data/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_FIXED_msgfplus.mzid \
-d /data/ID_007275_FB1B42E8.fasta  \
-t 20ppm -m 0 -inst 3 -e 1 -ti -1,2 -ntt 1 -tda 1 \
-minLength 6 -maxLength 50 -minCharge 2 -maxCharge 5 \
-n 1 -protocol 1 -thread 7 \
-mod /data/MSGFPlus_Mods.txt \
-minNumPeaks 5 \
-addFeatures 1

java -Xmx4000M \
-jar /app/MSGFPlus.jar \
-s /data/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02_FIXED.mzML \
-o /data/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02_FIXED_msgfplus.mzid \
-d /data/ID_007275_FB1B42E8.fasta  \
-t 20ppm -m 0 -inst 3 -e 1 -ti -1,2 -ntt 1 -tda 1 \
-minLength 6 -maxLength 50 -minCharge 2 -maxCharge 5 \
-n 1 -protocol 1 -thread 7 \
-mod /data/MSGFPlus_Mods.txt \
-minNumPeaks 5 \
-addFeatures 1
```

**TEST PASSED!**


## Step05: MASIC

Build Dockerfile (one time):

```
docker build -t "biodavidjm:masic" .
```

Start the container:

```
docker run -v $PWD/data:/data:rw -it biodavidjm:masic /bin/bash
```

Run in container:

```
mono /app/MASIC_Console.exe \
/I:/data/raw/*.raw /O:/data/masic_output/ \
/P:/data/masic_input/TMT10_LTQ-FT_10ppm_ReporterTol0.003Da_2014-08-06.xml \
> /data/masic.log
```

Check log: `/data/masic.log`


## Questions

- ~~Why is the MSGF+ version so old (v2017.08.23) (23 August 2017)? (which fails)~~: Matt: Use the latest version.
- How to resolve: `1000_collect_data.R` used to create `msgfData_original.RData`  (only works inside PNNL due to dependency on internal resources)
- PIPELINE.md: why fasta file names differ between step01:`ID_006404_2D994010.fasta` and step04:`ID_007275_FB1B42E8.fasta`?

