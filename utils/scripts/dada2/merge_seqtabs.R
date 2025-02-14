#!/usr/bin/env Rscript
suppressMessages(library(dada2))

# Load the per-sample results (each a list containing 'ddF' and 'merger')
mergers <- lapply(snakemake@input[["seqtabs"]], readRDS)

names(mergers) <- sapply(mergers, function(mat) rownames(mat)[1])


# Extract ddF objects (for tracking read counts)
#dadaFs <- lapply(snakemake@input[["ddFs"]], readRDS)

dadaFs <- lapply(snakemake@input[["ddFs"]], function(f) {
  obj <- readRDS(f)
  obj[[1]]
})

print(rownames(dadaFs[[1]]))
print(rownames(dadaFs[[2]]))


# Build the final sequence table from all samples
seqtab.all <- makeSequenceTable(mergers)

# Save the sequence table
saveRDS(seqtab.all, snakemake@output[["seqtab"]])

# Function to count the unique reads
getNreads <- function(x) sum(getUniques(x))


# Create a tracking matrix (rows for samples; columns for "denoised" and "merged")
track <- cbind(sapply(dadaFs, getNreads), sapply(mergers, getNreads))
colnames(track) <- c("denoised", "merged")

# Write the tracking info to a file
write.table(track, snakemake@output[["nreads"]], sep="\t", quote=FALSE)
