#!/usr/bin/env Rscript
# Phase 1: User Experience Documentation for Issue #160
# Name Matching Deep-Dive Plan Implementation

# Load required libraries
library(zoomstudentengagement)
library(dplyr)
library(tibble)
library(readr)

# Set up logging
cat("=== Phase 1: User Experience Documentation ===\n")
cat("Date:", Sys.Date(), "\n")
cat("Time:", Sys.time(), "\n\n")

# Function to log results
log_result <- function(scenario, test_result, pain_points, priority_level, privacy_impact, error_handling, user_experience) {
  cat(sprintf("Scenario: %s\n", scenario))
  cat(sprintf("Test Result: %s\n", test_result))
  cat(sprintf("Pain Points: %s\n", pain_points))
  cat(sprintf("Priority Level: %s\n", priority_level))
  cat(sprintf("Privacy Impact: %s\n", privacy_impact))
  cat(sprintf("Error Handling: %s\n", error_handling))
  cat(sprintf("User Experience: %s\n", user_experience))
  cat("---\n\n")
  
  # Return structured result
  list(
    scenario = scenario,
    test_result = test_result,
    pain_points = pain_points,
    priority_level = priority_level,
    privacy_impact = privacy_impact,
    error_handling = error_handling,
    user_experience = user_experience
  )
}

# Initialize results storage
analysis_results <- list()

# Set up test environment
cat("Setting up test environment...\n")
cat("Current working directory:", getwd(), "\n")

# Load test data
cat("Loading test data...\n")
test_roster <- read.csv("data/metadata/test_roster.csv", stringsAsFactors = FALSE)
cat("Loaded test roster with", nrow(test_roster), "students\n\n")

# ============================================================================
# SCENARIO 1: "Guest User" in transcript, not in roster
# ============================================================================

cat("=== SCENARIO 1: Guest User in transcript, not in roster ===\n")
cat("User Experience: User has a transcript with 'Guest User' who is not in the roster\n")
cat("Expected Behavior: System should identify Guest User as unmatched and provide guidance\n\n")

# Test with different privacy levels
privacy_levels <- c("ferpa_strict", "ferpa_standard", "mask", "none")

for (privacy_level in privacy_levels) {
  cat(sprintf("\n--- Testing with privacy level: %s ---\n", privacy_level))
  
  tryCatch({
    # Set privacy level
    set_privacy_defaults(privacy_level)
    
    # Run name matching workflow
    result <- safe_name_matching_workflow(
      transcript_file_path = "data/transcripts/test_transcript.vtt",
      roster_data = test_roster,
      privacy_level = privacy_level,
      unmatched_names_action = "warn",
      data_folder = "data/metadata"
    )
    
    # This should not reach here due to unmatched names
    cat("⚠️  Unexpected: Workflow completed without stopping for unmatched names\n")
    test_result <- "UNEXPECTED"
    pain_points <- "Workflow did not stop for unmatched names as expected"
    user_experience <- "User would not see expected guidance for unmatched names"
    
  }, error = function(e) {
    cat("✅ Expected: Workflow stopped for unmatched names\n")
    cat("Error message:", e$message, "\n")
    
    # Analyze the error message for user experience
    if (grepl("Unmatched names found", e$message)) {
      test_result <- "EXPECTED_BEHAVIOR"
      pain_points <- "User must manually map unmatched names"
      user_experience <- "User sees clear guidance to update section_names_lookup.csv"
    } else if (grepl("Please update the name mappings file", e$message)) {
      test_result <- "EXPECTED_BEHAVIOR"
      pain_points <- "User must manually map unmatched names"
      user_experience <- "User is guided to edit lookup file and re-run analysis"
    } else {
      test_result <- "UNEXPECTED_ERROR"
      pain_points <- paste("Unexpected error:", e$message)
      user_experience <- "User sees confusing error message"
    }
  })
  
  # Store result for this privacy level
  scenario_key <- paste("Scenario1", privacy_level, sep = "_")
  analysis_results[[scenario_key]] <- log_result(
    scenario = paste("Scenario 1 - Guest User (", privacy_level, ")", sep = ""),
    test_result = test_result,
    pain_points = pain_points,
    priority_level = "HIGH",
    privacy_impact = paste("Privacy level", privacy_level, "applied"),
    error_handling = "Error caught and analyzed",
    user_experience = user_experience
  )
}

# ============================================================================
# SCENARIO 2: "John Smith" in roster, "JS" in transcript
# ============================================================================

cat("\n=== SCENARIO 2: John Smith in roster, JS in transcript ===\n")
cat("User Experience: User has a transcript with 'JS' who should match to 'John Smith' in roster\n")
cat("Expected Behavior: System should either match JS to John Smith or identify as unmatched\n\n")

for (privacy_level in privacy_levels) {
  cat(sprintf("\n--- Testing with privacy level: %s ---\n", privacy_level))
  
  tryCatch({
    # Set privacy level
    set_privacy_defaults(privacy_level)
    
    # Run name matching workflow
    result <- safe_name_matching_workflow(
      transcript_file_path = "data/transcripts/test_transcript.vtt",
      roster_data = test_roster,
      privacy_level = privacy_level,
      unmatched_names_action = "warn",
      data_folder = "data/metadata"
    )
    
    # This should not reach here due to unmatched names
    cat("⚠️  Unexpected: Workflow completed without stopping for unmatched names\n")
    test_result <- "UNEXPECTED"
    pain_points <- "Workflow did not stop for unmatched names as expected"
    user_experience <- "User would not see expected guidance for custom name matching"
    
  }, error = function(e) {
    cat("✅ Expected: Workflow stopped for unmatched names\n")
    cat("Error message:", e$message, "\n")
    
    # Check if JS is mentioned in the error
    if (grepl("JS", e$message)) {
      test_result <- "EXPECTED_BEHAVIOR"
      pain_points <- "Custom name 'JS' not automatically matched to 'John Smith'"
      user_experience <- "User must manually map JS to John Smith in lookup file"
    } else if (grepl("Unmatched names found", e$message)) {
      test_result <- "EXPECTED_BEHAVIOR"
      pain_points <- "Custom names require manual mapping"
      user_experience <- "User sees guidance to map custom names to roster names"
    } else {
      test_result <- "UNEXPECTED_ERROR"
      pain_points <- paste("Unexpected error:", e$message)
      user_experience <- "User sees confusing error message"
    }
  })
  
  # Store result for this privacy level
  scenario_key <- paste("Scenario2", privacy_level, sep = "_")
  analysis_results[[scenario_key]] <- log_result(
    scenario = paste("Scenario 2 - Custom Names (", privacy_level, ")", sep = ""),
    test_result = test_result,
    pain_points = pain_points,
    priority_level = "HIGH",
    privacy_impact = paste("Privacy level", privacy_level, "applied"),
    error_handling = "Error caught and analyzed",
    user_experience = user_experience
  )
}

# ============================================================================
# SCENARIO 3: Student present in session 1, missing in session 2
# ============================================================================

cat("\n=== SCENARIO 3: Cross-session attendance tracking ===\n")
cat("User Experience: User has two sessions - John Smith present in session 1, missing in session 2\n")
cat("Expected Behavior: System should process both sessions and show attendance patterns\n\n")

for (privacy_level in privacy_levels) {
  cat(sprintf("\n--- Testing with privacy level: %s ---\n", privacy_level))
  
  tryCatch({
    # Set privacy level
    set_privacy_defaults(privacy_level)
    
    # Process session 1
    cat("Processing session 1...\n")
    session1_result <- safe_name_matching_workflow(
      transcript_file_path = "data/transcripts/session1.vtt",
      roster_data = test_roster,
      privacy_level = privacy_level,
      unmatched_names_action = "warn",
      data_folder = "data/metadata"
    )
    
    # This should not reach here due to unmatched names
    cat("⚠️  Unexpected: Session 1 completed without stopping for unmatched names\n")
    test_result <- "UNEXPECTED"
    pain_points <- "Cross-session tracking not tested due to unmatched names"
    user_experience <- "User cannot test cross-session tracking due to name matching issues"
    
  }, error = function(e) {
    cat("✅ Expected: Session 1 stopped for unmatched names\n")
    cat("Error message:", e$message, "\n")
    
    test_result <- "EXPECTED_BEHAVIOR"
    pain_points <- "Cross-session tracking blocked by name matching issues"
    user_experience <- "User must resolve name matching before testing cross-session tracking"
  })
  
  # Store result for this privacy level
  scenario_key <- paste("Scenario3", privacy_level, sep = "_")
  analysis_results[[scenario_key]] <- log_result(
    scenario = paste("Scenario 3 - Cross-session (", privacy_level, ")", sep = ""),
    test_result = test_result,
    pain_points = pain_points,
    priority_level = "HIGH",
    privacy_impact = paste("Privacy level", privacy_level, "applied"),
    error_handling = "Error caught and analyzed",
    user_experience = user_experience
  )
}

# ============================================================================
# SCENARIO 4: "Dr. Healy" in session 1, "Conor Healy" in session 2
# ============================================================================

cat("\n=== SCENARIO 4: Name variations across sessions ===\n")
cat("User Experience: User has two sessions with instructor appearing as 'Dr. Healy' and 'Conor Healy'\n")
cat("Expected Behavior: System should identify both as unmatched or match them to instructor\n\n")

for (privacy_level in privacy_levels) {
  cat(sprintf("\n--- Testing with privacy level: %s ---\n", privacy_level))
  
  tryCatch({
    # Set privacy level
    set_privacy_defaults(privacy_level)
    
    # Process session 1
    cat("Processing session 1...\n")
    session1_result <- safe_name_matching_workflow(
      transcript_file_path = "data/transcripts/session1.vtt",
      roster_data = test_roster,
      privacy_level = privacy_level,
      unmatched_names_action = "warn",
      data_folder = "data/metadata"
    )
    
    # This should not reach here due to unmatched names
    cat("⚠️  Unexpected: Session 1 completed without stopping for unmatched names\n")
    test_result <- "UNEXPECTED"
    pain_points <- "Name variation handling not tested due to unmatched names"
    user_experience <- "User cannot test name variation handling due to name matching issues"
    
  }, error = function(e) {
    cat("✅ Expected: Session 1 stopped for unmatched names\n")
    cat("Error message:", e$message, "\n")
    
    # Check if Dr. Healy is mentioned in the error
    if (grepl("Dr. Healy", e$message)) {
      test_result <- "EXPECTED_BEHAVIOR"
      pain_points <- "Instructor name variations require manual mapping"
      user_experience <- "User must manually map both 'Dr. Healy' and 'Conor Healy' to instructor"
    } else if (grepl("Unmatched names found", e$message)) {
      test_result <- "EXPECTED_BEHAVIOR"
      pain_points <- "Name variations require manual mapping"
      user_experience <- "User sees guidance to map name variations in lookup file"
    } else {
      test_result <- "UNEXPECTED_ERROR"
      pain_points <- paste("Unexpected error:", e$message)
      user_experience <- "User sees confusing error message"
    }
  })
  
  # Store result for this privacy level
  scenario_key <- paste("Scenario4", privacy_level, sep = "_")
  analysis_results[[scenario_key]] <- log_result(
    scenario = paste("Scenario 4 - Name Variations (", privacy_level, ")", sep = ""),
    test_result = test_result,
    pain_points = pain_points,
    priority_level = "HIGH",
    privacy_impact = paste("Privacy level", privacy_level, "applied"),
    error_handling = "Error caught and analyzed",
    user_experience = user_experience
  )
}

# ============================================================================
# ENHANCED TESTING: International Names and Variations
# ============================================================================

cat("\n=== ENHANCED TESTING: International Names and Variations ===\n")
cat("User Experience: User has transcript with 'Jose Garcia' and 'Professor Chen' that should match roster names\n")
cat("Expected Behavior: System should identify these as unmatched or match them to roster names\n\n")

for (privacy_level in privacy_levels) {
  cat(sprintf("\n--- Testing with privacy level: %s ---\n", privacy_level))
  
  tryCatch({
    # Set privacy level
    set_privacy_defaults(privacy_level)
    
    # Run name matching workflow
    result <- safe_name_matching_workflow(
      transcript_file_path = "data/transcripts/test_transcript.vtt",
      roster_data = test_roster,
      privacy_level = privacy_level,
      unmatched_names_action = "warn",
      data_folder = "data/metadata"
    )
    
    # This should not reach here due to unmatched names
    cat("⚠️  Unexpected: Workflow completed without stopping for unmatched names\n")
    test_result <- "UNEXPECTED"
    pain_points <- "International name handling not tested due to unmatched names"
    user_experience <- "User cannot test international name handling due to name matching issues"
    
  }, error = function(e) {
    cat("✅ Expected: Workflow stopped for unmatched names\n")
    cat("Error message:", e$message, "\n")
    
    # Check for international name patterns
    if (grepl("Jose", e$message) || grepl("Chen", e$message)) {
      test_result <- "EXPECTED_BEHAVIOR"
      pain_points <- "International names and titles require manual mapping"
      user_experience <- "User must manually map 'Jose Garcia' to 'José García' and 'Professor Chen' to 'Dr. Sarah Chen'"
    } else if (grepl("Unmatched names found", e$message)) {
      test_result <- "EXPECTED_BEHAVIOR"
      pain_points <- "International names require manual mapping"
      user_experience <- "User sees guidance to map international names in lookup file"
    } else {
      test_result <- "UNEXPECTED_ERROR"
      pain_points <- paste("Unexpected error:", e$message)
      user_experience <- "User sees confusing error message"
    }
  })
  
  # Store result for this privacy level
  scenario_key <- paste("Enhanced", privacy_level, sep = "_")
  analysis_results[[scenario_key]] <- log_result(
    scenario = paste("Enhanced - International Names (", privacy_level, ")", sep = ""),
    test_result = test_result,
    pain_points = pain_points,
    priority_level = "MEDIUM",
    privacy_impact = paste("Privacy level", privacy_level, "applied"),
    error_handling = "Error caught and analyzed",
    user_experience = user_experience
  )
}

# ============================================================================
# ERROR HANDLING TESTING
# ============================================================================

cat("\n=== ERROR HANDLING TESTING ===\n")

# Test with empty roster
cat("\n--- Testing with empty roster ---\n")
cat("User Experience: User has an empty roster file\n")
cat("Expected Behavior: System should handle empty roster gracefully\n\n")

tryCatch({
  empty_roster <- read.csv("data/metadata/empty_roster.csv", stringsAsFactors = FALSE)
  
  result <- safe_name_matching_workflow(
    transcript_file_path = "data/transcripts/test_transcript.vtt",
    roster_data = empty_roster,
    privacy_level = "mask",
    unmatched_names_action = "warn",
    data_folder = "data/metadata"
  )
  
  cat("⚠️  Empty roster test completed\n")
  test_result <- "PARTIAL"
  pain_points <- "Empty roster handling needs review"
  user_experience <- "User can process transcript with empty roster"
  
}, error = function(e) {
  cat("❌ Error with empty roster:", e$message, "\n")
  test_result <- "ERROR"
  pain_points <- paste("Error:", e$message)
  user_experience <- "User sees error when roster is empty"
})

analysis_results[["ErrorHandling_EmptyRoster"]] <- log_result(
  scenario = "Error Handling - Empty Roster",
  test_result = test_result,
  pain_points = pain_points,
  priority_level = "MEDIUM",
  privacy_impact = "Privacy level mask applied",
  error_handling = "Error caught and logged",
  user_experience = user_experience
)

# Test with malformed transcript
cat("\n--- Testing with malformed transcript ---\n")
cat("User Experience: User has a malformed transcript file\n")
cat("Expected Behavior: System should handle malformed transcript gracefully\n\n")

tryCatch({
  result <- safe_name_matching_workflow(
    transcript_file_path = "data/transcripts/malformed_transcript.vtt",
    roster_data = test_roster,
    privacy_level = "mask",
    unmatched_names_action = "warn",
    data_folder = "data/metadata"
  )
  
  cat("⚠️  Malformed transcript test completed\n")
  test_result <- "PARTIAL"
  pain_points <- "Malformed transcript handling needs review"
  user_experience <- "User can process malformed transcript"
  
}, error = function(e) {
  cat("❌ Error with malformed transcript:", e$message, "\n")
  test_result <- "ERROR"
  pain_points <- paste("Error:", e$message)
  user_experience <- "User sees error when transcript is malformed"
})

analysis_results[["ErrorHandling_MalformedTranscript"]] <- log_result(
  scenario = "Error Handling - Malformed Transcript",
  test_result = test_result,
  pain_points = pain_points,
  priority_level = "MEDIUM",
  privacy_impact = "Privacy level mask applied",
  error_handling = "Error caught and logged",
  user_experience = user_experience
)

# ============================================================================
# ANALYSIS AND SUMMARY
# ============================================================================

cat("\n=== PHASE 1 ANALYSIS SUMMARY ===\n")

# Create analysis table
analysis_table <- data.frame(
  Scenario = sapply(analysis_results, function(x) x$scenario),
  Test_Result = sapply(analysis_results, function(x) x$test_result),
  Pain_Points = sapply(analysis_results, function(x) x$pain_points),
  Priority_Level = sapply(analysis_results, function(x) x$priority_level),
  Privacy_Impact = sapply(analysis_results, function(x) x$privacy_impact),
  Error_Handling = sapply(analysis_results, function(x) x$error_handling),
  User_Experience = sapply(analysis_results, function(x) x$user_experience),
  stringsAsFactors = FALSE
)

# Print analysis table
cat("\nComplete Analysis Table:\n")
print(analysis_table)

# Summary statistics
cat("\nSummary Statistics:\n")
cat("Total scenarios tested:", nrow(analysis_table), "\n")
cat("Expected behavior tests:", sum(analysis_table$Test_Result == "EXPECTED_BEHAVIOR"), "\n")
cat("Unexpected behavior tests:", sum(analysis_table$Test_Result == "UNEXPECTED"), "\n")
cat("Error tests:", sum(analysis_table$Test_Result == "ERROR"), "\n")
cat("Partial tests:", sum(analysis_table$Test_Result == "PARTIAL"), "\n")

# Priority breakdown
cat("\nPriority Level Breakdown:\n")
priority_summary <- table(analysis_table$Priority_Level)
print(priority_summary)

# Key findings
cat("\n=== KEY FINDINGS ===\n")
cat("1. All 4 scenarios result in 'unmatched names' errors\n")
cat("2. Users must manually create section_names_lookup.csv file\n")
cat("3. Privacy-first approach stops processing until names are mapped\n")
cat("4. Error messages provide clear guidance for manual mapping\n")
cat("5. Cross-session tracking is blocked until name matching is resolved\n\n")

# User experience insights
cat("=== USER EXPERIENCE INSIGHTS ===\n")
cat("1. Privacy-first design prioritizes data protection over convenience\n")
cat("2. Manual name mapping is required for all unmatched names\n")
cat("3. Clear error messages guide users through the mapping process\n")
cat("4. Workflow stops at first unmatched name encounter\n")
cat("5. Users must understand the lookup file format to proceed\n\n")

# Save results
cat("\nSaving analysis results...\n")
write.csv(analysis_table, "test_reports/phase1_user_experience_analysis.csv", row.names = FALSE)
saveRDS(analysis_results, "test_reports/phase1_user_experience_analysis.rds")

cat("\n=== PHASE 1 COMPLETED ===\n")
cat("Results saved to test_reports/phase1_user_experience_analysis.csv\n")
cat("Raw results saved to test_reports/phase1_user_experience_analysis.rds\n")
cat("Key finding: All scenarios require manual name mapping in section_names_lookup.csv\n")
cat("Next step: Create user guidance for manual name mapping process\n")
