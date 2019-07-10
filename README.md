Prototype of PNNL pipeline 
===

___Testing implementation of PNNL pipeline on BIC infrastructure___


Initial documents provided by the PNNL with details of the pipeline (converted to `md` format by the BIC) :

- [PIPELINE](docs/PIPELINE.md)
- [SOFTWARE_SOURCES](docs/SOFTWARE_SOURCES.md)
  
The [scripts](scripts/README.md) directory contains additional files and scripts.


# WORKFLOW

## GLOBAL PROTEOME Test files

Two `raw` files used for testing purposes from the pilot project global protein abundance dataset:

```
MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.raw
MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.raw
```

## PHOSPHO PROTEOME Test files

Two `raw` files used for testing purposes from the pilot project phospho protein abundance dataset:

```
MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03.raw MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03.raw
```

## Step 00: MASIC

Build Docker image (one time, or after a new version of MASIC is released):

```
docker build -t "biodavidjm:masic" .
```

Start the container:

```
docker run -v $PWD/data:/data:rw -v $PWD/parameters:/parameters:rw -it biodavidjm:masic /bin/bash
```

Run in container:

- GLOBAL
  
```
mono /app/masic/MASIC_Console.exe \
/I:/data/test_global/raw/*.raw \
/O:/data/test_global/masic_output/ \
/P:/parameters/TMT10_LTQ-FT_10ppm_ReporterTol0.003Da_2014-08-06.xml \
> /data/test_global/step00_masic.log
```

- PHOSPHO

```
mono /app/masic/MASIC_Console.exe \
/I:/data/test_phospho/raw/*.raw \
/O:/data/test_phospho/masic_output/ \
/P:/parameters/TMT10_LTQ-FT_10ppm_ReporterTol0.003Da_2014-08-06.xml \
> /data/test_phospho/step00_masic.log

```


## STEP 01: convert `.raw` to `.mzML` files

- Input directory/files: `/data/test_global/raw/*.raw`
- Run: [step01/convertRaw.sh](step01/convertRaw.sh)
- Output directory: `msgfplus_input/*.mzML`

## STEP 02: FULLY TRYPTIC SEARCH

Run on Docker MS-GF+ using the `.mzML` file from `msconvert` (step 1), get a `.mzid` file
  
Run MS-GF+ on Docker container (openjdk). Created a Dockerfile available in directory [`step02`](step02/Dockerfile).  

Build Docker image (one time, or after a new version of MS-GF+ is released):

```
docker build -t "biodavidjm:msgfplus" .
```

And start container:

```
docker run -v $PWD/data:/data:rw -v $PWD/parameters:/parameters:rw -it biodavidjm:msgfplus  /bin/bash
```

Run in docker: [step02/step02msgfplus_tryptic.sh](step02/step02msgfplus_tryptic.sh)

- Input directory/files: `/data/test_global/msgfplus_input/`
  + `*.mzML`
  +  `sequence_db.fasta` sequence db
  +  `MSGFPlus_Mods.txt` config file
- Output directory/file: `/data/test_global/msgfplus_output/*.mzid`


**ISSUE**: [Error] Cannot create folder `/data/msgfplus_output/filename.mzid`

**SUGGESTION**: Let MSGF+ create the output directory/file name by default

**FIX**: Release 2019.06.28 (commit [59a093c](https://github.com/MSGFPlus/msgfplus/commit/59a093c4a0ca999dc24cf289ccbf261e9511610a))

## Step 3:

### A) Run `msconvert` with the mzrefiner option to create a new `.mzML` file named `_FIXED.mzML`

[`step03/step03a.sh`](step03/step03a.sh)

**ISSUE**: msconvert ignores the path to the specified output directory

### B) Run `PPMErrorCharter` using the `.mzid` file from step 2a and the `_FIXED.mzML` file from step 3a

Build Docker image (only once)

```
cd step03/
docker build -t "biodavidjm:ppmerror" .
```

Start container:

```
docker run -v $PWD/data:/data:rw -v $PWD/parameters:/parameters:rw -it biodavidjm:ppmerror /bin/bash
```

Run in docker:

**test_global**

```
mono /app/PPMErrorCharterPython.exe \
-I:/data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzid \
-F:/data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_FIXED.mzML \
-EValue:1E-10 > /data/test_global/step03b.log

mono /app/PPMErrorCharterPython.exe \
-I:/data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02.mzid \
-F:/data/test_global/msgfplus_output/MoTrPAC_Pilot_TMT_W_S1_02_12Oct17_Elm_AQ-17-09-02_FIXED.mzML \
-EValue:1E-10 >> /data/test_global/step03b.log
```

**test_phospho**

```
mono /app/PPMErrorCharterPython.exe \
-I:/data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S1_01_DIL_28Oct17_Elm_AQ-17-10-03.mzid \
-EValue:1E-10 > /data/test_phospho/step03b.log

mono /app/PPMErrorCharterPython.exe \
-I:/data/test_phospho/msgfplus_output/MoTrPAC_Pilot_TMT_P_S2_01_3Nov17_Elm_AQ-17-10-03.mzid \
-EValue:1E-10 >> /data/test_phospho/step03b.log
```
 

## Step 4: Protein Identification and Quantification

Run MS-GF+ using the `_FIXED.mzml` file from Step 3: That creates a `.mzID` file (called it `Dataset_final.mzid`). 

Run the same docker container as in step02

```
docker run -v $PWD/data:/data:rw -v $PWD/parameters:/parameters:rw -it biodavidjm:msgfplus  /bin/bash
```

And execute: [step04/step04msgfplus.sh](step04/step04msgfplus.sh)


## Step 5: `MzidToTSVConverter`

Run MzidToTSVConverter to convert `Dataset_final.mzid` to `Dataset.tsv`

Build Docker image (one time, or after a new version of MzidToTsvConverter is released):

```
cd step05/
docker build -t "biodavidjm:mzid2tsv" .
```

Start container:

```
docker run -v $PWD/data:/data:rw -v $PWD/parameters:/parameters:rw -it biodavidjm:mzid2tsv /bin/bash
```

And run in docker: [step05/step05net462.sh](step05/step05net462.sh)


**ISSUE**: it does not create the output directory: "`Could not find a part of the path`". Can we change that?


## Step 6: `PeptideHitResultsProcRunner`

Run PeptideHitResultsProcRunner using the .tsv file from step 5:

Build Docker image (one time, or after a new version of PeptideHitResultsProcRunner is released):

```
cd step06/
docker build -t "biodavidjm:phrp" .
```

Start container:

```
docker run -v $PWD/data:/data:rw -v $PWD/parameters:/parameters:rw -it biodavidjm:phrp /bin/bash
```

And run in docker: [`step06/step06phrp.sh`](step06/step06phrp.sh)



## Step 7: AScore

Build:

```
cd step06/
docker build -t "biodavidjm:ascore" .
```

Start container:

```
docker run -v $PWD/data:/data:rw -v $PWD/parameters:/parameters:rw -it biodavidjm:ascore /bin/bash
```

```
mono AScore_Console.exe \
-T:msgfplus \
-F:Dataset_W_S2_Fr_04_2May17_msgfplus_syn.txt \
-D:Dataset_W_S2_Fr_04_2May17.mzML \
-P:AScore_CID_0.5Da_ETD_0.5Da_HCD_0.05Da.xml \
-U:Dataset_W_S2_Fr_04_2May17_msgfplus_syn_plus_ascore.txt \
-L:LogFile.txt
-Fasta:../H_sapiens_M_musculus_RefSeq_Excerpt.fasta
```



# Questions

- ~~Why is the MSGF+ version so old (v2017.08.23) (23 August 2017)? (which fails)~~: Matt: Use the latest version.
- How to resolve: `1000_collect_data.R` used to create `msgfData_original.RData`  (only works inside PNNL due to dependency on internal resources)


# Notes

`Mono` is used to run `MASIC` on Linux:

```
mono MASIC.exe /I:MoTrPAC_Pilot_TMT_x.raw /P:TMT10_LTQ-FT_10ppm_ReporterTol0.003Da_2014-08-06.xml
```
 
For `MSConvert.exe`, the Linux version is available [here](http://proteowizard.sourceforge.net/download.html). Example command line they have using docker:

```
docker run -it --rm -e WINEDEBUG=-all -v /your/data:/data chambm/pwiz-skyline-i-agree-to-the-vendor-licenses wine msconvert /data/file.raw
```

