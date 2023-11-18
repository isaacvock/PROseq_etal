rule genomecov_plus:
    input:
        bam="results/sorted_bam/{sample}.bam",
        scale="results/normalize/scale"
    output:
        "results/genomecov_plus/{sample}.bg"
    log:
        "logs/genomecov_plus/{sample}.log"
    params:
        extra="-bga -strand + {}".format(str(config["genomecov_params"])),
        normalize=NORMALIZE,
        shellscript = workflow.source_path("../scripts/coverage.sh")
    threads: 1
    conda:
        "../envs/coverage.yaml"
    shell:
        """
        chmod +x {params.shellscript}
        {params.shellscript} {params.normalize} {wildcards.sample} {input} {output} {params.extra} 1> {log} 2>&1
        """

rule genomecov_minus:
    input:
        bam="results/sorted_bam/{sample}.bam",
        scale="results/normalize/scale"
    output:
        "results/genomecov_minus/{sample}.bg"
    log:
        "logs/genomecov_minus/{sample}.log"
    params:
        extra="-bga -strand - {}".format(str(config["genomecov_params"])),
        normalize=NORMALIZE,
        shellscript = workflow.source_path("../scripts/coverage.sh")
    threads: 1
    conda:
        "../envs/coverage.yaml"
    shell:
        """
        chmod +x {params.shellscript}
        {params.shellscript} {params.normalize} {wildcards.sample} {input} {output} {params.extra} 1> {log} 2>&1
        """

rule genomecov:
    input:
        bam="results/sorted_bam/{sample}.bam",
        scale="results/normalize/scale"
    output:
        "results/genomecov/{sample}.bg"
    log:
        "logs/genomecov/{sample}.log"
    params:
        extra="-bg {}".format(str(config["genomecov_params"])),
        normalize=NORMALIZE,
        shellscript = workflow.source_path("../scripts/coverage.sh")
    threads: 1
    conda:
        "../envs/coverage.yaml"
    shell:
        """
        chmod +x {params.shellscript}
        {params.shellscript} {params.normalize} {wildcards.sample} {input} {output} {params.extra} 1> {log} 2>&1
        """


rule chrom_sizes:
    input:
        expand("results/sorted_bam/{sample_one}.bam", sample_one = SAMP_NAMES[1])
    output:
        "results/genomecov/genome.chrom.sizes",
    log:
        "logs/chrom_sizes/chrom_sizes.log"
    conda:
        "../envs/chrom.yaml"
    params:
        shellscript = workflow.source_path("../scripts/chrom.sh"),
    threads: 1
    shell:
        """
        chmod +x {params.shellscript}
        {params.shellscript} {input} {output} 1> {log} 2>&1
        """

rule sort_bg_plus:
    input:
        "results/genomecov_plus/{sample}.bg"
    output:
        "results/sort_bg_plus/{sample}.bg"
    log:
        "logs/sort_bg_plus/{sample}.log"
    threads: 1
    shell:
        "LC_COLLATE=C sort -k1,1 -k2,2n {input} > {output} 2> {log}"

rule sort_bg_minus:
    input:
        "results/genomecov_minus/{sample}.bg"
    output:
        "results/sort_bg_minus/{sample}.bg"
    log:
        "logs/sort_bg_minus/{sample}.log"
    threads: 1
    shell:
        "LC_COLLATE=C sort -k1,1 -k2,2n {input} > {output} 2> {log}"

rule sort_bg:
    input:
        "results/genomecov/{sample}.bg"
    output:
        "results/sort_bg/{sample}.bg"
    log:
        "logs/sort_bg/{sample}.log"
    threads: 1
    shell:
        "LC_COLLATE=C sort -k1,1 -k2,2n {input} > {output} 2> {log}"



rule bg2bw_plus:
    input:
        bedGraph="results/sort_bg_plus/{sample}.bg",
        chromsizes="results/genomecov/genome.chrom.sizes"
    output:
        "results/bigwig_plus/{sample}.bw"
    params:
        config["bg2bw_params"]
    log:
        "logs/bg2bw_plus/{sample}.log"
    threads: 1
    wrapper:
        "v2.2.1/bio/ucsc/bedGraphToBigWig"

rule bg2bw_minus:
    input:
        bedGraph="results/sort_bg_minus/{sample}.bg",
        chromsizes="results/genomecov/genome.chrom.sizes"
    output:
        "results/bigwig_minus/{sample}.bw"
    params:
        config["bg2bw_params"]
    log:
        "logs/bg2bw_minus/{sample}.log"
    threads: 1
    wrapper:
        "v2.2.1/bio/ucsc/bedGraphToBigWig"

rule bg2bw:
    input:
        bedGraph="results/sort_bg/{sample}.bg",
        chromsizes="results/genomecov/genome.chrom.sizes"
    output:
        "results/bigwig/{sample}.bw"
    params:
        config["bg2bw_params"]
    log:
        "logs/bg2bw/{sample}.log"
    threads: 1
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