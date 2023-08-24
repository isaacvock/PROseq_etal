rule genomecov_plus:
    input:
        "results/align/{sample}.bam",
    output:
        "results/genomecov/{sample}_pos.bg"
    log:
        "logs/genomecov/{sample}_pos.log"
    params:
        "-bga -strand + {}".format(str(config["genomecov_params"]))
    wrapper:
        "v2.2.1/bio/bedtools/genomecov"

rule genomecov_minus:
    input:
        "results/align/{sample}.bam",
    output:
        "results/genomecov/{sample}_min.bg"
    log:
        "logs/genomecov/{sample}_min.log"
    params:
        "-bga -strand - {}".format(str(config["genomecov_params"]))
    wrapper:
        "v2.2.1/bio/bedtools/genomecov"

rule genomecov:
    input:
        "results/align/{sample}.bam",
    output:
        "results/genomecov/{sample}.bg"
    log:
        "logs/genomecov/{sample}.log"
    params:
        "-bg {}".format(str(config["genomecov_params"]))
    wrapper:
        "v2.2.1/bio/bedtools/genomecov"


rule chrom_sizes:
    input:
        expand("results/align/{sample_one}.bam", sample_one = SAMP_NAMES[1])
    output:
        "results/genomecov/genome.chrom.sizes",
    log:
        "logs/chrom_sizes/chrom_sizes.out"
    conda:
        "../envs/chrom.yaml"
    params:
        shellscript = workflow.source_path("../scripts/chrom.sh"),
    threads: 1
    shell:
        """
        chmod +x {params.shellscript}
        {params.shellscript} {input} {output}
        """

rule sort_bg_pos:
    input:
        "results/genomecov/{sample}_pos.bg"
    output:
        "results/sort_bg/{sample}_pos_sorted.bg"
    log:
        "logs/sort_bg/{sample}_pos.log"
    shell:
        "LC_COLLATE=C sort -k1,1 -k2,2n {input} > {output}"

rule sort_bg_min:
    input:
        "results/genomecov/{sample}_min.bg"
    output:
        "results/sort_bg/{sample}_min_sorted.bg"
    log:
        "logs/sort_bg/{sample}_min.log"
    shell:
        "LC_COLLATE=C sort -k1,1 -k2,2n {input} > {output}"



rule bg2bw_pos:
    input:
        bedGraph="results/sort_bg/{sample}_pos_sorted.bg",
        chromsizes="results/genomecov/genome.chrom.sizes"
    output:
        "results/bigwig/{sample}_pos.bw"
    params:
        config["bg2bw_params"]
    log:
        "logs/bg2bw/{sample}.log"
    wrapper:
        "v2.2.1/bio/ucsc/bedGraphToBigWig"

rule bg2bw_min:
    input:
        bedGraph="results/sort_bg/{sample}_min_sorted.bg",
        chromsizes="results/genomecov/genome.chrom.sizes"
    output:
        "results/bigwig/{sample}_min.bw"
    params:
        config["bg2bw_params"]
    log:
        "logs/bg2bw/{sample}.log"
    wrapper:
        "v2.2.1/bio/ucsc/bedGraphToBigWig"


#rule bigwigs_pos:
#    input:
#        "results/align/{sample}.bam",
#    output:
#        "results/align/{sample}_coverage_pow.bw",
#    params:
#        genome=config["genome_name"],
#        effective_genome_size=config["genome_size"],
#        extra=config["deeptools_params"],
#        read_length=config["read_length"]
#    wrapper:
#        "v2.2.1/bio/deeptools/bamcoverage"


#rule bigwigs_min:
#    input:
#        "results/align/{sample}.bam",
#    output:
#        "results/align/{sample}_coverage_min.bw",
#    params:
#        genome=config["genome_name"],
#        effective_genome_size=config["genome_size"],
#        extra="--filterRNAstrand forward + {}".format(str(config["genomecov_params"])),
#        read_length=config["read_length"]
#    wrapper:
#        "v2.2.1/bio/deeptools/bamcoverage"