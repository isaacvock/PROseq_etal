### Make Tag Directory for HOMER
rule homer_makeTagDir:
    input:
        bam="results/align/{sample}.bam",
    output:
        directory("results/tagDir/{sample}")
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
            tag="results/tagDir/{sample}",
        output:
            transcripts="results/findPeaks/{sample}_transcripts.txt",
            gtf="results/findPeaks/{sample}.gtf"
        params:
            style=config["findPeaks_style"],
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
            tag="results/tagDir/{sample}",
        output:
            "results/findPeaks/{sample}_peaks.txt"
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
        expand("results/findPeaks/{SID}_{type}.txt", SID = SAMP_NAMES, type = PEAK_TYPE)
    output:
        "results/mergePeaks/merged.peaks"
    params:
        extra=config["mergePeaks_params"]  # optional params, see homer manual
    threads: 1
    log:
        "logs/mergePeaks/mergePeaks.log"
    wrapper:
        "v2.4.0/bio/homer/mergePeaks"


rule homer_annotatePeaks:
    input:
        peaks="results/mergePeaks/merged.peaks",
        genome=config["genome"],
        gtf=config["annotation"]
    output:
        annotations="results/annotatePeaks/merged_annot.txt",
    threads: 2
    params:
        mode="",
        extra=config["annotatePeaks_params"]  # optional params, see http://homer.ucsd.edu/homer/ngs/annotation.html
    log:
        "logs/annotatePeaks/annotatePeaks.log"
    wrapper:
        "v2.4.0/bio/homer/annotatePeaks"   