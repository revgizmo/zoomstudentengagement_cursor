### Issue #326 Consolidated Plan: Privacy-Aware Participant Identification and Lookup Safety

#### Problem statement
- R Markdown Step 6.2 can overwrite `data/metadata/section_names_lookup.csv`, erasing instructor/student mappings added by users.
- Participant identification (instructor, enrolled student, guest/unknown) is interleaved with metric computation, making the flow harder to reason about and test.

#### Goals
- Eliminate any accidental overwrites of `section_names_lookup.csv`.
- Make participant identification a clear, first-class step that precedes metrics and is privacy-aware by default.
- Preserve manual mappings across runs; make writes opt-in and transactional.

#### Non-goals
- Redesigning metric algorithms or visualizations.
- Changing package public APIs unless necessary for safety/clarity.

#### Current state
- Step 6.2 runs name matching and may write to the lookup file.
- Fixes already merged:
  - Preserve existing entries and backup before writes.
  - Handle empty/missing-column lookup files.
  - Step 6.2 now supports a read-only mode (gated by `params$allow_lookup_write`).

#### Target state (outcome)
- A safe, testable, idempotent process:
  1) Load roster/transcripts.
  2) Identify/classify participants with a pure function (no writes).
  3) Optionally merge-instructor rows into the lookup file using a safe merge utility when explicitly enabled.
  4) Compute metrics using already-classified data.
- All writes are opt-in and transactional with backups; manual rows are never clobbered.

#### Technical approach
- Add a package-level utility for safe lookup merge (read/validate/normalize/dedupe/backup/atomic-write).
- Add a pure function that classifies participants (adds `clean_name`, `participant_type`, `student_id`, `is_matched`).
- Refactor Step 6.2 to call these utilities and remain read-only by default.
- Expand tests for merge scenarios, encodings, and read-only gating.

#### Deliverables
- New utilities (R/lookup_merge_utils.R) and tests.
- Updated Step 6.2 Rmd to call the safe API.
- Documentation/vignette notes explaining the flow and the opt-in write flag.

#### Milestones
1) Utilities + tests (merge/classify) implemented.
2) Step 6.2 refactor to use utilities (read-only default).
3) Docs/vignette updates and examples.
4) Pre-PR validation; PR; merge.

#### Risks and mitigations
- Risk: Hidden user workflows rely on prior side-effects — Mitigate with clear docs and keeping an opt-in write path.
- Risk: Encoding/dedup corner cases — Mitigate with UTF-8 normalization, deterministic dedupe, unit tests.

#### Acceptance criteria
- Manual mappings are never lost.
- Default runs do not modify files; writes require explicit opt-in.
- Participant classification exists prior to metrics; tests cover common and edge scenarios.


