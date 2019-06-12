

library(dplyr)

load("msgfData_psm_filtered.RData")

msgfData <- mutate(msgfData, isDecoy = grepl("^XXX", Protein),
                   cleanSeq = sub(".\\.(.*)\\..","\\1",Peptide))


#===============================================================================
library(Biostrings)
mySequences <- readAAStringSet("Rattus_norvegicus_UniProt_MoTrPAC_2017-10-20.fasta.gz")
prot_lengths <-
   data.frame(Protein = sub("^(\\S+)\\s.*","\\1",names(mySequences)),
              Length = width(mySequences),
              stringsAsFactors = FALSE)
prot_lengths <- mutate(prot_lengths, Protein = paste0("XXX_", Protein)) %>%
   rbind(prot_lengths, .)
#===============================================================================




pepN1000 <- select(msgfData, Protein, Peptide) %>%
   distinct %>%
   group_by(Protein) %>%
   summarise(pepN = n()) %>%
   inner_join(prot_lengths) %>%
   mutate(pep_per_1000 = 1000*pepN/Length,
          isDecoy = grepl("^XXX", Protein))


#====== viz of forward vs reverse ==============================================
library(ggplot2)
ggplot(pepN1000, aes(x = pep_per_1000, color=isDecoy, fill=isDecoy)) +
   geom_density(alpha=0.1) +
   scale_x_log10(breaks = signif(10^seq(0, log10(1000), by=0.5), 1)) +
   annotation_logticks(sides="b")

# it looks like threshold 5 is the right one

#===============================================================================


y <- filter(pepN1000, pep_per_1000 > 4.1) %>% 
   select(Protein) %>% 
   inner_join(msgfData)


# y <- filter(pepN1000, pepN > 3) %>% 
#    select(Protein) %>% 
#    inner_join(msgfData)


#=== peptide FDRs ===
msgfData %>% 
   select(cleanSeq, isDecoy) %>% 
   distinct %>% 
   group_by(isDecoy) %>% 
   summarise(cnt = n())
y %>% 
   select(cleanSeq, isDecoy) %>% 
   distinct %>% 
   group_by(isDecoy) %>% 
   summarise(cnt = n())
#===

#=== protein FDRs ===
msgfData %>% 
   select(Protein, isDecoy) %>% 
   distinct %>% 
   group_by(isDecoy) %>% 
   summarise(cnt = n())
y %>% 
   select(Protein, isDecoy) %>% 
   distinct %>% 
   group_by(isDecoy) %>% 
   summarise(cnt = n())
#===

msgfData <- y
save(msgfData, file="msgfData_prot_coverage_filtered.RData")


# checking number of peptides per protein
msgfData %>% select(Protein, cleanSeq) %>% distinct() %>%
   group_by(Protein) %>%
   summarise(PepPerProt = n()) %>%
   group_by(PepPerProt) %>%
   summarise(count = n()) %>%
   ggplot() +
   aes(x=PepPerProt, y=count) +
   geom_bar(stat="identity")



msgfData %>% select(Protein, cleanSeq) %>% distinct() %>%
   group_by(Protein) %>%
   summarise(PepPerProt = n()) %>%
   arrange(-PepPerProt)
