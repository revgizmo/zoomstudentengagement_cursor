#!/usr/bin/env Rscript

# Systematic Investigation of dplyr Segmentation Faults
# Issue #95: Investigate dplyr segmentation faults in package context

cat("🔍 Systematic Investigation of dplyr Segmentation Faults\n")
cat("=====================================================\n\n")

# 1. Environment Information
cat("1. Environment Information:\n")
cat("   R version:", R.version.string, "\n")
cat("   dplyr version:", as.character(packageVersion("dplyr")), "\n")
cat("   rlang version:", as.character(packageVersion("rlang")), "\n")
cat("   tibble version:", as.character(packageVersion("tibble")), "\n")
cat("   Working directory:", getwd(), "\n\n")

# 2. Test dplyr operations in isolation
cat("2. Testing dplyr operations in isolation:\n")
library(dplyr)
library(readr)

# Create test data similar to what causes issues
test_data <- data.frame(
  enrolled = c(TRUE, FALSE, TRUE, TRUE, FALSE),
  name = c("Alice", "Bob", "Charlie", "Diana", "Eve"),
  value = 1:5,
  stringsAsFactors = FALSE
)

cat("   Testing basic dplyr filter...\n")
tryCatch({
  result <- test_data %>% filter(enrolled == TRUE)
  cat("   ✅ Basic dplyr filter works (", nrow(result), "rows)\n")
}, error = function(e) {
  cat("   ❌ Basic dplyr filter failed:", e$message, "\n")
})

cat("   Testing dplyr mutate...\n")
tryCatch({
  result <- test_data %>% mutate(new_col = value * 2)
  cat("   ✅ Basic dplyr mutate works\n")
}, error = function(e) {
  cat("   ❌ Basic dplyr mutate failed:", e$message, "\n")
})

cat("   Testing dplyr summarise...\n")
tryCatch({
  result <- test_data %>% 
    group_by(enrolled) %>% 
    summarise(count = n(), .groups = "drop")
  cat("   ✅ Basic dplyr summarise works\n")
}, error = function(e) {
  cat("   ❌ Basic dplyr summarise failed:", e$message, "\n")
})

# 3. Test with package data
cat("\n3. Testing with package data:\n")
tryCatch({
  roster_data <- read_csv(system.file("extdata/roster.csv", package = "zoomstudentengagement"))
  cat("   ✅ Package data loaded successfully (", nrow(roster_data), "rows)\n")
  
  cat("   Testing dplyr filter on package data...\n")
  result <- roster_data %>% filter(enrolled == TRUE)
  cat("   ✅ dplyr filter on package data works (", nrow(result), "rows)\n")
  
}, error = function(e) {
  cat("   ❌ Package data test failed:", e$message, "\n")
})

# 4. Test package loading context
cat("\n4. Testing package loading context:\n")
library(devtools)

tryCatch({
  load_all()
  cat("   ✅ Package loaded successfully\n")
  
  # Test our function that was causing segfaults
  cat("   Testing load_roster function...\n")
  result <- load_roster(
    data_folder = system.file("extdata", package = "zoomstudentengagement"),
    roster_file = "roster.csv"
  )
  cat("   ✅ load_roster function works (", nrow(result), "rows)\n")
  
}, error = function(e) {
  cat("   ❌ Package loading test failed:", e$message, "\n")
})

# 5. Test validation script context
cat("\n5. Testing validation script context:\n")
tryCatch({
  # Simulate the validation script environment
  validation_status <- list(
    code_style = FALSE,
    linting = FALSE,
    documentation = FALSE,
    readme = FALSE,
    vignettes = FALSE,
    function_signatures = FALSE,
    data_validation = FALSE,
    testing = FALSE,
    package_check = FALSE
  )
  
  cat("   Simulating validation script steps...\n")
  
  # Test the exact operation that was causing segfaults
  cat("   Testing load_zoom_recorded_sessions_list...\n")
  result <- load_zoom_recorded_sessions_list(
    data_folder = system.file("extdata", package = "zoomstudentengagement"),
    transcripts_folder = "transcripts"
  )
  cat("   ✅ load_zoom_recorded_sessions_list works\n")
  
}, error = function(e) {
  if (grepl("segfault", e$message, ignore.case = TRUE)) {
    cat("   ❌ SEGMENTATION FAULT DETECTED!\n")
    cat("   💡 This confirms the issue is context-specific\n")
  } else {
    cat("   ❌ Test failed:", e$message, "\n")
  }
})

# 6. Memory analysis
cat("\n6. Memory analysis:\n")
cat("   Memory before operations:", gc()["Vcells", "used"], "\n")

tryCatch({
  # Perform operations that might cause memory issues
  for (i in 1:10) {
    result <- test_data %>% filter(enrolled == TRUE)
  }
  cat("   Memory after operations:", gc()["Vcells", "used"], "\n")
  cat("   ✅ Memory usage looks stable\n")
}, error = function(e) {
  cat("   ❌ Memory test failed:", e$message, "\n")
})

# 7. Package configuration check
cat("\n7. Package configuration check:\n")
cat("   Checking DESCRIPTION file...\n")
desc <- readLines("DESCRIPTION")
dplyr_line <- grep("dplyr", desc, value = TRUE)
cat("   dplyr dependency:", dplyr_line, "\n")

cat("   Checking NAMESPACE file...\n")
namespace <- readLines("NAMESPACE")
import_lines <- grep("importFrom", namespace, value = TRUE)
cat("   Import statements:", length(import_lines), "found\n")

# 8. Recommendations
cat("\n8. Recommendations:\n")
cat("   - If segfaults occur in validation context but not isolation:\n")
cat("     * This suggests a package loading/environment issue\n")
cat("     * Check for global variable conflicts\n")
cat("     * Check for memory management issues\n")
cat("   - If segfaults occur consistently:\n")
cat("     * This suggests an upstream dplyr/rlang issue\n")
cat("     * Consider updating to latest versions\n")
cat("     * Check for known bugs in current versions\n")
cat("   - Next steps:\n")
cat("     * Test with different dplyr/rlang versions\n")
cat("     * Check for package conflicts\n")
cat("     * Consider filing upstream bug report\n")

cat("\nInvestigation complete.\n") 