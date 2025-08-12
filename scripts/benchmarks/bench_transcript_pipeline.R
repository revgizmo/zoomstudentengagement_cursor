#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(zoomstudentengagement))
suppressPackageStartupMessages(library(tibble))

args <- commandArgs(trailingOnly = TRUE)
# Optional arg: base temp dir
base_dir <- if (length(args) >= 1) args[[1]] else tempdir()

sample <- system.file("extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
                      package = "zoomstudentengagement")
if (sample == "") {
  stop("Sample transcript not found in installed package")
}

sizes <- c(1, 50, 500)
results <- list()

for (n in sizes) {
  dir_n <- file.path(base_dir, paste0("bench_transcripts_", n))
  if (!dir.exists(dir_n)) dir.create(dir_n, recursive = TRUE)
  # Populate folder with n copies
  for (i in seq_len(n)) {
    file.copy(sample, file.path(dir_n, sprintf("copy_%03d.transcript.vtt", i)), overwrite = TRUE)
  }
  cat(sprintf("\nProcessing %d files in %s...\n", n, dir_n))
  t0 <- Sys.time()
  metrics <- analyze_transcripts(dir_n, write = FALSE)
  t1 <- Sys.time()
  dt <- as.numeric(difftime(t1, t0, units = "secs"))
  cat(sprintf("Elapsed: %.2f sec\n", dt))
  results[[as.character(n)]] <- list(n = n, seconds = dt, rows = nrow(metrics))
}

cat("\nSummary:\n")
print(do.call(rbind, lapply(results, function(x) unlist(x))))