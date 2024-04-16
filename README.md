
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
## basic example code
```

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
    2.  Run `load_transcript_files_list()` to get a data.table from a
        provided folder including transcript files of Zoom recordings.
    3.  Update / Make Cancelled Classes CSV
        1.  If you have an existing “cancelled_classes.csv”, update it
            as necessary, or
        2.  Run `make_blank_cancelled_classes_df()` and save it as a
            .csv file.
    4.  Run `join_transcripts_list()` to get a tibble from the joining
        of the listing of session recordings loaded from the cloud
        recording csvs (‘df_zoom_recorded_sessions’), the list of
        transcript files (‘df_transcript_files’), and the list of
        cancelled classes (‘df_cancelled_classes’) into a single tibble.
5.  Load Zoom Transcript files and Run Faculty Linguistic Inquiry and
    Word Count on those sessions.
    1.  Run `fliwc_transcript_files()`.
