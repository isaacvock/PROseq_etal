
if config["method"] == "ChIPseq":
    ### Call peaks
    rule macs2_callpeak:
        input:
            treatment="results/align/{sample}.bam",
            control="results/align/{sample}.bam"
        output:
            # all output-files must share the same basename and only differ by it's extension
            # Usable extensions (and which tools they implicitly call) are listed here:
            #         https://snakemake-wrappers.readthedocs.io/en/stable/wrappers/macs2/callpeak.html.
            multiext("results/macs2_callpeak/{sample}"
                    "_peaks.xls",   ### required
                    ### optional output files
                    # these output extensions internally set the --bdg or -B option:
                    "_treat_pileup.bdg",
                    "_control_lambda.bdg",
                    # these output extensions internally set the --broad option:
                    "_peaks.broadPeak",
                    "_peaks.gappedPeak"
                    )
        log:
            "logs/macs2/callpeak.log"
        params:
            config["macs2_params"]
        wrapper:
            "v2.4.0/bio/macs2/callpeak"

else:

    ### Call peaks
    rule macs2_callpeak:
        input:
            treatment="results/align/{sample}.bam",
        output:
            # all output-files must share the same basename and only differ by it's extension
            # Usable extensions (and which tools they implicitly call) are listed here:
            #         https://snakemake-wrappers.readthedocs.io/en/stable/wrappers/macs2/callpeak.html.
            multiext("results/macs2_callpeak/{sample}"
                    "_peaks.xls",   ### required
                    ### optional output files
                    # these output extensions internally set the --broad option:
                    "_peaks.broadPeak",
                    "_peaks.gappedPeak"
                    )
        log:
            "logs/macs2/callpeak.log"
        params:
            config["macs2_params"]
        wrapper:
            "v2.4.0/bio/macs2/callpeak"

