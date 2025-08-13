#!/usr/bin/env Rscript
# Phase 1: Comprehensive User Experience Analysis for Issue #160
# Name Matching Deep-Dive Plan Implementation

# Load required libraries
library(zoomstudentengagement)
library(dplyr)
library(tibble)
library(readr)

# Set up logging
cat("=== Phase 1: Comprehensive User Experience Analysis ===\n")
cat("Date:", Sys.Date(), "\n")
cat("Time:", Sys.time(), "\n\n")

# Function to log results
log_result <- function(scenario, test_result, pain_points, priority_level, privacy_impact, error_handling) {
  cat(sprintf("Scenario: %s\n", scenario))
  cat(sprintf("Test Result: %s\n", test_result))
  cat(sprintf("Pain Points: %s\n", pain_points))
  cat(sprintf("Priority Level: %s\n", priority_level))
  cat(sprintf("Privacy Impact: %s\n", privacy_impact))
  cat(sprintf("Error Handling: %s\n", error_handling))
  cat("---\n\n")
  
  # Return structured result
  list(
    scenario = scenario,
    test_result = test_result,
    pain_points = pain_points,
    priority_level = priority_level,
    privacy_impact = privacy_impact,
    error_handling = error_handling
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
cat("Loaded test roster with", nrow(test_roster), "students\n")

# Create proper name lookup file for testing
cat("Creating test name lookup file...\n")
test_lookup <- data.frame(
  transcript_name = c("Dr. Healy", "Conor Healy", "JS", "Guest User", "Jose Garcia", "Professor Chen", "John Smith Jr", "OConnor", "John Smith II"),
  preferred_name = c("Dr. Healy", "Dr. Healy", "John Smith", "Guest User", "José García", "Dr. Sarah Chen", "John Smith Jr.", "O'Connor", "John Smith 2"),
  formal_name = c("Dr. Healy", "Dr. Healy", "John Smith", "Guest User", "José García", "Dr. Sarah Chen", "John Smith Jr.", "O'Connor", "John Smith 2"),
  participant_type = c("instructor", "instructor", "enrolled_student", "guest", "enrolled_student", "instructor", "enrolled_student", "enrolled_student", "enrolled_student"),
  student_id = c("INSTRUCTOR", "INSTRUCTOR", "STU001", "GUEST", "STU003", "INSTRUCTOR", "STU005", "STU006", "STU007"),
  stringsAsFactors = FALSE
)

write.csv(test_lookup, "data/metadata/section_names_lookup.csv", row.names = FALSE)
cat("Created test name lookup with", nrow(test_lookup), "entries\n\n")

# ============================================================================
# SCENARIO 1: "Guest User" in transcript, not in roster
# ============================================================================

cat("=== SCENARIO 1: Guest User in transcript, not in roster ===\n")

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
    
    # Check if "Guest User" was handled
    if (!is.null(result)) {
      # Check for guest user handling
      guest_handled <- any(grepl("Guest", result$name, ignore.case = TRUE) | 
                          grepl("Guest", result$preferred_name, ignore.case = TRUE))
      
      # Check if guest is properly categorized
      guest_categorized <- any(grepl("guest", result$participant_type, ignore.case = TRUE))
      
      if (guest_handled && guest_categorized) {
        cat("✅ Guest User was handled appropriately\n")
        test_result <- "SUCCESS"
        pain_points <- "None identified"
      } else if (guest_handled) {
        cat("⚠️  Guest User found but categorization unclear\n")
        test_result <- "PARTIAL"
        pain_points <- "Guest user categorization not clear"
      } else {
        cat("⚠️  Guest User handling unclear\n")
        test_result <- "PARTIAL"
        pain_points <- "Guest user handling not clear"
      }
    } else {
      cat("❌ Workflow failed\n")
      test_result <- "FAILED"
      pain_points <- "Workflow returned NULL"
    }
    
  }, error = function(e) {
    cat("❌ Error:", e$message, "\n")
    test_result <- "ERROR"
    pain_points <- paste("Error:", e$message)
  })
  
  # Store result for this privacy level
  scenario_key <- paste("Scenario1", privacy_level, sep = "_")
  analysis_results[[scenario_key]] <- log_result(
    scenario = paste("Scenario 1 - Guest User (", privacy_level, ")", sep = ""),
    test_result = test_result,
    pain_points = pain_points,
    priority_level = "HIGH",
    privacy_impact = paste("Privacy level", privacy_level, "applied"),
    error_handling = "Error caught and logged"
  )
}

# ============================================================================
# SCENARIO 2: "John Smith" in roster, "JS" in transcript
# ============================================================================

cat("\n=== SCENARIO 2: John Smith in roster, JS in transcript ===\n")

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
    
    # Check if "JS" was matched to "John Smith"
    if (!is.null(result)) {
      # Check for JS to John Smith mapping
      js_matched <- any(grepl("JS", result$name, ignore.case = TRUE) & 
                       grepl("John Smith", result$preferred_name, ignore.case = TRUE))
      
      # Check if JS is properly categorized as enrolled student
      js_categorized <- any(grepl("JS", result$name, ignore.case = TRUE) & 
                           grepl("enrolled_student", result$participant_type, ignore.case = TRUE))
      
      if (js_matched && js_categorized) {
        cat("✅ JS was matched to John Smith and properly categorized\n")
        test_result <- "SUCCESS"
        pain_points <- "None identified"
      } else if (js_matched) {
        cat("⚠️  JS was matched but categorization unclear\n")
        test_result <- "PARTIAL"
        pain_points <- "Custom name matching works but categorization unclear"
      } else {
        cat("⚠️  JS matching unclear\n")
        test_result <- "PARTIAL"
        pain_points <- "Custom name matching not clear"
      }
    } else {
      cat("❌ Workflow failed\n")
      test_result <- "FAILED"
      pain_points <- "Workflow returned NULL"
    }
    
  }, error = function(e) {
    cat("❌ Error:", e$message, "\n")
    test_result <- "ERROR"
    pain_points <- paste("Error:", e$message)
  })
  
  # Store result for this privacy level
  scenario_key <- paste("Scenario2", privacy_level, sep = "_")
  analysis_results[[scenario_key]] <- log_result(
    scenario = paste("Scenario 2 - Custom Names (", privacy_level, ")", sep = ""),
    test_result = test_result,
    pain_points = pain_points,
    priority_level = "HIGH",
    privacy_impact = paste("Privacy level", privacy_level, "applied"),
    error_handling = "Error caught and logged"
  )
}

# ============================================================================
# SCENARIO 3: Student present in session 1, missing in session 2
# ============================================================================

cat("\n=== SCENARIO 3: Cross-session attendance tracking ===\n")

for (privacy_level in privacy_levels) {
  cat(sprintf("\n--- Testing with privacy level: %s ---\n", privacy_level))
  
  tryCatch({
    # Set privacy level
    set_privacy_defaults(privacy_level)
    
    # Process session 1
    session1_result <- safe_name_matching_workflow(
      transcript_file_path = "data/transcripts/session1.vtt",
      roster_data = test_roster,
      privacy_level = privacy_level,
      unmatched_names_action = "warn",
      data_folder = "data/metadata"
    )
    
    # Process session 2
    session2_result <- safe_name_matching_workflow(
      transcript_file_path = "data/transcripts/session2.vtt",
      roster_data = test_roster,
      privacy_level = privacy_level,
      unmatched_names_action = "warn",
      data_folder = "data/metadata"
    )
    
    # Check cross-session tracking
    if (!is.null(session1_result) && !is.null(session2_result)) {
      # Check if John Smith appears in session 1 but not session 2
      john_in_session1 <- any(grepl("John Smith", session1_result$name, ignore.case = TRUE) |
                             grepl("John Smith", session1_result$preferred_name, ignore.case = TRUE))
      john_in_session2 <- any(grepl("John Smith", session2_result$name, ignore.case = TRUE) |
                             grepl("John Smith", session2_result$preferred_name, ignore.case = TRUE))
      
      if (john_in_session1 && !john_in_session2) {
        cat("✅ Cross-session attendance tracking working - John Smith present in session 1, missing in session 2\n")
        test_result <- "SUCCESS"
        pain_points <- "None identified"
      } else if (john_in_session1 && john_in_session2) {
        cat("⚠️  John Smith appears in both sessions (unexpected)\n")
        test_result <- "PARTIAL"
        pain_points <- "Cross-session tracking shows unexpected results"
      } else {
        cat("⚠️  Cross-session tracking unclear\n")
        test_result <- "PARTIAL"
        pain_points <- "Cross-session tracking not clear"
      }
    } else {
      cat("❌ One or both sessions failed\n")
      test_result <- "FAILED"
      pain_points <- "Session processing failed"
    }
    
  }, error = function(e) {
    cat("❌ Error:", e$message, "\n")
    test_result <- "ERROR"
    pain_points <- paste("Error:", e$message)
  })
  
  # Store result for this privacy level
  scenario_key <- paste("Scenario3", privacy_level, sep = "_")
  analysis_results[[scenario_key]] <- log_result(
    scenario = paste("Scenario 3 - Cross-session (", privacy_level, ")", sep = ""),
    test_result = test_result,
    pain_points = pain_points,
    priority_level = "HIGH",
    privacy_impact = paste("Privacy level", privacy_level, "applied"),
    error_handling = "Error caught and logged"
  )
}

# ============================================================================
# SCENARIO 4: "Dr. Healy" in session 1, "Conor Healy" in session 2
# ============================================================================

cat("\n=== SCENARIO 4: Name variations across sessions ===\n")

for (privacy_level in privacy_levels) {
  cat(sprintf("\n--- Testing with privacy level: %s ---\n", privacy_level))
  
  tryCatch({
    # Set privacy level
    set_privacy_defaults(privacy_level)
    
    # Process session 1
    session1_result <- safe_name_matching_workflow(
      transcript_file_path = "data/transcripts/session1.vtt",
      roster_data = test_roster,
      privacy_level = privacy_level,
      unmatched_names_action = "warn",
      data_folder = "data/metadata"
    )
    
    # Process session 2
    session2_result <- safe_name_matching_workflow(
      transcript_file_path = "data/transcripts/session2.vtt",
      roster_data = test_roster,
      privacy_level = privacy_level,
      unmatched_names_action = "warn",
      data_folder = "data/metadata"
    )
    
    # Check name variation handling
    if (!is.null(session1_result) && !is.null(session2_result)) {
      # Check if both "Dr. Healy" and "Conor Healy" are handled
      dr_healy_in_session1 <- any(grepl("Dr. Healy", session1_result$name, ignore.case = TRUE) |
                                 grepl("Dr. Healy", session1_result$preferred_name, ignore.case = TRUE))
      conor_healy_in_session2 <- any(grepl("Conor Healy", session2_result$name, ignore.case = TRUE) |
                                    grepl("Conor Healy", session2_result$preferred_name, ignore.case = TRUE))
      
      # Check if both are categorized as instructor
      dr_healy_instructor <- any(grepl("Dr. Healy", session1_result$name, ignore.case = TRUE) & 
                                grepl("instructor", session1_result$participant_type, ignore.case = TRUE))
      conor_healy_instructor <- any(grepl("Conor Healy", session2_result$name, ignore.case = TRUE) & 
                                   grepl("instructor", session2_result$participant_type, ignore.case = TRUE))
      
      if (dr_healy_in_session1 && conor_healy_in_session2 && dr_healy_instructor && conor_healy_instructor) {
        cat("✅ Name variations handled appropriately - both Dr. Healy and Conor Healy properly categorized as instructor\n")
        test_result <- "SUCCESS"
        pain_points <- "None identified"
      } else if (dr_healy_in_session1 && conor_healy_in_session2) {
        cat("⚠️  Name variations found but categorization unclear\n")
        test_result <- "PARTIAL"
        pain_points <- "Name variations found but instructor categorization unclear"
      } else {
        cat("⚠️  Name variation handling unclear\n")
        test_result <- "PARTIAL"
        pain_points <- "Name variation handling not clear"
      }
    } else {
      cat("❌ One or both sessions failed\n")
      test_result <- "FAILED"
      pain_points <- "Session processing failed"
    }
    
  }, error = function(e) {
    cat("❌ Error:", e$message, "\n")
    test_result <- "ERROR"
    pain_points <- paste("Error:", e$message)
  })
  
  # Store result for this privacy level
  scenario_key <- paste("Scenario4", privacy_level, sep = "_")
  analysis_results[[scenario_key]] <- log_result(
    scenario = paste("Scenario 4 - Name Variations (", privacy_level, ")", sep = ""),
    test_result = test_result,
    pain_points = pain_points,
    priority_level = "HIGH",
    privacy_impact = paste("Privacy level", privacy_level, "applied"),
    error_handling = "Error caught and logged"
  )
}

# ============================================================================
# ENHANCED TESTING: International Names and Variations
# ============================================================================

cat("\n=== ENHANCED TESTING: International Names and Variations ===\n")

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
    
    # Check international name handling
    if (!is.null(result)) {
      # Check José García vs Jose Garcia
      jose_handled <- any(grepl("Jose", result$name, ignore.case = TRUE) |
                         grepl("Jose", result$preferred_name, ignore.case = TRUE))
      
      # Check Dr. Sarah Chen vs Professor Chen
      chen_handled <- any(grepl("Chen", result$name, ignore.case = TRUE) |
                         grepl("Chen", result$preferred_name, ignore.case = TRUE))
      
      # Check if José is properly mapped to José García
      jose_mapped <- any(grepl("Jose", result$name, ignore.case = TRUE) & 
                        grepl("José García", result$preferred_name, ignore.case = TRUE))
      
      # Check if Professor Chen is properly mapped to Dr. Sarah Chen
      chen_mapped <- any(grepl("Chen", result$name, ignore.case = TRUE) & 
                        grepl("Dr. Sarah Chen", result$preferred_name, ignore.case = TRUE))
      
      if (jose_handled && chen_handled && jose_mapped && chen_mapped) {
        cat("✅ International names handled appropriately - José mapped to José García, Professor Chen mapped to Dr. Sarah Chen\n")
        test_result <- "SUCCESS"
        pain_points <- "None identified"
      } else if (jose_handled && chen_handled) {
        cat("⚠️  International names found but mapping unclear\n")
        test_result <- "PARTIAL"
        pain_points <- "International names found but proper mapping unclear"
      } else {
        cat("⚠️  International name handling unclear\n")
        test_result <- "PARTIAL"
        pain_points <- "International name handling not clear"
      }
    } else {
      cat("❌ Workflow failed\n")
      test_result <- "FAILED"
      pain_points <- "Workflow returned NULL"
    }
    
  }, error = function(e) {
    cat("❌ Error:", e$message, "\n")
    test_result <- "ERROR"
    pain_points <- paste("Error:", e$message)
  })
  
  # Store result for this privacy level
  scenario_key <- paste("Enhanced", privacy_level, sep = "_")
  analysis_results[[scenario_key]] <- log_result(
    scenario = paste("Enhanced - International Names (", privacy_level, ")", sep = ""),
    test_result = test_result,
    pain_points = pain_points,
    priority_level = "MEDIUM",
    privacy_impact = paste("Privacy level", privacy_level, "applied"),
    error_handling = "Error caught and logged"
  )
}

# ============================================================================
# ERROR HANDLING TESTING
# ============================================================================

cat("\n=== ERROR HANDLING TESTING ===\n")

# Test with empty roster
cat("\n--- Testing with empty roster ---\n")
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
  
}, error = function(e) {
  cat("❌ Error with empty roster:", e$message, "\n")
  test_result <- "ERROR"
  pain_points <- paste("Error:", e$message)
})

analysis_results[["ErrorHandling_EmptyRoster"]] <- log_result(
  scenario = "Error Handling - Empty Roster",
  test_result = test_result,
  pain_points = pain_points,
  priority_level = "MEDIUM",
  privacy_impact = "Privacy level mask applied",
  error_handling = "Error caught and logged"
)

# Test with malformed transcript
cat("\n--- Testing with malformed transcript ---\n")
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
  
}, error = function(e) {
  cat("❌ Error with malformed transcript:", e$message, "\n")
  test_result <- "ERROR"
  pain_points <- paste("Error:", e$message)
})

analysis_results[["ErrorHandling_MalformedTranscript"]] <- log_result(
  scenario = "Error Handling - Malformed Transcript",
  test_result = test_result,
  pain_points = pain_points,
  priority_level = "MEDIUM",
  privacy_impact = "Privacy level mask applied",
  error_handling = "Error caught and logged"
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
  stringsAsFactors = FALSE
)

# Print analysis table
cat("\nComplete Analysis Table:\n")
print(analysis_table)

# Summary statistics
cat("\nSummary Statistics:\n")
cat("Total scenarios tested:", nrow(analysis_table), "\n")
cat("Successful tests:", sum(analysis_table$Test_Result == "SUCCESS"), "\n")
cat("Partial successes:", sum(analysis_table$Test_Result == "PARTIAL"), "\n")
cat("Failed tests:", sum(analysis_table$Test_Result == "FAILED"), "\n")
cat("Error tests:", sum(analysis_table$Test_Result == "ERROR"), "\n")

# Priority breakdown
cat("\nPriority Level Breakdown:\n")
priority_summary <- table(analysis_table$Priority_Level)
print(priority_summary)

# Save results
cat("\nSaving analysis results...\n")
write.csv(analysis_table, "test_reports/phase1_comprehensive_analysis_results.csv", row.names = FALSE)
saveRDS(analysis_results, "test_reports/phase1_comprehensive_analysis_results.rds")

cat("\n=== PHASE 1 COMPLETED ===\n")
cat("Results saved to test_reports/phase1_comprehensive_analysis_results.csv\n")
cat("Raw results saved to test_reports/phase1_comprehensive_analysis_results.rds\n")
cat("Please review the analysis table above and proceed to Phase 2.\n")
