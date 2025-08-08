# Privacy-First MVP Prompt (Issues #125, #126)

You are working on the R package `zoomstudentengagement` (local path: `/Users/piper/git/zoomstudentengagement`). Goal: implement a lean, privacy-first MVP that makes masked/FERPA-safe behavior the default without changing public APIs broadly.

## Context to include in your chat
- Link these files into the chat for full context:
  - `@full-context.md`
  - `@PROJECT.md`

## Constraints
- Keep scope tight; avoid refactors unrelated to privacy defaults.
- Do NOT add new parameters to all functions now. Centralize privacy and apply it at user-facing boundaries.
- Follow tidyverse style; use `<-` for assignment; snake_case for functions; add roxygen2 docs for exported functions; add testthat tests. All examples and vignettes must run with masked outputs by default.

## Deliverables
- Global default privacy
  - Add `.onLoad()` to set `options(zoomstudentengagement.privacy_level = "mask")` if not already set by the user.
  - Add `set_privacy_defaults(privacy_level = c("mask", "none"))` to set the global option.
- Central privacy gate
  - Add `ensure_privacy(x, privacy_level = getOption("zoomstudentengagement.privacy_level", "mask"), ...)` that returns a privacy-safe object.
  - Implement levels now: "mask" and "none". Keep structure ready for future levels, but do not implement them yet.
- Integrations (only at user-facing boundaries)
  - Writers: `R/write_transcripts_summary.R`, `R/write_engagement_metrics.R`
  - Summaries: `R/summarize_transcript_metrics.R`
  - Plots: `R/plot_users_by_metric.R`, `R/plot_users_masked_section_by_metric.R`
  - Existing helper: `R/mask_user_names_by_metric.R` (reuse internally; do not change its public API)
  - Rule: Before returning/plotting/writing user-identifiable data, pass through `ensure_privacy()`.
- Documentation
  - roxygen2 docs for `set_privacy_defaults()` and `ensure_privacy()` with examples that run in masked mode.
  - Add a short vignette: "Ethical & FERPA Guide" explaining defaults, opt-out, and risks of unmasking.
- Tests (testthat)
  - New tests asserting masked outputs by default for at least one writer, one summary, and one plot.
  - Test that `set_privacy_defaults("none")` un-masks (with a `warning()`), and `set_privacy_defaults("mask")` restores masked behavior.
- CI/dev workflow
  - Ensure `devtools::document()` updates docs.
  - Run `devtools::test()` and `devtools::check()`; examples and vignette must run masked.

## Implementation Notes
- Add `.onLoad()` in `R/zoomstudentengagement-package.R` (or create if missing) to set the default option.
- `ensure_privacy()` (mask level):
  - If `x` has user-identifying fields (e.g., person names), mask them (reuse `mask_user_names_by_metric()` or a small internal masker).
  - Be conservative: mask when in doubt.
  - Preserve type/class and columns (prefer tibble outputs).
- Warnings/messages:
  - When `privacy_level == "none"`, emit `warning("Privacy disabled; outputs may contain identifiable data.")`.
  - Keep messages minimal otherwise.
- Do not break public APIs. Only add internal calls to `ensure_privacy()` at the end of the high-surface functions before returning/writing/plotting.

## Acceptance Criteria
- Default behavior: masked outputs for summaries, writers, and plots.
- One-line opt-out: `set_privacy_defaults("none")` un-masks (with warning).
- All examples and vignettes run masked by default.
- `devtools::test()` passes; `devtools::check()` has 0 errors/0 warnings (notes minimal/acceptable).
- Roxygen docs exist and examples are runnable.
- New vignette added and builds.

## Files to Edit (Primary)
- `R/zoomstudentengagement-package.R` (.onLoad)
- `R/mask_user_names_by_metric.R` (internal reuse)
- `R/summarize_transcript_metrics.R`
- `R/write_transcripts_summary.R`
- `R/write_engagement_metrics.R`
- `R/plot_users_by_metric.R`
- `R/plot_users_masked_section_by_metric.R`
- Add new: `R/ensure_privacy.R`, `R/set_privacy_defaults.R`
- Tests in `tests/testthat/`
- Vignette in `vignettes/` (e.g., `ferpa-ethics.Rmd`)

## Suggested Sequence
1. Branch: `git checkout -b feature/privacy-defaults-mvp`
2. Add `.onLoad()`, `ensure_privacy()`, `set_privacy_defaults()`
3. Integrate `ensure_privacy()` in the 5 boundary functions above
4. Add tests and the ethics/FERPA vignette
5. Run:
   ```zsh
   Rscript -e "devtools::document(); devtools::test(); devtools::check()" | cat
   ```
6. Commit with conventional messages and open PR:
   ```zsh
   gh pr create --title "feat: privacy-first defaults MVP (Issues #125, #126)" --body 'Implements .onLoad(), ensure_privacy(), set_privacy_defaults(), and integrates masking at user-facing boundaries. Adds tests and ethics/FERPA vignette.'
   ```
7. Merge (use admin if branch protection requires):
   ```zsh
   gh pr merge --merge --admin
   ```

## Future Enhancement (Post-MVP)
- Optional per-function `privacy_level` arguments for deeper control. Defer until after MVP/CRAN.
- Rationale:
  - Keeps MVP lean and reduces churn to public APIs now.
  - We retain a single global default for consistency and safety.
  - Future work can thread function-level parameters once the MVP is shipped and stable.