---
plan: Issue 227 — Performance, Privacy, and Pre-PR Workflow Consolidation
milestone: v1.0 CRAN readiness
tracking_issue_title: Issue 227 Tracking
default_labels: [performance, privacy, refactor, docs, ci]
---

## Vectorize name matching to eliminate rowwise loops
Labels: performance, refactor

Why
- Rowwise loops in name matching cause O(n×m) behavior and slow large runs.

What
- In `safe_name_matching_workflow.R`:
  - Replace row loop in `apply_name_matching()` with vectorized mapping (`match()`/indexing) to fill `preferred_name`, `formal_name`, `participant_type`, `student_id`.
  - In `create_name_lookup()`, apply existing mappings and roster matches via vectorized joins/lookups rather than per-row loops.

Acceptance
- Same outputs on fixtures; ≥5x speedup on medium datasets; no added deps.

Validation
- Time complexity reduced; memory-neutral; API unchanged.

## Centralize privacy level constants and PII columns
Labels: privacy, refactor

Why
- Duplicated constants drift and create subtle bugs.

What
- Add internal helpers: `zse_valid_privacy_levels()` and `zse_pii_columns()`.
- Replace hard-coded vectors in: `safe_name_matching_workflow`, `process_transcript_with_privacy`, `detect_unmatched_names`, `anonymize_educational_data`, `validate_privacy_compliance`.

Acceptance
- Single source of truth; tests reference helpers; no behavior change.

Validation
- Zero runtime cost; reduced maintenance risk.

## Standardize error signaling and quiet default output
Labels: docs, refactor, ci

Why
- Mixed `stop()`/`abort_zse()` and noisy `message()` can fail CRAN/tests.

What
- Switch exported functions to use `abort_zse()` for typed errors.
- Introduce `zse_message(..., verbose_opt = "zoomstudentengagement.verbose")` that prints only when the option is TRUE and outside `TESTTHAT`.
- Gate existing `message()/cat()/print()` through `zse_message`.

Acceptance
- Tests/CI logs are quiet by default; error classes stable for assertions.

Validation
- Negligible perf impact; better CRAN hygiene.

## Deduplicate context/update scripts and gate PROJECT.md prompts
Labels: scripts, docs, ci

Why
- `get-context.sh` and `save-context.sh` duplicate big “PROJECT.md UPDATE REQUIRED” blocks; noisy by default.

What
- Extract the prompt logic into `scripts/project-md-update.sh`.
- Add `--project-md-reminder` flag to show the prompt; default runs stay quiet.
- Keep existing flags `--check-project-md` and `--fix-project-md` in `save-context.sh`.

Acceptance
- Both scripts work; prompt appears only with the new flag; no duped code.

Validation
- Smaller maintenance surface; predictable pre-PR flow.

## Vectorized/data.table summarization in transcript metrics
Labels: performance, refactor

Why
- `summarize_transcript_metrics()` does per-group loops; slow on large inputs.

What
- Replace per-group loop with vectorized aggregation (`split/lapply` or `data.table` by=) for `n`, `duration`, `wordcount`, percentages, and `wpm`.
- Preserve output schema, ordering, and privacy application.

Acceptance
- ≥3x speedup on medium inputs; identical results on tests; no segfault path.

Validation
- Uses existing Imports; avoids problematic dplyr paths.

## Unify hashing/anonymization implementation
Labels: privacy, refactor

Why
- Hashing logic duplicated; risk of inconsistent results.

What
- Make `anonymize_educational_data(method = "hash")` delegate to `hash_name_consistently()`.
- Parameterize hash length (default 8 chars) for consistency.

Acceptance
- Same hashes as before for default; tests pass; fewer code paths.

Validation
- No perf regression; simpler maintenance.

## Trim the public API surface (soft deprecations)
Labels: api, docs

Why
- Large surface increases maintenance/testing burden and user confusion.

What
- Mark for deprecation (docs only for now): `match_names_with_privacy`, possibly `process_transcript_with_privacy` if not a primary entry point.
- Keep exports for this release; add `@seealso` to preferred entry points.

Acceptance
- Reference topics and README clarify the primary API; no breakage.

Validation
- Zero runtime cost; clearer UX.

## Robust schema type checks via inherits
Labels: schema, refactor

Why
- Exact class equality fails for subclasses (e.g., `hms`).

What
- Change `validate_schema()` to use `inherits(df[[nm]], exp_type)`.

Acceptance
- No false negatives on typed columns; tests updated accordingly.

Validation
- No measurable perf impact; safer checks.

## Fast-path options in pre-PR validation
Labels: ci, docs, scripts

Why
- Full `devtools::check()` and vignette builds slow local validations.

What
- Add `--fast` (default) and `--full` flags to `scripts/pre-pr-validation.R`.
- In fast mode: skip vignettes and run `check(vignettes = FALSE, manual = FALSE)`; full mode keeps current behavior.

Acceptance
- Fast runs complete in minutes; full runs still available.

Validation
- Improved dev UX; no package behavior change.

## Reduce test output pollution at the source
Labels: ci, test, refactor

Why
- Noisy messages in package code trigger CI/test warnings.

What
- Wrap diagnostics identified by the validation script (section 7.5) in `zse_message()` or remove if redundant.

Acceptance
- Validation script reports zero pollution; test logs are clean.

Validation
- No functional changes; cleaner CI.

## Minor speedups and safety tweaks
Labels: performance, refactor

Why
- Small hotspots add up on large analyses.

What
- Prefer `vapply()` over `sapply()` in hashing loops.
- Precompute normalized names once where repeatedly used.
- Add early returns/guards where cheap validations apply.

Acceptance
- Micro-benchmarks show small wins; no behavior changes.

Validation
- Safe, incremental improvements.