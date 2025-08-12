# zoomstudentengagement 0.1.2

- New unified plotting API: `plot_users()` with `facet_by` and `mask_by` options.
- New unified writer: `write_metrics()` for engagement, summary, and session_summary outputs.
- New orchestration: `analyze_transcripts()` for one-call folder→metrics flow.
- New `privacy_audit()` helper to summarize masking coverage.
- Added provenance attributes to `summarize_transcript_metrics()` outputs: `schema_version`, `source_files`, `processing_timestamp`, `privacy_level`.
- Legacy functions now delegate (soft-deprecated):
  - `plot_users_by_metric()`, `plot_users_masked_section_by_metric()` → `plot_users()`
  - `write_engagement_metrics()`, `write_transcripts_summary()`, `write_transcripts_session_summary()` → `write_metrics()`
- README: added 5-minute whole-game example using the unified APIs.