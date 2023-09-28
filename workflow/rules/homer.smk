### Make Tag Directory for HOMER
rule homer_makeTagDir:
    input:
        bam="results/align/{sample}.bam",
    output:
        directory("results/homer_tagDir/{sample}")
    params:
        extra=config["makeTagDir_params"]
    threads: 1
    log:
        "logs/homer_makeTagDir/{sample}.log"
    wrapper:
        "v2.4.0/bio/homer/makeTagDirectory"



if config["findPeaks_style"] == "groseq":

    ### Find transcripts
    rule homer_findPeaks:
        input:
            tag="results/homer_tagDir/{sample}",
        output:
            transcripts="results/homer_findPeaks/{sample}_transcripts.txt",
            gtf="results/homer_findPeaks/{sample}.gtf"
        params:
            style="groseq",
            extra=config["findPeaks_params"]
        threads: 1
        log:
            "logs/homer_findPeaks/{sample}.log"
        conda:
            "../envs/homer.yaml"
        script:
            "../scripts/findPeaks.py"

else:

    ### Find peaks
    rule homer_findPeaks:
        input:
            tag="results/homer_tagDir/{sample}",
        output:
            "results/homer_findPeaks/{sample}_peaks.txt"
        params:
            style=config["findPeaks_style"],
            extra=config["findPeaks_params"]
        threads: 1
        log:
            "logs/homer_findPeaks/{sample}.log"
        wrapper:
            "v2.4.0/bio/homer/findPeaks"


rule homer_mergePeaks:
    input:
        # input peak files
        expand("results/homer_findPeaks/{SID}_{type}.txt", SID = SAMP_NAMES, type = HOMER_PEAK_TYPE)
    output:
        "results/homer_mergePeaks/merged.peaks"
    params:
        extra=config["mergePeaks_params"]  # optional params, see homer manual
    threads: 1
    log:
        "logs/homer_mergePeaks/mergePeaks.log"
    wrapper:
        "v2.4.0/bio/homer/mergePeaks"


rule homer_annotatePeaks:
    input:
        peaks="results/homer_mergePeaks/merged.peaks",
        genome=config["genome"],
        gtf=config["annotation"]
    output:
        annotations="results/homer_annotatePeaks/merged_annot.txt",
    threads: 4
    params:
        mode="",
        extra=config["annotatePeaks_params"]  # optional params, see http://homer.ucsd.edu/homer/ngs/annotation.html
    log:
        "logs/homer_annotatePeaks/annotatePeaks.log"
    wrapper:
        "v2.6.0/bio/homer/annotatePeaks"   

rule homer_annotateSeparatePeaks:
    input:
        peaks=expand("results/homer_findPeaks/{{sample}}_{type}.txt", type = HOMER_PEAK_TYPE),
        genome=config["genome"],
        gtf=config["annotation"]
    output:
        annotations="results/homer_annotatePeaks/{sample}_annot.txt",
    threads: 4
    params:
        mode="",
        extra=config["annotatePeaks_params"]  # optional params, see http://homer.ucsd.edu/homer/ngs/annotation.html
    log:
        "logs/homer_annotateSeparatePeaks/{sample}.log"
    wrapper:
        "v2.4.0/bio/homer/annotatePeaks"   