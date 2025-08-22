#!/bin/bash

echo "Measuring Docker performance baseline..."

# Function to measure time
measure_time() {
    local start_time=$(date +%s.%N)
    eval "$1"
    local end_time=$(date +%s.%N)
    echo "$(echo "$end_time - $start_time" | bc -l)"
}

# Test current Dockerfiles
for dockerfile in Dockerfile Dockerfile.updated Dockerfile.complete Dockerfile.minimal; do
    if [ -f "$dockerfile" ]; then
        echo "Testing $dockerfile..."
        
        # Measure build time
        build_time=$(measure_time "docker build -f $dockerfile -t test:$dockerfile .")
        echo "Build time for $dockerfile: ${build_time}s"
        
        # Measure startup time
        startup_time=$(measure_time "docker run --rm test:$dockerfile R -e 'cat(\"started\n\")'")
        echo "Startup time for $dockerfile: ${startup_time}s"
        
        # Measure image size
        image_size=$(docker images test:$dockerfile --format "table {{.Size}}" | tail -n 1)
        echo "Image size for $dockerfile: $image_size"
        echo "---"
    fi
done
