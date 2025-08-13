## Spin-offs: Data Processing Modules

Scope: Extract focused, reusable data-processing components as small R packages.

Related doc: `docs/planning/SPINOFF_PROJECTS_PLAN.md`

### Subprojects
1) Zoom VTT Transcript Parsing Library
- Source: `R/load_zoom_transcript.R`, `R/process_zoom_transcript.R`, `inst/extdata/*`, `vignettes/transcript-processing.Rmd`
- Deliverables: Minimal parser package + CLI entrypoint
- Tasks: [ ] support .transcript.vtt + variants; [ ] robust parsing; [ ] examples/tests

2) Time-Window Consolidation Utilities
- Source: `R/consolidate_transcript.R`
- Deliverables: Generic consolidation utilities (group/time window)
- Tasks: [ ] configurable merge windows; [ ] grouped operations; [ ] tests/examples

3) Name Matching/Cleaning Helpers
- Source: `R/make_clean_names_df.R`, `R/make_roster_small.R`, `R/make_sections_df.R`
- Deliverables: Helpers for normalization and join prep
- Tasks: [ ] consistent column expectations; [ ] demo recipes; [ ] tests

4) Batch Transcript/Metrics Pipeline
- Source: `R/summarize_transcript_files.R`, `R/summarize_transcript_metrics.R`, writers in `R/write_*`
- Deliverables: Skeleton pipeline with pluggable metrics
- Tasks: [ ] adapters; [ ] sample metrics; [ ] batch runners

### Acceptance criteria
- [ ] One minimal package published (VTT parser or consolidation utils)
- [ ] Remaining module stubs created with tests and README
- [ ] Clear interoperability guidance

### Labels
Suggested: `priority:medium`, `area:core`, `enhancement`

### Related issues (cross-links)
- #97 Support multiple Zoom file types: cc.vtt and chat.txt files
- #110 Performance: Vectorized operations for lag functions
- #56 Add transcript_file column with intelligent duplicate handling
- #50 Generalize Topic parsing in load_zoom_recorded_sessions_list
- Refactors/naming/internalization: #28–#33, #29–#31