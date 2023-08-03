rule genomecov_plus:
    input:
        "results/align/{sample}.bam",
    output:
        "results/genomecov/{sample}_pos.bg"
    log:
        "logs/genomecov/{sample}.log"
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
        "logs/genomecov/{sample}.log"
    params:
        "-strand - {}".format(str(config["genomecov_params"]))
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
    threads: 1
    shell:
        """
        samtools view -H {input} \
            | awk -v OFS="\t" ' $1 ~ /^@SQ/ {split($2, chr, ":")
                                                split($3, size, ":")
                                                print chr[2], size[2]}' > {output}
        """

rule bg2bw_pos:
    input:
        bedGraph="results/genomecov/{sample}_pos.bg",
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
        bedGraph="results/genomecov/{sample}_min.bg",
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