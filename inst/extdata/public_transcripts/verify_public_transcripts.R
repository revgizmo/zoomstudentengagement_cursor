# Quick verification of public transcripts
# Run after fetching with download_public_vtts.sh

suppressPackageStartupMessages(library(zoomstudentengagement))

root <- system.file("extdata", "public_transcripts", package = "zoomstudentengagement")
if (!nzchar(root)) {
  # Fallback if running from source
  root <- file.path("inst", "extdata", "public_transcripts")
}

stopifnot(dir.exists(root))

subdirs <- list.dirs(root, recursive = FALSE)
cat("Public transcript folders:\n")
print(basename(subdirs))

summaries <- list()

for (d in subdirs) {
  vtts <- list.files(d, pattern = "\\.vtt$", full.names = TRUE)
  if (!length(vtts)) next
  cat("\n---\nCourse folder:", basename(d), "\n")
  cat("VTT files:", paste(basename(vtts), collapse = ", "), "\n")
  # Parse first 1-2 files for a quick check
  for (f in head(vtts, 2)) {
    cat("Parsing:", basename(f), "\n")
    tr <- try(parse_zoom_transcript(f), silent = TRUE)
    if (inherits(tr, "try-error")) {
      cat("  Failed to parse\n")
      next
    }
    cat("  Entries:", nrow(tr), " Speakers:", paste(unique(tr$speaker), collapse = ", "), "\n")
    # Simple participation summary
    part <- try(analyze_participation(tr), silent = TRUE)
    if (!inherits(part, "try-error")) {
      print(utils::head(part, 3))
    }
  }
}

cat("\nVerification complete.\n")