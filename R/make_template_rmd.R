#' Write Section Names Lookup
#'
#' This function a template file (generally the `Readme.Rmd` file in the
#' `zoomstudentengagment` documentation) and saves it as a .Rmd file that can be
#' used to run analyses with the `zoomstudentengagment` library.
#'
#' @param new_template_file_name The file name of the created report template.
#' @param template_file The file name of the template file. This defaults to the
#'   `Readme.Rmd` file in the `zoomstudentengagment` documentation.
#'
#' @return Nothing. (printed message and saved file as side effects.)
#' @export
#'
#' @examples
#' make_template_rmd(new_template_file_name = 'README.Rmd',
#' template_file = "README.Rmd")




make_template_rmd <-
  function(new_template_file_name = 'README.Rmd',
           template_file = paste0(system.file("",  package="zoomstudentengagement"), 'README.Rmd')
           ) {
    template_file <- new_template_file_name <- NULL


    # copy the files to the new folder
    file.copy(template_file, new_template_file_name)
    print(paste(new_template_file_name, 'created'))
  }

