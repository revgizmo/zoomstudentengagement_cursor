---
title: Docs: `_pkgdown.yml`, README updates, NEWS, vignette improvements
labels: enhancement, documentation
---

Tasks
- Add `_pkgdown.yml` to organize reference by families and articles
- Ensure all exported functions have complete roxygen with examples
- Create `NEWS.md` and add lifecycle badge(s) to README
- Update vignettes: schemas, privacy policy/options, end-to-end examples
- Confirm Pages deploy job builds site from `docs/`

Acceptance criteria
- Pkgdown site builds locally and on CI; nav is clear
- README has quickstart and badges
- NEWS.md created and populated for current changes
- Vignettes cover pipelines and privacy