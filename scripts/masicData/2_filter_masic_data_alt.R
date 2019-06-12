
load("masicData_original.RData")

library(dplyr)
library(tidyr)

s2n_min_threshold = 4
interference_score_threshold = 0.90

# retain only those MS2 scans that do not have much interference at MS1 levels
masicData <- masicData %>%
   filter(InterferenceScore > interference_score_threshold)

selected <- masicData %>%
   select(Dataset, ScanNumber, contains("SignalToNoise")) %>%
   gather(channel, s2n, -c(Dataset, ScanNumber)) %>%
   mutate(s2n = ifelse(is.na(s2n), 0, s2n)) %>% # impute NA with 0 values
   # group_by(Dataset, ScanNumber) %>%
   # summarise(s2n_min = min(s2n)) %>%
   filter(s2n > s2n_min_threshold) %>% # key filter step
   select(-s2n) %>%
   mutate(channel = sub("_SignalToNoise","",channel))
# QC viz
selected %>% group_by(Dataset, ScanNumber) %>% summarise(n = n()) %>% .$n %>% table %>% barplot

# linked filtered Dataset/ScanNumber/channel
masicData <- masicData %>%
   select(Dataset, ScanNumber, starts_with("Ion"), -contains("SignalToNoise")) %>%
   gather(channel,intensity,-c(Dataset,ScanNumber)) %>%
   inner_join(selected) %>%
   spread(channel, intensity)

save(masicData, file="masicData_filtered.RData", compress = 'xz')

