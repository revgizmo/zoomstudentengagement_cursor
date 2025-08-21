### Issue #326 Implementation Guide: Safe Lookup + Privacy-Aware Identification

#### Overview
Implement a safe, privacy-aware participant identification workflow and eliminate accidental overwrites of `data/metadata/section_names_lookup.csv`.

#### Branch
```
git checkout -b feature/issue-326-privacy-aware-identification
git push -u origin feature/issue-326-privacy-aware-identification
```

#### Tasks
1) Create safe merge/write utility
   - File: `R/lookup_merge_utils.R`
   - Functions:
     - `read_lookup_safely(path)` → UTF-8, ensure expected columns; return 0-row df if missing.
     - `merge_lookup_preserve(existing_df, add_df)` → preserve existing rows; fill only missing fields; dedupe by `transcript_name` deterministically.
     - `write_lookup_transactional(df, path)` → backup `.backup.YYYYMMDD_HHMMSS`, temp file, atomic rename.
     - `ensure_instructor_rows(existing_df, instructor_name)` → returns merged df; no side effects.

2) Create participant classification
   - File: `R/participant_classification.R`
   - Function: `classify_participants(transcript_df, roster_df, lookup_df, privacy_level = "ferpa_standard")`
     - Output columns: `clean_name`, `participant_type`, `student_id`, `is_matched`.
     - Pure (no writes); applies privacy defaults.

3) Refactor Step 6.2 (Rmd) to use new utilities
   - Keep default read-only execution.
   - Gate any lookup writes behind a single opt-in flag (already introduced): `params$allow_lookup_write`.
   - Replace any direct `write.csv()` with `write_lookup_transactional()` via a small wrapper.

4) Tests (testthat)
   - File: `tests/testthat/test-lookup-merge-utils.R`
     - empty file → create with instructor entry
     - missing columns → normalize and preserve data
     - duplicates → deterministic dedupe
     - preserve manual rows when adding instructor
     - transactional write creates backup
   - File: `tests/testthat/test-participant-classification.R`
     - instructor, enrolled students, guests; masking according to privacy level
     - UTF-8 names roundtrip
   - File: `tests/testthat/test-rmd-readonly-gate.R`
     - simulate Step 6.2 in read-only mode (no filesystem writes)

5) Docs
   - Update `vignettes/name-matching-troubleshooting.Rmd` with safe flow and the `allow_lookup_write` flag.
   - Add a short “Before metrics: classify participants” note in `vignettes/whole-game.Rmd`.

#### Commands (validation)
```
./scripts/save-context.sh
Rscript scripts/pre-pr-validation.R
devtools::document(); devtools::test(); devtools::check()
```

#### Success criteria
- Running Step 6.2 without `allow_lookup_write=TRUE` does not touch the filesystem.
- Manual mappings are preserved; backups exist for any write.
- Participant classification feeds metrics cleanly; tests pass; CRAN checks remain green.


