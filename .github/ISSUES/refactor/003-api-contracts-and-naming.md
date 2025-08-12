---
title: API: Contracts, naming conventions, arguments, and returns
labels: enhancement, api
---

Tasks
- Document verb families: `load_`, `make_`, `summarize_`, `write_`, `plot_`, `create_`, `validate_/ensure_`
- Standardize argument order and names (data first, then selectors/config, then I/O)
- Use `match.arg()` for enums; consistent names: `path`, `dir`, `file`, `pattern`
- Ensure all functions return tibbles or named lists; document with `@return`
- Introduce typed errors using `rlang::abort(..., class = c("zse_error", "zse_xxx_error"))`
- Add deprecation shims where renames are needed, with `lifecycle::deprecate_warn()`

Acceptance criteria
- All exported functions aligned with naming and arg standards
- Errors are classed; tests assert on error classes where applicable
- Deprecation notices present for renamed functions