This page discusses advice for running the pipeline, as well as information about how the pipeline is structured. This can be useful for understanding the inner workings of the pipeline.


## Pipeline usage tips

* Save a copy of the PROseq_etal config file along with the output of the pipeline. This can facilitate rerunning the pipeline on datasets you already ran it on once.
* If the pipeline fails due to time out of a rule, or because you purposely cancelled its jobs prematurely, the directory in which you ran the pipeline can become "locked". You'll know when this happens because trying to rerun the pipeline will yield an error saying something along the lines of "the directory is locked". To unlock it, activate an environment with Snakemake installed and run `snakemake --unlock` inside the locked directory. 
* If something goes wrong, make sure to check both the .log and .out files. The former usually contains the output of running a particular tool (e.g., bwa-mem2), and this is often most useful for identifying the source of a problem. In some cases though, such logs of the output of a tool are not possible to capture, leaving the .out file to capture any relevant error messages.
* If running the pipeline within scratch60, parts of the conda environments created by the pipeline can get deleted in the 60 day time period. You can tell this is the case when log files suggest that the relevant software is not available (e.g., "samtools: command not found"). You can force the pipeline to recreate the conda environemnts by deleting the hidden `.snakemake/` directory contained in your working directory (the directory in which you ran the pipeline): `rm -r .snakemake`
* One plus of using Snakedeploy to deploy PROseq_etal is that you don't have to manually update the pipeline. If you are tracking the main branch of the repository, then you will always be running the most up-to-date code on that branch. There can be a bit of a lag (a couple minutes at the most) between updates being made to a branch, and those changes being registered by a Snakedeploy deployed workflow. Be mindful of this if you are trying to run the pipeline with recently made changes.
* As PROseq_etal matures, it will gain new branches and tags (the latter of which are old branches saved for posterity and reproducibilites sake). At any time, you can change which branch of the pipeline you are using by going into the `workflow/` directory created when you first deploy the workflow with Snakedeploy. Inside, you will find a lone, rather concise Snakefile. The meat of it will look like:

``` python
module PROseq_etal:
    snakefile:
        github("isaacvock/PROseq_etal", path="workflow/Snakefile", branch = "main")
    config:
        config
```

>You can change `branch = "main"` to whatever existing branch you please.

## Structure of the pipeline

The pipeline is structured [as recommended](https://snakemake.readthedocs.io/en/stable/snakefiles/deployment.html#integrated-package-management) by the Snakemake developers. A Snakefile is located in the `workflow/` directory. This Snakefile is fairly barebones and merely indicates what the expected final output is, and what files contain all of the rules to run. Each step of the pipeline is specified in .smk files in the `workflow/rules/` directory. These files are split up into sets of similar rules (e.g., all of the MACS2 rules are in one .smk file, called `macs2.smk`).

Some of the rules are wrappers from the [Snakemake wrapper repository](https://snakemake-wrappers.readthedocs.io/en/stable/). These wrappers load remote conda environment specifications stored in a common Github repo. Some of the rules are custom made and thus require custom conda environments that are specific to PROseq_etal. These conda environments are specified in .yaml files in the `workflow/envs/` directory. They specify the dependencies for sets of related rules, and what conda channes they can be downloaded from.

Finally, some steps use custom scripts that I wrote. These scripts are located in the `workflow/scripts` directory. Python scripts are easy to call in Snakemake rules, but a little bit of extra effort is required to call non-Python scripts. Such rules typically look like:

``` python
params:
    rscript=workflow.source_path("../scripts/calculate_PI.R")
threads: 1
shell:
    r"""
    chmod +x {params.rscript}
    {params.rscript} -p {input.pause} -g {input.gb} -a {input.gtf} -o {output.PI}
    """
```

This is an example from the step of the pipeline that calculates pause indices. The script has to be specified using `workflow.source_path(...)`, which causes Snakemake to create a temporary copy of the script on your system. This causes problems in newer versions of Snakemake, as the act of copying these scripts is often logged as a change that causes the relevant step to get rerun even if its inputs have remained unchanged. In the `run_slurm.sh` script in the yale_profile repository discussed in the Yale deployment documentation, that is why `--rerun-triggers mtime` is included in the call to Snakemake; this makes it so that bona fide modification of inputs is the only thing that will trigger a rerun a rule. Finally, note that the script needs to be made executable with `chmod +x {params.rscript}`.


