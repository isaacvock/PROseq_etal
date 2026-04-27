MACS2_CALLPEAK_DIR = "results/macs2_callpeak"


def _has_macs2_flag(params, *flags):
    return any(flag in params.split() for flag in flags)


def get_macs2_callpeak_params(broad=False, bdg=False):
    params = macs2_params.strip()

    if broad and not _has_macs2_flag(params, "--broad"):
        params = f"{params} --broad".strip()
    elif not broad and _has_macs2_flag(params, "--broad"):
        raise ValueError(
            "Remove --broad from callpeaks_params when macs2_narrow is True."
        )

    if bdg and not _has_macs2_flag(params, "--bdg", "-B"):
        params = f"{params} --bdg".strip()
    elif not bdg and _has_macs2_flag(params, "--bdg", "-B"):
        raise ValueError(
            "Remove --bdg/-B from callpeaks_params unless bedGraph outputs are declared."
        )

    return params


if config["method"] == "ChIPseq":
    if config["macs2_narrow"]:

        ### Call peaks
        rule macs2_callpeak:
            input:
                treatment="results/sorted_bam/{treatment}.bam",
                #control=expand("results/align/{control}.bam", control = get_control_sample),
                control=get_control_sample,
            output:
                # all output-files must share the same basename and only differ by it's extension
                # Usable extensions (and which tools they implicitly call) are listed here:
                #         https://snakemake-wrappers.readthedocs.io/en/stable/wrappers/macs2/callpeak.html.
                multiext(
                    "results/macs2_callpeak/{treatment}",
                    "_peaks.xls",
                    "_treat_pileup.bdg",
                    "_control_lambda.bdg",
                    "_peaks.narrowPeak",
                    "_summits.bed",
                ),
            log:
                "logs/macs2_callpeaks/{treatment}.log",
            params:
                extra=get_macs2_callpeak_params(bdg=True),
                outdir=MACS2_CALLPEAK_DIR,
            threads: 4
            conda:
                "../envs/macs2.yaml"
            shell:
                """
                macs2 callpeak \
                    -t {input.treatment:q} \
                    -c {input.control:q} \
                    --outdir {params.outdir:q} \
                    -n {wildcards.treatment:q} \
                    {params.extra} 1> {log} 2>&1
                """

    else:

        ### Call peaks
        rule macs2_callpeak:
            input:
                treatment="results/sorted_bam/{treatment}.bam",
                #control=expand("results/align/{control}.bam", control = get_control_sample),
                control=get_control_sample,
            output:
                # all output-files must share the same basename and only differ by it's extension
                # Usable extensions (and which tools they implicitly call) are listed here:
                #         https://snakemake-wrappers.readthedocs.io/en/stable/wrappers/macs2/callpeak.html.
                multiext(
                    "results/macs2_callpeak/{treatment}",
                    "_peaks.xls",
                    "_treat_pileup.bdg",
                    "_control_lambda.bdg",
                    "_peaks.broadPeak",
                    "_peaks.gappedPeak",
                ),
            log:
                "logs/macs2_callpeaks/{treatment}.log",
            params:
                extra=get_macs2_callpeak_params(broad=True, bdg=True),
                outdir=MACS2_CALLPEAK_DIR,
            threads: 4
            conda:
                "../envs/macs2.yaml"
            shell:
                """
                macs2 callpeak \
                    -t {input.treatment:q} \
                    -c {input.control:q} \
                    --outdir {params.outdir:q} \
                    -n {wildcards.treatment:q} \
                    {params.extra} 1> {log} 2>&1
                """

    ### Create fold enrichment track
    rule macs2_enrichment:
        input:
            treatment="results/macs2_callpeak/{treatment}_treat_pileup.bdg",
            control="results/macs2_callpeak/{treatment}_control_lambda.bdg",
        output:
            fe="results/macs2_enrichment/{treatment}_FE.bdg",
        params:
            extra=config["bdgcmp_FE_params"],
        log:
            "logs/macs2_enrichment/{treatment}.log",
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
            diff="results/macs2_differential/{treatment}_diff.bdg",
        params:
            extra=config["bdgcmp_diff_params"],
        log:
            "logs/macs2_differential/{treatment}.log",
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
            "logs/macs2_sort/{treatment}.log",
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
            chromsizes="results/genomecov/genome.chrom.sizes",
        output:
            "results/macs2_diff_bw/{treatment}_diff.bw",
        params:
            config["bg2bw_params"],
        log:
            "logs/diff_bg2bw/{treatment}.log",
        threads: 1
        wrapper:
            "v2.2.1/bio/ucsc/bedGraphToBigWig"

    rule FE_bg2bw:
        input:
            bedGraph="results/macs2_sort/{treatment}_sorted_FE.bg",
            chromsizes="results/genomecov/genome.chrom.sizes",
        output:
            "results/macs2_FE_bw/{treatment}_FE.bw",
        params:
            config["bg2bw_params"],
        log:
            "logs/FE_bg2bw/{treatment}.log",
        threads: 1
        wrapper:
            "v2.2.1/bio/ucsc/bedGraphToBigWig"

else:
    if config["macs2_narrow"]:

        ### Call peaks
        rule macs2_callpeak:
            input:
                treatment="results/sorted_bam/{sample}.bam",
                #control=expand("results/align/{control}.bam", control = get_control_sample),
            output:
                # all output-files must share the same basename and only differ by it's extension
                # Usable extensions (and which tools they implicitly call) are listed here:
                #         https://snakemake-wrappers.readthedocs.io/en/stable/wrappers/macs2/callpeak.html.
                multiext(
                    "results/macs2_callpeak/{sample}",
                    "_peaks.xls",
                    "_peaks.narrowPeak",
                    "_summits.bed",
                ),
            log:
                "logs/macs2_callpeaks/{sample}.log",
            params:
                extra=get_macs2_callpeak_params(),
                outdir=MACS2_CALLPEAK_DIR,
            threads: 4
            conda:
                "../envs/macs2.yaml"
            shell:
                """
                macs2 callpeak \
                    -t {input.treatment:q} \
                    --outdir {params.outdir:q} \
                    -n {wildcards.sample:q} \
                    {params.extra} 1> {log} 2>&1
                """

    else:

        ### Call peaks
        rule macs2_callpeak:
            input:
                treatment="results/sorted_bam/{sample}.bam",
                #control=expand("results/align/{control}.bam", control = get_control_sample),
            output:
                # all output-files must share the same basename and only differ by it's extension
                # Usable extensions (and which tools they implicitly call) are listed here:
                #         https://snakemake-wrappers.readthedocs.io/en/stable/wrappers/macs2/callpeak.html.
                multiext(
                    "results/macs2_callpeak/{sample}",
                    "_peaks.xls",
                    "_peaks.broadPeak",
                    "_peaks.gappedPeak",
                ),
            log:
                "logs/macs2_callpeaks/{sample}.log",
            params:
                extra=get_macs2_callpeak_params(broad=True),
                outdir=MACS2_CALLPEAK_DIR,
            threads: 4
            conda:
                "../envs/macs2.yaml"
            shell:
                """
                macs2 callpeak \
                    -t {input.treatment:q} \
                    --outdir {params.outdir:q} \
                    -n {wildcards.sample:q} \
                    {params.extra} 1> {log} 2>&1
                """
