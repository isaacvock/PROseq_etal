# Index
rule index:
    input:
        config["genome"],
    output:
        "bwa-mem2_index/genome.0123",
        "bwa-mem2_index/genome.amb",
        "bwa-mem2_index/genome.ann",
        "bwa-mem2_index/genome.bwt.2bit.64",
        "bwa-mem2_index/genome.pac",
    log:
        "logs/index/index.log",
    wrapper:
        "v2.2.1/bio/bwa-mem2/index"


if config["PE"]:

    # Align
    rule align:
        input:
            reads=["results/trimmed/{sample}.1.fastq", "results/trimmed/{sample}.2.fastq"],
            # Index can be a list of (all) files created by bwa, or one of them
            idx=multiext("bwa-mem2_index/genome", ".amb", ".ann", ".bwt.2bit.64", ".pac"),
        output:
            "results/align/{sample}.bam",
        log:
            "logs/bwa_mem2/{sample}.log",
        params:
            extra=r"-R '@RG\tID:{sample}\tSM:{sample}'",
            sort="none",  # Can be 'none', 'samtools' or 'picard'.
            sort_order="coordinate",  # Can be 'coordinate' (default) or 'queryname'.
            sort_extra="",  # Extra args for samtools/picard.
        threads: 24
        wrapper:
            "v2.2.1/bio/bwa-mem2/mem"

else:
