#!/usr/bin/env Rscript
# Setup script for real-world testing using package test data
# This script sets up the required directory structure and copies test data

cat("🔧 Setting up real-world testing environment with package test data\n")
cat("================================================================\n\n")

# Load the package
devtools::load_all()

# Create required directories
dirs <- c("data", "data/transcripts", "data/metadata", "reports", "outputs")
for (dir in dirs) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat("✅ Created directory:", dir, "\n")
  } else {
    cat("ℹ️  Directory exists:", dir, "\n")
  }
}

# Copy transcript files
transcript_files <- list.files(
  system.file("extdata/transcripts", package = "zoomstudentengagement"),
  full.names = TRUE,
  pattern = "\\.(vtt|txt|csv)$"
)

for (file in transcript_files) {
  dest_file <- file.path("data/transcripts", basename(file))
  file.copy(file, dest_file, overwrite = TRUE)
  cat("✅ Copied transcript file:", basename(file), "\n")
}

# Copy metadata files
metadata_files <- c(
  "roster.csv",
  "cancelled_classes.csv",
  "transcripts_summary.csv",
  "transcripts_session_summary.csv"
)

for (file in metadata_files) {
  src_file <- system.file("extdata", file, package = "zoomstudentengagement")
  if (file.exists(src_file)) {
    dest_file <- file.path("data/metadata", file)
    file.copy(src_file, dest_file, overwrite = TRUE)
    cat("✅ Copied metadata file:", file, "\n")
  }
}

# Copy section names lookup
lookup_file <- system.file("extdata/section_names_lookup.csv", package = "zoomstudentengagement")
if (file.exists(lookup_file)) {
  dest_file <- file.path("data", "section_names_lookup.csv")
  file.copy(lookup_file, dest_file, overwrite = TRUE)
  cat("✅ Copied section names lookup file\n")
}

cat("\n🎉 Real-world testing environment setup complete!\n")
cat("📁 Data directory structure:\n")
cat("   data/transcripts/ - Contains test transcript files\n")
cat("   data/metadata/ - Contains test roster and metadata files\n")
cat("   data/ - Contains section names lookup file\n")
cat("   reports/ - Will contain test results\n")
cat("   outputs/ - Will contain test outputs\n\n")

cat("🚀 You can now run: ./run_tests.sh\n")



