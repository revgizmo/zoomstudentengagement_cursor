# Test .onLoad default option behavior - Comprehensive coverage for Issue #218

test_that(".onLoad sets default privacy_level to mask when unset", {
	old <- getOption("zoomstudentengagement.privacy_level", NULL)
	on.exit(options(zoomstudentengagement.privacy_level = old), add = TRUE)
	options(zoomstudentengagement.privacy_level = NULL)
	# simulate load behavior using internal access
	zoomstudentengagement:::.onLoad(NULL, NULL)
	expect_identical(getOption("zoomstudentengagement.privacy_level"), "mask")
})

test_that(".onLoad preserves existing privacy_level when already set", {
	old <- getOption("zoomstudentengagement.privacy_level", NULL)
	on.exit(options(zoomstudentengagement.privacy_level = old), add = TRUE)
	
	# Test with different existing values (using valid privacy levels)
	test_values <- c("ferpa_strict", "ferpa_standard", "mask", "none")
	
	for (test_value in test_values) {
		options(zoomstudentengagement.privacy_level = test_value)
		# simulate load behavior using internal access
		zoomstudentengagement:::.onLoad(NULL, NULL)
		expect_identical(getOption("zoomstudentengagement.privacy_level"), test_value)
	}
})

test_that(".onLoad handles edge cases correctly", {
	old <- getOption("zoomstudentengagement.privacy_level", NULL)
	on.exit(options(zoomstudentengagement.privacy_level = old), add = TRUE)
	
	# Test with empty string
	options(zoomstudentengagement.privacy_level = "")
	zoomstudentengagement:::.onLoad(NULL, NULL)
	expect_identical(getOption("zoomstudentengagement.privacy_level"), "")
	
	# Test with NA
	options(zoomstudentengagement.privacy_level = NA)
	zoomstudentengagement:::.onLoad(NULL, NULL)
	expect_identical(getOption("zoomstudentengagement.privacy_level"), NA)
	
	# Test with numeric value
	options(zoomstudentengagement.privacy_level = 123)
	zoomstudentengagement:::.onLoad(NULL, NULL)
	expect_identical(getOption("zoomstudentengagement.privacy_level"), 123)
})

test_that(".onLoad function parameters are handled correctly", {
	old <- getOption("zoomstudentengagement.privacy_level", NULL)
	on.exit(options(zoomstudentengagement.privacy_level = old), add = TRUE)
	options(zoomstudentengagement.privacy_level = NULL)
	
	# Test with various parameter combinations
	zoomstudentengagement:::.onLoad(NULL, NULL)
	expect_identical(getOption("zoomstudentengagement.privacy_level"), "mask")
	
	options(zoomstudentengagement.privacy_level = NULL)
	zoomstudentengagement:::.onLoad("test_lib", "test_pkg")
	expect_identical(getOption("zoomstudentengagement.privacy_level"), "mask")
	
	options(zoomstudentengagement.privacy_level = NULL)
	zoomstudentengagement:::.onLoad(character(0), character(0))
	expect_identical(getOption("zoomstudentengagement.privacy_level"), "mask")
})

test_that(".onLoad integrates correctly with set_privacy_defaults", {
	old <- getOption("zoomstudentengagement.privacy_level", NULL)
	on.exit(options(zoomstudentengagement.privacy_level = old), add = TRUE)
	
	# Test that .onLoad doesn't override set_privacy_defaults
	options(zoomstudentengagement.privacy_level = NULL)
	set_privacy_defaults("ferpa_standard")
	zoomstudentengagement:::.onLoad(NULL, NULL)
	expect_identical(getOption("zoomstudentengagement.privacy_level"), "ferpa_standard")
})

test_that(".onLoad behavior is consistent across multiple calls", {
	old <- getOption("zoomstudentengagement.privacy_level", NULL)
	on.exit(options(zoomstudentengagement.privacy_level = old), add = TRUE)
	
	# Multiple calls should not change behavior
	options(zoomstudentengagement.privacy_level = NULL)
	zoomstudentengagement:::.onLoad(NULL, NULL)
	first_call <- getOption("zoomstudentengagement.privacy_level")
	
	options(zoomstudentengagement.privacy_level = NULL)
	zoomstudentengagement:::.onLoad(NULL, NULL)
	second_call <- getOption("zoomstudentengagement.privacy_level")
	
	expect_identical(first_call, second_call)
	expect_identical(first_call, "mask")
})

# Additional tests for related privacy functionality to ensure comprehensive coverage

test_that("calculate_content_similarity returns 1 for identical simple inputs", {
	df <- data.frame(
		name = c("A", "B"),
		duration = c(10, 20),
		wordcount = c(5, 15),
		stringsAsFactors = FALSE
	)
	expect_equal(calculate_content_similarity(df, df), 1.0)
})

test_that("ensure_privacy masks names under default mask level", {
	old <- getOption("zoomstudentengagement.privacy_level", NULL)
	on.exit(options(zoomstudentengagement.privacy_level = old), add = TRUE)
	set_privacy_defaults("mask")
	df <- data.frame(
		preferred_name = c("Alice Johnson", "Bob Smith"),
		stringsAsFactors = FALSE
	)
	masked <- ensure_privacy(df, privacy_level = getOption("zoomstudentengagement.privacy_level", "mask"))
	expect_true(all(masked$preferred_name != df$preferred_name))
})
