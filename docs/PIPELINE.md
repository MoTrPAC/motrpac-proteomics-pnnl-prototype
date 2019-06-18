PIPELINE
===



## 1. MZML CONVERSION

**SOFTWARE**: `MSConvert (Proteowizard)`

```
MSConvert.exe MoTrPAC_Pilot_TMT_x.raw --filter "peakPicking true 1-" --mzML --32 --outfile MoTrPAC_Pilot_TMT_x.mzML
```

**INPUT**: files in directory `pilot_data_global_20190110/raw/`

**OUTPUT**: `.mzML files` (tracked in-house)

## 2. MS-GF+ FULLY TRYPTIC SEARCH

### SOFTWARE: MS-GF+ (v2017.08.23) (23 August 2017)

```
java.exe -Xmx4000M -jar MSGFPlus.jar -s MoTrPAC_Pilot_TMT_x.mzML -o MoTrPAC_Pilot_TMT_x_msgfplus.mzid -d ID_006404_2D994010.fasta  -t 50ppm -m 0 -inst 3 -e 1 -ti -1,2 -ntt 2 -tda 1 -minLength 6 -maxLength 50 -n 1 -protocol 1 -thread 7 -mod MSGFPlus_Mods.txt -minNumPeaks 5 -addFeatures 1
```

**INPUT**:
- `.mzML` files from step 1 (tracked in-house)
- `pilot_data_global_20190110/processed/msgfplus_mzRefinery_input/MSGFPlus_Mods.txt` **QUESTION**: what does it mean?
-  `pilot_data_global_20190110/processed/msgfplus_mzRefinery_input/ID_006404_2D994010.fasta`: this is a decoy FASTA created by combining `Rattus_norvegicus_UniProt_MoTrPAC_2017-10-20.fasta` and `Tryp_Pig_Bov.fasta`

**OUTPUT**: `.mzid` files (tracked in-house)

## 3a. MZ_REFINERY IN-SILICO MASS ERROR CORRECTION

**SOFTWARE**: `MSConvert (Proteowizard)`

```
msconvert.exe MoTrPAC_Pilot_TMT_x.mzML --outfile MoTrPAC_Pilot_TMT_x_FIXED.mzML --filter "mzRefiner MoTrPAC_Pilot_TMT_x_msgfplus.mzid thresholdValue=-1e-10 thresholdStep=10 maxSteps=2" --32 --mzML
```

**INPUT**:  

`.mzML` files from step 2 

MS-GF+ search results (.mzid files) from step 2

**OUTPUT**:  

- `.mzML` files with updated m/z values for data in MS1 and MS2 spectra, and also updated parent ion m/z values (tracked in-house)

- `QC graphics` in directory `pilot_data_global_20190110/processed/msgfplus_mzRefinery_output` (two png files per dataset)

## 3b. MZ_REFINERY ERROR CORRECTION CHARTS (Optional) 

**SOFTWARE**: PPMErrorCharter v1.1.7068 (9 May 2019)
  
```
PPMErrorCharter.exe MoTrPAC_Pilot_TMT_x_msgfplus.mzid 1E-10
```

**INPUT**:  

- `.mzid` file from step 2
- `MoTrPAC_Pilot_TMT_x_FIXED.mzml` from step 3a

**OUTPUT**:  

- Two .png files, named `Dataset_MZRefinery_MassErrors.png` and `Dataset_MZRefinery_Histograms.png`

- NOTE: For PPMErrorCharter, the default mode is to create the plots using OxyPlot. 

Alternatively, use the /Python switch, which creates similar plots using the PPMErrorCharter_Plotter.py script.

## 4. PROTEIN IDENTIFICATION AND QUANTIFICATION

**SOFTWARE**: MS-GF+ (v2018.04.09) (9 April 2018)

```
java.exe -Xmx4000M \
        -jar MSGFPlus.jar \
        -s MoTrPAC_Pilot_TMT_x.mzML \
        -o MoTrPAC_Pilot_TMT_x_msgfplus.mzid \
        -d ID_007275_FB1B42E8.fasta  \
        -t 20ppm -m 0 -inst 3 -e 1 -ti -1,2 -ntt 1 -tda 1 \
        -minLength 6 -maxLength 50 -minCharge 2 -maxCharge 5 \
        -n 1 -protocol 1 -thread 7 \
        -mod MSGFPlus_Mods.txt \
        -minNumPeaks 5 \
        -addFeatures 1
```


**INPUT**:  

- `.mzML` output files from step 3

- `pilot_data_global_20190110/processed/msgfplus_input/MSGFPlus_Mods.txt`
         
- pilot_data_global_20190110/processed/msgfplus_input/ID_007275_FB1B42E8.fasta: this is a decoy FASTA created by combining `Rattus_norvegicus_NCBI_RefSeq_2018-04-10.fasta` and `Tryp_Pig_Bov.fasta`


**OUTPUT**:  .mzid files in directory pilot_data_global_20190110/processed/msgfplus_output/



## 5. REPORTER ION EXTRACTION
  
**SOFTWARE**: MASIC v2.8.6507
MASIC.exe /I:MoTrPAC_Pilot_TMT_x.raw /P:TMT10_LTQ-FT_10ppm_ReporterTol0.003Da_2014-08-06.xml

**INPUT**:  files in directory pilot_data_global_20190110/raw/
TMT10_LTQ-FT_10ppm_ReporterTol0.003Da_2014-08-06.xml in directory pilot_data_global_20190110/processed/MASIC_input

**OUTPUT**:  files in directory pilot_data_global_20190110/processed/MASIC_output/



## 6. RELATIVE QUANTIFICATION

**SOFTWARE**: 

**.R files in scripts/masicData:**

- `0_get_extended_masic_data.R` to create masicData_original.RData (only works inside PNNL due to dependency on internal resources)
- `1_itraq_name_coding.R` to create `isobaricTagDesign.RData`
- `2_filter_masic_data_alt.R` to create `masicData_filter.RData`

**.R files in scripts/msmsData**

- `1000_collect_data.R`: to create msgfData_original.RData  (only works inside PNNL due to dependency on internal resources)
- `2000_filter_msgf.R`: to create `msgfData_psm_filtered.RData` using `msgfData_original.RData`
- `2500_protein_coverage_filter_calibration.R` to create `msgfData_prot_coverage_filtered.RData` using `msgfData_psm_filtered.RData`
- `3000_inference.R` to create `protein_inference.RData` using `msgfData_prot_coverage_filtered.RData`
- `4000_parsimonial_msgf.R` to create `msgfData_filtered_final.RData` using `protein_inference.RData` and `msgfData_prot_coverage_filtered.RData`

**.R files in scripts/quant**

- `1_link_msms_masic.R`: to create `quantData.RData` using `msgfData_filtered_final.RData` and `masicData_filter.RData`
- `2_aggregation.R` updates `quantData.RData` using `isobaricTagDesign.RData`
- `3_quant_handling.R` to create `crossTab.RData` using `quantData.RData` and `isobaricTagDesign.RData`
- `4_derive_norm_coeff.R` to create `norm.coeff.RData` using `crossTab.RData`
- `5_normalize.R` updates `crossTab.RData` using `norm.coeff.RData`
- `6_filter_export_add_gene.R`  to create `rat_pilot_tmt_fractionated_global.txt` using `crossTab.RData`

**INPUT**:  

- tab-delimited files created from the `.mzid.gz` files in directory `pilot_data_global_20190110/processed/msgfplus_output/`
- `_ReporterIons.txt` files in directory `pilot_data_global_20190110/processed/MASIC_output/`
- `_SICstats.txt` files in directory `pilot_data_global_20190110/processed/MASIC_output/`
- `pre_isobaricTagSamples.txt` in directory `pilot_data_global_20190110/processed/quantification_input/`: defines TMT channels
- `Rattus_norvegicus_UniProt_MoTrPAC_2017-10-20.fasta` (as a `.gz` file) from directory `proteinFASTA`

**OUTPUT**:  

- `rat_pilot_tmt_fractionated_global.txt` in directory `pilot_data_global_20190110/processed/quantification/output/`
- Quantitation values are log-2 normalized ratios of fold-change vs. the reference channel.
-  Ratios are computed by summing reporter ion intensities up to the protein level, then dividing by the reference channel intensity.
