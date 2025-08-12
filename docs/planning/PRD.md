# Product Requirements Document (PRD)

## Product: zoomstudentengagement (R package)

### Document Purpose
Align stakeholders on vision, scope, requirements, decisions, and success criteria for near-term releases (pre-CRAN and immediate post-CRAN), with explicit attention to privacy, ethics, and CRAN compliance.

### Status and Version
- Status: Draft for review
- Source of truth for project status: `PROJECT.md`
- Related docs: `README.md`, `DOCUMENTATION.md`, `docs/development/CRAN_SUBMISSION.md`, `docs/development/CRAN_PREMORTEM_ACTION_PLAN.md`, `docs/development/ethical-issues-research/ETHICAL_ISSUES_ANALYSIS.md`, `docs/development/PRE_PR_VALIDATION.md`

---

## 1) Product Summary

### Problem
Instructors and educational researchers need reliable, privacy-preserving tools to analyze participation and engagement from Zoom class recordings. Existing workflows are ad hoc, error-prone, and risk exposing student PII.

### Solution
An R package that loads Zoom `.transcript.vtt` files, computes engagement metrics, supports roster matching, provides privacy-first defaults that mask PII, and offers plots and writers to communicate insights ethically.

### Target Users and Personas
- Instructor (primary): wants quick, ethical insights into participation equity across sessions.
- Department/Teaching Analyst (secondary): performs batch analyses across courses/terms.
- Educational Researcher (secondary): needs reproducible, privacy-conscious metrics and exports.

### Positioning
- Privacy-first and FERPA-aware by default
- Reproducible, scriptable workflows in R
- Focused scope: Zoom transcripts → engagement metrics → ethical visualization/reporting

### Non-Goals (for now)
- No ingestion of `.cc.vtt` (closed captions) or `.newChat.txt` (chat logs)
- No Zoom API integration
- No storage of raw PII beyond in-memory processing during an analysis session
- No telemetry/analytics collection; no network calls

---

## 2) Goals and Success Metrics

### Goals (near-term)
- CRAN-ready package that is safe by default (privacy masked) and well-documented.
- Reliable processing of `.transcript.vtt` at classroom scale (hundreds to thousands of files).
- Clear ethical guidance and compliance references (FERPA-oriented docs and guardrails).

### Success Metrics
- Quality and Compliance
  - R CMD check: 0 errors, 0 warnings, ≤ 2 notes (documented and acceptable)
  - Test coverage ≥ 90% across exported functions
  - Privacy features: privacy level = "mask" by default; verified in tests
- Performance and Reliability
  - Process 500 transcript files totaling ≥ 1M utterances within target resources
  - No segmentation faults across supported OS/R versions in CI matrix
- Adoption and Usability
  - Vignettes cover “Getting Started,” transcript processing, roster matching, plotting, and ethics
  - Clear end-to-end example with `summarize_transcript_metrics()` passes on fresh installs

---

## 3) Scope

### In-Scope (MVP + near-term)
- Input: Zoom `.transcript.vtt` files
- Core: load → process → metrics → plots/writers
- Data management: roster loading and name-cleaning; session mapping
- Privacy: `ensure_privacy()` and `set_privacy_defaults()` integrated across user-facing outputs
- Documentation: README, vignettes, FERPA/ethics guidance, CRAN submission docs

### Out-of-Scope (future candidates)
- Additional input types: `.cc.vtt`, chat logs (`.newChat.txt`)
- Zoom API integration; LMS integrations
- Shiny/GUI wrapper

---

## 4) User Experience

### Representative Flows
- Single-course analysis
  1) Load transcripts directory → 2) Load roster → 3) `summarize_transcript_metrics()` → 4) `plot_users_by_metric()` → 5) (optional) writers
- Multi-section/term analysis
  1) Create session mapping → 2) Batch process with `summarize_transcript_files()` → 3) Masked plots and section summaries

### UX Principles
- Privacy by default; explicit opt-out only with warnings
- Reproducible and scriptable: every flow is available via functions; examples runnable
- Clear failure modes: actionable error messages and validation helpers

---

## 5) Functional Requirements (FR)

For each FR, include acceptance criteria (AC).

### FR-1 Transcript Loading
- Description: Load Zoom `.transcript.vtt` files.
- Functions: `load_zoom_transcript()`, `load_and_process_zoom_transcript()`
- AC:
  - Given valid `.transcript.vtt`, returns structured tibble/data.table with utterances, timestamps, speaker
  - Invalid path/file returns informative error; corrupted files handled gracefully

### FR-2 Transcript Processing and Consolidation
- Description: Normalize fields, detect/handle duplicates, consolidate per-session data.
- Functions: `process_zoom_transcript()`, `consolidate_transcript()`, `detect_duplicate_transcripts()`
- AC:
  - Produces stable schemas for downstream metrics
  - Duplicate detection documented and configurable per `Issue #56`

### FR-3 Metrics Computation
- Description: Compute engagement metrics per speaker/student (e.g., talk time, utterance counts).
- Functions: `summarize_transcript_metrics()`, `make_transcripts_summary_df()`
- AC:
  - Metrics defined and documented; outputs deterministic for given inputs
  - Batch mode supported via `summarize_transcript_files()`

### FR-4 Roster Matching and Name Cleaning
- Description: Map transcript speakers to roster identities, with masking defaults.
- Functions: `load_roster()`, `make_clean_names_df()`, `make_names_to_clean_df()`
- AC:
  - Fuzzy/clean matching documented; mismatches surfaced in outputs for manual review

### FR-5 Session and Course Mapping (Advanced)
- Description: Map recordings to courses/sections/terms.
- Functions: `create_session_mapping()`, `load_session_mapping()`
- AC:
  - Supports multi-course scenarios; documented assumptions and examples provided

### FR-6 Visualization
- Description: Privacy-conscious plotting of engagement metrics.
- Functions: `plot_users_by_metric()`, `plot_users_masked_section_by_metric()`
- AC:
  - Plots mask PII by default; legends and labels align with privacy level

### FR-7 Writers and Reports
- Description: Export summaries and reports; ensure privacy enforcement at boundaries.
- Functions: `write_engagement_metrics()`, `write_transcripts_summary()`, `write_transcripts_session_summary()`
- AC:
  - Writers refuse to output unmasked PII unless user explicitly sets privacy level to "none" and receives a warning

### FR-8 Privacy Controls (Default Safe)
- Description: Global configuration and enforcement hooks.
- Functions: `set_privacy_defaults()`, `ensure_privacy()`, `.onLoad()`
- AC:
  - Package load sets `zoomstudentengagement.privacy_level = "mask"` unless user has set it
  - Tests cover masked default across summaries, plots, writers

### FR-9 Documentation and Vignettes
- Description: End-to-end vignettes and ethics/FERPA guidance.
- AC:
  - “Getting Started,” transcript processing, roster cleaning, plotting, session mapping
  - FERPA and ethical use vignette links from README and reference site

---

## 6) Non-Functional Requirements (NFR)

### NFR-1 Privacy, Ethics, and Compliance
- Default masked outputs; explicit opt-out with warnings
- FERPA guidance included; ethical risks documented with mitigations
- No telemetry, no network I/O; all processing local by default

### NFR-2 Performance and Stability
- Batch processing scales to ≥ 500 files and ≥ 1M utterances under typical laptop/server resources
- No segmentation faults across supported R versions and OSes; CI matrix validates

### NFR-3 Reliability and Quality
- Test coverage ≥ 90% for exported functions
- Deterministic outputs; clear error messages; reproducible examples

### NFR-4 CRAN Compliance
- R CMD check clean: 0 errors, 0 warnings, ≤ 2 acceptable notes
- `.Rbuildignore` excludes non-standard files; LICENSE and URLs valid

---

## 7) Data Model and Schemas (high level)
- Transcript: file metadata, session id, segment/utterance with start/end times, speaker label
- Roster: student identifiers (masked by default), section/course metadata
- Mapping: link transcripts to courses/sections/terms
- Metrics: per-speaker/per-session aggregates (counts, durations)
- Privacy fields masked by default: `preferred_name`, `name`, `first_last`, `name_raw`, `student_id`, `email`

---

## 8) API and Backward Compatibility
- Public surface: Exported functions in `R/` (see `NAMESPACE` and README key functions)
- Stability: Aim to avoid breaking changes; if necessary, provide migration notes
- Naming consistency: Track in issues ([#16], [#23]); avoid acronyms in user-facing APIs

---

## 9) Release Plan and Gating Criteria

### Pre-CRAN Release (0.1.x → 0.2.0)
- Gating criteria
  - All FR-1..FR-9 and NFR-1..NFR-4 acceptance criteria met
  - R CMD check clean; vignettes pass; README examples run
  - Real-world testing completed ([#129], [#83]); results documented
  - Performance validation completed ([#127], [#113])

### Post-CRAN Minor Releases
- Performance enhancements and large-dataset tuning
- Additional input support (e.g., `.cc.vtt`, chat logs) as separate, opt-in features with updated ethics guidance

---

## 10) Risks and Mitigations
- Privacy/Ethical Backlash: Default masked; strong guidance; examples promote equitable use (not surveillance)
- Performance/Segfaults: Reduce dplyr hotspots; base-R alternatives; CI on matrix; profiling and benchmarks
- Real-World Variability: Expand fixtures; document edge cases; encourage issue reporting with redacted snippets
- CRAN Policy Drift: Track with `CRAN_PREMORTEM_ACTION_PLAN.md`; pre-PR validation script

---

## 11) Decisions to Confirm (Checkpoint)
- Privacy-first defaults, with `ensure_privacy()` at user-facing boundaries: CONFIRM
- Scope limited to `.transcript.vtt` for initial CRAN release: CONFIRM
- Exclude `.cc.vtt` and chat logs from the CRAN-bound scope: CONFIRM
- No telemetry or network operations: CONFIRM
- Maintain clear ethics/FERPA guidance and warnings on opt-out: CONFIRM

Mark each as Accepted/Rejected during review and update scope accordingly.

---

## 12) Open Questions
- Should we add an optional Shiny companion app post-CRAN?
- Priority of `.cc.vtt` vs. chat logs for next input type?
- Institutional deployment guidance beyond vignette (e.g., templates, IT checklists)?
- Do we need stricter PII redaction utilities for free-text fields in future?

---

## 13) Traceability and References
- Issues: `#123`, `#125`–`#130`, `#83`, `#84`, `#90`, `#97`, `#110`, `#113`, `#115`, `#127`
- Key docs: `PROJECT.md`, `README.md`, `DOCUMENTATION.md`, FERPA/ethics analysis in `docs/development/ethical-issues-research/`

---

## 14) Appendix
- Glossary: PII, FERPA, CRAN, P95 (95th percentile processing time)
- Example entry points:
  - `summarize_transcript_metrics()` for core metrics
  - `plot_users_by_metric()` and `plot_users_masked_section_by_metric()` for visualization
  - Writers: `write_engagement_metrics()`, `write_transcripts_summary()`

Owner: Maintainers
Reviewers: Maintainer team and ethics/compliance reviewers
Last updated: YYYY-MM-DD (update on acceptance)