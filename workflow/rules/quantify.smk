rule create_PI_gtf:
    input:
        config["annotation"],
    output:
        config["PI_gtf"]
    params:
        rscript=workflow.source_path("../scripts/create_PI_gtf.R")
    conda:
        "../envs/quantify.yaml"
    log:
        "logs/create_PI_gtf/create_PI_gtf.log"
    threads: 1
    shell:
        r"""
        chmod +x {params.rscript}
        {params.rscript} -o {output} -i {input}
        """

rule quantify_pause:
    input:
        bam="results/align/{sample}.bam",
        gtf=config["PI_gtf"]
    output:
        counts="results/quantify/{sample}_pause.csv",
    params:
        strand=config["strandedness"]
    conda:
        "../envs/quantify.yaml"
    log:
        "logs/quantify/{sample}_quantify_pause.log"
    threads: 1
    shell:
        """
        htseq-count -t pause -m intersection-strict -s {params.strand} \
        -r pos -p bam --add-chromosome-info \
        -c {output.counts} {input.bam} {input.gtf}
        """

rule quantify_genebody:
    input:
        bam="results/align/{sample}.bam",
        gtf=config["PI_gtf"]
    output:
        counts="results/quantify/{sample}_genebody.csv",
    params:
        strand=config["strandedness"]
    conda:
        "../envs/quantify.yaml"
    threads: 1
    log:
        "logs/quantify/{sample}_quantify_genebody.log"
    shell:
        """
        htseq-count -t gene_body -m union -s {params.strand} \
        -r pos -p bam --add-chromosome-info \
        -c {output.counts} {input.bam} {input.gtf}
        """

rule quantify_gene:
    input:
        bam="results/align/{sample}.bam",
        gtf=config["PI_gtf"]
    output:
        counts="results/quantify/{sample}_gene.csv",
    params:
        strand=config["strandedness"]
    conda:
        "../envs/quantify.yaml"
    log:
        "logs/quantify/{sample}_quantify_gene.log"
    threads: 1
    shell:
        """
        htseq-count -t transcript -m union -s {params.strand} \
        -r pos -p bam --add-chromosome-info \
        -c {output.counts} {input.bam} {input.gtf}
        """