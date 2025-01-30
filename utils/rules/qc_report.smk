rule qc_report1:
    input:
        rules.combineReadCounts.output,
        rules.plotASVLength.output,
        rules.plotQualityProfileAfterdada2.output,
        rules.plotQualityProfileRaw.output,
        rules.plotQualityProfileAfterQC.output,
        rules.separate_vsearch_hits.output,
        rules.vsearchParse.output,
        rules.combining_annotations.output
    conda:
        "rmd"
    params:
        path=config["path"],
        outdir=config["path"]+"/"+ config["output_dir"],
        fwd=config["forward_read_suffix"],
        rev=config["reverse_read_suffix"],
        primer_removal=config["primer_removal"],
        primer_investigation=config["primer_investigation"],
        Nread=config["path"]+"/"+config["output_dir"]+"/dada2/Nreads.tsv",
        quality=config["path"]+"/"+config["output_dir"]+"/figures/quality/",
    output:
        config["output_dir"]+"/QC_html_report/"+"qc_report_1.html",
    shell:
        """
        Rscript -e 'rmarkdown::render(input="{params.path}/utils/scripts/dada2/qc_report_1.Rmd",output_file="{params.path}/{output}", params= list(quality="{params.quality}", out_dir="{params.outdir}", fwd_suffix= "{params.fwd}", rev_suffix="{params.rev}", primer_removal= "{params.primer_removal}", primer_investigation= "{params.primer_investigation}", Nread ="{params.Nread}"))'
        """



rule qc_report2:
    input:
        rules.combineReadCounts.output,
        rules.plotASVLength.output,
        rules.plotQualityProfileAfterdada2.output,
        rules.plotQualityProfileRaw.output,
        rules.plotQualityProfileAfterQC.output,
        rules.separate_vsearch_hits.output,
        rules.vsearchParse.output,
        rules.combining_annotations.output
    conda:
        "rmd"
    params:
        path=config["path"],
        taxonomy=config["path"]+"/"+config["output_dir"]+"/taxonomy/dada2_tables/GTDB_RDP.tsv",
        seqtab=config["path"]+"/"+config["output_dir"]+"/dada2/seqtab_nochimeras.csv",
        source=config["path"]+"/utils/scripts/dada2/pos_ctrl_references.R",
        pos=config["Positive_samples"],
        ref=config["path"]+"/utils/databases/",
    output:
        config["output_dir"]+"/QC_html_report/"+"qc_report_2.html",
    shell:
        """
        Rscript -e 'rmarkdown::render(input="{params.path}/utils/scripts/dada2/qc_report_2.Rmd",output_file="{params.path}/{output}", params= list(seqtab="{params.seqtab}", taxonomy="{params.taxonomy}", pos="{params.pos}", ref="{params.ref}", source="{params.source}"))'
        """




rule qc_report3:
    input:
        rules.combineReadCounts.output,
        rules.plotASVLength.output,
        rules.plotQualityProfileAfterdada2.output,
        rules.plotQualityProfileRaw.output,
        rules.plotQualityProfileAfterQC.output,
        rules.separate_vsearch_hits.output,
        rules.vsearchParse.output,
        rules.combining_annotations.output
    conda:
        "rmd"
    params:
        path=config["path"],
        outdir=config["path"]+"/"+ config["output_dir"],
        taxonomy=config["path"]+"/"+config["output_dir"]+"/taxonomy/dada2_tables/GTDB_RDP.tsv",
        seqtab=config["path"]+"/"+config["output_dir"]+"/dada2/seqtab_nochimeras.csv",
        length_distribution=config["path"]+"/"+config["output_dir"]+"/figures/length_distribution/",        
        krona=config["path"]+"/"+config["output_dir"]+"/QC_html_report/"+"krona_Species_result"
    output:
        config["output_dir"]+"/QC_html_report/"+"qc_report_3.html",
    shell:
        """
        Rscript -e 'rmarkdown::render(input="{params.path}/utils/scripts/dada2/qc_report_3.Rmd",output_file="{params.path}/{output}", params= list(seqtab="{params.seqtab}", taxonomy="{params.taxonomy}", krona="{params.krona}", path="{params.path}", length_dist="{params.length_distribution}", out_dir="{params.outdir}"))'
        """




rule qc_report_final:
    input:
        rules.qc_report1.output,
        rules.qc_report2.output,
        rules.qc_report3.output,
        rules.combineReadCounts.output,
        rules.plotASVLength.output,
        rules.plotQualityProfileAfterdada2.output,
        rules.plotQualityProfileRaw.output,
        rules.plotQualityProfileAfterQC.output,
        rules.separate_vsearch_hits.output,
        rules.vsearchParse.output,
        rules.combining_annotations.output
    conda:
        "rmd"
    output:
        config["output_dir"]+"/QC_html_report/"+"final_qc_report.html"
    shell:
        """
        pandoc --standalone {input[0]} {input[1]} {input[2]} -o {output}
        """
