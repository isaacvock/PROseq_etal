#!/usr/bin/env Rscript
### PURPOSE OF THIS SCRIPT
## Calculate pause index in PROseq_etal pipeline

# Load dependencies ------------------------------------------------------------

library(readr)
library(dplyr)
library(rtracklayer)
library(optparse)

# Process parameters -----------------------------------------------------------

args = commandArgs(trailingOnly = TRUE)


option_list <- list(
  make_option(c("-p", "--pause", type="character"),
              help = "Path to input pause site coverage quantification"),
  make_option(c("-g", "--genebody", type="character"),
              help = 'Path to input gene body coverage quantification'),
  make_option(c("-o", "--output", type="character"),
              help = 'Path to output table'),
  make_option(c("-a", "--annotation", type="character"),
              help = 'Path to annotation gtf file'),
  make_option(c("-e", "--echocode", type="logical"),
              default = "FALSE",
              help = 'print R code to stdout'))

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser) # Load options from command line.

# Set R code printing for debug mode
options(echo = as.logical(opt$echocode))


# Calculate pause index --------------------------------------------------------

### Load data
pause <- read_csv(opt$pause)
genebody <- read_csv(opt$genebody)
gtf <- as_tibble(rtracklayer::import(opt$annotation))

### Add column names
colnames(pause) <- c("gene_id", "seqnames", "pause_reads")
colnames(genebody) <- c("gene_id", "seqnames", "gb_reads")


### Filter out pause site 0s and merge
merged <- inner_join(pause,
                     genebody %>% filter(gb_reads > 0) %>% 
                       filter(!grepl("__", gene_id)),
                     by = c("gene_id", "seqnames"))


### Get lengths of features
gb_l <- gtf %>%
  filter(type == "gene_body") %>%
  dplyr::mutate(gb_length = width) %>%
  dplyr::select(seqnames, gb_length, gene_id) %>%
  dplyr::distinct()

p_l <- gtf %>%
  filter(type == "pause") %>%
  dplyr::mutate(p_length = width) %>%
  dplyr::select(seqnames, p_length, gene_id) %>%
  dplyr::distinct()


### RPK normalized pause index

# Add gb length
merged <- inner_join(merged, gb_l, by = c("seqnames", "gene_id"))
merged <- inner_join(merged, p_l, by = c("seqnames", "gene_id"))

# Calculate PI
merged <- merged %>%
  mutate(PI = (pause_reads/(p_length/1000))/(gb_reads/(gb_length/1000)))


### Save output

write_csv(merged, file = opt$output)

