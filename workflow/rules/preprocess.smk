## Trim adapters
if config["PE"]:

    # Trim with fastp (automatically detects adapters)
    rule fastp:
        input:
            sample=get_input_fastqs,
        output:
            trimmed=[
                "results/trimmed/{sample}.1.fastq",
                "results/trimmed/{sample}.2.fastq",
            ],
            unpaired1="results/trimmed/{sample}.u1.fastq",
            unpaired2="results/trimmed/{sample}.u2.fastq",
            failed="results/trimmed/{sample}.failed.fastq",
            html="results/reports/{sample}.html",
            json="results/reports/{sample}.json",
        log:
            "logs/fastp/{sample}.log",
        params:
            adapters=config.get("fastp_adapters", ""),
            extra=config.get("fastp_parameters", ""),
        threads: 2
        wrapper:
            "v2.2.1/bio/fastp"

else:

    # Trim with fastp (automatically detects adapters)
    rule fastp:
        input:
            sample=get_input_fastqs,
        output:
            trimmed="results/trimmed/{sample}.1.fastq",
            failed="results/trimmed/{sample}.1.failed.fastq",
            html="results/reports/{sample}.1.html",
            json="results/reports/{sample}.1.json",
        log:
            "logs/fastp/{sample}.log",
        params:
            adapters=config.get("fastp_adapters", ""),
            extra=config.get("fastp_parameters", ""),
        threads: 1
        wrapper:
            "v2.2.1/bio/fastp"


# Run fastqc on trimmed fastqs
rule fastqc:
    input:
        "results/trimmed/{sample}.{read}.fastq",
    output:
        html="results/fastqc/{sample}_r{read}.html",
        zip="results/fastqc/{sample}_r{read}_fastqc.zip",
    log:
        "logs/fastqc/{sample}_r{read}.log",
    params:
        extra=config["fastqc_params"],
    resources:
        mem_mb=9000,
    threads: 4
    wrapper:
        "v2.2.1/bio/fastqc"
