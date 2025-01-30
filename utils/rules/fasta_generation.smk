rule fasta_file:
    input:
        seqtab =rules.removeChimeras.output.rds
    output:
        seqfasta=config["output_dir"]+"/fasta_files/ASVs_seqs.fasta"
    threads:
        config['threads']
    conda:
        "dada2_new"
    script:
        "../scripts/dada2/fastaGeneration.R"
