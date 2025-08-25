## Issue #310 Implementation Guide — Coverage Uplift to ≥90%

### Branch
feature/issue-310-coverage

### Steps
1. Create branch:
   ```bash
   git checkout -b feature/issue-310-coverage
   git push -u origin feature/issue-310-coverage
   ```
2. Baseline coverage:
   ```r
   covr::package_coverage()
   covr::report()
   ```
3. Add tests for verbose/interactive paths:
   - load_zoom_recorded_sessions_list(verbose = TRUE): expect messages captured
   - create_session_mapping: non-interactive fallback diagnostic when verbose (no prompts in CI)
4. Add any minimal additional edge/error-path tests needed to cross ≥90%.
5. Validate locally:
   ```r
   devtools::test()
   Rscript scripts/pre-pr-validation.R
   devtools::check()
   covr::package_coverage()
   ```
6. Commit and push with conventional message referencing #310.
7. Open PR to main; include “Closes #310”.

### Acceptance criteria
- Package coverage ≥90%
- Tests are quiet by default; diagnostics gated
- Validator fully green

### Notes
- Prefer structural assertions over brittle message matching.
- Do not alter runtime behavior; tests only.
