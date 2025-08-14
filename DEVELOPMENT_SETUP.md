# Development Setup Guide

## Overview

This project uses Docker containers for consistent development environments. The setup ensures all developers have the same R environment, dependencies, and tools.

## Container Configuration

### Files Included in Git (Development Only)
- `.devcontainer/devcontainer.json` - Container configuration
- `.Rprofile` - R environment setup for development
- `Dockerfile` - Alternative container definition
- `.dockerignore` - Docker build exclusions

### Files Excluded from R Package Build
- All Docker/container files (`.Rbuildignore`)
- Development documentation (`docs/`, `*.md` files)
- Test scripts and utilities (`scripts/`, `test_*.R`)
- IDE configurations (`.cursor/`, `.vscode/`)

### Files Excluded from Git
- Container backups (`.cursor_backup/`)
- Docker build artifacts (`Dockerfile.backup`)
- Temporary files and caches

## Container Features

### R Environment
- **R 4.4.0** (stable version)
- **All package dependencies** pre-installed
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
2. Container builds automatically
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

## Container Management

### Rebuilding Container
- **When**: After changing `.devcontainer/devcontainer.json`
- **How**: Cmd+Shift+P → "Dev Containers: Rebuild Container"

### Updating Dependencies
- Edit `postCreateCommand` in `.devcontainer/devcontainer.json`
- Rebuild container to apply changes

### Troubleshooting
- **Container won't start**: Check Docker is running
- **R packages missing**: Rebuild container
- **Git issues**: Check container has Git installed

## Best Practices

### Development
- Always work in the container environment
- Use `devtools::` functions for package operations
- Run tests before committing changes
- Keep `.Rprofile` minimal and focused

### Version Control
- Commit `.devcontainer/` and `.Rprofile` changes
- Don't commit container build artifacts
- Document container changes in commit messages

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
