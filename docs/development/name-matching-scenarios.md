# Name Matching Scenarios - Technical Documentation

**Date**: August 15, 2025  
**Purpose**: Technical documentation for Issue #160 name matching scenarios  
**Audience**: Developers and advanced users  

## Overview

This document provides detailed technical information about the four main name matching scenarios identified in Issue #160. Each scenario includes implementation details, privacy considerations, and technical solutions.

## Scenario 1: Guest User in Transcript, Not in Roster

### Problem Description
Zoom transcripts often contain generic names like "Guest User", "Unknown User", or "Guest-1234" that don't correspond to any student in the official roster.

### Technical Impact
- **Privacy Risk**: Low - these are not real student names
- **Analysis Impact**: High - can skew participation metrics
- **Processing Block**: Yes - system stops on unmatched names

### Implementation Solution

#### 1.1 Standardized Guest Mapping
```r
# Create standardized guest identifiers
guest_mapping <- data.frame(
  transcript_name = c("Guest User", "Unknown User", "Guest-1234", "Guest User (2)"),
  preferred_name = c("GUEST_001", "GUEST_002", "GUEST_003", "GUEST_004"),
  stringsAsFactors = FALSE
)
```

#### 1.2 Privacy Considerations
- Guest names are not real student data
- Can be safely excluded from privacy masking
- Use consistent identifiers across sessions

#### 1.3 Technical Implementation
```r
# In safe_name_matching_workflow.R
handle_guest_users <- function(transcript_names, roster_names) {
  guest_patterns <- c("^Guest", "^Unknown", "Guest-\\d+")
  guest_names <- transcript_names[grepl(paste(guest_patterns, collapse = "|"), transcript_names)]
  
  if (length(guest_names) > 0) {
    # Create standardized mappings
    guest_mappings <- data.frame(
      transcript_name = guest_names,
      preferred_name = paste0("GUEST_", sprintf("%03d", seq_along(guest_names))),
      stringsAsFactors = FALSE
    )
    return(guest_mappings)
  }
  return(NULL)
}
```

### Success Criteria
- [ ] All guest users are consistently identified
- [ ] Guest users don't block processing
- [ ] Guest participation is tracked separately
- [ ] Privacy compliance maintained

## Scenario 2: Custom Names (JS → John Smith)

### Problem Description
Students use abbreviated, nicknames, or custom identifiers in Zoom that don't match their official roster names.

### Technical Impact
- **Privacy Risk**: Medium - requires manual mapping
- **Analysis Impact**: High - affects individual student tracking
- **Processing Block**: Yes - system stops on unmatched names

### Implementation Solution

#### 2.1 Manual Mapping Process
```r
# Example mapping for custom names
custom_mapping <- data.frame(
  transcript_name = c("JS", "Dr. Smith", "JohnS", "jsmith", "JSmith"),
  preferred_name = c("John Smith", "John Smith", "John Smith", "John Smith", "John Smith"),
  stringsAsFactors = FALSE
)
```

#### 2.2 Fuzzy Matching Enhancement
```r
# Enhanced find_roster_match function with confidence scores
find_roster_match_with_confidence <- function(name, roster_data) {
  # Normalize name for comparison
  normalized_name <- normalize_name_for_matching(name)
  
  # Calculate similarity scores
  similarity_scores <- sapply(roster_data$name, function(roster_name) {
    normalized_roster <- normalize_name_for_matching(roster_name)
    stringdist::stringdist(normalized_name, normalized_roster, method = "jw")
  })
  
  # Find best match
  best_match_idx <- which.min(similarity_scores)
  confidence <- 1 - similarity_scores[best_match_idx]
  
  if (confidence > 0.8) {
    return(list(
      match = roster_data$name[best_match_idx],
      confidence = confidence,
      suggested_mapping = data.frame(
        transcript_name = name,
        preferred_name = roster_data$name[best_match_idx],
        stringsAsFactors = FALSE
      )
    ))
  }
  
  return(NULL)
}
```

#### 2.3 Privacy Considerations
- Real names only in memory during processing
- Mappings stored securely
- All outputs privacy-masked

### Success Criteria
- [ ] Custom names are correctly mapped to roster names
- [ ] Fuzzy matching provides helpful suggestions
- [ ] Manual mapping process is clear and secure
- [ ] Privacy compliance maintained throughout

## Scenario 3: Cross-Session Attendance Tracking

### Problem Description
Names appear differently across multiple Zoom sessions, making it difficult to track individual student participation across sessions.

### Technical Impact
- **Privacy Risk**: Medium - requires consistent cross-session mapping
- **Analysis Impact**: High - affects longitudinal analysis
- **Processing Block**: Yes - system stops on unmatched names

### Implementation Solution

#### 3.1 Cross-Session Name Consistency
```r
# Comprehensive mapping for cross-session consistency
cross_session_mapping <- data.frame(
  transcript_name = c("John Smith", "J. Smith", "Smith, John", "JohnS", "Smith J."),
  preferred_name = c("John Smith", "John Smith", "John Smith", "John Smith", "John Smith"),
  stringsAsFactors = FALSE
)
```

#### 3.2 Session-Aware Processing
```r
# Enhanced workflow for multiple sessions
process_multiple_sessions <- function(transcript_files, roster_data, lookup_file) {
  all_results <- list()
  
  for (file in transcript_files) {
    session_data <- load_zoom_transcript(file)
    
    # Apply consistent name matching across sessions
    session_results <- safe_name_matching_workflow(
      transcript_data = session_data,
      roster_data = roster_data,
      section_names_lookup_file = lookup_file
    )
    
    all_results[[basename(file)]] <- session_results
  }
  
  return(all_results)
}
```

#### 3.3 Consistent Hashing for Cross-Session Matching
```r
# Use consistent hashing for cross-session privacy
hash_name_consistently <- function(name, salt = "zoomstudentengagement") {
  # Create consistent hash for cross-session matching
  hash_input <- paste0(name, salt)
  return(digest::digest(hash_input, algo = "sha256"))
}
```

### Success Criteria
- [ ] Names are consistently identified across sessions
- [ ] Cross-session analysis is possible
- [ ] Privacy masking is consistent across sessions
- [ ] Performance is acceptable for multiple sessions

## Scenario 4: Name Variations Across Sessions

### Problem Description
Students use different name formats in different sessions (e.g., "John Smith" vs "Smith, John" vs "J. Smith").

### Technical Impact
- **Privacy Risk**: Medium - requires comprehensive mapping
- **Analysis Impact**: High - affects individual tracking
- **Processing Block**: Yes - system stops on unmatched names

### Implementation Solution

#### 4.1 Comprehensive Name Variation Mapping
```r
# Handle all possible name variations
variation_mapping <- data.frame(
  transcript_name = c(
    "John Smith", "Smith, John", "J. Smith", "John S.", "Smith",
    "John A. Smith", "Smith, John A.", "J.A. Smith", "John Smith Jr."
  ),
  preferred_name = c(
    "John Smith", "John Smith", "John Smith", "John Smith", "John Smith",
    "John Smith", "John Smith", "John Smith", "John Smith"
  ),
  stringsAsFactors = FALSE
)
```

#### 4.2 Name Normalization Function
```r
# Enhanced name normalization
normalize_name_for_matching <- function(name) {
  # Remove common prefixes/suffixes
  name <- gsub("^(Dr\\.|Prof\\.|Mr\\.|Ms\\.|Mrs\\.)\\s*", "", name, ignore.case = TRUE)
  name <- gsub("\\s+(Jr\\.|Sr\\.|III|IV|V)$", "", name, ignore.case = TRUE)
  
  # Standardize whitespace
  name <- gsub("\\s+", " ", trimws(name))
  
  # Convert to lowercase for comparison
  name <- tolower(name)
  
  return(name)
}
```

#### 4.3 Automatic Variation Detection
```r
# Detect potential name variations
detect_name_variations <- function(name, roster_data) {
  normalized_name <- normalize_name_for_matching(name)
  
  # Check for variations
  variations <- list()
  
  # Split name parts
  name_parts <- strsplit(normalized_name, "\\s+")[[1]]
  
  if (length(name_parts) >= 2) {
    # Check "Last, First" format
    variations[[1]] <- paste(name_parts[2], name_parts[1], sep = ", ")
    
    # Check abbreviated first name
    if (nchar(name_parts[1]) > 1) {
      variations[[2]] <- paste(substr(name_parts[1], 1, 1), name_parts[2])
    }
    
    # Check abbreviated last name
    if (nchar(name_parts[2]) > 1) {
      variations[[3]] <- paste(name_parts[1], substr(name_parts[2], 1, 1))
    }
  }
  
  return(variations)
}
```

### Success Criteria
- [ ] All name variations are correctly identified
- [ ] Automatic variation detection works reliably
- [ ] Manual mapping process handles edge cases
- [ ] Privacy compliance maintained

## Technical Implementation Details

### Privacy-First Design Principles

#### 1. Memory-Only Processing
```r
# Real names only exist in memory during processing
process_with_privacy <- function(transcript_data, roster_data) {
  # Process with real names in memory
  results <- process_transcript(transcript_data, roster_data)
  
  # Clean up sensitive data
  rm(transcript_data, roster_data)
  gc()
  
  # Return privacy-masked results
  return(mask_user_names_by_metric(results))
}
```

#### 2. Consistent Privacy Masking
```r
# Ensure all outputs are privacy-masked
mask_user_names_by_metric <- function(data, privacy_level = "mask") {
  if (privacy_level == "mask") {
    # Hash all names consistently
    data$user_name <- sapply(data$user_name, hash_name_consistently)
  }
  return(data)
}
```

#### 3. Validation at Boundaries
```r
# Validate privacy compliance at output boundaries
validate_privacy_compliance <- function(output_data) {
  # Check that no real names appear in outputs
  if (any(grepl("^[A-Z][a-z]+\\s+[A-Z][a-z]+$", output_data$user_name))) {
    stop("Privacy violation: Real names detected in output")
  }
  return(TRUE)
}
```

### Error Handling and User Guidance

#### 1. Specific Error Messages
```r
# Provide actionable error messages
handle_unmatched_names <- function(unmatched_names) {
  if (length(unmatched_names) > 0) {
    stop(
      "Found unmatched names: ", paste(unmatched_names, collapse = ", "), "\n",
      "Please update your section_names_lookup.csv file with these mappings.\n",
      "See vignette('name-matching-troubleshooting') for detailed instructions.\n",
      "Example mappings:\n",
      paste(sapply(unmatched_names, function(name) {
        paste0("  ", name, " -> [Your roster name]")
      }), collapse = "\n")
    )
  }
}
```

#### 2. Validation Functions
```r
# Validate lookup file format
validate_lookup_file_format <- function(lookup_data) {
  required_cols <- c("transcript_name", "preferred_name")
  
  if (!all(required_cols %in% names(lookup_data))) {
    missing_cols <- setdiff(required_cols, names(lookup_data))
    stop("Lookup file missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  if (nrow(lookup_data) == 0) {
    warning("Lookup file is empty - no name mappings provided")
  }
  
  return(TRUE)
}
```

## Testing Strategy

### Unit Tests for Each Scenario
```r
# Test Scenario 1: Guest Users
test_that("guest users are handled correctly", {
  guest_data <- data.frame(user_name = c("Guest User", "Unknown User"))
  result <- handle_guest_users(guest_data$user_name, roster_data)
  expect_equal(nrow(result), 2)
  expect_true(all(grepl("^GUEST_", result$preferred_name)))
})

# Test Scenario 2: Custom Names
test_that("custom names are mapped correctly", {
  custom_data <- data.frame(user_name = c("JS", "Dr. Smith"))
  result <- find_roster_match_with_confidence("JS", roster_data)
  expect_true(!is.null(result))
  expect_true(result$confidence > 0.8)
})

# Test Scenario 3: Cross-Session Consistency
test_that("names are consistent across sessions", {
  session1 <- data.frame(user_name = "John Smith")
  session2 <- data.frame(user_name = "J. Smith")
  
  hash1 <- hash_name_consistently("John Smith")
  hash2 <- hash_name_consistently("J. Smith")
  
  # Should be different hashes for different names
  expect_false(hash1 == hash2)
})

# Test Scenario 4: Name Variations
test_that("name variations are detected", {
  variations <- detect_name_variations("John Smith", roster_data)
  expect_true(length(variations) > 0)
  expect_true("Smith, John" %in% unlist(variations))
})
```

### Integration Tests
```r
# Test complete workflow with all scenarios
test_that("complete workflow handles all scenarios", {
  # Create test data with all scenarios
  test_transcript <- data.frame(
    user_name = c("Guest User", "JS", "John Smith", "Smith, John"),
    message = "test message",
    timestamp = Sys.time()
  )
  
  # Run workflow
  result <- safe_name_matching_workflow(
    transcript_data = test_transcript,
    roster_data = test_roster,
    section_names_lookup_file = "test_lookup.csv"
  )
  
  # Verify results
  expect_true(nrow(result) > 0)
  expect_true(validate_privacy_compliance(result))
})
```

## Performance Considerations

### Optimization Strategies
1. **Caching**: Cache normalized names and lookup tables
2. **Vectorization**: Use vectorized operations for name matching
3. **Early Exit**: Stop processing when privacy violations are detected
4. **Memory Management**: Clean up sensitive data immediately

### Scalability
- **Small datasets**: Direct processing
- **Medium datasets**: Chunked processing
- **Large datasets**: Parallel processing with privacy safeguards

## Conclusion

The four name matching scenarios represent the most common challenges when working with Zoom transcripts and student rosters. The privacy-first approach ensures that student data remains protected while enabling meaningful analysis.

Key success factors:
1. **Comprehensive mapping**: Handle all name variations
2. **Privacy compliance**: Never expose real names in outputs
3. **User guidance**: Clear error messages and documentation
4. **Performance**: Efficient processing for large datasets
5. **Testing**: Thorough validation of all scenarios

This technical documentation provides the foundation for implementing robust name matching while maintaining the highest standards of privacy and security.

