#!/usr/bin/env Rscript
# Setup script for QA testing of zoomstudentengagement package
# Run this script to prepare your environment for testing

cat("=== QA Testing Setup for zoomstudentengagement ===\n\n")

# Check if package is installed
if (!require(zoomstudentengagement, quietly = TRUE)) {
  cat("❌ Package 'zoomstudentengagement' not found.\n")
  cat("Installing from GitHub...\n")
  
  if (!require(devtools, quietly = TRUE)) {
    install.packages("devtools")
  }
  
  devtools::install_github("revgizmo/zoomstudentengagement")
  cat("✅ Package installed successfully.\n\n")
} else {
  cat("✅ Package 'zoomstudentengagement' is already installed.\n")
  cat("Version:", as.character(packageVersion("zoomstudentengagement")), "\n\n")
}

# Create testing directory relative to current working directory
test_dir <- file.path(getwd(), "zoom_real_world_testing")
if (!dir.exists(test_dir)) {
  dir.create(test_dir, recursive = TRUE)
  cat("✅ Created testing directory:", test_dir, "\n")
} else {
  cat("ℹ️  Testing directory already exists:", test_dir, "\n")
}

# Create subdirectories
subdirs <- c(
  "data",
  "data/transcripts", 
  "data/metadata",
  "outputs",
  "reports"
)

for (subdir in subdirs) {
  full_path <- file.path(test_dir, subdir)
  if (!dir.exists(full_path)) {
    dir.create(full_path, recursive = TRUE)
    cat("✅ Created:", subdir, "\n")
  }
}

cat("\n=== Setup Complete ===\n")
cat("📁 Testing directory:", test_dir, "\n")
cat("📁 Data directory:", file.path(test_dir, "data"), "\n")
cat("📁 Outputs directory:", file.path(test_dir, "outputs"), "\n")
cat("📁 Reports directory:", file.path(test_dir, "reports"), "\n\n")

cat("📋 NEXT STEPS:\n")
cat("1. Copy your Zoom transcript files (.vtt) to:", file.path(test_dir, "data/transcripts"), "\n")
cat("2. Copy your student roster (.csv) to:", file.path(test_dir, "data/metadata"), "\n")
cat("3. Copy your Zoom recordings list (.csv) to:", file.path(test_dir, "data/metadata"), "\n")
cat("4. Open qa_test_scenario_1.Rmd and run the analysis\n\n")

cat("📖 For detailed instructions, see qa_test_scenario_1.Rmd\n")
cat("🐛 For issues, visit: https://github.com/revgizmo/zoomstudentengagement/issues\n\n")

cat("✅ Setup completed successfully!\n") 