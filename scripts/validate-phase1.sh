#!/bin/bash

echo "Validating Phase 1 completion..."

# Test 1: Container startup
echo "Test 1: Container startup"
start_time=$(date +%s)
docker run --rm zoomstudentengagement:latest R -e "cat('started\n')" > /dev/null
end_time=$(date +%s)
startup_time=$((end_time - start_time))

if [ $startup_time -lt 60 ]; then
    echo "✅ Container starts in ${startup_time} seconds (<60s)"
else
    echo "❌ Container startup too slow: ${startup_time} seconds"
    exit 1
fi

# Test 2: Package installation
echo "Test 2: Package installation"
docker run --rm zoomstudentengagement:latest \
  R -e "library(zoomstudentengagement); cat('Package loads successfully\n')" > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Package installs and loads successfully"
else
    echo "❌ Package installation failed"
    exit 1
fi

# Test 3: Basic functionality
echo "Test 3: Basic functionality"
docker run --rm zoomstudentengagement:latest \
  R -e "ls(env = asNamespace('zoomstudentengagement'))" > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Basic functionality works"
else
    echo "❌ Basic functionality failed"
    exit 1
fi

# Test 4: Dependency audit
echo "Test 4: Dependency audit"
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:latest \
  Rscript /workspace/scripts/audit-dependencies.R > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Dependency audit passes"
else
    echo "❌ Dependency audit failed"
    exit 1
fi

# Test 5: Performance baseline
echo "Test 5: Performance baseline"
if [ -f "docs/docker-performance-baseline.md" ]; then
    echo "✅ Performance baseline documented"
else
    echo "❌ Performance baseline missing"
    exit 1
fi

echo "✅ Phase 1 validation completed successfully"
