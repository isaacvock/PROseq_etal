
if config["method"] == "ChIPseq":
    ### Call peaks
    rule macs2_callpeak:
        input:
            treatment="results/sorted_bam/{treatment}.bam",
            #control=expand("results/align/{control}.bam", control = get_control_sample),
            control=get_control_sample
        output:
            # all output-files must share the same basename and only differ by it's extension
            # Usable extensions (and which tools they implicitly call) are listed here:
            #         https://snakemake-wrappers.readthedocs.io/en/stable/wrappers/macs2/callpeak.html.
            multiext("results/macs2_callpeak/{treatment}",
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
            "logs/macs2_callpeaks/{treatment}.log"
        params:
            macs2_params
        threads: 4
        wrapper:
            "v2.4.0/bio/macs2/callpeak"

    ### Create fold enrichment track
    rule macs2_enrichment:
        input: 
            treatment="results/macs2_callpeak/{treatment}_treat_pileup.bdg",
            control="results/macs2_callpeak/{treatment}_control_lambda.bdg",
        output:
            fe="results/macs2_enrichment/{treatment}_FE.bdg"
        params:
            extra=config["bdgcmp_FE_params"],
        log:
            "logs/macs2_enrichment/{treatment}.log"
        conda:
            "../envs/macs2.yaml"
        threads: 4
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
            treatment="results/macs2_callpeak/{treatment}_treat_pileup.bdg",
            control="results/macs2_callpeak/{treatment}_control_lambda.bdg",
        output:
            diff="results/macs2_differential/{treatment}_diff.bdg"
        params:
            extra=config["bdgcmp_diff_params"],
        log:
            "logs/macs2_differential/{treatment}.log"
        conda:
            "../envs/macs2.yaml"
        threads: 4
        shell:
            """
            macs2 bdgcmp \
                -t {input.treatment} \
                -c {input.control} \
                -o {output.diff} \
                -m subtract {params.extra} 1> {log} 2>&1 
            """

    ### Sort BedGraph files uppercase letter before lowercase
    rule macs2_sort:
        input:
            diff="results/macs2_differential/{treatment}_diff.bdg",
            fe="results/macs2_enrichment/{treatment}_FE.bdg",
        output:
            diff="results/macs2_sort/{treatment}_sorted_diff.bg",
            fe="results/macs2_sort/{treatment}_sorted_FE.bg",
        conda:
            "../envs/macs2.yaml"
        log:
            "logs/macs2_sort/{treatment}.log"
        threads: 1
        shell:
            """
            LC_COLLATE=C sort -k1,1 -k2,2n {input.diff} > {output.diff} 2> {log}
            LC_COLLATE=C sort -k1,1 -k2,2n {input.fe} > {output.fe} 2> {log}
            """

    ### Convert bedGraph to bigWig
    rule diff_bg2bw:
        input:
            bedGraph="results/macs2_sort/{treatment}_sorted_diff.bg",
            chromsizes="results/genomecov/genome.chrom.sizes"
        output:
            "results/macs2_diff_bw/{treatment}_diff.bw"
        params:
            config["bg2bw_params"]
        log:
            "logs/diff_bg2bw/{treatment}.log"
        threads: 1
        wrapper:
            "v2.2.1/bio/ucsc/bedGraphToBigWig"    

    rule FE_bg2bw:
        input:
            bedGraph="results/macs2_sort/{treatment}_sorted_FE.bg",
            chromsizes="results/genomecov/genome.chrom.sizes"
        output:
            "results/macs2_FE_bw/{treatment}_FE.bw"
        params:
            config["bg2bw_params"]
        log:
            "logs/FE_bg2bw/{treatment}.log"
        threads: 1
        wrapper:
            "v2.2.1/bio/ucsc/bedGraphToBigWig" 

else:

    ### Call peaks
    rule macs2_callpeak:
        input:
            treatment="results/sorted_bam/{sample}.bam",
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
            "logs/macs2/{sample}.log"
        params:
            config["macs2_params"]
        threads: 4
        wrapper:
            "v2.4.0/bio/macs2/callpeak"

