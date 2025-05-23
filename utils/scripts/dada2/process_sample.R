#!/usr/bin/env Rscript
suppressMessages(library(dada2))

# Get the sample name (if needed for logging)
sam <- snakemake@wildcards[["sample"]]
cat("Processing sample:", sam, "\n")

# Read in the filtered reads for this sample
filtF <- snakemake@input[["R1"]]
filtR <- snakemake@input[["R2"]]


# Load the error models (these are assumed to be created already)
load(snakemake@input[["errR1"]])  # loads object `errF`
load(snakemake@input[["errR2"]])  # loads object `errR`

mergers <- vector("list", length(sam))
dadaFs <- vector("list", length(sam))

names(mergers) <- sam
names(dadaFs) <- sam

names(filtF) <- sam
names(filtR) <- sam

# Dereplicate and run DADA2 on the forward and reverse reads
set.seed(100)

derepF <- derepFastq(filtF)
ddF <- dada(derepF, err = errF, multithread = snakemake@threads)

dadaFs[[sam]] <- ddF

derepR <- derepFastq(filtR)
ddR <- dada(derepR, err = errR, multithread = snakemake@threads)

saveRDS(ddF, snakemake@output[["ddF"]])
saveRDS(ddR, snakemake@output[["ddR"]])
saveRDS(derepF, snakemake@output[["derepF"]])
saveRDS(derepR, snakemake@output[["derepR"]])
