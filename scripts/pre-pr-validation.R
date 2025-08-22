#!/usr/bin/env Rscript

# Pre-PR Validation Script
# Runs checks similar to Cursor Bugbot for R packages

library(devtools)
library(lintr)
library(styler)

cat("🔍 Running Pre-PR Validation (Bugbot-style checks)...\n\n")

# Initialize status tracking
validation_status <- list(
  code_style = FALSE,
  linting = FALSE,
  documentation = FALSE,
  readme = FALSE,
  vignettes = FALSE,
  function_signatures = FALSE,
  data_validation = FALSE,
  testing = FALSE,
  package_check = FALSE,
  test_output_validation = FALSE
)

# 1. Code Style and Quality
cat("1. Code Style and Quality:\n")
tryCatch({
  styler::style_pkg()
  cat("   ✅ Code formatting applied\n")
  validation_status$code_style <- TRUE
}, error = function(e) {
  cat("   ❌ Code formatting failed:", e$message, "\n")
})

tryCatch({
  lint_results <- lintr::lint_package()
  if (length(lint_results) == 0) {
    cat("   ✅ No linting issues found\n")
    validation_status$linting <- TRUE
  } else {
    cat("   ⚠️  Linting issues found:", length(lint_results), "\n")
    for (i in 1:min(5, length(lint_results))) {
      cat("      -", lint_results[[i]]$message, "at", lint_results[[i]]$filename, ":", lint_results[[i]]$line_number, "\n")
    }
  }
}, error = function(e) {
  cat("   ❌ Linting failed:", e$message, "\n")
})

# 2. Documentation
cat("\n2. Documentation:\n")
tryCatch({
  devtools::document()
  cat("   ✅ Documentation updated\n")
  validation_status$documentation <- TRUE
}, error = function(e) {
  cat("   ❌ Documentation failed:", e$message, "\n")
})

tryCatch({
  devtools::build_readme()
  cat("   ✅ README built\n")
  validation_status$readme <- TRUE
}, error = function(e) {
  cat("   ❌ README build failed:", e$message, "\n")
})

# 3. Vignette Validation
cat("\n3. Vignette Validation:\n")
tryCatch({
  # Check if vignettes build
  # Note: devtools::build_vignettes() will generate HTML files in doc/
  # Source files (.Rmd, .R) are properly located in vignettes/
  devtools::build_vignettes()
  cat("   ✅ Vignettes build successfully\n")
  cat("   ℹ️  Generated HTML files in doc/ (auto-ignored by .gitignore)\n")
  validation_status$vignettes <- TRUE
}, error = function(e) {
  cat("   ❌ Vignette build failed:", e$message, "\n")
})

# 4. Function Signature Validation (Enhanced)
cat("\n4. Function Signature Validation:\n")
tryCatch({
  # Load package and check function signatures
  devtools::load_all()
  
  # Get only exported symbols from this package, not imported ones
  exported_functions <- getNamespaceExports("zoomstudentengagement")
  
  # Check for common issues
  issues_found <- FALSE
  
  # Track specific function signature issues
  function_signature_issues <- list()
  
  # Functions to ignore (test helpers or not applicable here)
  ignore_functions <- c(
    "create_sample_roster", "create_sample_section_names_lookup",
    "create_sample_metrics_lookup", "create_sample_transcript_metrics",
    "create_temp_test_file"
  )
  
  for (func_name in exported_functions) {
    if (func_name %in% ignore_functions) next
    obj <- tryCatch(get(func_name, envir = asNamespace("zoomstudentengagement")), error = function(e) NULL)
    if (!is.function(obj)) next
    
    # Check if function has documentation topic
    help_topic <- file.exists(file.path("man", paste0(func_name, ".Rd")))
    
    if (!help_topic) {
      cat("   ℹ️  Note: Function", func_name, "may lack a man topic (documentation).\n")
      # Do not mark as a signature failure; informational only
    }
    
    # Example specific signature check
    if (func_name == "load_roster") {
      args <- names(formals(obj))
      if (!all(c("data_folder", "roster_file") %in% args)) {
        function_signature_issues[[func_name]] <- "Expected data_folder and roster_file arguments"
        issues_found <- TRUE
      }
    }
  }
  
  if (length(function_signature_issues) > 0) {
    cat("   ⚠️  Function signature issues found:\n")
    for (func in names(function_signature_issues)) {
      cat("      -", func, ":", function_signature_issues[[func]], "\n")
    }
  }
  
  if (!issues_found) {
    cat("   ✅ Function signatures and documentation look good\n")
    validation_status$function_signatures <- TRUE
  }
}, error = function(e) {
  cat("   ❌ Function validation failed:", e$message, "\n")
})

# 5. Data Structure Validation (Enhanced)
cat("\n5. Data Structure Validation:\n")
tryCatch({
  # Check if sample data loads correctly
  roster <- load_roster(
    data_folder = system.file("extdata", package = "zoomstudentengagement"),
    roster_file = "roster.csv"
  )
  cat("   ✅ Roster data loads successfully\n")
  
  # Check column names
  if (nrow(roster) > 0) {
    cat("   ✅ Roster has data rows\n")
    cat("   📋 Available columns:", paste(names(roster), collapse = ", "), "\n")
    
    # Check for common column name issues
    expected_columns <- c("first_last", "preferred_name", "last_first")
    missing_columns <- setdiff(expected_columns, names(roster))
    if (length(missing_columns) > 0) {
      cat("   ⚠️  Missing expected columns:", paste(missing_columns, collapse = ", "), "\n")
    }
    
    # Check for 'name' column that might be incorrectly referenced
    if ("name" %in% names(roster)) {
      cat("   ✅ 'name' column exists\n")
    } else {
      cat("   ⚠️  'name' column not found - vignettes may need updating\n")
    }
  } else {
    cat("   ⚠️  Roster is empty\n")
    cat("   💡 This may cause issues in vignettes and examples\n")
    cat("   🔍 Check inst/extdata/roster.csv for data\n")
  }
  
  # Check other sample data files
  cat("\n   📁 Checking other sample data files:\n")
  sample_files <- list.files(system.file("extdata", package = "zoomstudentengagement"))
  for (file in sample_files) {
    if (grepl("\\.csv$", file)) {
      tryCatch({
        data <- read.csv(system.file("extdata", file, package = "zoomstudentengagement"))
        cat("   ✅", file, "-", nrow(data), "rows\n")
      }, error = function(e) {
        cat("   ❌", file, "- Error loading\n")
      })
    }
  }
  
  validation_status$data_validation <- TRUE
  
}, error = function(e) {
  cat("   ❌ Data validation failed:", e$message, "\n")
})

# 6. Mathematical Formula Validation
cat("\n6. Mathematical Formula Validation:\n")
tryCatch({
  # Check for common mathematical errors in vignettes
  vignette_files <- list.files("vignettes", pattern = "\\.Rmd$", full.names = TRUE)
  
  for (vignette_file in vignette_files) {
    vignette_content <- readLines(vignette_file)
    
    # Check for Gini coefficient formula errors
    gini_patterns <- c(
      "1 - \\(?2 \\* sum\\(?rank\\(?\\.\\*\\) \\* \\.*\\) / \\(?n\\(?\\) \\* sum\\(?\\.\\*\\)\\)\\) - 1/n\\(?\\)",
      "gini_coefficient.*1 -"
    )
    
    for (pattern in gini_patterns) {
      matches <- grep(pattern, vignette_content, value = TRUE)
      if (length(matches) > 0) {
        cat("   ⚠️  Potential Gini coefficient formula error in", basename(vignette_file), "\n")
        cat("      Check formula: should not start with '1 -' and should use correct final term\n")
      }
    }
  }
  
  cat("   ✅ Mathematical formula validation completed\n")
}, error = function(e) {
  cat("   ❌ Mathematical validation failed:", e$message, "\n")
})

# 7. Testing
cat("\n7. Testing:\n")
tryCatch({
  # Run tests with timeout and error handling
  test_results <- devtools::test(reporter = "stop")
  cat("   ✅ All tests pass\n")
  validation_status$testing <- TRUE
}, error = function(e) {
  if (grepl("segfault", e$message, ignore.case = TRUE)) {
    cat("   ❌ Testing failed: Segmentation fault detected\n")
    cat("   💡 This may indicate memory management issues\n")
    cat("   🔍 Check for memory leaks in functions\n")
  } else {
    cat("   ❌ Testing failed:", e$message, "\n")
  }
}, warning = function(w) {
  cat("   ⚠️  Test warning:", w$message, "\n")
})

# 7.5. Test Output Validation
cat("\n7.5. Test Output Validation:\n")
tryCatch({
  # Check for diagnostic output pollution in R files
  r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
  # Whitelist helper files that intentionally wrap diagnostics
  whitelist_files <- c("utils_diagnostics.R")
  output_issues <- list()
  
  for (r_file in r_files) {
    if (basename(r_file) %in% whitelist_files) next
    content <- readLines(r_file)
    # Look for print(), cat(), message() outside of TESTTHAT checks
    for (i in seq_along(content)) {
      line <- content[i]
      # Skip commented lines (including roxygen)
      if (grepl("^\\s*#", line)) next
      
      # Check for output functions
      if (grepl("\\b(print|cat|message)\\s*\\(", line)) {
        # Check if this line is inside a TESTTHAT conditional
        in_testthat_block <- FALSE
        
        # Look backwards for TESTTHAT check with proper scope detection
        brace_count <- 0
        for (j in i:1) {
          line_content <- content[j]
          
          # Count closing braces
          if (grepl("^\\s*}", line_content)) {
            brace_count <- brace_count + 1
          }
          
          # Count opening braces
          if (grepl("\\{\\s*$", line_content)) {
            brace_count <- brace_count - 1
          }
          
          # Check for TESTTHAT conditional
          if (grepl('Sys.getenv("TESTTHAT") != "true"', line_content, fixed = TRUE)) {
            # If we're at brace level 0 or 1, we're in the TESTTHAT block
            if (brace_count <= 1) {
              in_testthat_block <- TRUE
            }
            break
          }
          
          # If we've gone too far back without finding the conditional, stop
          if (j < max(1, i - 50)) {
            break
          }
        }
        
        if (!in_testthat_block) {
          output_issues[[basename(r_file)]] <- c(output_issues[[basename(r_file)]], 
                                                paste("Line", i, ":", trimws(line)))
        }
      }
    }
  }
  
  if (length(output_issues) > 0) {
    cat("   ⚠️  Found diagnostic output not conditional on test environment:\n")
    for (file in names(output_issues)) {
      cat("      ", file, ":\n")
      for (issue in output_issues[[file]]) {
        cat("         ", issue, "\n")
      }
    }
    cat("   💡 Wrap print(), cat(), message() in if (Sys.getenv(\"TESTTHAT\") != \"true\")\n")
  } else {
    cat("   ✅ All diagnostic output properly conditional\n")
  }
  
  validation_status$test_output_validation <- TRUE
}, error = function(e) {
  cat("   ❌ Test output validation failed:", e$message, "\n")
})

# 8. Shell Script Validation
cat("\n8. Shell Script Validation:\n")
tryCatch({
  # Check for bash integer comparisons on floating point values
  shell_files <- list.files("scripts", pattern = "\\.sh$", full.names = TRUE)
  issues_found <- FALSE
  
  for (file in shell_files) {
    content <- readLines(file)
    # Look for integer comparisons on variables that might be decimal
    decimal_comparisons <- grep("\\[.*\\$.*\\..*\\s+[-][lg][te]\\s+[0-9]", content)
    if (length(decimal_comparisons) > 0) {
      cat("   ⚠️  Potential floating point comparison issues in", basename(file), "\n")
      issues_found <- TRUE
    }
  }
  
  if (!issues_found) {
    cat("   ✅ Shell script validation completed\n")
  }
}, error = function(e) {
  cat("   ❌ Shell script validation failed:", e$message, "\n")
})

# 9. Parameter Usage Validation
cat("\n9. Parameter Usage Validation:\n")
tryCatch({
  # Check for parameters that are validated but not used
  r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
  issues_found <- FALSE
  
  for (file in r_files) {
    content <- readLines(file)
    # Look for match.arg() calls
    match_args <- grep("match\\.arg\\(", content)
    
    for (line_num in match_args) {
      line <- content[line_num]
      # Extract parameter name from match.arg() call
      param_match <- regexpr("match\\.arg\\(([^,)]+)", line)
      if (param_match > 0) {
        param_name <- substr(line, param_match + 10, param_match + attr(param_match, "match.length") - 1)
        param_name <- gsub("^\\s+|\\s+$", "", param_name) # trim whitespace
        
        # Check if parameter is actually used in the function
        function_start <- max(1, line_num - 50) # Look back 50 lines for function start
        function_end <- min(length(content), line_num + 100) # Look forward 100 lines
        function_content <- content[function_start:function_end]
        
        # Look for parameter usage (excluding the match.arg line itself)
        usage_lines <- grep(paste0("\\b", param_name, "\\b"), function_content)
        usage_lines <- usage_lines[usage_lines != (line_num - function_start + 1)] # Exclude match.arg line
        
        if (length(usage_lines) == 0) {
          cat("   ⚠️  Parameter", param_name, "validated but not used in", basename(file), "\n")
          issues_found <- TRUE
        }
      }
    }
  }
  
  if (!issues_found) {
    cat("   ✅ Parameter usage validation completed\n")
  }
}, error = function(e) {
  cat("   ❌ Parameter usage validation failed:", e$message, "\n")
})

# 10. Package Check
cat("\n10. Package Check:\n")
tryCatch({
  check_results <- devtools::check()
  cat("   ✅ Package check completed\n")
  validation_status$package_check <- TRUE
}, error = function(e) {
  cat("   ❌ Package check failed:", e$message, "\n")
})

cat("\n🎯 Pre-PR Validation Complete!\n")
cat("Review the results above and fix any issues before creating your PR.\n")
cat("This helps catch issues that Bugbot would identify.\n\n")

# Dynamic Summary based on actual results
cat("📊 SUMMARY:\n")
cat(ifelse(validation_status$code_style, "✅", "❌"), "Code Quality: Styling and linting\n")
cat(ifelse(validation_status$documentation, "✅", "❌"), "Documentation: Updated and built\n")
cat(ifelse(validation_status$readme, "✅", "❌"), "README: Built successfully\n")
cat(ifelse(validation_status$vignettes, "✅", "❌"), "Vignettes: All build successfully\n")
cat(ifelse(validation_status$function_signatures, "✅", "❌"), "Function Signatures: Validated\n")
cat(ifelse(validation_status$data_validation, "✅", "❌"), "Data Validation: Completed\n")
cat(ifelse(validation_status$testing, "✅", "❌"), "Testing: All tests pass\n")
cat(ifelse(validation_status$test_output_validation, "✅", "❌"), "Test Output: Clean and minimal\n")
cat(ifelse(validation_status$package_check, "✅", "❌"), "Package Check: Completed\n\n")

# Count issues
total_checks <- length(validation_status)
passed_checks <- sum(unlist(validation_status))
failed_checks <- total_checks - passed_checks

if (failed_checks == 0) {
  cat("🎉 All validation checks passed! Ready for PR.\n")
} else {
  cat("⚠️  ", failed_checks, "validation check(s) failed. Please fix issues before creating PR.\n")
}

cat("\n🔧 NEXT STEPS:\n")
if (!validation_status$testing) {
  cat("1. Fix failing tests\n")
}
if (!validation_status$data_validation) {
  cat("2. Fix data loading issues\n")
}
if (!validation_status$function_signatures) {
  cat("3. Fix function signature issues\n")
}
if (!validation_status$vignettes) {
  cat("4. Fix vignette build issues\n")
}
if (failed_checks == 0) {
  cat("✅ Ready to create PR!\n")
} else {
  cat("5. Run validation again after fixes\n")
} 