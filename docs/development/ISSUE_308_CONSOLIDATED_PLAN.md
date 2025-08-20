## Issue #308: Gate diagnostic output in runtime code — Consolidated Plan

### Summary
Gate diagnostic output in runtime code to ensure tests and normal usage are quiet by default, while preserving opt-in verbosity and interactive flows.

### Scope (files)
- `R/create_session_mapping.R`
- `R/load_zoom_recorded_sessions_list.R`
- `R/make_new_analysis_template.R`
- `R/utils_diagnostics.R`

### Goals and success criteria
- Add `verbose = FALSE` parameter where needed
- Wrap `print()`, `message()`, `cat()` with `if (isTRUE(verbose) && Sys.getenv("TESTTHAT") != "true")`
- Guard interactive prompts with `interactive()` and provide non-interactive fallback
- Pre-PR validator reports: "All diagnostic output properly conditional"

### Non-goals
- Behavior changes unrelated to logging/verbosity
- API changes beyond adding optional `verbose` (default FALSE)

### Risks and mitigations
- Risk: Silencing useful diagnostics. Mitigation: keep `verbose = TRUE` pathways and clear CONTRIBUTING.md policy.
- Risk: Tests relying on messages. Mitigation: adjust tests to set `verbose = TRUE` locally when asserting messages.

### Implementation outline
1. Add `verbose = FALSE` to affected functions (backward compatible)
2. Replace bare diagnostics with guarded blocks
3. Wrap any prompts with `interactive()`; add fallback branches
4. Update validator (if needed) to re-scan; ensure clean report
5. Add minimal tests only if required for coverage (tracked under #310)

### Verification
- Run `Rscript scripts/pre-pr-validation.R` → Test Output Validation clean
- `devtools::test()` has no unexpected console output

### Links
- Issue: #308
- Coverage uplift: #310
- Policy: CONTRIBUTING.md Diagnostic Output Policy


