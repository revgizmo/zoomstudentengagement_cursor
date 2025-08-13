---
plan: Documentation overhaul (v0.2)
default_labels: [docs]
milestone: v0.2 Docs polish
tracking_issue_title: Documentation overhaul (v0.2)
---

## Fix README repo and issues links to canonical repository
Labels: docs, readme

Why
- Ensure users land on the right repository and issue tracker.

What
- Update README Links section to point to `revgizmo/zoomstudentengagement` for both repo and issues.
- Verify DESCRIPTION URL/BugReports already match.

Acceptance
- README links resolve to the canonical repo and its issues page.

## Add badges to README (R CMD check, pkgdown, license, lifecycle)
Labels: docs, readme, pkgdown

Why
- Provide trust signals and quick status visibility.

What
- Add badges for R-CMD-check, pkgdown site, MIT license, lifecycle (experimental).

Acceptance
- Badges render at top of README; links resolve; pkgdown badge points to GitHub Pages site.

## Improve Install section: devtools and pak; add CRAN note
Labels: docs, readme

Why
- Offer faster install paths and set expectations for CRAN.

What
- Show `devtools::install_github()` and `pak::pak()` alternatives.
- Add placeholder for CRAN install once available.

Acceptance
- Users can copy/paste either option successfully; section renders in README and on pkgdown.

## Add 60-second end-to-end quickstart snippet to README
Labels: docs, readme

Why
- Reduce time-to-first-plot for new users.

What
- Minimal example: one transcript metrics, batch summarize directory, and a privacy-safe plot using `inst/extdata`.

Acceptance
- Snippet runs as-is using bundled data; verified after `devtools::build_readme()`.

## Document supported file types and limitations in README
Labels: docs, readme

Why
- Set clear expectations for `.transcript.vtt` vs `.cc.vtt` and chat files.

What
- Add a small support matrix table with notes.
- Mention planned support or guidance for unsupported types.

Acceptance
- Table renders and clarifies `.transcript.vtt` is supported; others not yet.

## Add roster requirements to README and link to load_roster()
Labels: docs, readme

Why
- Reduce confusion around required columns and formats.

What
- List required columns for roster ingestion.
- Link to `?load_roster` and relevant vignette.

Acceptance
- README specifies required fields; example roster in `inst/extdata` referenced.

## Create Troubleshooting & FAQ vignette
Labels: docs, vignettes, faq

Why
- Deflect common setup and data issues with concise answers.

What
- New vignette covering: unsupported file types, file-not-found, roster schema mismatches, name matching workflow, time zones, masked names in plots.

Acceptance
- Vignette builds; linked from README and pkgdown navbar.

## Organize pkgdown reference groups and navbar
Labels: docs, pkgdown

Why
- Improve discoverability of core vs advanced functions.

What
- Add `_pkgdown.yml` with reference groups: Core processing, Data management, Analysis & plotting, Privacy & FERPA, Writing/exports, Advanced utilities.
- Ensure navbar shows Get started, Reference, Articles, FAQ.

Acceptance
- Pkgdown builds with grouped reference and correct navbar.

## Document input validation and error behavior for key functions
Labels: docs, reference

Why
- Users benefit from predictable errors and clear messages.

What
- In roxygen for exported functions (e.g., `summarize_transcript_metrics`, `process_zoom_transcript`), explicitly document error/warning cases and supported extensions.
- Ensure functions emit descriptive errors when neither file nor `transcript_df` is provided, or when file type unsupported.

Acceptance
- Help pages show validation behavior; examples demonstrate errors with `expect_error` in tests (if applicable).

## Clarify privacy defaults in README and link FERPA vignette
Labels: docs, privacy, readme

Why
- Make privacy behavior explicit and safe.

What
- Short README section on default masking, available modes, and the global option `zoomstudentengagement.privacy_level`.
- Link to FERPA & Ethics vignette.

Acceptance
- Section renders; example toggling shows a warning for `none`.

## Add README to inst/extdata describing sample files
Labels: docs

Why
- Help users understand the purpose and structure of included data.

What
- `inst/extdata/README.md` describing each sample file and how it’s used.

Acceptance
- File present; linked from README’s sample data section.

## Add Performance tips article (vignette)
Labels: docs, vignettes, performance

Why
- Set expectations and provide guidance for large archives.

What
- New vignette: batching strategies, memory notes, using summary functions efficiently.

Acceptance
- Vignette builds; linked from pkgdown.

## Add NEWS.md and wire it into pkgdown site
Labels: docs, pkgdown

Why
- Communicate user-visible changes and breaking changes.

What
- Create `NEWS.md` and add to pkgdown config so it appears in the site.

Acceptance
- NEWS renders on pkgdown; future releases update the changelog.

## Add coverage workflow/badge (optional)
Labels: docs, coverage, ci

Why
- Increase trust via visibility into test coverage.

What
- Add a GitHub Actions workflow to run `covr::codecov()` or equivalent.
- Add coverage badge to README.

Acceptance
- Workflow runs; badge displays coverage; consider Codecov integration if preferred.

## Specify minimum R version in DESCRIPTION
Labels: docs

Why
- Set clear expectations on supported environments.

What
- Add `Depends: R (>= 4.x.y)` to DESCRIPTION (choose appropriate minimum).

Acceptance
- DESCRIPTION includes minimum R version; pkg checks pass.

## Link `inst/new_analysis_template.Rmd` from README
Labels: docs, readme

Why
- Provide a guided, ready-to-knit workflow for new users.

What
- Mention and link the included analysis template in README and pkgdown home.

Acceptance
- Link present and working; template accessible via `system.file()`.

## Document privacy-aware name matching workflow
Labels: docs, privacy, reference

Why
- New name-matching functions and privacy checks were added on main. Users need clear guidance.

What
- Document `safe_name_matching_workflow()`, `prompt_name_matching()`, `validate_privacy_compliance()`, and related helpers (e.g., `hash_name_consistently()`).
- Clarify expected inputs/outputs, privacy guarantees, and typical failure modes.

Acceptance
- Help pages describe parameters, return values, and privacy behavior, with runnable examples using bundled data.

## Add vignette: Privacy-aware name matching
Labels: docs, vignettes, privacy

Why
- Provide an end-to-end, FERPA-conscious workflow for matching transcript names to rosters.

What
- New vignette that walks through: extracting names, matching with privacy, handling unmatched names, validating compliance, and exporting masked outputs.

Acceptance
- Vignette builds; linked from README and pkgdown under a new "Name Matching & Privacy" section.

## Update README with name matching quickstart and links
Labels: docs, readme, privacy

Why
- Surface the new, safer matching workflow to first-time users.

What
- Add a short quickstart snippet for `safe_name_matching_workflow()` and link to the new vignette.
- Mention privacy defaults and how matching respects masking.

Acceptance
- README renders with the snippet; links resolve to the vignette and reference topics.

## Document dataset: section_names_lookup
Labels: docs, reference, data

Why
- A new data object `section_names_lookup` was added and should be documented for users/tests.

What
- Ensure `R/data.R` roxygen for `section_names_lookup` is complete (title, description, format, examples).
- Confirm `man/section_names_lookup.Rd` renders correctly and examples run.

Acceptance
- Data object appears on pkgdown; help page is complete with runnable examples.

## Update pkgdown reference groups for Name Matching & Privacy
Labels: docs, pkgdown, privacy

Why
- Improve discoverability of the new API surface.

What
- Update `_pkgdown.yml` to add a "Name Matching & Privacy" reference group containing the new functions.

Acceptance
- Pkgdown site shows the new group; functions appear under it.

## Document real-world testing scripts and workflow
Labels: docs

Why
- New scripts under `scripts/real_world_testing/` enable realistic validation and should be discoverable.

What
- Add a short docs page (or README section) explaining how to run the real-world tests, required inputs, and expected outputs.

Acceptance
- Users can follow the docs to run the scripts and reproduce expected artifacts.