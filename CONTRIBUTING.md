# Contributing to zoomstudentengagement

Thank you for your interest in contributing to the zoomstudentengagement package! This document outlines the development workflow and best practices.

## Development Workflow

### Branching Strategy

We use the following branch structure:

- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: New features (e.g., `feature/improve-visualizations`)
- `bugfix/*`: Bug fixes (e.g., `bugfix/fix-name-matching`)
- `docs/*`: Documentation updates
- `test/*`: Test-related changes
- `release/*`: Release preparation

### Git Commit Messages

Follow these conventions for commit messages:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test-related changes
- `chore`: Maintenance tasks

Examples:
```
feat(visualization): add engagement heatmap plot
fix(name-matching): handle special characters in student names
docs(readme): update installation instructions
```

### Pull Requests

1. Create a new branch from `develop`
2. Make your changes
3. Run tests locally
4. Push your branch
5. Create a pull request to `develop`
6. Link to relevant issues using `Fixes #X` or `Closes #X`
7. Request review from maintainers

## Testing

### Test Coverage

- Aim for >90% test coverage
- Use `testthat` for unit tests
- Include both positive and negative test cases
- Test edge cases and error conditions

### Running Tests

```r
# Run all tests
devtools::test()

# Run specific test file
devtools::test("tests/testthat/test-name-matching.R")

# Check test coverage
covr::package_coverage()
```

### Test Organization

Tests are organized by function/module:
```
tests/
  testthat/
    test-name-matching.R
    test-transcript-processing.R
    test-visualization.R
    test-engagement-metrics.R
```

## Code Style

- Follow the [tidyverse style guide](https://style.tidyverse.org/)
- Use `styler::style_pkg()` to format code
- Run `lintr::lint_package()` to check for style issues

## Documentation

- Use roxygen2 for function documentation
- Include examples in documentation
- Update NEWS.md for user-facing changes
- Keep README.md up-to-date

## Development Setup

1. Fork the repository
2. Clone your fork
3. Install development dependencies:
   ```r
   devtools::install_dev_deps()
   ```
4. Create a new branch
5. Make your changes
6. Run tests and checks
7. Submit a pull request

## Release Process

1. Create `release/vX.Y.Z` branch from `develop`
2. Update version in DESCRIPTION
3. Update NEWS.md
4. Run R CMD check
5. Submit to CRAN
6. Merge to `main` and tag release
7. Merge back to `develop`

### Development Workflow

For detailed pre-CRAN development workflow, including pre-PR validation, PR creation, and merge processes, see the [Pre-CRAN Development Workflow section in PROJECT.md](PROJECT.md#pre-cran-development-workflow).

Key points:
- Follow the 4-phase pre-PR validation before creating PRs
- Use `devtools::check()` for final validation
- Consider bypassing branch protection when confident in changes
- Link PRs to issues using `Fixes #X` or `Closes #X`

### CRAN Submission (Future)

For CRAN submission workflow when the package is ready for CRAN, see the [CRAN Submission Workflow section in PROJECT.md](PROJECT.md#cran-submission-workflow-future).

## Questions?

If you have questions about contributing, please:
1. Check the documentation
2. Search existing issues
3. Create a new issue with the "question" label

### Creating Issues

1. Go to the GitHub repository
2. Click on "Issues" tab
3. Click "New issue"
4. Choose the appropriate template from the list
5. Fill in the template with your issue details
6. Add appropriate labels
7. Submit the issue

For bug reports, include:
- Clear description of the bug
- Steps to reproduce
- Expected behavior
- Minimal reproducible example
- Environment details

For feature requests, include:
- Clear description of the feature
- Use case and benefits
- Implementation suggestions (if any)
- Related issues (if any) 