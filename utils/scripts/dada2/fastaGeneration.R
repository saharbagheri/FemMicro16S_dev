suppressMessages(library(dada2))
suppressMessages(library(DECIPHER))

seqtab = readRDS(snakemake@input[['seqtab']])

seqs <- colnames(seqtab)

names(seqs) <- seqs 

seq_stringset<-DNAStringSet(seqs)

writeXStringSet(seq_stringset,snakemake@output[['seqfasta']])

print("ASV sequences written to FASTA file")
