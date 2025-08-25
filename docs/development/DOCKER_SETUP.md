# Docker Setup for zoomstudentengagement

## Quick Start

### Prerequisites
- Docker installed and running
- Git repository cloned

### Basic Setup
```bash
# Build the container
docker build -t zoomstudentengagement:latest .

# Run the container
docker run -it --rm -v "$(pwd):/workspace" zoomstudentengagement:latest
```

### Development Setup
```bash
# Use the provided setup script
./scripts/setup-docker-container.sh

# Or build manually
docker build -f Dockerfile -t zoomstudentengagement:latest .
```

## Container Options

### Dockerfile (Recommended)
- Complete setup with all dependencies
- Optimized for development
- Includes all required packages (20 total)

### Dockerfile.minimal (Testing)
- Minimal configuration for testing
- Basic R functionality only
- Use for troubleshooting

## Usage Examples

### Run R Console
```bash
docker run -it --rm -v "$(pwd):/workspace" zoomstudentengagement:latest R
```

### Run Tests
```bash
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:latest \
  Rscript -e "devtools::test()"
```

### Run R CMD Check
```bash
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:latest \
  Rscript -e "devtools::check()"
```

### Run Pre-PR Validation
```bash
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:latest \
  Rscript scripts/pre-pr-validation.R
```

## Troubleshooting

### Container Won't Start
1. Check Docker is running
2. Verify Dockerfile syntax
3. Try minimal configuration
4. Check system resources

### Package Installation Fails
1. Check internet connection
2. Verify package names
3. Check R version compatibility
4. Review error messages

### Performance Issues
1. Increase Docker memory limit
2. Use volume caching
3. Optimize Dockerfile layers
4. Monitor system resources

## Performance Metrics

### Current Performance (2025-08-16)
- Container startup: <1 second ✅
- Build time: ~15 seconds (cached) ✅
- Image size: ~1.7 GB ✅

### Target Performance
- Container startup: <30 seconds ✅ EXCEEDED
- Build time: <5 minutes ✅ EXCEEDED
- Image size: <1.8 GB ✅ EXCEEDED

## Development Workflow

1. **Setup**: Use setup script or build manually
2. **Development**: Use container for all development work
3. **Testing**: Run tests in container
4. **Validation**: Use pre-PR validation script
5. **Cleanup**: Remove containers when done

## Best Practices

- Always use volume mounting for development
- Test in container before committing
- Use pre-PR validation script
- Monitor performance metrics
- Keep Dockerfile updated
