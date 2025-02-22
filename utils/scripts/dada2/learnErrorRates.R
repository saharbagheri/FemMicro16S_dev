suppressMessages(library(dada2))
suppressMessages(library(ggplot2))

R1= as.vector(snakemake@input[['R1']])
R2= as.vector(snakemake@input[['R2']])

neg_samples <- unlist(base::strsplit(snakemake@params[['neg']], split = "\\|"))

message("Number of sample listed as negative: ", length(neg_samples))


#Reading in negative samples to exclude them from the list of samples
if (length(neg_samples) > 0) {
  R1_files <- R1[!(sub("_R.*", "", sub(".*/", "", R1)) %in% neg_samples)]
  R2_files <- R2[!(sub("_R.*", "", sub(".*/", "", R2)) %in% neg_samples)]
  message("Number of samples after excluding negative samples: ", length(R2_files))
} else {
  R1_files <- R1
  R2_files <- R2
  message("No negative samples were provided.")
}


errF <- learnErrors(R1_files, nbases=snakemake@config[["learn_nbases"]], multithread=snakemake@threads)
errR <- learnErrors(R2_files, nbases=snakemake@config[["learn_nbases"]], multithread=snakemake@threads)

save(errF,file=snakemake@output[['errR1']])
save(errR,file=snakemake@output[['errR2']])


## ---- plot-rates ----
p<-plotErrors(errF,nominalQ=TRUE)
ggsave(snakemake@output[['plotErr1']],plot=p)

p<-plotErrors(errR,nominalQ=TRUE)
ggsave(snakemake@output[['plotErr2']],plot=p)
