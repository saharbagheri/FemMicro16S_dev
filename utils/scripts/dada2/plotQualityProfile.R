suppressMessages(library(dada2))
suppressMessages(library(ggplot2))
suppressMessages(library(gridExtra))
suppressMessages(library(ShortRead))

filtFs = snakemake@input[['R1']]
filtRs = snakemake@input[['R2']]

#The number of records to sample from the fastq file.
nRecords= snakemake@config[['nRecords']]

exists <- file.exists(filtFs) & file.exists(filtRs)
filtFs <- filtFs[exists]
filtRs <- filtRs[exists]

#Removing the undetermined sample
filtFs <- filtFs[!grepl("Undetermined", filtFs)]
filtRs <- filtRs[!grepl("Undetermined", filtRs)]


# Create a function to count reads in a FASTQ file
count_reads <- function(file_path) {
  reads <- readFastq(file_path)
  return(length(reads))
}


# Iterate through the list of FASTQ files and count reads
valid_filtFs <- character(0)  # To store valid file paths

for (file_path in filtFs) {
  read_count <- count_reads(file_path)
  if (read_count > 0) {
    valid_filtFs <- c(valid_filtFs, file_path)
  } else {
    print(paste("File:", file_path, "has zero reads and will be disregarded.\n"))
  }
}


# Iterate through the list of FASTQ files and count reads
valid_filtRs <- character(0)  # To store valid file paths

for (file_path in filtRs) {
  read_count <- count_reads(file_path)
  if (read_count > 0) {
    valid_filtRs <- c(valid_filtRs, file_path)
  } else {
    print(paste("File:", file_path, "has zero reads and will be disregarded.\n"))
  }
}


p_F<- plotQualityProfile(valid_filtFs,n=nRecords,aggregate=T) + 
  theme_classic(base_size = 10) +  # Increase base size for classic theme
  theme(
    axis.title = element_text(size = 14),  # Increase size of axis titles
    axis.text = element_text(size = 12),   # Increase size of axis text
    legend.title = element_text(size = 14),# Increase size of legend title
    legend.text = element_text(size = 12), # Increase size of legend text
    strip.text = element_text(size = 16)   # Increase size of strip text (facet labels)
  )


print("Out of plotQualityProfile R1")


ggsave(snakemake@output$R1,p_F)


p_R<- plotQualityProfile(valid_filtRs,n=nRecords,aggregate=T)+ 
  theme_classic(base_size = 10) +  # Increase base size for classic theme
  theme(
    axis.title = element_text(size = 14),  # Increase size of axis titles
    axis.text = element_text(size = 12),   # Increase size of axis text
    legend.title = element_text(size = 14),# Increase size of legend title
    legend.text = element_text(size = 12), # Increase size of legend text
    strip.text = element_text(size = 16)   # Increase size of strip text (facet labels)
  )


print("Out of plotQualityProfile R2")

ggsave(snakemake@output$R2,p_R)
print("Out of saving Quality profiles")

                   

