# Example Configuration for Real-World Testing
# Copy this file to config.R and modify as needed

# Test Configuration
test_config <- list(
  
  # Data directories
  data_dirs = list(
    transcripts = "data/transcripts",
    metadata = "data/metadata"
  ),
  
  # Output directories
  output_dirs = list(
    reports = "reports",
    outputs = "outputs"
  ),
  
  # Test scenarios to run
  scenarios = c(
    "functionality",  # Core functionality tests
    "performance",    # Performance and memory tests
    "privacy",        # Privacy and security tests
    "edge_cases"      # Error handling and edge cases
  ),
  
  # Performance thresholds
  performance = list(
    max_processing_time = 300,  # seconds
    max_memory_usage = 1024,    # MB
    max_file_size = 50          # MB
  ),
  
  # Privacy settings
  privacy = list(
    mask_names = TRUE,
    anonymize_data = TRUE,
    check_sensitive_content = TRUE
  ),
  
  # Test data requirements
  data_requirements = list(
    min_transcript_files = 1,
    min_roster_records = 5,
    require_session_metadata = TRUE
  ),
  
  # Output settings
  output = list(
    generate_plots = TRUE,
    save_results = TRUE,
    create_report = TRUE,
    include_timestamps = TRUE
  ),
  
  # Logging settings
  logging = list(
    level = "INFO",  # DEBUG, INFO, WARN, ERROR
    log_to_file = TRUE,
    log_file = "test_run.log"
  )
)

# Save the configuration
saveRDS(test_config, "test_config.rds")

cat("Example configuration saved to test_config.rds\n")
cat("Copy this file to config.R and modify as needed for your testing environment.\n") 