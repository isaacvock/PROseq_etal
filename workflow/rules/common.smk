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


if config["aligner" == "bowtie2"]:

    if config["bowtie2_build_params"].str.contains("large-index"):
        INDEX_SUFFIX = "21"
    else:
        INDEX_SUFFIX = "2"

if config["indices"].endswith('/'):
    INDEX_PATH = str(config["indices"])
    INDEX_PATH = INDEX_PATH[:-1]
else:
    INDEX_PATH = str(config["indices"])




def get_input_fastqs(wildcards):
    fastq_path = config["samples"][wildcards.sample]
    fastq_files = sorted(glob.glob(f"{fastq_path}/*.fastq*"))
    return fastq_files

def get_control_sample(wildcards):
    return config["controls"][wildcards.treatment]

