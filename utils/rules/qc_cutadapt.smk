rule fastqcRaw:
    input:
        unpack(lambda wc: dict(list_files.loc[wc.sample]))
    output:
        R1= config["output_dir"] + "/fastqc_raw/{sample}" + config["forward_read_suffix"] + "_fastqc.html",
        R2= config["output_dir"] + "/fastqc_raw/{sample}" + config["reverse_read_suffix"] + "_fastqc.html"
    resources:
        tmpdir=temp(directory(config["output_dir"] + "/fastqc_raw/tmp/"))
    conda:
        "QC"
    params:
        output=directory(config["output_dir"]+ "/fastqc_raw")
    shell: "fastqc -o {params.output} -d {resources.tmpdir} {input.R1} {input.R2} "




rule multiqcRaw:
    input:
        R1 =expand(config["output_dir"]+"/fastqc_raw/{sample}" + config["forward_read_suffix"] +"_fastqc.html",sample=SAMPLES),
        R2 =expand(config["output_dir"]+"/fastqc_raw/{sample}" + config["reverse_read_suffix"] +"_fastqc.html",sample=SAMPLES)
    output:
        config["output_dir"]+"/multiqc_raw/multiqc_report_raw.html"
    conda:
        "QC"
    params:
        fastqc_dir=config["output_dir"]+"/fastqc_raw",
        multiqc_dir=config["output_dir"]+"/multiqc_raw",
        multiqc_html="multiqc_report_raw.html"
    shell: 
        "multiqc -f {params.fastqc_dir} -o {params.multiqc_dir} -n {params.multiqc_html} "



rule cutAdapt:
    input:
        R1=rules.filterNsRaw.output.R1,
        R2=rules.filterNsRaw.output.R2
    output:
        R1= config["output_dir"]+"/cutadapt/{sample}" + config["forward_read_suffix"] + config["compression_suffix"],
        R2= config["output_dir"]+"/cutadapt/{sample}" + config["reverse_read_suffix"] + config["compression_suffix"]
    params:
        m=config["min_len"],
        o=config["min_overlap"],
        e=config["max_e"]
    threads:
        config["threads"]
    conda:
        "QC"
    shell:
        """
        if [[ "{config[primer_removal]}" == "True" ]]; then
            cutadapt -m {params.m} -O {params.o} -e {params.e} --discard-untrimmed \
                -g {config[fwd_primer]} -G {config[rev_primer]} -a {config[rev_primer_rc]} -A {config[fwd_primer_rc]} \
                -o {output.R1} -p {output.R2} \
                {input.R1} {input.R2}
        else
            touch {output.R1} {output.R2}
            echo "Rule 'cutAdapt' is not executed because 'primer_removal' is set to 'false' in the config file."
        fi
        """




rule primerRMVinvestigation:
    input:
        R1= expand(config["output_dir"]+"/filtN/{sample}" + config["forward_read_suffix"] + config["compression_suffix"],sample=SAMPLES),
        R2= expand(config["output_dir"]+"/filtN/{sample}" + config["reverse_read_suffix"] + config["compression_suffix"],sample=SAMPLES),
        cut1= expand(config["output_dir"]+"/cutadapt/{sample}" + config["forward_read_suffix"] + config["compression_suffix"],sample=SAMPLES),
        cut2= expand(config["output_dir"]+"/cutadapt/{sample}" + config["reverse_read_suffix"] + config["compression_suffix"],sample=SAMPLES)
    params:
        dir=config["output_dir"]+"/primer_status/"
    output:
        primer_status_bf=config["output_dir"]+"/primer_status/primer_existance_raw.csv",
        primer_status_af=config["output_dir"]+"/primer_status/primer_existance_trimmed.csv"
    conda:
        "dada2_new"
    script:
        "../scripts/dada2/primer_investigation.R"





rule cutAdaptQc:
    input:
        rules.cutAdapt.output if config.get("primer_removal", True) else (unpack(lambda wc: dict(list_files.loc[wc.sample])),)
    output:
        R1= config["output_dir"]+"/cutadapt_qc/{sample}" + config["forward_read_suffix"] + config["compression_suffix"],
        R2= config["output_dir"]+"/cutadapt_qc/{sample}" + config["reverse_read_suffix"] + config["compression_suffix"]
    params:
        nextseqTrim=config["nextseqTrim"],
        m=config["min_len"]
    threads:
        config['threads']
    conda:
        "QC"
    shell:
        "cutadapt --nextseq-trim={params.nextseqTrim} -m {params.m} -o {output.R1} -p {output.R2} {input} "



rule fastqcFilt:
    input:
        R1= rules.cutAdaptQc.output.R1,
        R2= rules.cutAdaptQc.output.R2
    output:
        R1= config["output_dir"]+"/fastqc_filt/{sample}"+ config["forward_read_suffix"] + "_fastqc.html",
        R2= config["output_dir"]+"/fastqc_filt/{sample}"+ config["reverse_read_suffix"] + "_fastqc.html"
    resources:
        tempdir=temp(directory(config["output_dir"] + "/fastqc_filt/tmp/"))
    conda:
        "QC"
    params:
         fastqc_dir=directory(config["output_dir"]+ "/fastqc_filt")
    shell: 
        "fastqc -o {params.fastqc_dir} -d {resources.tmpdir} {input.R1} {input.R2} " 



rule multiqcFilt:
    input:
        R1= expand(config["output_dir"]+"/fastqc_filt/{sample}"+ config["forward_read_suffix"] + "_fastqc.html",sample=SAMPLES),
        R2= expand(config["output_dir"]+"/fastqc_filt/{sample}"+ config["reverse_read_suffix"] + "_fastqc.html",sample=SAMPLES)
    output:
        config["output_dir"]+"/multiqc_filt/multiqc_report_filtered.html"
    conda:
        "QC"
    params:
        fastqc_dir=config["output_dir"]+"/fastqc_filt",
        multiqc_dir=config["output_dir"]+"/multiqc_filt",
        multiqc_html="multiqc_report_filtered.html"
    shell: 
        "multiqc -f {params.fastqc_dir} -o {params.multiqc_dir} -n {params.multiqc_html}"
