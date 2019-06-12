
load("crossTab.RData")

library(dplyr)
library(tibble)

# tranform to tibble
x <- crossTab %>% 
   as.data.frame() %>% 
   rownames_to_column(var="ids") %>%
   # filter(!grepl("Contaminant", ids)) %>%
   filter(!grepl("XXX", ids)) %>%
   filter(grepl("_RAT", ids)) %>%
   # filter(grepl("\\*",ids)) %>%
   mutate(UniProtAccFull = sub("^.*\\|(.*)\\|(.*)$","\\1",ids)) %>%
   mutate(UniProtName = sub("^.*\\|(.*)\\|(.*)$","\\2",ids)) %>%
   mutate(UNIPROTKB = sub("^([^-]*)(-\\d+)?$","\\1",UniProtAccFull))

library(UniProt.ws)
up <- UniProt.ws(taxId=10116)
columns <- c("ENTREZ_GENE","GENES","UNIPROTKB")
kt <- "UNIPROTKB"
res <- select(up, unique(x$UNIPROTKB), columns, kt)
res2 <- res %>% 
   mutate(Gene = sub("^(\\S+).*$","\\1",GENES)) %>%
   dplyr::select(-GENES) %>%
   mutate(ENTREZ_GENE = as.numeric(ENTREZ_GENE)) %>%
   group_by(UNIPROTKB, Gene) %>% 
   summarise(ENTREZ_GENE = min(ENTREZ_GENE))


y <- inner_join(x, res2) %>%
   dplyr::select(-ids) %>%
   rename(EntrezGene = ENTREZ_GENE,
          UniProtAcc = UNIPROTKB) %>%
   dplyr::select(UniProtAccFull, UniProtAcc, UniProtName,
                 Gene, EntrezGene, everything())


write.table(y, file="rat_pilot_tmt_fractionated_global.txt", 
            quote=FALSE, sep='\t', na='', row.names = F)







