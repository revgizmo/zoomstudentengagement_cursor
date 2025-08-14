---
title: Performance: Identify and optimize hotspots
labels: enhancement, performance
---

Tasks
- Profile critical pipelines (bench/Rprof) to identify top bottlenecks
- Optimize targeted hotspots (joins, grouping, allocations)
- Add micro-benchmarks for optimized helpers
- Document results briefly (scripts/benchmarks.md)

Acceptance criteria
- Measurable speedup on representative data
- No regressions in correctness (tests pass)
- Benchmarks and scripts available for replication