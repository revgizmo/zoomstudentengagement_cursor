
<!-- README.md is generated from README.Rmd. Please edit that file -->

# zoomstudentengagement

<!-- badges: start -->
<!-- badges: end -->

The goal of zoomstudentengagement is to …

## Installation

You can install the development version of zoomstudentengagement like
so:

``` r
devtools::install_github("revgizmo/zoomstudentengagement")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(zoomstudentengagement)
```

# Steps to use zoomstudentengagement

## 1. Define Inputs:

- Current Term Inputs
  - `instructor_name_input`
  - etc
- Other Constants
  - `names_exclude_input`
  - etc

``` r
data_folder_input <- 'data_201_2024_t1_fall'
# data_folder_input <- 'data_lft'
library(zoomstudentengagement)

data_folder_input <- system.file("extdata",  package="zoomstudentengagement")
data_folder_input
#> [1] "/Library/Frameworks/R.framework/Versions/4.1-arm64/Resources/library/zoomstudentengagement/extdata"
```

## 2. Load the zoomstudentengagement library

- `r devtools::install_github("revgizmo/zoomstudentengagement")`
- `r library(zoomstudentengagement)`

``` r
library(zoomstudentengagement)

# devtools::load_all('../zoomstudentengagement')
# devtools::install_github("revgizmo/zoomstudentengagement")
```

## 3. Download the Zoom Recording Transcripts

1.  Download Zoom csv file with list of recordings and transcripts
    1.  Go to <https://www.zoom.us/recording>
    2.  Export the Cloud Recordings
    3.  Copy the cloud recording csv (naming convention:
        ’zoomus_recordings\_\_\d{8}.csv’) to ‘data/transcripts/’
2.  Download Transcripts
    1.  Go to <https://www.zoom.us/recording>
    2.  Click on each individual record to go to the page for that
        recording
    3.  Download the Audio Transcript and Chat File for each
        - Chat: ’GMT\d{8}-\d{6}\_Recording.cc.vtt’
        - Transcript: ’GMT\d{8}-\d{6}\_Recording.transcript.vtt’
    4.  Copy the Audio Transcript and Chat Files to ‘data/transcripts/’

## 4. Load the list of Zoom Recordings Transcripts

    1. Run `load_zoom_recorded_sessions_list()` to get a tibble from a provided csv file of Zoom recordings.

``` r
zoom_recorded_sessions_df <- load_zoom_recorded_sessions_list(
  data_folder = data_folder_input,
  transcripts_folder = "transcripts",
  topic_split_pattern = paste0(
    "^(?<dept>\\S+) (?<section>\\S+) - ",
    "(?<day>[A-Za-z]+) (?<time>\\S+\\s*\\S+) (?<instructor>\\(.*?\\))"
  ),
  zoom_recorded_sessions_csv_names_pattern =
    "zoomus_recordings__\\d{8}(?:\\s+copy\\s*\\d*)?\\.csv",
  dept = "LTF",
  semester_start_mdy = "Jan 01, 2024",
  scheduled_session_length_hours = 1.5
)
#> Rows: 4 Columns: 9
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (4): Topic, ID, Start Time, Last Accessed
#> dbl (4): File Size (MB), File Count, Total Views, Total Downloads
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

zoom_recorded_sessions_df
#> # A tibble: 3 × 15
#> # Groups:   Topic, ID, Start Time, File Size (MB) [3]
#>   Topic           ID    `Start Time` `File Size (MB)` `File Count` `Total Views`
#>   <chr>           <chr> <chr>                   <dbl>        <dbl>         <dbl>
#> 1 LTF 23.24 - Th… 960 … Jan 11, 202…            2317.           36             0
#> 2 LTF 23.24 - Th… 960 … Jan 18, 202…            1201.           24             0
#> 3 LTF 23.24 - Th… 996 … Jan 24, 202…             147.           11             0
#> # ℹ 9 more variables: `Total Downloads` <dbl>, `Last Accessed` <chr>,
#> #   dept <chr>, section <chr>, day <chr>, time <chr>, instructor <chr>,
#> #   match_start_time <dttm>, match_end_time <dttm>
```

    2. Run `load_transcript_files_list()` to get a data.table from a provided folder including transcript files of Zoom recordings.

``` r
transcript_files_df <- load_transcript_files_list(
  data_folder = data_folder_input,
  transcripts_folder = "transcripts",
  transcript_files_names_pattern = "GMT\\d{8}-\\d{6}_Recording",
  dt_extract_pattern = "(?<=GMT)\\d{8}",
  transcript_file_extension_pattern = ".transcript",
  closed_caption_file_extension_pattern = ".cc",
  recording_start_pattern = "(?<=GMT)\\d{8}-\\d{6}",
  recording_start_format = "%Y%m%d-%H%M%S",
  start_time_local_tzone = "America/Los_Angeles"
)

transcript_files_df
#> # A tibble: 1 × 6
#>   dt       recording_start     start_time_local    closed_caption_file          
#>   <chr>    <dttm>              <dttm>              <chr>                        
#> 1 20240124 2024-01-24 20:29:01 2024-01-24 12:29:01 GMT20240124-202901_Recording…
#> # ℹ 2 more variables: transcript_file <chr>, chat_file <chr>
```

    3. Load / Make Cancelled Classes CSV
        1. "cancelled_classes.csv" file:
            1. If you have an existing "cancelled_classes.csv", update it as necessary, or
            2. Run `make_blank_cancelled_classes_df()` and save it as a .csv file.
        2. Run `load_cancelled_classes()` to get a tibble from a provided csv file of cancelled class sessions for scheduled classes where a zoom recording is not expected. 

``` r
cancelled_classes_df <- load_cancelled_classes(
  data_folder = data_folder_input,
  cancelled_classes_file = "cancelled_classes.csv",
  cancelled_classes_col_types = "ccccccccnnnncTTcTTccci"
)
#> [1] "File does not exist: /Library/Frameworks/R.framework/Versions/4.1-arm64/Resources/library/zoomstudentengagement/extdata/cancelled_classes.csv"

cancelled_classes_df
#> # A tibble: 0 × 21
#> # ℹ 21 variables: dept <chr>, section <chr>, day <chr>, time <chr>,
#> #   instructor <chr>, Topic <chr>, ID <chr>, Start Time <chr>,
#> #   File Size (MB) <dbl>, File Count <dbl>, Total Views <dbl>,
#> #   Total Downloads <dbl>, Last Accessed <chr>, match_start_time <dttm>,
#> #   match_end_time <dttm>, dt <chr>, recording_start <dttm>,
#> #   start_time_local <dttm>, transcript_file <chr>, chat_file <chr>,
#> #   closed_caption_file <chr>
```

    4. Run `join_transcripts_list()` to get a tibble from the joining of the listing of session recordings loaded from the cloud recording csvs ('zoom_recorded_sessions_df'), the list of transcript files ('transcript_files_df'), and the list of cancelled classes ('cancelled_classes_df') into a single tibble.

``` r
transcripts_list_df <- join_transcripts_list(
  df_zoom_recorded_sessions = zoom_recorded_sessions_df,
  df_transcript_files = transcript_files_df,
  df_cancelled_classes = cancelled_classes_df
)

transcripts_list_df
#> # A tibble: 1 × 22
#>   Topic           ID    `Start Time` `File Size (MB)` `File Count` `Total Views`
#>   <chr>           <chr> <chr>                   <dbl>        <dbl>         <dbl>
#> 1 LTF 23.24 - Th… 996 … Jan 24, 202…             147.           11             0
#> # ℹ 16 more variables: `Total Downloads` <dbl>, `Last Accessed` <chr>,
#> #   dept <chr>, section <chr>, day <chr>, time <chr>, instructor <chr>,
#> #   match_start_time <dttm>, match_end_time <dttm>, dt <chr>,
#> #   recording_start <dttm>, start_time_local <dttm>, closed_caption_file <chr>,
#> #   transcript_file <chr>, chat_file <chr>, session_num <int>
```

## 5. Load Zoom Transcript files and Run Faculty Linguistic Inquiry and Word Count on those sessions.

    1. Run `fliwc_transcript_files()`.

``` r
fliwc_transcript_files(
  transcripts_list_df,
  data_folder = data_folder_input,
  transcripts_folder = "transcripts",
  names_to_exclude = NULL
)
#> Rows: 306 Columns: 1
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: "\t"
#> chr (1): WEBVTT
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 7 × 33
#>   Topic           ID    `Start Time` `File Size (MB)` `File Count` `Total Views`
#>   <chr>           <chr> <chr>                   <dbl>        <dbl>         <dbl>
#> 1 LTF 23.24 - Th… 996 … Jan 24, 202…             147.           11             0
#> 2 LTF 23.24 - Th… 996 … Jan 24, 202…             147.           11             0
#> 3 LTF 23.24 - Th… 996 … Jan 24, 202…             147.           11             0
#> 4 LTF 23.24 - Th… 996 … Jan 24, 202…             147.           11             0
#> 5 LTF 23.24 - Th… 996 … Jan 24, 202…             147.           11             0
#> 6 LTF 23.24 - Th… 996 … Jan 24, 202…             147.           11             0
#> 7 LTF 23.24 - Th… 996 … Jan 24, 202…             147.           11             0
#> # ℹ 27 more variables: `Total Downloads` <dbl>, `Last Accessed` <chr>,
#> #   dept <chr>, section <chr>, day <chr>, time <chr>, instructor <chr>,
#> #   match_start_time <dttm>, match_end_time <dttm>, dt <chr>,
#> #   recording_start <dttm>, start_time_local <dttm>, closed_caption_file <chr>,
#> #   transcript_file <chr>, chat_file <chr>, session_num <int>,
#> #   transcript_path <chr>, name <chr>, n <int>, duration <dbl>,
#> #   wordcount <dbl>, comments <list>, n_perc <dbl>, duration_perc <dbl>, …
```

# Steps to use zoomstudentengagement

1.  Define Inputs:
    - Current Term Inputs
      - `instructor_name_input`
      - etc
    - Other Constants
      - `names_exclude_input`
      - etc
2.  Load the zoomstudentengagement library
    - `r devtools::install_github("revgizmo/zoomstudentengagement")`
    - `r library(zoomstudentengagement)`
3.  Download the Zoom Recording Transcripts
    1.  Download Zoom csv file with list of recordings and transcripts
        1.  Go to <https://www.zoom.us/recording>
        2.  Export the Cloud Recordings
        3.  Copy the cloud recording csv (naming convention:
            ’zoomus_recordings\_\_\d{8}.csv’) to ‘data/transcripts/’
    2.  Download Transcripts
        1.  Go to <https://www.zoom.us/recording>
        2.  Click on each individual record to go to the page for that
            recording
        3.  Download the Audio Transcript and Chat File for each
            - Chat: ’GMT\d{8}-\d{6}\_Recording.cc.vtt’
            - Transcript: ’GMT\d{8}-\d{6}\_Recording.transcript.vtt’
        4.  Copy the Audio Transcript and Chat Files to
            ‘data/transcripts/’
4.  Load the list of Zoom Recordings Transcripts
    1.  Run `load_zoom_recorded_sessions_list()` to get a tibble from a
        provided csv file of Zoom recordings.

``` r

load_zoom_recorded_sessions_list(data_folder = system.file("extdata",  package="zoomstudentengagement")
)
#> Rows: 4 Columns: 9
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (4): Topic, ID, Start Time, Last Accessed
#> dbl (4): File Size (MB), File Count, Total Views, Total Downloads
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 3 × 15
#> # Groups:   Topic, ID, Start Time, File Size (MB) [3]
#>   Topic           ID    `Start Time` `File Size (MB)` `File Count` `Total Views`
#>   <chr>           <chr> <chr>                   <dbl>        <dbl>         <dbl>
#> 1 LTF 23.24 - Th… 960 … Jan 11, 202…            2317.           36             0
#> 2 LTF 23.24 - Th… 960 … Jan 18, 202…            1201.           24             0
#> 3 LTF 23.24 - Th… 996 … Jan 24, 202…             147.           11             0
#> # ℹ 9 more variables: `Total Downloads` <dbl>, `Last Accessed` <chr>,
#> #   dept <chr>, section <chr>, day <chr>, time <chr>, instructor <chr>,
#> #   match_start_time <dttm>, match_end_time <dttm>
```

    2. Run `load_transcript_files_list()` to get a data.table from a provided folder including transcript files of Zoom recordings.
    3. Update / Make Cancelled Classes CSV
        1. If you have an existing "cancelled_classes.csv", update it as necessary, or
        2. Run `make_blank_cancelled_classes_df()` and save it as a .csv file.
    4. Run `join_transcripts_list()` to get a tibble from the joining of the listing of session recordings loaded from the cloud recording csvs ('df_zoom_recorded_sessions'), the list of transcript files ('df_transcript_files'), and the list of cancelled classes ('df_cancelled_classes') into a single tibble.

5.  Load Zoom Transcript files and Run Faculty Linguistic Inquiry and
    Word Count on those sessions.
    1.  Run `fliwc_transcript_files()`.

# Old

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
