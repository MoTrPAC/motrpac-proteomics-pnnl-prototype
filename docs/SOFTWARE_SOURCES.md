# Software Sources

## MSConvert (Proteowizard)

For conversion from `.raw` files to `.mzML` files, I believe you need to run the Windows build of `MSConvert.exe `via `Wine` (and possibly via `mono`), since it uses 
Windows specific DLLs from Thermo to read the `.raw` files.  
Bryson Gibbons is exploring options for this.

http://proteowizard.sourceforge.net/download.html

Linux Wine/Docker 64-bit

Following the MS-GF+ tryptic search (step 2 in [PIPELINE](../docs/PIPELINE.md)) you use MSConvert to run MZ_Refinery (aka mzRefiner).  

For that, you can use the Linux specific build of `MSConvert`, since it's reading and writing `mzML` files
http://proteowizard.sourceforge.net/download.html

Linux Native 64-bit

`MSConvert` source code:
https://github.com/ProteoWizard/pwiz


## MS-GF+

- Releases (.jar file): https://github.com/MSGFPlus/msgfplus/releases
- Source code: https://github.com/MSGFPlus/msgfplus
- Requirements: java


## PPM Error Charter

- Releases: https://github.com/PNNL-Comp-Mass-Spec/PPMErrorCharter/releases/
- Source: https://github.com/PNNL-Comp-Mass-Spec/PPMErrorCharter
- Requirements: mono (https://www.mono-project.com/)


## MASIC

- Releases: https://github.com/PNNL-Comp-Mass-Spec/MASIC/releases
- Source: https://github.com/PNNL-Comp-Mass-Spec/MASIC
- Requirements: mono (https://www.mono-project.com/)

Note: Although MASIC.exe is a GUI application, it also has a command line interface, as shown in step 5 in PIPELINE.txt
      As of May 2019, we are working on a console only version that will support .mzML files 
      (though it is still advised to process .raw files with MASIC since more information can be extracted from them).


## AScore Console

- Releases: https://github.com/PNNL-Comp-Mass-Spec/AScore/releases
- Source: https://github.com/PNNL-Comp-Mass-Spec/AScore
- Requirements: mono (https://www.mono-project.com/)


## R Scripts for Downstream Processing

Available at the [script folder](../scripts/README.md)
