motrpac-proteomics-pnnl-prototype
===

___Testing implementation of PNNL pipeline on BIC infrastructure___


Initial documents provided by the PNNL with details of how to run the pipeline:

- [PIPELINE](docs/PIPELINE.md)
- [SOFTWARE_SOURCES](docs/SOFTWARE_SOURCES.md)
  
The [scripts](scripts/README.txt) directory contains additional files and scripts.

## Notes

To run MASIC on Linux you need to use Mono:

```
mono MASIC.exe /I:MoTrPAC_Pilot_TMT_x.raw /P:TMT10_LTQ-FT_10ppm_ReporterTol0.003Da_2014-08-06.xml
```
 
For `MSConvert.exe`, the Linux version is available at http://proteowizard.sourceforge.net/download.html though it looks like it requires Wine or Docker.
 

 ## Keep in mind: comments from the PNNL

Although all of our C#-based tools should work on Linux via mono, we have not thoroughly tested all of them (since we run the software on Windows).  The one exception is MS-GF+, which we do run on Linux (and Windows) in an automated fashion.


## Questions

- Why is the MSGF+ version so old (v2017.08.23) (23 August 2017)?
- How to resolve: `1000_collect_data.R` used to create `msgfData_original.RData`  (only works inside PNNL due to dependency on internal resources)


