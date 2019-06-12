
library(magrittr)
library(knitr)
library(dplyr)
library(tibble)
library(tidyr)
library(ggplot2)

load("quantData.RData")

intens <- quantData %>%
   select(-MixID) %>%
   group_by(Specie) %>%
   summarise_all(funs(sum)) %>%
   gather(reporter,value,-Specie) %>%
   filter(value > 0)

ggplot(intens, aes(x=value)) +
   geom_histogram() +
   scale_x_log10() +
   facet_wrap(~reporter, nrow = 2) +
   ggtitle("distribution of reporter ion intensity values")

f <- function(x) {
   r <- quantile(x, probs = c(0.005, 0.05, 0.5, 0.95, 0.995))
   names(r) <- c("ymin", "lower", "middle", "upper", "ymax")
   r
}
ggplot(intens, aes(x=reporter, y=value)) +
   scale_y_log10() +
   stat_summary(fun.data = f, geom="boxplot", position="dodge") +
   ggtitle("distribution of reporter ion intensity values") +
   theme(axis.text.x = element_text(angle=45, hjust = 1))


intens %>%
   group_by(reporter) %>%
   summarise("top 99.5%" = quantile(value,probs=0.995),
             "bottom 0.5%" = quantile(value,probs=0.005),
             "99% IQR" = `top 99.5%`/`bottom 0.5%`) %T>%
   kable() %>%
   .$`99% IQR` %>%
   mean
