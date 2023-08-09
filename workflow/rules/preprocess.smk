
## Trim adapters
if config["PE"]:

    # Trim with fastp (automatically detects adapters)
    rule fastp:
        input:
            sample=get_input_fastqs
        output:
            trimmed=["results/trimmed/{sample}.1.fastq", "results/trimmed/{sample}.2.fastq"],
            # Unpaired reads separately
            unpaired1="results/trimmed/{sample}.u1.fastq",
            unpaired2="results/trimmed/{sample}.u2.fastq",
            failed="results/trimmed/{sample}.failed.fastq",
            html="results/trimmed/reports/{sample}.html",
            json="results/trimmed/reports/{sample}.json"
        log:
            "logs/fastp/{sample}.log"
        params:
            adapters=config["fastp_adapters"],
            extra=""
        threads: 2
        wrapper:
            "v2.2.1/bio/fastp"


    # Run fastqc on trimmed fastqs
    rule fastqc_r1:
        input:
            "results/trimmed/{sample}.1.fastq"
        output:
            html="results/fastqc/{sample}_r1.html",
            zip="results/fastqc/{sample}_r1_fastqc.zip"
        log:
            "logs/fastqc/{sample}_r1.log"
        params:
            extra = config["fastqc_params"]
        resources:
            mem_mb = 9000 
        threads: 4
        wrapper:
            "v2.2.1/bio/fastqc"

    rule fastqc_r2:
        input:
            "results/trimmed/{sample}.2.fastq"
        output:
            html="results/fastqc/{sample}_r2.html",
            zip="results/fastqc/{sample}_r2_fastqc.zip"
        log:
            "logs/fastqc/{sample}_r2.log"
        params:
            extra = config["fastqc_params"]
        resources:
            mem_mb = 9000 
        threads: 4
        wrapper:
            "v2.2.1/bio/fastqc"

else:

    # Trim with fastp (automatically detects adapters)
    rule fastp:
        input:
            sample=get_input_fastqs
        output:
            trimmed="results/trimmed/{sample}.fastq",
            failed="results/trimmed/{sample}.failed.fastq",
            html="results/trimmed/reports/{sample}.html",
            json="results/trimmed/reports{sample}.json"
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
            html="results/fastqc/{sample}.html",
            zip="results/fastqc/{sample}_fastqc.zip"
        log:
            "logs/fastqc/{sample}.log"
        params:
            extra = config["fastqc_params"]
        resources:
            mem_mb = 9000 
        threads: 4
        wrapper:
            "v2.2.1/bio/fastqc"
