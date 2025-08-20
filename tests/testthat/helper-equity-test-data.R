# Equity Test Data Utilities for Issue #294
# Comprehensive test scenarios for equity metrics functions

#' Create realistic equity test scenarios for comprehensive testing
#' @return A list containing various test data scenarios
#' @keywords internal
create_equity_test_data <- function() {
  # Single participant class
  single_student <- tibble::tibble(
    preferred_name = "Alice",
    section = "101.A",
    duration = 100,
    wordcount = 500,
    n = 5
  )

  # All equal participation
  equal_participation <- tibble::tibble(
    preferred_name = c("Alice", "Bob", "Charlie", "Diana"),
    section = rep("101.A", 4),
    duration = rep(100, 4),
    wordcount = rep(500, 4),
    n = rep(5, 4)
  )

  # Extreme differences
  extreme_differences <- tibble::tibble(
    preferred_name = c("HighParticipant", "Alice", "Bob", "Charlie"),
    section = rep("101.A", 4),
    duration = c(1000, 100, 90, 80),
    wordcount = c(5000, 500, 450, 400),
    n = c(50, 5, 4, 3)
  )

  # International names
  international_names <- tibble::tibble(
    preferred_name = c("José García", "Ming Li", "Fatima Al-Zahra", "Oleksandr Kovalenko"),
    section = rep("101.A", 4),
    duration = c(120, 110, 105, 95),
    wordcount = c(600, 550, 525, 475),
    n = c(6, 5, 5, 4)
  )

  # Large class
  large_class <- tibble::tibble(
    preferred_name = paste0("Student", 1:60),
    section = rep("101.A", 60),
    duration = sample(50:200, 60, replace = TRUE),
    wordcount = sample(250:1000, 60, replace = TRUE),
    n = sample(1:10, 60, replace = TRUE)
  )

  # Problematic data
  problematic_data <- tibble::tibble(
    preferred_name = c("Alice", "Bob", "Charlie", "Diana", "Eve"),
    section = rep("101.A", 5),
    duration = c(100, NA, 0, -10, 50),
    wordcount = c(500, 400, 0, 200, NA),
    n = c(5, 4, 0, 2, 1)
  )

  # Duplicate names
  duplicate_names <- tibble::tibble(
    preferred_name = c("Alice Smith", "Alice Smith", "Bob Jones", "Bob Jones"),
    section = rep("101.A", 4),
    duration = c(100, 95, 90, 85),
    wordcount = c(500, 475, 450, 425),
    n = c(5, 4, 3, 2)
  )

  # Multi-section data for comparison
  multi_section <- tibble::tibble(
    preferred_name = c(
      "Alice", "Bob", "Charlie", "Diana",
      "Eve", "Frank", "Grace", "Henry"
    ),
    section = c(rep("101.A", 4), rep("101.B", 4)),
    duration = c(100, 90, 80, 70, 95, 85, 75, 65),
    wordcount = c(500, 450, 400, 350, 475, 425, 375, 325),
    n = c(5, 4, 3, 2, 4, 3, 2, 1)
  )

  # Edge case: very small differences
  small_differences <- tibble::tibble(
    preferred_name = c("Alice", "Bob", "Charlie", "Diana"),
    section = rep("101.A", 4),
    duration = c(100, 99, 98, 97),
    wordcount = c(500, 498, 496, 494),
    n = c(5, 4, 4, 3)
  )

  # Edge case: all zeros
  all_zeros <- tibble::tibble(
    preferred_name = c("Alice", "Bob", "Charlie"),
    section = rep("101.A", 3),
    duration = c(0, 0, 0),
    wordcount = c(0, 0, 0),
    n = c(0, 0, 0)
  )

  # Edge case: mixed data types
  mixed_data_types <- tibble::tibble(
    preferred_name = c("Alice", "Bob", "Charlie"),
    section = c("101.A", "101.A", "101.A"),
    duration = c(100, 90, 80),
    wordcount = c(500, 450, 400),
    n = c(5, 4, 3),
    # Add some additional columns that might be present
    course = c(101, 101, 101),
    day = c("2023-01-01", "2023-01-01", "2023-01-01")
  )

  list(
    single_student = single_student,
    equal_participation = equal_participation,
    extreme_differences = extreme_differences,
    international_names = international_names,
    large_class = large_class,
    problematic_data = problematic_data,
    duplicate_names = duplicate_names,
    multi_section = multi_section,
    small_differences = small_differences,
    all_zeros = all_zeros,
    mixed_data_types = mixed_data_types
  )
}

#' Create equity-focused test scenarios for specific validation
#' @return A list containing equity-specific test scenarios
#' @keywords internal
create_equity_validation_data <- function() {
  # Participation gap analysis
  participation_gaps <- tibble::tibble(
    preferred_name = c(
      "HighParticipant1", "HighParticipant2", "HighParticipant3",
      "MediumParticipant1", "MediumParticipant2", "MediumParticipant3",
      "LowParticipant1", "LowParticipant2", "LowParticipant3"
    ),
    section = rep("101.A", 9),
    duration = c(200, 180, 160, 100, 90, 80, 20, 15, 10),
    wordcount = c(1000, 900, 800, 500, 450, 400, 100, 75, 50),
    n = c(20, 18, 16, 10, 9, 8, 2, 1, 1)
  )

  # Gender-balanced participation (for equity analysis)
  gender_balanced <- tibble::tibble(
    preferred_name = c(
      "Alice", "Betty", "Carol", "Diana", "Eve",
      "Adam", "Bob", "Charlie", "David", "Frank"
    ),
    section = rep("101.A", 10),
    duration = c(100, 95, 90, 85, 80, 100, 95, 90, 85, 80),
    wordcount = c(500, 475, 450, 425, 400, 500, 475, 450, 425, 400),
    n = c(5, 4, 4, 3, 3, 5, 4, 4, 3, 3)
  )

  # Section comparison for equity analysis
  section_comparison <- tibble::tibble(
    preferred_name = c(
      "Alice", "Bob", "Charlie", "Diana",
      "Eve", "Frank", "Grace", "Henry",
      "Ivy", "Jack", "Kate", "Liam"
    ),
    section = c(rep("101.A", 4), rep("101.B", 4), rep("101.C", 4)),
    duration = c(100, 90, 80, 70, 95, 85, 75, 65, 90, 80, 70, 60),
    wordcount = c(500, 450, 400, 350, 475, 425, 375, 325, 450, 400, 350, 300),
    n = c(5, 4, 3, 2, 4, 3, 2, 1, 3, 2, 1, 1)
  )

  list(
    participation_gaps = participation_gaps,
    gender_balanced = gender_balanced,
    section_comparison = section_comparison
  )
}
