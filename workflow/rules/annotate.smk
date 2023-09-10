rule annotate_broadPeaks:
    input:
        bed_graph="results/macs2_callpeak/{treatment}_peaks.broadPeak",
        genome=config["genome"],
        gtf=config["annotation"]
    output:
        annotations="results/annotate_broadPeaks/{treatment}_annot.txt",
    threads: 4
    params:
        mode="",
        extra=config["annotate_broadPeaks_params"]  # optional params, see http://homer.ucsd.edu/homer/ngs/annotation.html
    log:
        "logs/homer_annotatePeaks/annotatePeaks.log"
    wrapper:
        "v2.6.0/bio/homer/annotatePeaks"