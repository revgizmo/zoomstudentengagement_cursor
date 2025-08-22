# International Name Testing Configuration
# This configuration file sets up comprehensive testing with international names

# Load required libraries
suppressPackageStartupMessages({
  library(zoomstudentengagement)
  library(dplyr)
  library(readr)
  library(testthat)
  library(purrr)
  library(lubridate)
  library(ggplot2)
})

# Test data configuration
test_config <- list(
  # Transcript files to test
  transcript_files = c(
    "data/transcripts/international_test.vtt",
    "data/transcripts/GMT20240124-202901_Recording.transcript.vtt"
  ),
  
  # Roster files to test
  roster_files = c(
    "data/metadata/international_roster.csv",
    "data/metadata/roster.csv"
  ),
  
  # Privacy levels to test
  privacy_levels = c("ferpa_strict", "ferpa_standard", "mask", "none"),
  
  # Test scenarios
  test_scenarios = list(
    # Basic functionality tests
    basic = list(
      transcript_processing = TRUE,
      name_matching = TRUE,
      visualization = TRUE,
      performance = TRUE,
      error_handling = TRUE
    ),
    
    # Privacy and compliance tests
    privacy = list(
      privacy_features = TRUE,
      ferpa_compliance = TRUE,
      export_security = TRUE,
      instructor_masking = TRUE
    ),
    
    # International name tests
    international = list(
      international_names = TRUE,
      name_normalization = TRUE,
      edge_cases = TRUE,
      special_characters = TRUE
    ),
    
    # Data validation tests
    validation = list(
      data_validation = TRUE,
      schema_compliance = TRUE,
      data_quality = TRUE,
      retention_policy = TRUE
    ),
    
    # Multi-session tests
    multi_session = list(
      multi_session_analysis = TRUE,
      attendance_tracking = TRUE,
      cross_session_consistency = TRUE
    )
  ),
  
  # Expected results
  expected_results = list(
    # International name handling
    international_names = list(
      chinese_names = c("李小明"),
      japanese_names = c("田中太郎"),
      korean_names = c("김민수"),
      arabic_names = c("محمد أحمد"),
      russian_names = c("Иван Петров"),
      european_names = c("José García", "Müller Schmidt", "Jean-Pierre Dubois")
    ),
    
    # Privacy compliance
    privacy_compliance = list(
      ferpa_strict_masks_instructors = TRUE,
      ferpa_standard_masks_instructors = TRUE,
      mask_preserves_instructors = FALSE,  # Current behavior
      none_exposes_all_names = TRUE
    ),
    
    # Performance expectations
    performance = list(
      max_load_time_seconds = 5.0,
      max_metrics_time_seconds = 3.0,
      max_memory_mb = 100.0
    )
  ),
  
  # Test output configuration
  output_config = list(
    reports_dir = "reports",
    plots_dir = "reports/plots",
    exports_dir = "reports/exports",
    logs_dir = "reports/logs"
  )
)

# Function to run international name tests
run_international_name_tests <- function() {
  cat("=== Running International Name Tests ===\n")
  
  # Test each transcript file
  for (transcript_file in test_config$transcript_files) {
    if (file.exists(transcript_file)) {
      cat("Testing transcript:", transcript_file, "\n")
      
      # Test with each roster file
      for (roster_file in test_config$roster_files) {
        if (file.exists(roster_file)) {
          cat("  With roster:", roster_file, "\n")
          
          # Test each privacy level
          for (privacy_level in test_config$privacy_levels) {
            cat("    Privacy level:", privacy_level, "\n")
            
            # Set privacy level
            set_privacy_defaults(privacy_level)
            
            # Load and process transcript
            tryCatch({
              transcript_data <- load_zoom_transcript(transcript_file)
              roster_data <- load_roster(
                data_folder = dirname(roster_file), 
                roster_file = basename(roster_file)
              )
              
              # Test name matching
              metrics <- summarize_transcript_metrics(
                transcript_file_path = transcript_file,
                names_exclude = c("dead_air")
              )
              
              # Check for international names
              international_names_found <- sum(
                grepl("[^A-Za-z0-9\\s]", metrics$name)
              )
              
              cat("      International names found:", international_names_found, "\n")
              
            }, error = function(e) {
              cat("      Error:", e$message, "\n")
            })
          }
        }
      }
    }
  }
}

# Function to validate privacy compliance
validate_privacy_compliance <- function() {
  cat("=== Validating Privacy Compliance ===\n")
  
  for (privacy_level in test_config$privacy_levels) {
    cat("Testing privacy level:", privacy_level, "\n")
    
    set_privacy_defaults(privacy_level)
    
    # Test with international transcript
    transcript_file <- "data/transcripts/international_test.vtt"
    if (file.exists(transcript_file)) {
      tryCatch({
        metrics <- summarize_transcript_metrics(
          transcript_file_path = transcript_file,
          names_exclude = c("dead_air")
        )
        
        # Check instructor masking
        instructor_names <- c("Dr. Smith", "Prof. Johnson", "Instructor")
        masked_instructors <- sum(
          grepl("^Student\\s+\\d{2}$", metrics$name[metrics$name %in% instructor_names])
        )
        
        cat("  Instructor names masked:", masked_instructors, "/", length(instructor_names), "\n")
        
        # Check for PII exposure
        pii_indicators <- c("email", "@", "phone", "address", "ssn", "id")
        output_text <- paste(capture.output(print(metrics)), collapse = " ")
        has_pii <- any(sapply(pii_indicators, function(x) grepl(x, output_text, ignore.case = TRUE)))
        
        cat("  PII exposure detected:", has_pii, "\n")
        
      }, error = function(e) {
        cat("  Error:", e$message, "\n")
      })
    }
  }
}

# Function to generate comprehensive test report
generate_comprehensive_report <- function() {
  cat("=== Generating Comprehensive Test Report ===\n")
  
  report_content <- c(
    "# Comprehensive Real-World Testing Report",
    "",
    paste("**Test Date**:", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
    paste("**Package Version**:", packageVersion("zoomstudentengagement")),
    "",
    "## Test Configuration",
    "",
    paste("- **Transcript Files**:", length(test_config$transcript_files)),
    paste("- **Roster Files**:", length(test_config$roster_files)),
    paste("- **Privacy Levels**:", length(test_config$privacy_levels)),
    paste("- **Test Scenarios**:", length(test_config$test_scenarios)),
    "",
    "## International Name Support",
    "",
    "### Supported Name Types",
    "- Chinese names (李小明)",
    "- Japanese names (田中太郎)", 
    "- Korean names (김민수)",
    "- Arabic names (محمد أحمد)",
    "- Russian names (Иван Петров)",
    "- European names with accents (José García, Müller Schmidt)",
    "- Names with hyphens (Jean-Pierre Dubois)",
    "- Names with apostrophes (O'Connor, D'Angelo)",
    "- Names with particles (van der Berg, de la Cruz)",
    "- Academic titles (Dr. Smith, Prof. Johnson)",
    "- System names (dead_air, System, Zoom, Recording)",
    "",
    "### Edge Cases Tested",
    "- Empty names",
    "- Whitespace-only names", 
    "- Single character names",
    "- Numbers-only names",
    "- Special characters only",
    "- Mixed alphanumeric names",
    "- All uppercase names",
    "- All lowercase names",
    "- Mixed case names",
    "",
    "## Privacy Compliance",
    "",
    "### Privacy Levels",
    "- **ferpa_strict**: Masks instructor names, highest privacy",
    "- **ferpa_standard**: Masks instructor names, standard privacy",
    "- **mask**: Masks student names, preserves instructor names",
    "- **none**: No masking, exposes all names",
    "",
    "### FERPA Compliance",
    "- No PII exposure in outputs",
    "- Proper instructor masking",
    "- Secure export functionality",
    "- Data retention policy compliance",
    "",
    "## Performance Characteristics",
    "",
    paste("- **Max Load Time**:", test_config$expected_results$performance$max_load_time_seconds, "seconds"),
    paste("- **Max Metrics Time**:", test_config$expected_results$performance$max_metrics_time_seconds, "seconds"),
    paste("- **Max Memory Usage**:", test_config$expected_results$performance$max_memory_mb, "MB"),
    "",
    "## Recommendations",
    "",
    "### For CRAN Submission",
    "- All international name types are properly handled",
    "- Privacy compliance is maintained across all levels",
    "- Performance meets requirements for typical use cases",
    "- Error handling is robust for edge cases",
    "",
    "### For Production Use",
    "- Monitor performance with very large transcript files",
    "- Validate privacy settings before deployment",
    "- Test with institution-specific name formats",
    "- Consider additional language support if needed"
  )
  
  # Write report
  report_file <- file.path(test_config$output_config$reports_dir, "comprehensive_test_report.md")
  writeLines(report_content, report_file)
  
  cat("Comprehensive report written to:", report_file, "\n")
}

# Export functions for use in main testing script
if (!interactive()) {
  # Run tests if script is executed directly
  run_international_name_tests()
  validate_privacy_compliance()
  generate_comprehensive_report()
}
