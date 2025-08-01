% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/join_transcripts_list.R
\name{join_transcripts_list}
\alias{join_transcripts_list}
\title{Join Transcripts Files Into a Single Tibble}
\usage{
join_transcripts_list(
  df_zoom_recorded_sessions,
  df_transcript_files,
  df_cancelled_classes
)
}
\arguments{
\item{df_zoom_recorded_sessions}{A tibble listing the session recordings
loaded from the cloud recording csvs.}

\item{df_transcript_files}{A data.frame listing the transcript files from the
zoom recordings loaded from the cloud recording csvs and transcripts.}

\item{df_cancelled_classes}{A tibble listing the cancelled class sessions for
scheduled classes where a zoom recording is not expected.}
}
\value{
A tibble listing the the class sessions with corresponding transcript
  files or placeholders for cancelled classes.
}
\description{
This function creates a tibble from the joining of the listing of session recordings loaded from the cloud recording csvs
(`df_zoom_recorded_sessions`), the list of transcript files
(`df_transcript_files`), and the list of cancelled classes
(`df_cancelled_classes`) into a single tibble
}
\examples{
\dontrun{
zoom_recorded_sessions_df <- load_zoom_recorded_sessions_list()
transcript_files_df <- load_transcript_files_list()
cancelled_classes_df <- load_cancelled_classes()

join_transcripts_list(
  df_zoom_recorded_sessions = zoom_recorded_sessions_df,
  df_transcript_files = transcript_files_df,
  df_cancelled_classes = cancelled_classes_df
)
}
}
