if config["aligner"] == "bwa-mem2" :

    # Index
    rule index:
        input:
            config["genome"],
        output:
            multiext(
                "{}/genome".format(INDEX_PATH), 
                ".amb", 
                ".ann", 
                ".bwt.2bit.64", 
                ".pac"),
        log:
            "logs/index/index.log",
        wrapper:
            "v2.2.1/bio/bwa-mem2/index"

    # Align
    rule align:
        input:
            reads=expand("results/trimmed/{{sample}}.{read}.fastq", read = READS),
            # Index can be a list of (all) files created by bwa, or one of them
            idx=multiext(
                "{}/genome".format(INDEX_PATH), 
                ".amb", 
                ".ann", 
                ".bwt.2bit.64", 
                ".pac"),
        output:
            "results/align/{sample}.bam",
        log:
            "logs/align/{sample}.log",
        params:
            extra=config["bwamem2_align_params"],
            sort=config["bwamem2_sort"],  # Can be 'none', 'samtools' or 'picard'.
            sort_order=config["bwamem2_sort_order"],  # Can be 'coordinate' (default) or 'queryname'.
            sort_extra=config["bwamem2_sort_extra"],  # Extra args for samtools/picard.
        threads: 20
        wrapper:
            "v2.2.1/bio/bwa-mem2/mem"


elif config["aligner" == "bowtie2"]:

    # Index
    rule index:
        input:
            ref=config["genome"],
        output:
            multiext(
                "{}/genome".format(INDEX_PATH), 
                expand(".1.bt{suffix}", suffix = INDEX_SUFFIX),
                expand(".2.bt{suffix}", suffix = INDEX_SUFFIX),
                expand(".3.bt{suffix}", suffix = INDEX_SUFFIX),
                expand(".4.bt{suffix}", suffix = INDEX_SUFFIX),
                expand(".rev.1.bt{suffix}", suffix = INDEX_SUFFIX),
                expand(".rev.1.bt{suffix}", suffix = INDEX_SUFFIX),
            ),
        log:
            "logs/index/index.log",
        params:
            extra=config["bowtie2_build_params"],  # optional parameters
        threads: 10
        wrapper:
            "v2.5.0/bio/bowtie2/build"


    # Align
    rule align:
        input:
            reads=expand("results/trimmed/{{sample}}.{read}.fastq", read = READS),
            idx=multiext(
                "{}/genome".format(INDEX_PATH), 
                expand(".1.bt{suffix}", suffix = INDEX_SUFFIX),
                expand(".2.bt{suffix}", suffix = INDEX_SUFFIX),
                expand(".3.bt{suffix}", suffix = INDEX_SUFFIX),
                expand(".4.bt{suffix}", suffix = INDEX_SUFFIX),
                expand(".rev.1.bt{suffix}", suffix = INDEX_SUFFIX),
                expand(".rev.1.bt{suffix}", suffix = INDEX_SUFFIX),
            ),
        output:
            "results/align/{sample}.bam",
        log:
            "logs/align/{sample}.log",
        params:
            extra=config["bowtie2_align_params"],
        threads: 20
        wrapper:
            "v2.2.1/bio/bwa-mem2/mem"

# Sort bam files
rule sort:
    input:
        "results/align/{sample}.bam"
    output:
        "results/sorted_bam/{sample}.bam"
    log:
        "logs/sort/{sample}.log"
    params:
        extra=config["samtools_params"]
    threads: 8
    wrapper:
        "v2.6.0/bio/samtools/sort"

# Get alignment stats
rule alignment_stats:
    input:
        "results/align/{sample}.bam",
    output:
        "results/alignment_stats/{sample}.bamstats",
    log:
        "logs/alignment_stats/{sample}.log",
    params:
        extra=config["bamtools_params"],  # optional params string
    threads: 1
    wrapper:
        "v2.6.0/bio/bamtools/stats"
