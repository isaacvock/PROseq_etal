if[config["macs2_narrow"]]:

    rule annotate_narrowPeaks:
        input:
            peaks="results/macs2_callpeak/{treatment}_peaks.narrowPeak",
            genome=config["genome"],
            gtf=config["annotation"]
        output:
            annotations="results/annotate_narrowPeaks/{treatment}_annot.txt",
        threads: 4
        params:
            mode="",
            extra=config["annotate_macs2Peaks_params"]  # optional params, see http://homer.ucsd.edu/homer/ngs/annotation.html
        log:
            "logs/annotate_narrowPeaks/{treatment}.log"
        wrapper:
            "v2.6.0/bio/homer/annotatePeaks"

else:

    rule annotate_broadPeaks:
        input:
            peaks="results/macs2_callpeak/{treatment}_peaks.broadPeak",
            genome=config["genome"],
            gtf=config["annotation"]
        output:
            annotations="results/annotate_broadPeaks/{treatment}_annot.txt",
        threads: 4
        params:
            mode="",
            extra=config["annotate_macs2Peaks_params"]  # optional params, see http://homer.ucsd.edu/homer/ngs/annotation.html
        log:
            "logs/annotate_narrowPeaks/{treatment}.log"
        wrapper:
            "v2.6.0/bio/homer/annotatePeaks"