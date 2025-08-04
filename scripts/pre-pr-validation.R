#!/usr/bin/env Rscript

# Pre-PR Validation Script
# Runs checks similar to Cursor Bugbot for R packages

library(devtools)
library(lintr)
library(styler)

cat("🔍 Running Pre-PR Validation (Bugbot-style checks)...\n\n")

# Backup critical files before validation
cat("📋 Backing up critical files...\n")
gitignore_backup <- NULL
if (file.exists(".gitignore")) {
  gitignore_backup <- readLines(".gitignore")
  cat("   ✅ .gitignore backed up\n")
}

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
  spell_check = FALSE,
  examples_check = FALSE,
  coverage_check = FALSE,
  gitignore_integrity = TRUE  # Track if .gitignore was modified
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
  # Monitor .gitignore before vignette build
  gitignore_before <- readLines(".gitignore")
  
  # Check if vignettes build
  devtools::build_vignettes()
  
  # Check if .gitignore was modified
  gitignore_after <- readLines(".gitignore")
  if (!identical(gitignore_before, gitignore_after)) {
    cat("   ⚠️  .gitignore was modified during vignette build\n")
    validation_status$gitignore_integrity <- FALSE
  }
  
  cat("   ✅ Vignettes build successfully\n")
  validation_status$vignettes <- TRUE
}, error = function(e) {
  cat("   ❌ Vignette build failed:", e$message, "\n")
})

# 4. Function Signature Validation (Enhanced)
cat("\n4. Function Signature Validation:\n")
tryCatch({
  # Load package and check function signatures
  devtools::load_all()
  
  # Get all exported functions
  exported_functions <- ls("package:zoomstudentengagement")
  
  # Check for common issues
  issues_found <- FALSE
  
  # Check function signatures against known patterns
  function_signature_issues <- list()
  
  # Functions to ignore (test helpers, base R functions, etc.)
  ignore_functions <- c(
    "create_sample_roster", "create_sample_section_names_lookup", 
    "create_sample_metrics_lookup", "create_sample_transcript_metrics", 
    "create_temp_test_file", "library.dynam", "library.dynam.unload", 
    "system.file"
  )
  
  for (func_name in exported_functions) {
    # Skip functions that should be ignored
    if (func_name %in% ignore_functions) {
      next
    }
    
    if (is.function(get(func_name, envir = asNamespace("zoomstudentengagement")))) {
      # Check if function has documentation
      help_topic <- tryCatch({
        help(func_name, package = "zoomstudentengagement")
        TRUE
      }, error = function(e) FALSE)
      
      if (!help_topic) {
        cat("   ⚠️  Function", func_name, "may lack documentation\n")
        issues_found <- TRUE
      }
      
      # Check for specific function signature issues
      if (func_name == "load_roster") {
        func <- get(func_name, envir = asNamespace("zoomstudentengagement"))
        args <- names(formals(func))
        if (!("data_folder" %in% args) || !("roster_file" %in% args)) {
          function_signature_issues[[func_name]] <- "Expected data_folder and roster_file arguments"
          issues_found <- TRUE
        }
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
      "1 - \\(2 \\* sum\\(rank\\(.*\\) \\* .*\\) / \\(n\\(\\) \\* sum\\(.*\\)\\)\\) - 1/n\\(\\)",
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

# 8. Package Check
cat("\n8. Package Check:\n")
tryCatch({
  check_results <- devtools::check()
  cat("   ✅ Package check completed\n")
  validation_status$package_check <- TRUE
}, error = function(e) {
  cat("   ❌ Package check failed:", e$message, "\n")
})

# 9. CRAN-Specific Checks
cat("\n9. CRAN-Specific Checks:\n")
tryCatch({
  spell_results <- devtools::spell_check()
  if (length(spell_results) == 0) {
    cat("   ✅ No spelling errors found\n")
    validation_status$spell_check <- TRUE
  } else {
    cat("   ⚠️  Spelling errors found:", length(spell_results), "\n")
    for (i in 1:min(3, length(spell_results))) {
      cat("      -", spell_results[[i]]$word, "in", spell_results[[i]]$file, "\n")
    }
  }
}, error = function(e) {
  cat("   ❌ Spell check failed:", e$message, "\n")
})

tryCatch({
  devtools::check_examples()
  cat("   ✅ All examples run successfully\n")
  validation_status$examples_check <- TRUE
}, error = function(e) {
  cat("   ❌ Examples check failed:", e$message, "\n")
})

tryCatch({
  if (requireNamespace("covr", quietly = TRUE)) {
    coverage <- covr::package_coverage()
    coverage_percent <- round(attr(coverage, "coverage"), 1)
    cat("   📊 Test coverage:", coverage_percent, "%\n")
    if (coverage_percent >= 90) {
      cat("   ✅ Coverage meets CRAN requirements (≥90%)\n")
      validation_status$coverage_check <- TRUE
    } else {
      cat("   ⚠️  Coverage below CRAN requirements (<90%)\n")
    }
  } else {
    cat("   ℹ️  covr package not available, skipping coverage check\n")
  }
}, error = function(e) {
  cat("   ❌ Coverage check failed:", e$message, "\n")
})

cat("\n🎯 Pre-PR Validation Complete!\n")
cat("Review the results above and fix any issues before creating your PR.\n")
cat("This helps catch issues that Bugbot would identify.\n\n")

# Cleanup: Restore critical files
cat("🧹 Cleaning up...\n")
if (!is.null(gitignore_backup)) {
  current_gitignore <- readLines(".gitignore")
  if (!identical(current_gitignore, gitignore_backup)) {
    writeLines(gitignore_backup, ".gitignore")
    cat("   ❌ .gitignore was modified and restored - this indicates a validation failure\n")
    validation_status$gitignore_integrity <- FALSE
  } else {
    cat("   ✅ .gitignore integrity maintained\n")
  }
}

# Dynamic Summary based on actual results
cat("📊 SUMMARY:\n")
cat(ifelse(validation_status$code_style, "✅", "❌"), "Code Quality: Styling and linting\n")
cat(ifelse(validation_status$documentation, "✅", "❌"), "Documentation: Updated and built\n")
cat(ifelse(validation_status$readme, "✅", "❌"), "README: Built successfully\n")
cat(ifelse(validation_status$vignettes, "✅", "❌"), "Vignettes: All build successfully\n")
cat(ifelse(validation_status$function_signatures, "✅", "❌"), "Function Signatures: Validated\n")
cat(ifelse(validation_status$data_validation, "✅", "❌"), "Data Validation: Completed\n")
cat(ifelse(validation_status$testing, "✅", "❌"), "Testing: All tests pass\n")
cat(ifelse(validation_status$package_check, "✅", "❌"), "Package Check: Completed\n")
cat(ifelse(validation_status$spell_check, "✅", "❌"), "Spell Check: No errors\n")
cat(ifelse(validation_status$examples_check, "✅", "❌"), "Examples: All run successfully\n")
cat(ifelse(validation_status$coverage_check, "✅", "❌"), "Coverage: Meets CRAN requirements\n")
cat(ifelse(validation_status$gitignore_integrity, "✅", "❌"), "File Integrity: .gitignore not modified\n\n")

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
if (!validation_status$spell_check) {
  cat("5. Fix spelling errors\n")
}
if (!validation_status$examples_check) {
  cat("6. Fix example errors\n")
}
if (!validation_status$coverage_check) {
  cat("7. Improve test coverage to ≥90%\n")
}
if (!validation_status$gitignore_integrity) {
  cat("8. Investigate what modified .gitignore during validation\n")
}
if (failed_checks == 0) {
  cat("✅ Ready to create PR!\n")
} else {
  cat("9. Run validation again after fixes\n")
} 