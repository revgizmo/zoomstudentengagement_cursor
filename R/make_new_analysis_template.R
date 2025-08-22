#' Make New Analysis Template
#'
#' This function copies a template R Markdown file (the `new_analysis_template.Rmd` file
#' from the `zoomstudentengagement` package) and saves it as a new .Rmd file that can be
#' used as a starting point for running analyses with the `zoomstudentengagement` library.
#'
#' @param new_template_file_name The file name of the created report template.
#' @param template_file The file name of the template file. This defaults to the
#'   `new_analysis_template.Rmd` file in the `zoomstudentengagement` package.
#' @param verbose Logical flag to enable diagnostic output. Defaults to FALSE.
#'
#' @return TRUE if the file was copied, FALSE otherwise.
#' @export
#'
#' @examples
#' \dontrun{
#' make_new_analysis_template(
#'   new_template_file_name = "my_analysis.Rmd"
#' )
#' }
make_new_analysis_template <-
  function(new_template_file_name = "new_analysis.Rmd",
           template_file = system.file("new_analysis_template.Rmd", package = "zoomstudentengagement"),
           verbose = FALSE) {
    # copy the files to the new folder
    success <- file.copy(template_file, new_template_file_name, overwrite = TRUE)
    if (success) {
      # Emit a friendly creation message when verbose is TRUE or in interactive sessions
      diag_message_if(verbose, paste(new_template_file_name, "created"))
      return(TRUE)
    } else {
      return(FALSE)
    }
  }
