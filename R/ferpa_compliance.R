#' FERPA Compliance Functions
#'
#' Functions to validate and ensure FERPA compliance for educational data.
#' These functions help institutions maintain compliance with the Family
#' Educational Rights and Privacy Act (FERPA) when using this package.
#'
#' @name ferpa_compliance
#' @keywords internal
NULL

#' Validate FERPA Compliance
#'
#' Validates data for FERPA compliance by checking for personally identifiable
#' information (PII) and validating data handling procedures.
#'
#' @param data A data frame or tibble to validate
#' @param institution_type Type of institution. One of `c("educational", "research", "mixed")`
#' @param check_retention Whether to check data retention policies
#' @param retention_period Retention period to check against. One of `c("academic_year", "semester", "quarter", "custom")`
#' @param custom_retention_days Custom retention period in days (used when retention_period = "custom")
#'
#' @return A list containing compliance validation results with the following elements:
#'   - `compliant`: Logical indicating overall compliance
#'   - `pii_detected`: Character vector of detected PII fields
#'   - `recommendations`: Character vector of compliance recommendations
#'   - `retention_check`: Data retention validation results (if requested)
#'   - `institution_guidance`: Institution-specific recommendations
#'
#' @export
#'
#' @examples
#' # Validate sample data for FERPA compliance
#' sample_data <- tibble::tibble(
#'   student_id = c("12345", "67890"),
#'   preferred_name = c("Alice Johnson", "Bob Smith"),
#'   email = c("alice@university.edu", "bob@university.edu"),
#'   participation_score = c(85, 92)
#' )
#'
#' validation_result <- validate_ferpa_compliance(sample_data)
#' print(validation_result$compliant)
#' print(validation_result$recommendations)
validate_ferpa_compliance <- function(data,
                                      institution_type = c("educational", "research", "mixed"),
                                      check_retention = TRUE,
                                      retention_period = c("academic_year", "semester", "quarter", "custom"),
                                      custom_retention_days = NULL) {
  institution_type <- match.arg(institution_type)
  retention_period <- match.arg(retention_period)

  if (!is.data.frame(data)) {
    abort_zse("`data` must be a data.frame or tibble", class = "zse_input_error")
  }

  # Initialize results
  result <- list(
    compliant = TRUE,
    pii_detected = character(0),
    recommendations = character(0),
    retention_check = NULL,
    institution_guidance = character(0)
  )

  # Check for PII fields
  pii_patterns <- c(
    "student_id", "studentid", "student_id_", "id",
    "preferred_name", "name", "first_last", "name_raw",
    "email", "email_address", "e_mail",
    "phone", "phone_number", "telephone",
    "address", "street_address", "home_address",
    "ssn", "social_security", "social_security_number",
    "birth_date", "birthday", "date_of_birth",
    "parent_name", "guardian_name"
  )

  detected_pii <- character(0)
  for (pattern in pii_patterns) {
    matching_cols <- grep(pattern, names(data), ignore.case = TRUE, value = TRUE)
    detected_pii <- c(detected_pii, matching_cols)
  }

  result$pii_detected <- unique(detected_pii)

  # Generate recommendations based on PII detection
  if (length(result$pii_detected) > 0) {
    result$compliant <- FALSE
    result$recommendations <- c(
      result$recommendations,
      paste("PII detected in columns:", paste(result$pii_detected, collapse = ", ")),
      "Consider using ensure_privacy() to mask identifiable data",
      "Review institutional FERPA policies for data handling",
      "Ensure data access is limited to authorized personnel"
    )
  }

  # Institution-specific guidance
  if (institution_type == "educational") {
    result$institution_guidance <- c(
      result$institution_guidance,
      "Educational institutions must comply with FERPA regulations",
      "Student records must be protected from unauthorized access",
      "Consider implementing role-based access controls",
      "Document all data access and usage procedures"
    )
  } else if (institution_type == "research") {
    result$institution_guidance <- c(
      result$institution_guidance,
      "Research institutions should follow IRB guidelines",
      "Ensure proper consent procedures are in place",
      "Consider data anonymization for research publications",
      "Review institutional review board requirements"
    )
  } else if (institution_type == "mixed") {
    result$institution_guidance <- c(
      result$institution_guidance,
      "Mixed institutions must comply with both FERPA and research ethics",
      "Implement separate procedures for educational vs. research data",
      "Ensure clear data classification and handling procedures",
      "Review both FERPA and IRB requirements"
    )
  }

  # Data retention check
  if (check_retention) {
    result$retention_check <- check_data_retention_policy(
      data,
      retention_period = retention_period,
      custom_retention_days = custom_retention_days
    )

    if (!result$retention_check$compliant) {
      result$compliant <- FALSE
      result$recommendations <- c(
        result$recommendations,
        result$retention_check$recommendations
      )
    }
  }

  # Additional compliance recommendations
  result$recommendations <- c(
    result$recommendations,
    "Use set_privacy_defaults('mask') for privacy-safe outputs",
    "Implement secure data storage and transmission",
    "Train personnel on FERPA compliance requirements",
    "Maintain audit trails for data access and modifications"
  )

  result
}

#' Anonymize Educational Data
#'
#' Advanced anonymization for educational data that preserves data utility
#' while ensuring FERPA compliance.
#'
#' @param data A data frame or tibble to anonymize
#' @param method Anonymization method. One of `c("mask", "hash", "pseudonymize", "aggregate")`
#' @param preserve_columns Character vector of column names to preserve unchanged
#' @param hash_salt Salt for hash-based anonymization (optional)
#' @param aggregation_level Level for aggregation. One of `c("individual", "section", "course", "institution")`
#'
#' @return The anonymized data frame with the same structure as input
#'
#' @export
#'
#' @examples
#' # Anonymize sample data
#' sample_data <- tibble::tibble(
#'   student_id = c("12345", "67890"),
#'   preferred_name = c("Alice Johnson", "Bob Smith"),
#'   section = c("A", "B"),
#'   participation_score = c(85, 92)
#' )
#'
#' # Mask method (default)
#' anonymized <- anonymize_educational_data(sample_data, method = "mask")
#'
#' # Hash method with salt
#' hashed <- anonymize_educational_data(sample_data, method = "hash", hash_salt = "my_salt")
anonymize_educational_data <- function(data,
                                       method = c("mask", "hash", "pseudonymize", "aggregate"),
                                       preserve_columns = NULL,
                                       hash_salt = NULL,
                                       aggregation_level = c("individual", "section", "course", "institution")) {
  method <- match.arg(method)
  aggregation_level <- match.arg(aggregation_level)

  if (!is.data.frame(data)) {
    stop("Data must be a data frame or tibble", call. = FALSE)
  }

  # Define PII columns to anonymize
  pii_columns <- c(
    "student_id", "studentid", "student_id_",
    "preferred_name", "name", "first_last", "name_raw",
    "email", "email_address", "e_mail",
    "phone", "phone_number", "telephone"
  )

  # Find columns to anonymize
  columns_to_anonymize <- intersect(pii_columns, names(data))
  columns_to_preserve <- intersect(preserve_columns, names(data))
  columns_to_anonymize <- setdiff(columns_to_anonymize, columns_to_preserve)

  if (length(columns_to_anonymize) == 0) {
    diag_message("No PII columns found to anonymize")
    return(data)
  }

  result <- data

  if (method == "mask") {
    # Use existing ensure_privacy function
    result <- ensure_privacy(data, privacy_level = "mask")
  } else if (method == "hash") {
    # Hash-based anonymization
    for (col in columns_to_anonymize) {
      if (is.character(result[[col]]) || is.factor(result[[col]])) {
        values <- as.character(result[[col]])
        # Create deterministic hash
        hash_input <- if (!is.null(hash_salt)) paste0(values, hash_salt) else values
        hashed_values <- sapply(hash_input, function(x) {
          if (is.na(x) || nchar(x) == 0) {
            return(x)
          }
          digest::digest(x, algo = "sha256", serialize = FALSE)
        })
        result[[col]] <- substr(hashed_values, 1, 8) # Use first 8 characters
      }
    }
  } else if (method == "pseudonymize") {
    # Pseudonymization with consistent mapping
    for (col in columns_to_anonymize) {
      if (is.character(result[[col]]) || is.factor(result[[col]])) {
        values <- as.character(result[[col]])
        unique_vals <- unique(values[!is.na(values) & nchar(values) > 0])
        if (length(unique_vals) > 0) {
          # Create pseudonyms
          pseudonyms <- paste0("PSEUDO_", stringr::str_pad(seq_along(unique_vals), width = 3, pad = "0"))
          mapping <- stats::setNames(pseudonyms, unique_vals)
          result[[col]] <- mapping[values]
        }
      }
    }
  } else if (method == "aggregate") {
    # Aggregation-based anonymization
    if (aggregation_level == "individual") {
      # Individual level - apply masking
      result <- ensure_privacy(data, privacy_level = "mask")
    } else {
      # Higher aggregation levels
      group_cols <- switch(aggregation_level,
        "section" = intersect(c("section", "section_name"), names(data)),
        "course" = intersect(c("course", "course_id", "course_name"), names(data)),
        "institution" = character(0)
      )

      if (length(group_cols) > 0) {
        # Aggregate by group columns
        result <- data %>%
          dplyr::group_by(!!!rlang::syms(group_cols)) %>%
          dplyr::summarise(
            dplyr::across(
              dplyr::where(is.numeric),
              list(
                mean = ~ mean(.x, na.rm = TRUE),
                count = ~ dplyr::n(),
                min = ~ min(.x, na.rm = TRUE),
                max = ~ max(.x, na.rm = TRUE)
              ),
              .groups = "drop"
            )
          )
      } else {
        # No group columns available, fall back to masking
        result <- ensure_privacy(data, privacy_level = "mask")
      }
    }
  }

  result
}

#' Generate FERPA Compliance Report
#'
#' Generates comprehensive FERPA compliance reports for educational data.
#'
#' @param data A data frame or tibble to analyze
#' @param output_file Optional file path to save the report
#' @param report_format Report format. One of `c("text", "html", "json")`
#' @param include_audit_trail Whether to include audit trail information
#' @param institution_info Optional list with institution information
#'
#' @return A list containing the compliance report
#'
#' @export
#'
#' @examples
#' # Generate compliance report
#' sample_data <- tibble::tibble(
#'   student_id = c("12345", "67890"),
#'   preferred_name = c("Alice Johnson", "Bob Smith"),
#'   participation_score = c(85, 92)
#' )
#'
#' report <- generate_ferpa_report(sample_data)
#' print(report$summary)
generate_ferpa_report <- function(data,
                                  output_file = NULL,
                                  report_format = c("text", "html", "json"),
                                  include_audit_trail = TRUE,
                                  institution_info = NULL) {
  report_format <- match.arg(report_format)

  # Validate data
  validation_result <- validate_ferpa_compliance(data)

  # Generate audit trail
  audit_trail <- if (include_audit_trail) {
    list(
      report_generated = Sys.time(),
      data_rows = nrow(data),
      data_columns = ncol(data),
      pii_columns_detected = length(validation_result$pii_detected),
      privacy_level = getOption("zoomstudentengagement.privacy_level", "mask")
    )
  } else {
    NULL
  }

  # Build report
  report <- list(
    title = "FERPA Compliance Report",
    generated = Sys.time(),
    summary = list(
      compliant = validation_result$compliant,
      pii_detected = validation_result$pii_detected,
      recommendations_count = length(validation_result$recommendations)
    ),
    validation_results = validation_result,
    audit_trail = audit_trail,
    institution_info = institution_info,
    recommendations = validation_result$recommendations
  )

  # Save to file if requested
  if (!is.null(output_file)) {
    if (report_format == "json") {
      jsonlite::write_json(report, output_file, pretty = TRUE)
    } else if (report_format == "html") {
      # Create simple HTML report
      html_content <- paste0(
        "<html><head><title>FERPA Compliance Report</title></head><body>",
        "<h1>FERPA Compliance Report</h1>",
        "<p><strong>Generated:</strong> ", report$generated, "</p>",
        "<p><strong>Compliant:</strong> ", ifelse(report$summary$compliant, "Yes", "No"), "</p>",
        "<h2>Recommendations</h2><ul>",
        paste0("<li>", report$recommendations, "</li>", collapse = ""),
        "</ul></body></html>"
      )
      writeLines(html_content, output_file)
    } else {
      # Text format
      text_content <- paste0(
        "FERPA Compliance Report\n",
        "Generated: ", report$generated, "\n",
        "Compliant: ", ifelse(report$summary$compliant, "Yes", "No"), "\n",
        "PII Detected: ", paste(report$summary$pii_detected, collapse = ", "), "\n",
        "\nRecommendations:\n",
        paste0("- ", report$recommendations, collapse = "\n")
      )
      writeLines(text_content, output_file)
    }
  }

  report
}

#' Check Data Retention Policy
#'
#' Validates data retention policies and identifies data that should be
#' disposed of according to institutional policies.
#'
#' @param data A data frame or tibble to check
#' @param retention_period Retention period to check against. One of `c("academic_year", "semester", "quarter", "custom")`
#' @param custom_retention_days Custom retention period in days (used when retention_period = "custom")
#' @param date_column Column name containing dates to check against
#' @param current_date Current date for comparison (defaults to Sys.Date())
#'
#' @return A list containing retention validation results
#'
#' @export
#'
#' @examples
#' # Check data retention policy
#' sample_data <- tibble::tibble(
#'   student_id = c("12345", "67890"),
#'   session_date = as.Date(c("2024-01-15", "2024-02-20")),
#'   participation_score = c(85, 92)
#' )
#'
#' retention_check <- check_data_retention_policy(
#'   sample_data,
#'   retention_period = "academic_year",
#'   date_column = "session_date"
#' )
#' print(retention_check$compliant)
check_data_retention_policy <- function(data,
                                        retention_period = c("academic_year", "semester", "quarter", "custom"),
                                        custom_retention_days = NULL,
                                        date_column = NULL,
                                        current_date = Sys.Date()) {
  retention_period <- match.arg(retention_period)

  result <- list(
    compliant = TRUE,
    retention_period_days = 0,
    data_to_dispose = NULL,
    recommendations = character(0)
  )

  # Calculate retention period in days
  retention_days <- switch(retention_period,
    "academic_year" = 365,
    "semester" = 180,
    "quarter" = 90,
    "custom" = if (!is.null(custom_retention_days)) custom_retention_days else 365
  )

  result$retention_period_days <- retention_days

  # Check date column if provided
  if (!is.null(date_column) && date_column %in% names(data)) {
    if (is.character(data[[date_column]])) {
      dates <- as.Date(data[[date_column]])
    } else if (inherits(data[[date_column]], "Date")) {
      dates <- data[[date_column]]
    } else {
      dates <- as.Date(data[[date_column]])
    }

    # Find data older than retention period
    cutoff_date <- current_date - retention_days
    old_data_indices <- which(dates < cutoff_date)

    if (length(old_data_indices) > 0) {
      result$compliant <- FALSE
      result$data_to_dispose <- data[old_data_indices, ]
      result$recommendations <- c(
        result$recommendations,
        paste("Found", length(old_data_indices), "records older than retention period"),
        paste("Cutoff date:", cutoff_date),
        "Consider disposing of old data according to institutional policy",
        "Review data retention requirements with institutional compliance officer"
      )
    }
  }

  # General retention recommendations
  result$recommendations <- c(
    result$recommendations,
    paste("Retention period:", retention_period, "(", retention_days, "days)"),
    "Implement automated data disposal procedures",
    "Document data retention and disposal procedures",
    "Train personnel on data retention requirements"
  )

  result
}
