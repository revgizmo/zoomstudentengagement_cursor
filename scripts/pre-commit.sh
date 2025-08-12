#!/usr/bin/env bash
set -euo pipefail

# Find staged R files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(R|r|Rmd)$' || true)

if [ -z "$STAGED_FILES" ]; then
  echo "No staged R files to lint/style."
  exit 0
fi

echo "Styling staged R files with styler..."
Rscript -e "styler::style_files(command = 'R CMD', filetype = c('R', 'Rmd'), strict = FALSE, transformers = styler::tidyverse_style(), filefilter = function(paths) paths[paths %in% strsplit(Sys.getenv('STAGED'), '\\n')[[1]]])" \
  --vanilla --args

export STAGED="$STAGED_FILES"

echo "Running lintr on staged files..."
Rscript -e "lintr::lint(File = strsplit(Sys.getenv('STAGED'), '\\n')[[1]], error_on_lint = TRUE)"

echo "Done."