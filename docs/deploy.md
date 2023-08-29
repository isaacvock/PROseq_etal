## Setup

There are 4 steps required to get up and running with PROseq_etal

1. [Install conda (or mamba) on your system](#conda). This is the package manager that PROseq_etal uses to make setting up the necessary dependencies a breeze.
1. [Deploy workflow](#deploy) with [Snakedeploy](https://snakedeploy.readthedocs.io/en/latest/index.html)
1. [Edit the config file](#config) (located in config/ directory of deployed/cloned repo) to your liking
1. [Run it!](#run)

The remaining documentation on this page will describe each of these steps in greater detail and point you to additional documentation that might be useful.

### Install conda (or mamba)<a name="conda"></a>
[Conda](https://docs.conda.io/projects/conda/en/latest/index.html) is a package/environment management system. [Mamba](https://mamba.readthedocs.io/en/latest/) is a newer, faster, C++ reimplementation of conda. While often associated with Python package management, lots of software, including all of the PROseq_etal pipeline dependencies, can be installed with these package managers. They have pretty much the same syntax and can do the same things, so I highly suggest using Mamba in place of Conda whenever possible. 

One way to install Mamba is to first install Conda following the instructions at [this link](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html). Then you can call:

``` bash
conda install -n base -c conda-forge mamba
```
to install Mamba.

A second strategy would be to install Mambaforge, which is similar to something called Miniconda but uses Mamba instead of Conda. I will reproduce the instructions to install Mambaforge below, as this is probably the easiest way to get started with the necessary installation of Mamba. These instructions come from the [Snakemake Getting Started tutorial](https://snakemake.readthedocs.io/en/stable/tutorial/setup.html), so go to that link if you'd like to see the full original details:

* For Linux users with a 64-bit system, run these two lines of code from the terminal:

``` bash
curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh -o Mambaforge-Linux-x86_64.sh
bash Mambaforge-Linux-x86_64.sh
```
* For Mac users with x86_64 architecture: 
``` bash
curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-MacOSX-x86_64.sh -o Mambaforge-MacOSX-x86_64.sh
bash Mambaforge-MacOSX-x86_64.sh
```
* And for Mac users with ARM/M1 architecture:
``` bash
curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-MacOSX-arm64.sh -o Mambaforge-MacOSX-arm64.sh
bash Mambaforge-MacOSX-arm64.sh
```

When asked this question:
``` bash
Do you wish the installer to preprend the install location to PATH ...? [yes|no]
```
answer with `yes`. Prepending to PATH means that after closing your current terminal and opening a new one, you can call the `mamba` (or `conda`) command to install software packages and create isolated environments. We'll be using this in the next step.

### Deploy workflow<a name="deploy"></a>

PROseq_etal can be deployed using the tool [Snakedeploy](https://snakedeploy.readthedocs.io/en/latest/index.html). This is often more convenient than cloning the full repository locally. To get started with Snakedeploy, you first need to create a simple conda environment with Snakemake and Snakedeploy:


``` bash
mamba create -c conda-forge -c bioconda --name deploy_snakemake snakemake snakedeploy
```

Next, create a directory that you want to run PROseq_etal in (I'll refer to it as `workdir`) and move into it:
``` bash
mkdir workdir
cd workdir
```

Now, activate the `deploy_snakemake` environment and deploy the workflow as follows:

``` bash
conda activate deploy_snakemake
snakedeploy deploy-workflow https://github.com/isaacvock/PROseq_etal.git . --branch main
```

`snakedeploy deploy-workflow https://github.com/isaacvock/PROseq_etal.git` copies the content of the `config` directory in the PROseq_etal Github repo into the directoy specified (`.`, which means current directory, i.e., `workdir` in this example). It also creates a directory called `workflow` that contains a singular Snakefile that instructs Snakemake to use the workflow hosted on the main branch (that is what `--branch main` determines) of the PROseq_etal Github repo. `--branch main` can be replaced with any other existing branch.

### Edit the config file<a name="config"></a>
In the `config/` directory you will find a file named `config.yaml`. If you open it in a text editor, you will see several parameters which you can alter to your heart's content. The first parameter that you have to set is at the top of the file:

``` yaml
samples:
  WT_1: data/fastq/WT_1
  WT_2: data/fastq/WT_2
  WT_ctl: data/fastq/WT_ctl
  KO_1: data/fastq/KO_1
  KO_2: data/fastq/KO_2
  KO_ctl: data/fastq/KO_ctl
```
`samples` is the list of sample IDs and paths to .bam files that you want to process. Delete the existing sample names and paths and add yours. The sample names in this example are `WT_1`, `WT_2`, `WT_ctl`, `KO_1`, `KO_2`, and `KO_ctl`. These are the sample names that will append many of the files output by PROseq_etal. The `:` is necessary to distinguish the sample name from what follows, the path to the relevant bam file. Note, the path can be absolute (e.g., ~/path/to/fastqs/) or relative to the directory that you deployed to (i.e., `workdir` in this example). In the example config, the paths specified are relative. Thus, in this example, the bam files are located in a directory called `samples` that is inside of a directory called `data` located in `workdir`. Your data can be wherever you want it to be, but it might be easiest if you put it in a `data` directory inside the PROseq_etal directory as in this example. 

As another example, imagine that the `data` directory was in the directory that contains `workdir`, and that there was no `samples` subdirectory inside of `data`. In that case, the relative paths would look something like this:

``` yaml
samples:
  WT_1: ../data/WT_replicate_1.bam
  WT_2: ../data/WT_replicate_2.bam
  WT_ctl: ../data/WT_nos4U.bam
  KO_1: ../data/KO_replicate_1.bam
  KO_2: ../data/KO_replicate_2.bam
  KO_ctl: ../data/KO_nos4U.bam
```
where `../` means navigate up one directory. 

The next parameter you have to set denotes the experimental method used:

``` yaml
method: "ChIPseq"
```

The current options are "ChIPseq" and "PROseq", with more to come! 

The third parameter is only relevant if you are analyzing ChIPseq data, and it identifies the relevant Input control samples for each enrichment sample:

``` yaml
controls:
  WT_1: WT_ctl
  WT_2: WT_ctl
  KO_1: KO_ctl
  KO_2: KO_ctl
```
The "keys" (what is to the left of the ":") are sample IDs from `samples:`. The sample IDs in this section should only correspond to the IDs for enriched samples. The "values" (what is to the right of the ":") is the sample ID for the relevant Input sample. In this example, the sample labeled WT_ctl is the Input sample from which the WT_1 enrichment sample was derived. Fold enrichment tracks for WT_1 will be calculated using WT_ctl as the Input reference.

The remaining somewhat more self-explanatory required parameters are:

* `genome`: Path to genome fasta file to be used for alignment.
* `aligner`: Determines which aligner will be used (options are "bwa-mem2" and "bowtie2").
* `indices`: Path to aligner indices. These will be created at this path if not already present.
* `annotation`: Path to annotation gtf file to be used by HTSeq.
* `PI_gtf`: Path to pause site annotation gtf file to be used to calculate pause indices with HTSeq and custom scripts. This will be created automatically at this path if it does not already exist.
* `strandedness`: HTSeq parameter specifying library strandedness. Options are "reverse", "yes", or "no". See config comments and/or [HTSeq documentation](https://htseq.readthedocs.io/en/master/htseqcount.html) for more details.

 The remaining parmeters allow you to tune and alter the functionality of all tools used by PROseq_etal. The top of this set includes three parameters that are probably best to check before running the pipeline. See config comments and linked documentation for details. The remaining are purely optional but can allow you to modify default settings of any tool used. **You never have to set parameters specifying output files or number of threads to be used**; PROseq_etal will handle these automatically.

### Run it!<a name="run"></a>

Once steps 1-3 are complete, PROseq_etal can be run from the directory you deployed the workflow to as follows:

``` bash
snakemake --cores all --use-conda
```
There are **A LOT** of adjustable parameters that you can play with when running a Snakemake pipeline. I would point you to the [Snakemake documentation](https://snakemake.readthedocs.io/en/stable/executing/cli.html) 
for the details on everything you can change when running the pipeline.

