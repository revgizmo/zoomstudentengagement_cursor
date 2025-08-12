---
title: Schema: Validators and expected columns/types
labels: enhancement, data-model
---

Tasks
- Create `R/schema.R` with documented schemas for key data frames
- Implement `validate_schema(df, required_cols, types = NULL)` helper
- Add validators at public entry points; fail fast with typed errors
- Write vignette section detailing schemas and invariants
- Add tests for validators and error messaging

Acceptance criteria
- Validators exist and are used across pipelines
- Vignette documents schemas with examples
- Tests cover success and failure cases for schema checks