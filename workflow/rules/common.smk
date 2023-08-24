import glob

SAMP_NAMES = list(config['samples'].keys())

if config["findPeaks_style"] == "groseq":
    PEAK_TYPE = "transcripts"
else:
    PEAK_TYPE = "peaks"

if config["method"] == "ChIPseq":
    TREATMENT_NAMES = list(config['controls'].keys())

if config["PE"]:
    READS = [1, 2]
    READ_NAMES = ['r1', 'r2']
else:
    READS = [1]
    READ_NAMES = ['r1']

def get_input_fastqs(wildcards):
    fastq_path = config["samples"][wildcards.sample]
    fastq_files = sorted(glob.glob(f"{fastq_path}/*.fastq*"))
    return fastq_files

def get_control_sample(wildcards):
    return config["controls"][wildcards.treatment]

