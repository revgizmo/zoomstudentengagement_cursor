# Issue #310: Coverage Uplift to ≥90% — Consolidated Plan

## Summary
Raise package test coverage from ~87.9% to ≥90% while preserving privacy-first defaults and quiet test output. Focus on adding targeted tests for under-covered paths introduced or touched during #308 (diagnostic gating) and other high-value areas.

## Current status
- Tests: All green (local validator)
- Coverage: ~87.9% (target ≥90%)
- R CMD check: Clean (0 errors, 0 warnings, minor notes)

## Goals and success criteria
- Package-level coverage ≥90% (covr::package_coverage())
- No new test output pollution; tests remain quiet by default
- Pre-PR validator fully green
- No behavior changes beyond test additions

## Scope
- Add tests for previously untested/under-tested logical branches, including:
  - Verbose/diagnostic branches (quiet by default; opt-in via option/param)
  - Non-interactive fallbacks for interactive prompts
  - Edge/error paths in ingestion and summaries (as needed)
- Do not modify runtime package behavior; tests only (and minimal helper scaffolding as needed)

## Out-of-scope
- Refactors unrelated to testing
- Public API changes beyond optional verbose parameters already added in #308

## Plan of work
1. Baseline coverage
   - Run: covr::package_coverage() and covr::report()
   - Identify top files/functions by missed lines
2. Targeted tests (round 1)
   - Add tests for verbose branches in:
     - load_zoom_recorded_sessions_list(verbose = TRUE)
     - create_session_mapping (non-interactive fallback diagnostic when verbose)
   - Ensure captured output uses expect_message()/expect_output as appropriate
3. Targeted tests (round 2)
   - Add missing edge-path tests in ingestion/summaries only if needed to cross ≥90%
4. Validate
   - devtools::test(); scripts/pre-pr-validation.R; devtools::check()
   - Confirm coverage ≥90%

## Risks & mitigations
- Risk: Over-coupling to messages. Mitigation: Prefer structural assertions; reserve message checks for minimal surface.
- Risk: Flaky tests in CI. Mitigation: Avoid timing/dependent I/O; keep deterministic fixtures.

## Deliverables
- New/updated tests under tests/testthat/* (no behavior changes)
- Coverage ≥90% verified locally

## Links
- Related: #303, #295, #229, #228
- Policy: CONTRIBUTING.md (Diagnostic Output Policy)
