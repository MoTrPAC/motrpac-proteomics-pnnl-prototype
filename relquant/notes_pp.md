# Notes

## PlexedPiper

```
> library(PlexedPiper)
Loading required package: MSnID
Loading required package: Rcpp
The R.cache package needs to create a directory that will hold cache files. It is convenient to use one in the user's home directory, because it remains also after restarting R. Do you wish to create the '~/.Rcache' directory? If not, a temporary directory (/tmp/RtmpkSGNzB/.Rcache) that is specific to this R session will be used. [Y/n]:

```

Another step asking to create a directory:

```
> msnid <- remap_accessions_refseq_to_gene(msnid,
+                                          organism_name="Rattus norvegicus")
/root/.cache/AnnotationHub
  does not exist, create directory? (yes/no):
```

Is a hardcopy of the refseq a good idea?

```
path_to_FASTA <- system.file(
   "extdata/Rattus_norvegicus_NCBI_RefSeq_2018-04-10.fasta.gz",
   package = "PlexedPiperTestData")
```

Remapping to the 
- We should also keep track of isoforms, given the number of tissues that we are looking at
- It gets a lot of messages...

```
> msnid <- remap_accessions_refseq_to_gene(msnid,
+                                          organism_name="Rattus norvegicus")
/root/.cache/AnnotationHub
  does not exist, create directory? (yes/no): yes
  |======================================================================| 100%

snapshotDate(): 2019-10-29
downloading 1 resources
retrieving 1 resource
  |======================================================================| 100%

loading from cache
    ‘AH75745 : 82491’
Loading required package: AnnotationDbi
Loading required package: stats4
Loading required package: BiocGenerics
Loading required package: parallel

Attaching package: ‘BiocGenerics’

The following objects are masked from ‘package:parallel’:

    clusterApply, clusterApplyLB, clusterCall, clusterEvalQ,
    clusterExport, clusterMap, parApply, parCapply, parLapply,
    parLapplyLB, parRapply, parSapply, parSapplyLB

The following objects are masked from ‘package:stats’:

    IQR, mad, sd, var, xtabs

The following objects are masked from ‘package:base’:

    anyDuplicated, append, as.data.frame, basename, cbind, colnames,
    dirname, do.call, duplicated, eval, evalq, Filter, Find, get, grep,
    grepl, intersect, is.unsorted, lapply, Map, mapply, match, mget,
    order, paste, pmax, pmax.int, pmin, pmin.int, Position, rank,
    rbind, Reduce, rownames, sapply, setdiff, sort, table, tapply,
    union, unique, unsplit, which, which.max, which.min

Loading required package: Biobase
Welcome to Bioconductor

    Vignettes contain introductory material; view with
    'browseVignettes()'. To cite Bioconductor, see
    'citation("Biobase")', and for packages 'citation("pkgname")'.

Loading required package: IRanges
Loading required package: S4Vectors

Attaching package: ‘S4Vectors’

The following object is masked from ‘package:base’:

    expand.grid

'select()' returned many:1 mapping between keys and columns
```

How do they pass from many:1 mappings to...

```
> path_to_FASTA_gene <- remap_accessions_refseq_to_gene_fasta(
+    path_to_FASTA, organism_name="Rattus norvegicus")
snapshotDate(): 2019-10-29
downloading 0 resources
loading from cache
    ‘AH75745 : 82491’
'select()' returned 1:1 mapping between keys and columns
```

Inference of parsimonious protein set step

Is the best approach to select the unique_only?
Perhaps a good approach is the "protein groups" method by MaxQuant.
Anyway, could we keep track of the number o proteins affected?

Removing decoys

```
> show(msnid)
MSnID object
Working directory: "."
#Spectrum Files:  48
#PSMs: 349214 at 0.18 % FDR
#peptides: 80616 at 0.29 % FDR
#accessions: 4928 at 1 % FDR

> msnid <- apply_filter(msnid, "!isDecoy")

> show(msnid)
MSnID object
Working directory: "."
#Spectrum Files:  48
#PSMs: 348598 at 0 % FDR
#peptides: 80383 at 0 % FDR
#accessions: 4877 at 0 % FDR
```

MASIC filtering:

Would like to understand this step:

```
> nrow(masic_data)
[1] 1598123
> masic_data <- filter_masic_data(masic_data, 0.5, 0)
> nrow(masic_data)
[1] 1523732
```

For fractions.txt and samples.txt

```
more ./usr/local/lib/R/site-library/PlexedPiperTestData/extdata/study_design/samples.txt
PlexID  QuantBlock  ReporterName    ReporterAlias   MeasurementName
```

What is the QuantBlock


