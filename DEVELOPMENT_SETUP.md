# Development Setup Guide

## Overview

This project uses standard R development environments with Cursor IDE background agents. Docker development work is isolated in feature branches to maintain main branch stability.

## Development Configuration

### Files Included in Git (Development Only)
- `.Rprofile` - R environment setup for development
- `Dockerfile.cursor-template` - Reference template for Docker development (feature branches only)

### Files Excluded from R Package Build
- All Docker/container files (`.Rbuildignore`)
- Development documentation (`docs/`, `*.md` files)
- Test scripts and utilities (`scripts/`, `test_*.R`)
- IDE configurations (`.cursor/`, `.vscode/`)

### Files Excluded from Git
- Container backups (`.cursor_backup/`)
- Docker build artifacts (feature branches only)
- Temporary files and caches

## Development Environment

### R Environment
- **R 4.4.0** (stable version)
- **All package dependencies** installed via DESCRIPTION
- **Development tools**: styler, lintr, covr, roxygen2
- **Documentation tools**: knitr, rmarkdown

### Development Tools
- **Git** and **GitHub CLI** for version control
- **R Language Server** for code completion
- **R Debugger** for debugging
- **Enhanced R terminal** settings

### R Profile Configuration
The `.Rprofile` file configures:
- CRAN mirror settings
- Development package loading
- Working directory setup
- Interactive session messages

## Development Workflow

### Starting Development
1. Open project in Cursor
2. Background agent uses standard R environment
3. R environment is ready with all tools

### Package Development
- **Code**: `R/` directory
- **Tests**: `tests/testthat/`
- **Documentation**: `man/` (auto-generated)
- **Vignettes**: `vignettes/`

### Quality Assurance
- **Styling**: `styler::style_pkg()`
- **Linting**: `lintr::lint_package()`
- **Testing**: `devtools::test()`
- **Coverage**: `covr::package_coverage()`

### Building Package
- **Documentation**: `devtools::document()`
- **Check**: `devtools::check()`
- **Build**: `devtools::build()`

## Environment Management

### Docker Development (Feature Branches Only)
- **When**: For Docker-specific development work
- **How**: Use `Dockerfile.cursor-template` as reference
- **Location**: Isolated in feature branches

### Updating Dependencies
- Edit `DESCRIPTION` file for package dependencies
- Run `devtools::install_deps()` to update

### Troubleshooting
- **R packages missing**: Run `devtools::install_deps()`
- **Background agent issues**: Check Cursor IDE settings
- **Git issues**: Check Git installation

## Best Practices

### Development
- Use standard R development environment
- Use `devtools::` functions for package operations
- Run tests before committing changes
- Keep `.Rprofile` minimal and focused

### Version Control
- Commit `.Rprofile` changes
- Don't commit Docker build artifacts (feature branches only)
- Document environment changes in commit messages

### Package Building
- Use `devtools::check()` before releases
- Ensure all examples run (`devtools::check_examples()`)
- Verify CRAN compliance (`devtools::check_rhub()`)

## File Organization

```
zoomstudentengagement/
├── .devcontainer/          # Container configuration (git, not build)
├── .Rprofile              # R environment setup (git, not build)
├── Dockerfile             # Alternative container (git, not build)
├── R/                     # Package source code (git + build)
├── tests/                 # Package tests (git + build)
├── vignettes/             # Package vignettes (git + build)
├── man/                   # Generated documentation (git + build)
├── inst/                  # Package data (git + build)
└── docs/                  # Development docs (git, not build)
```

## Environment Variables

The container sets up:
- `R_LIBS_USER`: User R library path
- `R_ENVIRON_USER`: User R environment file
- Working directory: Project root

## Support

For container issues:
1. Check Docker is running
2. Rebuild container
3. Check `.devcontainer/devcontainer.json` syntax
4. Review container logs in terminal

For R package issues:
1. Check `.Rprofile` configuration
2. Verify package dependencies in `DESCRIPTION`
3. Run `devtools::check()` for diagnostics
