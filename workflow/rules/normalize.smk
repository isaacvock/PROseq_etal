##### RULES FOR NORMALIZING TRACKS
### Structure (OPTION 1):
# 

# Use pause-index HTseq run (gene-wide) to get normalization factors

if config["method"] == "PROseq":

    rule normalize:
        input:
            expand("results/quantify/{SID}_genebody.csv", SID = SAMP_NAMES)
        output:
            "results/normalize/scale"
        log:
            "logs/normalize/normalize.log"
        params:
            rscript=workflow.source_path("../scripts/normalize.R")
        threads: 1
        conda:
            "../envs/normalize.yaml"
        shell:
            r"""
            chmod +x {params.rscript}
            {params.rscript} --dirs ./results/quantify/ --spikename {config[spikename]}
            mv scale {output}
            """

else:

    rule normalize:
        input:
            expand("results/sorted_bam/{SID}.bam", SID = SAMP_NAMES)
        output:
            "results/normalize/scale"
        log:
            "logs/normalize/normalize.log"
        threads: 1
        shell:
            """
            touch {output}
            """