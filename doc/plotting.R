## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 8,
  fig.height = 6
)

## ----setup--------------------------------------------------------------------
library(zoomstudentengagement)
library(dplyr)
library(ggplot2)

## ----prepare-data-------------------------------------------------------------
# Create sample data for demonstration
# In practice, you would load actual transcript and roster data

# Sample transcript metrics
transcripts_metrics_df <- tibble::tibble(
  name = c("Alice Johnson", "Bob Smith", "Carol Davis", "David Wilson", "Eva Brown"),
  n = c(8, 12, 5, 15, 3),
  duration = c(45.2, 67.8, 23.1, 89.4, 12.5),
  wordcount = c(1200, 1800, 650, 2200, 400),
  comments = list("Good point", "Interesting question", "I agree", "Follow-up question", "Brief comment"),
  n_perc = c(18.6, 27.9, 11.6, 34.9, 7.0),
  duration_perc = c(19.2, 28.8, 9.8, 38.0, 5.3),
  wordcount_perc = c(19.2, 28.8, 10.4, 35.2, 6.4),
  wpm = c(26.5, 26.6, 28.1, 24.6, 32.0),
  course_section = "LTF.201.1",
  course = 201,
  section = 1,
  day = "Thursday",
  time = "18:30",
  name_raw = name,
  start_time_local = as.POSIXct("2024-01-24 18:30:00", tz = "America/Los_Angeles"),
  dept = "LTF",
  session_num = 1
)

# Sample roster sessions
roster_sessions <- tibble::tibble(
  student_id = c("12345", "12346", "12347", "12348", "12349"),
  first_last = c("Alice Johnson", "Bob Smith", "Carol Davis", "David Wilson", "Eva Brown"),
  preferred_name = c("Alice", "Bob", "Carol", "David", "Eva"),
  dept = "LTF",
  course = 201,
  section = 1,
  session_num = 1,
  start_time_local = as.POSIXct("2024-01-24 18:30:00", tz = "America/Los_Angeles"),
  course_section = "LTF.201.1"
)

# Create clean names dataframe
clean_names_df <- make_clean_names_df(
  data_folder = system.file("extdata", package = "zoomstudentengagement"),
  section_names_lookup_file = "section_names_lookup.csv",
  transcripts_metrics_df,
  roster_sessions
)

# Create summary dataframes
transcripts_session_summary_df <- make_transcripts_session_summary_df(clean_names_df)
transcripts_summary_df <- make_transcripts_summary_df(transcripts_session_summary_df)

# View the summary data
head(transcripts_summary_df)

## ----basic-plots--------------------------------------------------------------
# Plot session count
plot_users_by_metric(transcripts_summary_df, metric = "session_ct")

## ----comment-count------------------------------------------------------------
# Plot comment count
plot_users_by_metric(transcripts_summary_df, metric = "n")

## ----duration-----------------------------------------------------------------
# Plot speaking duration
plot_users_by_metric(transcripts_summary_df, metric = "duration")

## ----wordcount----------------------------------------------------------------
# Plot word count
plot_users_by_metric(transcripts_summary_df, metric = "wordcount")

## ----percentage-metrics-------------------------------------------------------
# Plot percentage of comments
plot_users_by_metric(transcripts_summary_df, metric = "perc_n")

# Plot percentage of speaking time
plot_users_by_metric(transcripts_summary_df, metric = "perc_duration")

# Plot percentage of words
plot_users_by_metric(transcripts_summary_df, metric = "perc_wordcount")

## ----students-only------------------------------------------------------------
# Create students-only summary
students_only_summary <- make_students_only_transcripts_summary_df(
  transcripts_session_summary_df
)

# Plot students-only metrics
plot_users_by_metric(students_only_summary, metric = "session_ct")

## ----masked-plots-------------------------------------------------------------
# Plot with masked names
plot_users_masked_section_by_metric(
  df = students_only_summary,
  metric = "n"
)

plot_users_masked_section_by_metric(
  df = students_only_summary,
  metric = "duration"
)

## ----custom-filtering---------------------------------------------------------
# Filter for specific sections
section_data <- transcripts_summary_df %>%
  filter(section == 1)  # Use the actual section number from our sample data

# Plot filtered data
plot_users_by_metric(section_data, metric = "wpm")

## ----comparative--------------------------------------------------------------
# Create comparison plots
par(mfrow = c(2, 2))
plot_users_by_metric(transcripts_summary_df, metric = "n")
plot_users_by_metric(transcripts_summary_df, metric = "duration")
plot_users_by_metric(transcripts_summary_df, metric = "wordcount")
plot_users_by_metric(transcripts_summary_df, metric = "wpm")

## ----equity-analysis----------------------------------------------------------
# Analyze participation distribution
participation_summary <- transcripts_summary_df %>%
  group_by(section) %>%
  summarise(
    total_students = n(),
    active_students = sum(n > 0),
    avg_comments = mean(n),
    median_comments = median(n),
    participation_rate = active_students / total_students
  )

participation_summary

## ----patterns-----------------------------------------------------------------
# Categorize students by engagement type
engagement_categories <- transcripts_summary_df %>%
  mutate(
    engagement_type = case_when(
      n == 0 ~ "No participation",
      n <= 2 ~ "Low participation", 
      n <= 5 ~ "Moderate participation",
      TRUE ~ "High participation"
    )
  ) %>%
  count(engagement_type)

engagement_categories

## ----custom-plots-------------------------------------------------------------
# Custom participation distribution
ggplot(transcripts_summary_df, aes(x = n)) +
  geom_histogram(binwidth = 1, fill = "steelblue", alpha = 0.7) +
  labs(
    title = "Distribution of Comment Counts",
    x = "Number of Comments",
    y = "Number of Students"
  ) +
  theme_minimal()

# Custom duration vs word count
ggplot(transcripts_summary_df, aes(x = duration, y = wordcount)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Speaking Duration vs Word Count",
    x = "Duration (seconds)",
    y = "Word Count"
  ) +
  theme_minimal()

