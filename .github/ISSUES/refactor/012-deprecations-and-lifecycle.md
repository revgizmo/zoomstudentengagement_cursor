---
title: Deprecations: Plan, shims, and lifecycle
labels: enhancement, api
---

Tasks
- Add `lifecycle` badges and `lifecycle::deprecate_warn()` for renamed functions
- Provide shims forwarding to new APIs
- Document migrations in NEWS and reference
- Set a removal timeline and communicate in docs

Acceptance criteria
- Deprecated functions warn with clear messages
- Users have guidance and time to migrate
- NEWS documents changes and deprecations