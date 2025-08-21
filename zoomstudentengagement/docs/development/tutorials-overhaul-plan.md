## Tutorials Overhaul: Privacy-First, Progressive Learning, Best-Practice Pattern

### Objectives and success criteria
- Align tutorials with privacy-first, equity-focused goals; runnable with package data via `system.file()`
- Provide progressive learning paths for instructors, researchers, and analysts
- Standardize vignette structure, runtime (<30s each), and CRAN-safe chunk options
- Add troubleshooting and ethical guidance to every tutorial
- Automate validation via pre-PR scripts and R CMD check; 0 errors/warnings target

### Milestones
- M1 (P0): Foundation and standards (templates, pkgdown IA, validation automation)
- M2 (P0): Core tutorials: Getting Started, Privacy-in-Practice, Transcript Workflow
- M3 (P1): Name Matching Basics + Troubleshooting, Multi-Session, Equity Visualization
- M4 (P2): Batch & Automation, Researcher Reproducibility & Ethics, Instructor One-Pager
- M5 (P0–P2): Best-Practice Tutorial Pattern doc + retrospective learnings

### Epic scope
Deliver a cohesive tutorial suite with standardized structure, runnable examples, and scenario-driven guidance.

Success metrics:
- All vignettes run in <30s on package data
- Every vignette includes privacy setup, troubleshooting, and “What’s next”
- pkgdown organizes tutorials by Start here, Privacy, Workflows, Troubleshooting
- Pre-PR validation runs clean (R CMD check 0E/0W)

### Issue backlog (implementation plan)
1) Standardize vignette template and chunk options [P0]
   - Add `vignettes/_template.Rmd` with standardized front matter, chunk options, and privacy defaults
   - Include Troubleshooting and What’s next sections
   - Document usage in `docs/development/tutorial-pattern.md`
   - Acceptance: Template knits quickly; uses `system.file()`; privacy defaults included

2) pkgdown information architecture for tutorials [P0]
   - Update `_pkgdown.yml` to group articles: Start here, Privacy, Workflows, Troubleshooting, Advanced
   - Ensure vignettes include index entries and cross-links
   - Acceptance: pkgdown builds; grouped navigation visible; next-step links present

3) Pre-PR validation integration for vignettes [P0]
   - Build vignettes and run `devtools::check_examples()` in pre-PR scripts
   - Capture per-vignette runtime; flag >30s chunks
   - Use `scripts/pre-pr-validation-background-agent.R` and `scripts/save-context.sh`
   - Acceptance: CI/pre-PR outputs timing and flags; examples pass locally

4) Getting Started vignette revamp [P0]
   - 10-minute onboarding: load → process → summarize → masked plot → next steps
   - Use `system.file()` roster and a single transcript
   - Show `set_privacy_defaults(mask_names=TRUE, retain_pii=FALSE)` by default
   - Acceptance: Knits <30s; masked plot; links to Privacy-in-Practice and Workflow

5) Privacy & FERPA in Practice vignette [P0]
   - Demonstrate `ensure_privacy()`, `validate_ferpa_compliance()`, `generate_ferpa_report()`
   - Decision checklist; safe tempdir write patterns
   - Acceptance: Masked outputs; clear remediation for violations

6) Transcript Processing Workflow vignette [P0]
   - End-to-end from VTT to masked metrics and summaries using `process_transcript_with_privacy()`
   - Include inputs/outputs diagram and minimal plots
   - Acceptance: Knits <30s; masked outputs; clear workflow

7) Name Matching Basics + Troubleshooting [P1]
   - Repro: `extract_*_names()`, `normalize_name_for_matching()`, `find_roster_match()`, `apply_name_matching()`
   - Symptom → diagnosis → fix table; safe remediation CSV with `conditionally_write_lookup()` to `tempdir()`
   - Acceptance: Actionable recipes; masked outputs

8) Multi-Session Course Analysis [P1]
   - Tiny session mapping via `system.file()`
   - Show `create_session_mapping()`, `analyze_multi_session_attendance()`
   - Acceptance: Knits <30s; masked outputs; links to visualization guide

9) Participation Equity Visualization Guide [P1]
   - Demonstrate `plot_users()`, `plot_users_by_metric()`; glossary for metrics
   - Acceptance: ≥3 charts; masked labels; short glossary

10) Batch Processing & Automation [P2]
   - Patterns for lists, progress, and safe outputs; guard long-running chunks
   - Acceptance: Clear guardrails; reproducibility notes; privacy preserved

11) Researcher Reproducibility & Ethics [P2]
   - Reproducible pipelines, versioning, sensitivity analyses, ethical reporting
   - Acceptance: No PII; links to Privacy-in-Practice and FERPA

12) Instructor Quickstart One-Pager [P2]
   - 4–6 commands with defaults; strong cross-links
   - Acceptance: <2 minutes to success; masked output

13) Best-Practice Tutorial Pattern guide [P0–P2]
   - Create `docs/development/tutorial-pattern.md`: structure, chunk options, runtime budgets, privacy-by-default, troubleshooting, pkgdown IA
   - Include Rmd skeleton and author checklist
   - Acceptance: Guide references real examples; copyable patterns

14) Cross-linking and discoverability sweep [P1]
   - Add What’s next links and `@seealso` references across vignettes
   - Acceptance: Each vignette links to next-step tutorials and key functions

15) Runtime and CRAN-safety sweep [P1]
   - Confirm `system.file()` everywhere; measure time; guard long chunks with `\donttest{}`
   - Acceptance: `devtools::check_examples()` and `devtools::check()` clean; timings captured

### User journey maps
Instructors: Getting Started → Instructor Quickstart → Privacy-in-Practice → Transcript Workflow → Equity Visualization → Troubleshooting

Researchers: Getting Started → Transcript Workflow → Name Matching + Troubleshooting → Multi-Session → Privacy-in-Practice → Reproducibility & Ethics

Analysts: Transcript Workflow → Multi-Session → Visualization → Privacy-in-Practice → Batch & Automation

### Best-practice tutorial skeleton (for template)
```markdown
---
title: "TITLE"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{TITLE}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(
  collapse = TRUE, comment = "#>", message = FALSE, warning = FALSE,
  fig.width = 7, fig.height = 4.5
)
```

- Audience: …
- Prerequisites: …
- Learning goals: …

```{r libraries}
library(zoomstudentengagement)
library(dplyr)
```

```{r data}
roster_path <- system.file("extdata", "roster.csv", package = "zoomstudentengagement")
transcript_path <- system.file(
  "extdata/transcripts",
  "GMT20240124-202901_Recording.transcript.vtt",
  package = "zoomstudentengagement"
)
privacy <- set_privacy_defaults(mask_names = TRUE, retain_pii = FALSE)
```

```{r workflow}
roster <- load_roster(roster_path)
transcript <- load_zoom_transcript(transcript_path)
processed <- process_transcript_with_privacy(transcript, roster, privacy = privacy)
metrics <- summarize_transcript_metrics(processed)
plot_users_by_metric(metrics, metric = "spokenSeconds", top_n = 15)
```

### Troubleshooting
- Names not matching → normalize and re-run matching (consider diacritics)
- FERPA validation failed → run `validate_ferpa_compliance()`; adjust defaults
- Unmasked labels → set `mask_names=TRUE` or use `mask_user_names_by_metric()`

### What’s next
- Link to 2–3 related vignettes in the journey
```

### PR and validation guidance
- Branch per issue; push before PR; link PR to issue
- Pre-PR checks: styler, lintr, roxygen, build vignettes, check examples
- Run `scripts/pre-pr-validation-background-agent.R` and `scripts/save-context.sh`
- CRAN rules: run with `system.file()` data; guard long chunks with `\donttest{}`; target 0E/0W

### Retrospective and learnings
- Capture runtime budgets, pain points, and user feedback
- Update `tutorial-pattern.md` with improvements and guidance for reuse by other packages

