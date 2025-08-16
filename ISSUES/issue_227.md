---
plan: Issue 227 — Implementation Breakdown
milestone: v1.0 CRAN readiness
tracking_issue_title: Issue 227 Tracking
default_labels: [performance, privacy, refactor, docs, ci]
---

## Vectorize name matching to eliminate rowwise loops
Labels: performance, refactor

Why
- Rowwise loops in name matching cause O(n×m) behavior and slow large runs.

What
- Vectorize `apply_name_matching()` and `create_name_lookup()` in `R/safe_name_matching_workflow.R` using `match()`/indexed assignment (no extra deps).

Acceptance
- Same outputs on fixtures; ≥5x speedup on medium datasets; no added deps.

## Centralize privacy level constants and PII columns
Labels: privacy, refactor

Why
- Duplicated constants drift across files.

What
- Add `zse_valid_privacy_levels()` and `zse_pii_columns()` internal helpers; replace hard-coded vectors across privacy-related functions.

Acceptance
- Single source of truth; no behavior change.

## Standardize error signaling and quiet default output
Labels: docs, refactor, ci

Why
- Inconsistent errors and noisy logs can fail CRAN/tests.

What
- Use `abort_zse()` across exported functions; introduce `zse_message()` gated by option `zoomstudentengagement.verbose` and test env.

Acceptance
- Quiet default logs; stable error classes; tests pass.

## Deduplicate context/update scripts and gate PROJECT.md prompts
Labels: scripts, docs, ci

Why
- Duplication in `get-context.sh` and `save-context.sh`; noisy by default.

What
- Create `scripts/project-md-update.sh`; move prompt block; expose via `--project-md-reminder` flag.

Acceptance
- Prompt appears only when requested; scripts remain functional.

## Vectorized/data.table summarization in transcript metrics
Labels: performance, refactor

Why
- Per-group loops in `summarize_transcript_metrics()` slow on large inputs.

What
- Replace loop with vectorized or data.table aggregation preserving schema and privacy application.

Acceptance
- ≥3x speedup; identical outputs; tests pass.

## Unify hashing/anonymization implementation
Labels: privacy, refactor

Why
- Duplicate hashing logic risks inconsistency.

What
- Delegate `anonymize_educational_data(method = "hash")` to `hash_name_consistently()`; parameterize hash length (default 8).

Acceptance
- Same default hashes; reduced code duplication.

## Trim the public API surface (soft deprecations)
Labels: api, docs

Why
- Large public surface increases maintenance burden.

What
- Doc-only deprecations for `match_names_with_privacy` and possibly `process_transcript_with_privacy`; prefer `safe_name_matching_workflow()`.

Acceptance
- Docs/README guide users; no breaking change.

## Robust schema type checks via inherits
Labels: schema, refactor

Why
- Exact class equality fails on subclasses.

What
- Use `inherits(df[[nm]], exp_type)` in `validate_schema()`; update tests.

Acceptance
- No false negatives; checks remain strict.

## Fast-path options in pre-PR validation
Labels: ci, scripts

Why
- Speed up local dev loops.

What
- Add `--fast` (default) and `--full` flags in `scripts/pre-pr-validation.R`; skip vignettes in fast mode.

Acceptance
- Fast completes quickly; full remains available.

## Reduce test output pollution at the source
Labels: ci, test, refactor

Why
- Noisy messages clutter CI and mask failures.

What
- Wrap diagnostics in `zse_message()` or remove redundant prints; confirm via validation script’s section 7.5.

Acceptance
- No pollution reported; logs clean.

## Minor speedups and safety tweaks
Labels: performance, refactor

Why
- Micro-optimizations compound on large data.

What
- Switch `sapply()`→`vapply()` where applicable; precompute normalized names where reused; add early guards.

Acceptance
- Micro-benchmark wins; no behavior regressions.