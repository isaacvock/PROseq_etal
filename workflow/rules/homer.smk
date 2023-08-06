rule homer_makeTagDir:
    input:
        bam=expand("results/align/{SID}.bam", SID = SAMP_NAMES),
    output:
        directory("tagDir/{sample}")