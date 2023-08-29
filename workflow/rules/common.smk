import glob

# Sample names to help expanding lists of all bam files
# and to aid in defining wildcards
SAMP_NAMES = list(config['samples'].keys())

# If PROseq method, use groseq peaks finding style in HOMER
if config["findPeaks_style"] == "groseq":
    PEAK_TYPE = "transcripts"
else: # Else, use peaks
    PEAK_TYPE = "peaks"

# Need to figure out which sample names are enrichments and which are inputs
    # Treatment = enrichment
if config["method"] == "ChIPseq":
    TREATMENT_NAMES = list(config['controls'].keys())

# Determine how many fastqs to look for
if config["PE"]:
    READS = [1, 2]
    READ_NAMES = ['r1', 'r2']
else:
    READS = [1]
    READ_NAMES = ['r1']


# Bowtie2 has two different alignment index suffixes, so gotta figure out which will apply
if config["aligner"] == "bowtie2":

    if config["bowtie2_build_params"].str.contains("large-index"):
        INDEX_SUFFIX = "21"
    else:
        INDEX_SUFFIX = "2"

# Make life easier for users and catch if they add a '/' at the end of their path
# to alignment indices. If so, remove it to avoid double '/' 
if config["indices"].endswith('/'):
    INDEX_PATH = str(config["indices"])
    INDEX_PATH = INDEX_PATH[:-1]
else:
    INDEX_PATH = str(config["indices"])

# Get input fastq files for first step
def get_input_fastqs(wildcards):
    fastq_path = config["samples"][wildcards.sample]
    fastq_files = sorted(glob.glob(f"{fastq_path}/*.fastq*"))
    return fastq_files

# Figure out which samples are each enrichment's input sample
def get_control_sample(wildcards):
    control_label = config["controls"][wildcards.treatment]
    return expand("results/sorted_bam/{control}.bam", control = control_label)

# Check if fastq files are gzipped
fastq_paths = config["samples"]

is_gz = False

for p in fastq_paths.values():

    fastqs = sorted(glob.glob(f"{p}/*.fastq*"))
    test_gz = any(path.endswith('.fastq.gz') for path in fastqs)
    is_gz = any([is_gz, test_gz])


# MACS2 peak calling -f parameter
if config["PE"]:
    macs2_params = config["callpeaks_params"] + " -f BAMPE"
else:
    macs2_params = config["callpeaks_params"]

