#!/usr/bin/env Rscript
### PURPOSE OF THIS SCRIPT
## Take a GTF annotation and create a new annotation file that marks annotated
## pause sites for pause index (PI) creation.

# Load dependencies ------------------------------------------------------------

library(rtracklayer)
library(dplyr)
library(optparse)


# Process parameters -----------------------------------------------------------

args = commandArgs(trailingOnly = TRUE)


option_list <- list(
    make_option(c("-i", "--input", type="character"),
                    help = "Path to input gtf file"),
    make_option(c("-o", "--output", type="character"),
                    help = 'Path to output gtf file'),
    make_option(c("-e", "--echocode", type="logical"),
                    default = "FALSE",
                    help = 'print R code to stdout'))

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser) # Load options from command line.

# Set R code printing for debug mode
options(echo = as.logical(opt$echocode))



# Create new gtf ---------------------------------------------------------------

# Load gtf
gtf <- rtracklayer::import(opt$input)

# Identify pause sites
    # pause site start = 100 bases upstream of most upstream TSS (or 1, if TSS is less than a start of 100 nt)
    # pause site end = pause site start + :
        # 500 if 500 < (width of longest transcript)/2
        # round(width of longest transcript/2) if this is > 60 and < 500
        # 60 if (width of longest transcript/2) < 60
        # width of longest transcript - 1 if this is < 60
PI <- as_tibble(gtf) %>%
  group_by(gene_id, strand) %>%
  summarise(seqnames = unique(seqnames)[1],
            start = pmax(min(start) - 100, 1),
            end = pmax(min(start) - 100, 1) + pmin(pmax(round(pmin(500, max(width)/2)), 60), max(end) - 1),
            source = unique(source)[1],
            type = "pause",
            score = NA,
            phase = NA,
            transcript_id = NA) %>%
  mutate(width = end - start)


# Identify gene bodies (downstream of pause site)
gene_body <- as_tibble(gtf) %>%
  group_by(gene_id, strand) %>%
  summarise(seqnames = unique(seqnames)[1],
            start = pmax(min(start) - 100, 1) + pmin(pmax(round(pmin(500, max(width)/2)), 60), max(end) - 1) + 1,
            end = max(end),
            source = unique(source)[1],
            type = "gene_body",
            score = NA,
            phase = NA,
            transcript_id = NA) %>%
  mutate(width = end - start)



## Turn pause site and gene body info into GenomicRanges for export

gene_body_gr <- GRanges(seqnames = Rle(gene_body$seqnames),
        ranges = IRanges(gene_body$start, end = gene_body$end, 
                         names = 1:nrow(gene_body)),
        strand = Rle(gene_body$strand),
        source = "PacBio",
        type = "gene_body",
        score = NA,
        phase = NA,
        transcript_id = NA,
        gene_id = gene_body$gene_id)

PI_gr <- GRanges(seqnames = Rle(PI$seqnames),
                 ranges = IRanges(PI$start, end = PI$end, 
                                  names = 1:nrow(PI)),
                 strand = Rle(PI$strand),
                 source = "PacBio",
                 type = "pause",
                 score = NA,
                 phase = NA,
                 transcript_id = NA,
                 gene_id = PI$gene_id)


# Create final gtf to export
gtf2 <- c(gtf, gene_body_gr, PI_gr)


# Export gtf with pause index info
rtracklayer::export(gtf2, 
                    opt$output)

