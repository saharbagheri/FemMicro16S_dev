#!/usr/bin/env Rscript
suppressMessages(library(dada2))

# Load the per-sample results
ddF=lapply(snakemake@input[["ddF"]], readRDS)
ddR=lapply(snakemake@input[["ddR"]], readRDS)
derepF=lapply(snakemake@input[["derepF"]], readRDS)
derepR=lapply(snakemake@input[["derepR"]], readRDS)


names(ddF)<-gsub("ddF_","",sub("\\.rds$", "",basename(snakemake@input[["ddF"]]), ignore.case = TRUE))
names(ddR)<-sub("\\.rds$", "",basename(snakemake@input[["ddR"]]), ignore.case = TRUE)
names(derepF)<-sub("\\.rds$", "",basename(snakemake@input[["derepF"]]), ignore.case = TRUE)
names(derepR)<-sub("\\.rds$", "",basename(snakemake@input[["derepR"]]), ignore.case = TRUE)

mergers <- mergePairs(ddF, derepF, ddR, derepR)

# Build the final sequence table from all samples
seqtab.all <- makeSequenceTable(mergers)

# Save the sequence table
saveRDS(seqtab.all, snakemake@output[["seqtab"]])

# Function to count the unique reads
getNreads <- function(x) sum(getUniques(x))


# Create a tracking matrix (rows for samples; columns for "denoised" and "merged")
track <- cbind(sapply(ddF, getNreads), sapply(mergers, getNreads))
colnames(track) <- c("denoised", "merged")

# Write the tracking info to a file
write.table(track, snakemake@output[["nreads"]], sep="\t", quote=FALSE)
