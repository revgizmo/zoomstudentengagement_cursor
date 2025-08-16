# R script to install packages
# This allows better Docker layer caching

packages <- c(
  'askpass', 'backports', 'base64enc', 'bit', 'bit64', 'brew', 'brio', 'bslib', 
  'cachem', 'callr', 'cli', 'clipr', 'codetools', 'collections', 'commonmark', 
  'covr', 'cpp11', 'crayon', 'credentials', 'curl', 'data.table', 'desc', 
  'devtools', 'diffobj', 'digest', 'downlit', 'dplyr', 'ellipsis', 'evaluate', 
  'fansi', 'farver', 'fastmap', 'fontawesome', 'fs', 'generics', 'gert', 
  'ggplot2', 'gh', 'gitcreds', 'glue', 'gtable', 'highr', 'hms', 'htmltools', 
  'htmlwidgets', 'httpuv', 'httr', 'httr2', 'ini', 'isoband', 'jquerylib', 
  'jsonlite', 'knitr', 'labeling', 'languageserver', 'later', 'lattice', 
  'lazyeval', 'lifecycle', 'lintr', 'lubridate', 'magrittr', 'MASS', 'Matrix', 
  'memoise', 'mgcv', 'mime', 'miniUI', 'nlme', 'openssl', 'pillar', 'pkgbuild', 
  'pkgconfig', 'pkgdown', 'pkgload', 'praise', 'prettyunits', 'processx', 
  'profvis', 'progress', 'promises', 'ps', 'purrr', 'R.cache', 'R.methodsS3', 
  'R.oo', 'R.utils', 'R6', 'ragg', 'rappdirs', 'rcmdcheck', 'RColorBrewer', 
  'Rcpp', 'readr', 'remotes', 'rex', 'rlang', 'rmarkdown', 'roxygen2', 
  'rprojroot', 'rstudioapi', 'rversions', 'sass', 'scales', 'sessioninfo', 
  'shiny', 'sourcetools', 'stringi', 'stringr', 'styler', 'sys', 'systemfonts', 
  'testthat', 'textshaping', 'tibble', 'tidyr', 'tidyselect', 'timechange', 
  'tinytex', 'tzdb', 'urlchecker', 'usethis', 'utf8', 'vctrs', 'viridisLite', 
  'vroom', 'waldo', 'whisker', 'withr', 'xfun', 'xml2', 'xmlparsedata', 
  'xopen', 'xtable', 'yaml', 'zip'
)

# Install packages with error handling
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, repos = 'https://cloud.r-project.org')
  }
}
