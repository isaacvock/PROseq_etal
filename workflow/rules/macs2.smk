
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
            "logs/macs2_callpeaks/callpeak.log"
        params:
            config["callpeaks_params"]
        wrapper:
            "v2.4.0/bio/macs2/callpeak"

    ### Create fold enrichment track
    rule macs2_enrichment:
        input: 
            treatment="results/macs2_callpeak/{sample}_treat_pileup.bdg",
            control="results/macs2_callpeak/{sample}_control_lambda.bdg",
        output:
            fe="results/macs2_enrichment/{sample}_FE.bdg"
        params:
            extra=config["bdgcmp_FE_params"],
        log:
            "logs/macs2_enrichment/{sample}.log"
        shell:
            """
            macs2 bdgcmp \
                -t {input.treatment} \
                -c {input.control} \
                -o {output.fe} \
                -m FE {params.extra} 1> {log} 2>&1 
            """

    ### Create fold differential track
    rule macs2_differential:
        input: 
            treatment="results/macs2_callpeak/{sample}_treat_pileup.bdg",
            control="results/macs2_callpeak/{sample}_control_lambda.bdg",
        output:
            fe="results/macs2_enrichment/{sample}_diff.bdg"
        params:
            extra=config["bdgcmp_diff_params"],
        log:
            "logs/macs2_enrichment/{sample}.log"
        shell:
            """
            macs2 bdgcmp \
                -t {input.treatment} \
                -c {input.control} \
                -o {output.fe} \
                -m subtract {params.extra} 1> {log} 2>&1 
            """

    ### Sort BedGraph files uppercase letter before lowercase

    ### Convert bedGraph to bigWig
    

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

