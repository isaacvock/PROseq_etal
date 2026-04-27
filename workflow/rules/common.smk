import glob
import os

FASTQ_SUFFIXES = (".fastq", ".fastq.gz", ".fq", ".fq.gz")
GZIPPED_FASTQ_SUFFIXES = (".fastq.gz", ".fq.gz")

# Sample names to help expanding lists of all bam files
# and to aid in defining wildcards
SAMP_NAMES = list(config["samples"].keys())

# If PROseq method, use groseq peaks finding style in HOMER
if config["findPeaks_style"] == "groseq":
    HOMER_PEAK_TYPE = "transcripts"
else:  # Else, use peaks
    HOMER_PEAK_TYPE = "peaks"

# Need to figure out which sample names are enrichments and which are inputs
# Treatment = enrichment
if config["method"] == "ChIPseq":
    TREATMENT_NAMES = list(config["controls"].keys())
else:
    TREATMENT_NAMES = ""

# Determine how many fastqs to look for
if config["PE"]:
    READS = [1, 2]
    READ_NAMES = ["r1", "r2"]
else:
    READS = [1]
    READ_NAMES = ["r1"]


# Bowtie2 has two different alignment index suffixes, so gotta figure out which will apply
if config["aligner"] == "bowtie2":
    if "large-index" in config["bowtie2_build_params"]:
        INDEX_SUFFIX = "2l"
    else:
        INDEX_SUFFIX = "2"

# Make life easier for users and catch if they add a '/' at the end of their path
# to alignment indices. If so, remove it to avoid double '/'

if config["indices"].endswith("/"):
    INDEX_PATH = str(config["indices"])
    INDEX_PATH = INDEX_PATH[:-1]
else:
    INDEX_PATH = str(config["indices"])


# Get input fastq files for first step
def get_fastq_files(fastq_path):
    return sorted(
        fastq
        for suffix in FASTQ_SUFFIXES
        for fastq in glob.glob(f"{fastq_path}/*{suffix}")
    )


def get_input_fastqs(wildcards):
    fastq_path = config["samples"][wildcards.sample]
    return get_fastq_files(fastq_path)


# Figure out which samples are each enrichment's input sample
def get_control_sample(wildcards):
    control_label = config["controls"][wildcards.treatment]
    return expand("results/sorted_bam/{control}.bam", control=control_label)


# Check if fastq files are gzipped
fastq_paths = config["samples"]

is_gz = False

for p in fastq_paths.values():
    fastqs = get_fastq_files(p)
    test_gz = any(path.endswith(GZIPPED_FASTQ_SUFFIXES) for path in fastqs)
    is_gz = any([is_gz, test_gz])


# MACS peak calling -f parameter
if config["PE"]:
    macs2_params = config["callpeaks_params"] + " -f BAMPE"
else:
    macs2_params = config["callpeaks_params"]


def _has_macs2_flag(params, *flags):
    return any(flag in params.split() for flag in flags)


def get_macs2_callpeak_params(broad=False, bdg=False):
    params = macs2_params.strip()

    if broad and not _has_macs2_flag(params, "--broad"):
        params = f"{params} --broad".strip()
    elif not broad and _has_macs2_flag(params, "--broad"):
        raise ValueError(
            "Remove --broad from callpeaks_params when macs2_narrow is True."
        )

    if bdg and not _has_macs2_flag(params, "--bdg", "-B"):
        params = f"{params} --bdg".strip()
    elif not bdg and _has_macs2_flag(params, "--bdg", "-B"):
        raise ValueError(
            "Remove --bdg/-B from callpeaks_params unless bedGraph outputs are declared."
        )

    return params


def get_macs2_callpeak_outdir(wildcards, output):
    return os.path.dirname(output[0])


# Peak type to be called by MACS
if config["macs2_narrow"]:
    MACS2_PEAK_TYPE = "narrow"

else:
    MACS2_PEAK_TYPE = "broad"

# Normalize?
if config["method"] == "PROseq":
    NORMALIZE = True

else:
    NORMALIZE = False


### Deal with annoying string formatting in bedtools shell scripts

# + strand proecssing
GC_PLUS = "-bga -strand + {}".format(str(config["genomecov_params"]))
GC_PLUS = GC_PLUS.strip()

# - strand processing
GC_MINUS = "-bga -strand - {}".format(str(config["genomecov_params"]))
GC_MINUS = GC_MINUS.strip()

# no strand
GC = "-bga {}".format(str(config["genomecov_params"]))
GC = GC.strip()
