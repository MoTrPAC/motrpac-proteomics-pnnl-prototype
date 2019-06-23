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

Docker 1: Docker with python and mono pre-installed

```
docker pull jonemo/pythonnet:python3.6.4-mono5.4.1.6-pythonnet2.4.0.dev0
docker run -v $PWD/data:/data:rw -it jonemo/pythonnet:python3.6.4-mono5.4.1.6-pythonnet2.4.0.dev0 /bin/bash
```

```
apt-get update
apt-get install unzip
pip install --upgrade pip
python3.6 -m pip install matplotlib
python3.6 -m pip install pandas
mkdir app
cd app && wget https://github.com/PNNL-Comp-Mass-Spec/PPMErrorCharter/releases/download/v1.2.7111/PPMErrorCharterPython_Program.zip
unzip PPMErrorCharterPython_Program.zip
ln -s /usr/local/bin/python3 /usr/bin/python3
mono PPMErrorCharterPython.exe -I:/data/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzid -EValue:1E-10

```

Output

```
mono PPMErrorCharterPython.exe -I:/data/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzid -EValue:1E-10
PPMErrorCharter, version 1.2.7111.20545 (June 21, 2019)

Using options:
 PSM results file: /data/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzid
 Spec EValue threshold: 1.0E-10
 PPM Error histogram bin size: 0.5
 Generating plots with OxyPlot

Creating plots for "MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02.mzid"
  Using fixed data file "/data/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_FIXED.mzML"

Loading data from the .mzid file
  6,290 PSMs passed the filters

Loading data from MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_FIXED.mzML
  25% complete
  54% complete
  82% complete

	Statistic                   Original    Refined
	MeanMassErrorPPM:              2.207      0.143
	MedianMassErrorPPM:            2.035     -0.001
	StDev(Mean):                   2.961      2.941
	StDev(Median):                 2.966      2.944
	PPM Window for 99%: 0 +/-     10.932      8.834
	PPM Window for 99%: high:     10.932      8.833
	PPM Window for 99%:  low:     -6.863     -8.834

Using data points with original and refined MassError between -0.2 and 0.2 Da
Using data points with original and refined PpmError between -50 and 50 ppm

Removed 0 out-of-range items from the original 6,290 items.

  Assuming Python 3 is at /usr/bin/python3

  /usr/bin/python3 /app/PPMErrorCharter_Plotter.py /data/MZRefinery_Plotting_Metadata.txt
Reading metadata file: /data/MZRefinery_Plotting_Metadata.txt

Reading MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_Histograms_TmpExportData.txt
Reading MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_MassErrorsVsTime_TmpExportData.txt
Reading MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_MassErrorsVsMass_TmpExportData.txt

Output: MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_MZRefinery_Histograms.png

Plot "Mass error (PPM)" vs. "Original: Counts"
  87 data points

Mass error histogram created

Output: MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_MZRefinery_MassErrors.png

Plot "Scan Time (minutes)" vs. "Original: Mass Error (PPM)" and
Plot "m/z" vs. "Original: Mass Error (PPM)"
  6,290 data points
  6,290 data points

Mass error trend plot created
Generated plots; see:
  /data/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_Histograms.png
and
  /data/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02/MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_MassErrors.png
Processing completed successfully
```

![MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_MZRefinery_MassErrors](https://user-images.githubusercontent.com/6676074/59978326-1b751d00-9590-11e9-8a50-f605e0e97f91.png)

![MoTrPAC_Pilot_TMT_W_S1_01_12Oct17_Elm_AQ-17-09-02_MZRefinery_Histograms](https://user-images.githubusercontent.com/6676074/59978342-3778be80-9590-11e9-8131-b67799948ebe.png)



**Test passed** BUT results might be wrong.


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

