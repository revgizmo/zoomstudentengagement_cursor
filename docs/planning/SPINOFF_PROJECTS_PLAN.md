### Spin-off Projects Plan and Roadmap

Purpose: Memorialize reusable assets identified in this repository and outline a prioritized roadmap to spin them off into standalone, reusable projects.

Scope: zoomstudentengagement (R package) – development tooling, testing infrastructure, privacy/compliance utilities, CI templates, and modular data-processing components.

---

## Prioritized spin-offs (high-level)

1) Real-World Testing Kit for Confidential Data (R-focused, generic)
- What: Standalone framework to validate real data safely outside IDE/LLM, with setup, data checks, automated and manual runners, and reporting.
- Source in repo: `scripts/real_world_testing/*` (setup.sh, validate_data.* , run_tests.sh, run_real_world_tests.R, whole_game_real_world.Rmd, README.md)
- Deliverables: Template repo + docs; package-agnostic by swapping the tested functions.
- Impact/Effort: Very high impact, low effort (nearly turnkey).

2) R Pre-PR “Bugbot-style” Validator (CLI package)
- What: One-command pre-PR checks (style, lintr, roxygen, vignettes, tests, rcmdcheck, output pollution scan).
- Source: `scripts/pre-pr-validation.R`
- Deliverables: Small R package/CLI (e.g., preprr::validate()) + optional GH Action.
- Impact/Effort: High impact, moderate effort.

3) Cursor/AI Context Automation Kit
- What: Generate current project context for AI chats and persist summary artifacts; optional PROJECT.md updater.
- Source: `scripts/save-context.sh`, `scripts/context-for-new-chat.sh`, `scripts/context-for-new-chat.R`, `docs/development/CONTEXT_PROVISION.md`, `docs/development/CURSOR_INTEGRATION.md`
- Deliverables: Language-agnostic shell + R scripts; templated docs; GH CLI integration.
- Impact/Effort: High impact, low effort.

4) Privacy-First Analytics Core (R)
- What: Drop-in privacy defaults, masking, and options handling for analytics packages; “secure by default.”
- Source: `R/ensure_privacy.R`, `R/set_privacy_defaults.R`
- Deliverables: Lightweight R package (e.g., privacyr) with docs and examples.
- Impact/Effort: High impact, moderate effort.

5) FERPA Compliance Toolkit (R + docs)
- What: Validate, anonymize, and report on FERPA compliance in datasets; guidance for institutions.
- Source: `R/ferpa_compliance.R`, vignette `vignettes/ferpa-ethics.Rmd`
- Deliverables: R package + institutional guide; sample policies/checklists.
- Impact/Effort: High impact, moderate effort.

6) GitHub Actions Templates for R Packages
- What: Opinionated CI set: R CMD check and pkgdown-to-Pages.
- Source: `.github/workflows/R-CMD-check.yaml`, `.github/workflows/pages.yml`
- Deliverables: Template workflows with README snippets.
- Impact/Effort: Medium-high impact, low effort.

7) Zoom VTT Transcript Parsing Library (R)
- What: Focused parser/loader for `.transcript.vtt` and variants; clean I/O API.
- Source: `R/load_zoom_transcript.R`, `R/process_zoom_transcript.R`, `inst/extdata/*`, `vignettes/transcript-processing.Rmd`
- Deliverables: Minimal R package + CLI entrypoint.
- Impact/Effort: Medium-high impact, moderate effort.

8) Time-Window Consolidation Utilities (R)
- What: Generic utilities to consolidate adjacent events by group/time windows (beyond transcripts).
- Source: `R/consolidate_transcript.R` and related summarizers
- Deliverables: Small R package with clear generics and tests.
- Impact/Effort: Medium impact, low–moderate effort.

9) Shell Script QA Harness
- What: Quick checks for shell quality, numeric comparisons, syntax, error handling.
- Source: `scripts/test-shell-scripts.sh`
- Deliverables: Standalone script + docs; optional pre-commit integration.
- Impact/Effort: Medium impact, low effort.

10) R Segfault/Memcheck Harness
- What: Valgrind and lldb/ASan wrappers tailored to R workflows, with minimal test scaffolds.
- Source: `scripts/valgrind.sh`, `scripts/debug_segfault.sh`
- Deliverables: Cross-platform troubleshooting kit + guide.
- Impact/Effort: Medium impact, low effort.

11) GH CLI Wrappers for Issues/PRs (safe escaping)
- What: Robust wrappers to create issues/PRs with file bodies, labels, branch checks.
- Source: `scripts/create-issue.sh`, `scripts/create-pr.sh`
- Deliverables: Small repo of reusable gh helpers.
- Impact/Effort: Medium impact, low effort.

12) CRAN Readiness Kit
- What: A curated set of ignore files, lintr configs, checklists, and “last-mile” guidance.
- Source: `.Rbuildignore`, `.lintr`, `CRAN_CHECKLIST.md`, `docs/development/CRAN_SUBMISSION.md`
- Deliverables: Template repo or `usethis`-style helpers.
- Impact/Effort: Medium impact, low effort.

13) Documentation Playbook for AI-Assisted Dev
- What: Production-ready guidelines and checklists for AI-in-the-loop R development.
- Source: `docs/development/AI_ASSISTED_DEVELOPMENT.md`, `CURSOR_INTEGRATION.md`, `CONTEXT_PROVISION.md`, `PROJECT.md`
- Deliverables: Public guide + samples; complements Context Kit.
- Impact/Effort: Medium impact, low effort.

14) Name Matching/Cleaning Helpers (R)
- What: Reusable helpers for name normalization and join prep across rosters/datasets.
- Source: `R/make_clean_names_df.R`, `R/make_roster_small.R`, `R/make_sections_df.R`
- Deliverables: Small R package with examples; optional fuzzy hooks.
- Impact/Effort: Medium impact, moderate effort.

15) Batch Transcript/Metrics Pipeline (R)
- What: Batch processing framework for files→metrics→summaries→writers; pluggable metrics.
- Source: `R/summarize_transcript_files.R`, `R/summarize_transcript_metrics.R`, writers in `R/write_*`
- Deliverables: Skeleton pipeline package with adapters.
- Impact/Effort: Medium impact, moderate effort.

---

## Recommended issue strategy (now vs later)

- Now: Create a small set of grouped “epic” issues with checklists (to avoid spamming 15 issues). Also create one top-level tracker.
- Later: As each group starts, split out per-project issues for execution, linking back to the group issue and epic.

Initial set to open:
- Epic tracker: “Spin-off projects: roadmap and tracking”
- Group 1 – Testing & QA Kits: Items 1, 9, 10
- Group 2 – Dev Workflow & Context Automation: Items 2, 3, 11, 12, 13
- Group 3 – Privacy & Compliance Kits: Items 4, 5
- Group 4 – Data Processing Modules: Items 7, 8, 14, 15
- Group 5 – CI Templates for R: Item 6

Labels (use existing labels only, per `docs/development/docs/development/docs/development/ISSUE_MANAGEMENT_QUICK_REFERENCE.md`):
- Priority: `priority:high` for Groups 1–2; `priority:medium` for others
- Area: `area:testing`, `area:development`, `area:documentation`, `area:core` as appropriate
- Type: `enhancement`

---

## Execution guidance

- Favor small, focused repos with MIT license.
- Provide minimal tests, README, and a short vignette/example per R package.
- Keep sensitive-data testing guidance front-and-center (reuse security language from `scripts/real_world_testing/README.md`).

---

## Next steps

1) Open the 6 issues (epic + 5 groups) using `scripts/create-spinoff-issues.sh` (see docs in `docs/planning/spinoff_issues/README.md`).
2) Start with Group 1 (Real-World Testing Kit) and Group 2 (Dev Workflow/Context), which are the quickest wins.
3) As work begins, split out per-project child issues tracking deliverables, publishing, and docs.
