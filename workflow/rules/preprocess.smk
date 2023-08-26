
# Unzip if gzipped
if is_gz:

    rule unzip:
        input:
            fastqs=get_input_fastqs,
        output:
            unzipped_fqs=temp(expand("results/unzipped/{{sample}}.{read}.fastq", read = READS)),
        log:
            "logs/unzip/{sample}.log"
        conda:
            "../envs/pigz.yaml"
        threads: 10
        script:
            "../scripts/pigz.py"

## Trim adapters
if config["PE"]:

    if is_gz:


        # Trim with fastp (automatically detects adapters)
        rule fastp:
            input:
                sample=expand("results/unzipped/{{sample}}.{read}.fastq", read = READS),
            output:
                trimmed=["results/trimmed/{sample}.1.fastq", "results/trimmed/{sample}.2.fastq"],
                # Unpaired reads separately
                unpaired1="results/trimmed/{sample}.u1.fastq",
                unpaired2="results/trimmed/{sample}.u2.fastq",
                failed="results/trimmed/{sample}.failed.fastq",
                html="results/reports/{sample}.html",
                json="results/reports/{sample}.json"
            log:
                "logs/fastp/{sample}.log"
            params:
                adapters=config["fastp_adapters"],
                extra=""
            threads: 2
            wrapper:
                "v2.2.1/bio/fastp"

    else:

        # Trim with fastp (automatically detects adapters)
        rule fastp:
            input:
                sample=get_input_fastqs,
            output:
                trimmed=["results/trimmed/{sample}.1.fastq", "results/trimmed/{sample}.2.fastq"],
                # Unpaired reads separately
                unpaired1="results/trimmed/{sample}.u1.fastq",
                unpaired2="results/trimmed/{sample}.u2.fastq",
                failed="results/trimmed/{sample}.failed.fastq",
                html="results/reports/{sample}.html",
                json="results/reports/{sample}.json"
            log:
                "logs/fastp/{sample}.log"
            params:
                adapters=config["fastp_adapters"],
                extra=""
            threads: 2
            wrapper:
                "v2.2.1/bio/fastp"




    # Run fastqc on trimmed fastqs
    rule fastqc:
        input:
            "results/trimmed/{sample}.{read}.fastq"
        output:
            html="results/fastqc/{sample}_r{read}.html",
            zip="results/fastqc/{sample}_r{read}_fastqc.zip"
        log:
            "logs/fastqc/{sample}_r{read}.log"
        params:
            extra = config["fastqc_params"]
        resources:
            mem_mb = 9000 
        threads: 4
        wrapper:
            "v2.2.1/bio/fastqc"
            
else:

    if is_gz:


        # Trim with fastp (automatically detects adapters)
        rule fastp:
            input:
                sample=expand("results/unzipped/{{sample}}.{read}.fastq", read = READS),
            output:
                trimmed="results/trimmed/{sample}.fastq",
                failed="results/trimmed/{sample}.failed.fastq",
                html="results/reports/{sample}.html",
                json="results/reports{sample}.json"
            log:
                "logs/fastp/{sample}.log"
            params:
                adapters=config["fastp_adapters"],
                extra=""
            threads: 1
            wrapper:
                "v2.2.1/bio/fastp"
    else:

        # Trim with fastp (automatically detects adapters)
        rule fastp:
            input:
                sample=get_input_fastqs
            output:
                trimmed="results/trimmed/{sample}.fastq",
                failed="results/trimmed/{sample}.failed.fastq",
                html="results/reports/{sample}.html",
                json="results/reports{sample}.json"
            log:
                "logs/fastp/{sample}.log"
            params:
                adapters=config["fastp_adapters"],
                extra=""
            threads: 1
            wrapper:
                "v2.2.1/bio/fastp"

    # Run fastqc on trimmed fastqs
    rule fastqc:
        input:
            "results/trimmed/{sample}.fastq"
        output:
            html="results/fastqc/{sample}_r1.html",
            zip="results/fastqc/{sample}_r1_fastqc.zip"
        log:
            "logs/fastqc/{sample}.log"
        params:
            extra = config["fastqc_params"]
        resources:
            mem_mb = 9000 
        threads: 4
        wrapper:
            "v2.2.1/bio/fastqc"
