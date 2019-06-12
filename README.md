motrpac-proteomics-pnnl-prototype
===

___Testing implementation of PNNL pipeline on BIC infrastructure___


Initial documents provided by the PNNL (converted to `md` format by the BIC) with details of the pipeline:

- [PIPELINE](docs/PIPELINE.md)
- [SOFTWARE_SOURCES](docs/SOFTWARE_SOURCES.md)
  
The [scripts](scripts/README.txt) directory contains additional files and scripts.

## Notes

`Mono` is used to run `MASIC` on Linux:

```
mono MASIC.exe /I:MoTrPAC_Pilot_TMT_x.raw /P:TMT10_LTQ-FT_10ppm_ReporterTol0.003Da_2014-08-06.xml
```
 
For `MSConvert.exe`, the Linux version is available at http://proteowizard.sourceforge.net/download.html though it looks like it requires Wine or Docker.

The ProteoWizard/Skyline projects now have a Wine/Docker 64-bit image that permits running `msconvert`, `skyline`, and other tools on Linux, supporting most current vendor formats. There are examples on using it and the command to download it to a docker instance at https://hub.docker.com/r/chambm/pwiz-skyline-i-agree-to-the-vendor-licenses
 
The example command line they have for msconvert:

```
docker run -it --rm -e WINEDEBUG=-all -v /your/data:/data chambm/pwiz-skyline-i-agree-to-the-vendor-licenses wine msconvert /data/file.raw
```
 

 ## Keep in mind: comments from the PNNL

Although all of our `C#`-based tools should work on Linux via `mono`, PNNL team has not thoroughly tested all of them (since they run the software on Windows).  The one exception is `MS-GF+`, which they do run on Linux (and Windows) in an automated fashion.


## Questions

- Why is the MSGF+ version so old (v2017.08.23) (23 August 2017)?
- How to resolve: `1000_collect_data.R` used to create `msgfData_original.RData`  (only works inside PNNL due to dependency on internal resources)


