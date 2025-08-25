## Issue #308 Implementation Guide — Gate diagnostic output in runtime code

### Branch
feature/issue-308-implementation

### Steps
1. Create branch:
   ```bash
   git checkout -b feature/issue-308-implementation
   git push -u origin feature/issue-308-implementation
   ```
2. Edit files to add `verbose = FALSE` and guards:
   - `R/create_session_mapping.R`
   - `R/load_zoom_recorded_sessions_list.R`
   - `R/make_new_analysis_template.R`
   - `R/utils_diagnostics.R`
   Examples:
   ```r
   if (isTRUE(verbose) && Sys.getenv("TESTTHAT") != "true") {
     message("...")
   }
   if (interactive()) { ... } else { ... }
   ```
3. Run validation:
   ```bash
   Rscript scripts/pre-pr-validation.R
   ```
4. Commit and push changes with conventional commits referencing #308.
5. Open PR to `main` (or `develop` per workflow), link "Closes #308".

### Acceptance criteria
- Pre-PR validator reports no ungated diagnostic output
- No interactive prompts in non-interactive mode

### Notes
- Coverage uplift work will proceed in #310.


