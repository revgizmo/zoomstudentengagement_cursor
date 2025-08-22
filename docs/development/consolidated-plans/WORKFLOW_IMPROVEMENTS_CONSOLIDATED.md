# Workflow Improvements Consolidated Plan

## 📋 **Overview**

This document consolidates all workflow-related improvements identified in PR #239. These improvements focus on standardizing error handling, improving development tools, and enhancing the overall development experience.

## 🎯 **Workflow Improvement Areas**

### 1. **Standardize error signaling and quiet default output**
**Issue**: #338 - refactor(error): standardize error signaling and quiet default output
**Labels**: refactor, documentation, priority:medium

**Why**
- Inconsistent errors and noisy logs can fail CRAN/tests.

**What**
- Use `abort_zse()` across exported functions; introduce `zse_message()` gated by option `zoomstudentengagement.verbose` and test env.
- Gate existing `message()/cat()/print()` through `zse_message`.

**Acceptance**
- Tests/CI logs are quiet by default; error classes stable for assertions.

**Validation**
- Negligible perf impact; better CRAN hygiene.

### 2. **Deduplicate context/update scripts and gate PROJECT.md prompts**
**Issue**: #339 - refactor(scripts): deduplicate context/update scripts and gate PROJECT.md prompts
**Labels**: refactor, documentation, priority:medium

**Why**
- Duplication in `get-context.sh` and `save-context.sh`; noisy by default.

**What**
- Extract the prompt logic into `scripts/project-md-update.sh`.
- Add `--project-md-reminder` flag to show the prompt; default runs stay quiet.
- Keep existing flags `--check-project-md` and `--fix-project-md` in `save-context.sh`.

**Acceptance**
- Both scripts work; prompt appears only with the new flag; no duped code.

**Validation**
- Smaller maintenance surface; predictable pre-PR flow.

### 3. **Fast-path options in pre-PR validation**
**Issue**: #337 - feat(workflow): implement AI-assisted PR review system
**Labels**: enhancement, priority:high, area:infrastructure

**Why**
- Full `devtools::check()` and vignette builds slow local validations.

**What**
- Add `--fast` (default) and `--full` flags to `scripts/pre-pr-validation.R`.
- In fast mode: skip vignettes and run `check(vignettes = FALSE, manual = FALSE)`; full mode keeps current behavior.

**Acceptance**
- Fast runs complete in minutes; full runs still available.

**Validation**
- Improved dev UX; no package behavior change.

### 4. **Reduce test output pollution at the source**
**Issue**: #344 - refactor(test): reduce test output pollution at the source
**Labels**: refactor, area:testing, priority:medium

**Why**
- Noisy messages in package code trigger CI/test warnings.

**What**
- Wrap diagnostics identified by the validation script (section 7.5) in `zse_message()` or remove if redundant.

**Acceptance**
- Validation script reports zero pollution; test logs are clean.

**Validation**
- No functional changes; cleaner CI.

### 5. **Trim the public API surface (soft deprecations)**
**Issue**: #342 - refactor(api): trim the public API surface (soft deprecations)
**Labels**: refactor, documentation, priority:medium

**Why**
- Large surface increases maintenance/testing burden and user confusion.

**What**
- Mark for deprecation (docs only for now): `match_names_with_privacy`, possibly `process_transcript_with_privacy` if not a primary entry point.
- Keep exports for this release; add `@seealso` to preferred entry points.

**Acceptance**
- Reference topics and README clarify the primary API; no breakage.

**Validation**
- Zero runtime cost; clearer UX.

### 6. **Robust schema type checks via inherits**
**Issue**: #343 - refactor(schema): robust schema type checks via inherits
**Labels**: refactor, priority:medium

**Why**
- Exact class equality fails for subclasses (e.g., `hms`).

**What**
- Change `validate_schema()` to use `inherits(df[[nm]], exp_type)`.

**Acceptance**
- No false negatives on typed columns; tests updated accordingly.

**Validation**
- No measurable perf impact; safer checks.

## 🔧 **Workflow Impact Summary**

### **Development Experience**
- **Quieter Defaults**: Less noise in development and CI
- **Faster Validation**: Quick checks for development iterations
- **Better Error Handling**: Consistent and informative error messages
- **Cleaner API**: Reduced surface area and clearer documentation

### **Maintenance Benefits**
- **Reduced Duplication**: Eliminated code duplication in scripts
- **Consistent Patterns**: Standardized error handling and messaging
- **Better Testing**: Cleaner test output and more reliable CI
- **Easier Debugging**: Better error messages and diagnostic information

### **User Experience**
- **Clearer Documentation**: Better API documentation and guidance
- **Predictable Behavior**: Consistent error handling across functions
- **Faster Development**: Quick validation cycles for developers
- **Better Support**: Easier to diagnose and fix issues

## 🔧 **Implementation Strategy**

### **Phase 1: High Priority (Priority: HIGH)**
1. **Fast-path pre-PR validation** (Issue #337)
   - Critical for development speed
   - High impact on developer experience
   - Clear implementation path

### **Phase 2: Medium Priority (Priority: MEDIUM)**
2. **Standardize error signaling** (Issue #338)
   - Improves CRAN compliance
   - Better user experience
   - Consistent error handling

3. **Deduplicate context scripts** (Issue #339)
   - Reduces maintenance burden
   - Improves script reliability
   - Better user experience

4. **Reduce test output pollution** (Issue #344)
   - Cleaner CI output
   - Better debugging experience
   - Improved test reliability

5. **Trim API surface** (Issue #342)
   - Reduces maintenance burden
   - Clearer user guidance
   - Better documentation

6. **Robust schema checks** (Issue #343)
   - More reliable validation
   - Better error handling
   - Improved compatibility

## 🧪 **Testing Strategy**

### **Workflow Testing**
- Test all script improvements with various inputs
- Verify error handling works as expected
- Ensure CI compatibility

### **Functional Testing**
- Verify that all functions work correctly
- Test edge cases and error conditions
- Ensure backward compatibility

### **Integration Testing**
- Test with real development workflows
- Verify CI pipeline compatibility
- Check for any workflow disruptions

## 📈 **Success Metrics**

### **Primary Metrics**
- [ ] Fast-path validation implemented
- [ ] Error signaling standardized
- [ ] Script duplication eliminated
- [ ] Test output pollution reduced
- [ ] API surface trimmed
- [ ] Schema checks improved

### **Secondary Metrics**
- [ ] Improved development speed
- [ ] Better user experience
- [ ] Reduced maintenance burden
- [ ] Cleaner CI output

## 🚨 **Risk Assessment**

### **Low Risk**
- Workflow improvements are mostly additive
- Existing functionality preserved
- Comprehensive test coverage available

### **Mitigation Strategies**
- Implement changes incrementally
- Maintain comprehensive test coverage
- Test with real development workflows
- Keep rollback capability

## 📝 **Implementation Timeline**

### **Week 1: High Priority Improvements**
- [ ] Implement fast-path validation
- [ ] Standardize error signaling
- [ ] Update tests and documentation

### **Week 2: Medium Priority Improvements**
- [ ] Deduplicate context scripts
- [ ] Reduce test output pollution
- [ ] Update tests and documentation

### **Week 3: API and Schema Improvements**
- [ ] Trim API surface
- [ ] Improve schema checks
- [ ] Final integration testing

## 🔗 **Related Issues**

- **Issue #337**: feat(workflow): implement AI-assisted PR review system
- **Issue #338**: refactor(error): standardize error signaling and quiet default output
- **Issue #339**: refactor(scripts): deduplicate context/update scripts and gate PROJECT.md prompts
- **Issue #342**: refactor(api): trim the public API surface (soft deprecations)
- **Issue #343**: refactor(schema): robust schema type checks via inherits
- **Issue #344**: refactor(test): reduce test output pollution at the source

## 📚 **References**

- [R Package Development Best Practices](https://r-pkgs.org/)
- [testthat Documentation](https://testthat.r-lib.org/)
- [R Error Handling Best Practices](https://adv-r.hadley.nz/conditions.html)

## 🔧 **Development Considerations**

### **CI/CD Compatibility**
- All improvements maintain CI/CD compatibility
- No changes that could break automated workflows
- Improved CI output and reliability

### **Developer Experience**
- Faster development cycles
- Better error messages and debugging
- Cleaner and more predictable workflows

### **User Experience**
- Consistent error handling
- Clearer documentation and guidance
- Better support and troubleshooting

---

**Status**: Ready for implementation  
**Priority**: HIGH - Workflow improvements critical for development efficiency  
**Estimated Time**: 3 weeks for complete implementation
