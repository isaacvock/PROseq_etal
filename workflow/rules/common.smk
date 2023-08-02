import glob

SAMP_NAMES = list(config['samples'].keys())

PAIRS = [1, 2]

def get_input_fastqs(wildcards):
    fastq_path = config["samples"][wildcards.sample]
    fastq_files = sorted(glob.glob(f"{fastq_path}/*.fastq*"))
    return fastq_files

