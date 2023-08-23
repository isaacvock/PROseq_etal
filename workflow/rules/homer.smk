### Make Tag Directory for HOMER
rule homer_makeTagDir:
    input:
        bam="results/align/{sample}.bam",
    output:
        directory("results/tagDir/{sample}")
    params:
        extra=config["makeTagDir_params"]
    log:
        "logs/homer_makeTagDir/{sample}.log"
    wrapper:
        "v2.4.0/bio/homer/makeTagDirectory"



if config["findPeaks_style"] == "groseq":

    ### Annotate transcripts
    rule homer_findPeaks:
        input:
            tag="tagDir/{sample}",
        output:
            "results/tagDir/{sample}/transcripts.txt",
            "results/findPeaks/{sample}/transcripts.gtf"
        params:
            style=config["findPeaks_style"],
            extra=config["findPeaks_params"]
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
            tag="tagDir/{sample}",
        output:
            "results/findPeaks/{sample}_peaks.txt"
        params:
            style=config["findPeaks_style"],
            extra=config["findPeaks_params"]
        log:
            "logs/homer_findPeaks/{sample}.log"
        wrapper:
            "v2.4.0/bio/homer/findPeaks"