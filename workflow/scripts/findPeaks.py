__author__ = "Jan Forster"
__copyright__ = "Copyright 2020, Jan Forster"
__email__ = "j.forster@dkfz.de"
__license__ = "MIT"

from snakemake.shell import shell
import os.path as path
import sys

extra = snakemake.params.get("extra", "")
log = snakemake.log_fmt_shell(stdout=True, stderr=True)

shell(
    "(findPeaks"
    " {snakemake.input.tag}"
    " -style {snakemake.params.style}"
    " {extra}"
    " -o {snakemake.output.transcripts}"
    " -gtf {snakemake.output.gtf})"
    " {log}"
)