# Index
rule index:
    input:
        config["genome"],
    output:
        "bwamem2_index/genome.0123",
        "bwamem2_index/genome.amb",
        "bwamem2_index/genome.ann",
        "bwamem2_index/genome.bwt.2bit.64",
        "bwamem2_index/genome.pac",
    log:
        "logs/index/index.log",
    wrapper:
        "v2.2.1/bio/bwa-mem2/index"

# Align
rule align:
    input:
        reads=expand("results/trimmed/{{sample}}.{read}.fastq", read = READS),
        # Index can be a list of (all) files created by bwa, or one of them
        idx=multiext("bwamem2_index/genome", ".amb", ".ann", ".bwt.2bit.64", ".pac"),
    output:
        "results/align/{sample}.bam",
    log:
        "logs/bwamem2/{sample}.log",
    params:
        extra=r"-R '@RG\tID:{sample}\tSM:{sample}'",
        sort="none",  # Can be 'none', 'samtools' or 'picard'.
        sort_order="coordinate",  # Can be 'coordinate' (default) or 'queryname'.
        sort_extra="",  # Extra args for samtools/picard.
    threads: 24
    wrapper:
        "v2.2.1/bio/bwa-mem2/mem"
