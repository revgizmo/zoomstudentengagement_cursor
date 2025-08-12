---
title: Privacy: Centralize PII detection and enforce guarantees
labels: enhancement, privacy
---

Tasks
- Centralize PII patterns in a single module and allow user extension
- Ensure `ensure_privacy()` is the gateway; add summaries of redactions
- Validate anonymization at entry points that require it
- Add tests for detection, masking, and policy options
- Document privacy policy and options in vignette

Acceptance criteria
- Single source of truth for PII patterns
- Entry points enforce privacy preconditions
- Tests confirm masking and logs; docs updated