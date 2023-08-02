if config["aligner"] == "bwa-mem2" :

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
            "logs/align/{sample}.log",
        params:
            extra=config["bwamem2_extra"],
            sort=config["bwamem2_sort"],  # Can be 'none', 'samtools' or 'picard'.
            sort_order=config["bwamem2_sort_order"],  # Can be 'coordinate' (default) or 'queryname'.
            sort_extra=config["bwamem2_sort_extra"],  # Extra args for samtools/picard.
        threads: 24
        wrapper:
            "v2.2.1/bio/bwa-mem2/mem"


else:

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
            "logs/align/{sample}.log",
        params:
            extra=config["bwamem2_extra"],
            sort=config["bwamem2_sort"],  # Can be 'none', 'samtools' or 'picard'.
            sort_order=config["bwamem2_sort_order"],  # Can be 'coordinate' (default) or 'queryname'.
            sort_extra=config["bwamem2_sort_extra"],  # Extra args for samtools/picard.
        threads: 24
        wrapper:
            "v2.2.1/bio/bwa-mem2/mem"
