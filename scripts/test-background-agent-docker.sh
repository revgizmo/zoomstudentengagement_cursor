#!/bin/bash

echo "Testing background agent Docker setup..."

# Test 1: Check if Dockerfile.agent exists
if [ -f "Dockerfile.agent" ]; then
    echo "✅ Dockerfile.agent exists"
else
    echo "❌ Dockerfile.agent missing"
    exit 1
fi

# Test 2: Build agent Docker image
echo "Building agent Docker image..."
docker build -f Dockerfile.agent -t zoomstudentengagement:agent .

if [ $? -eq 0 ]; then
    echo "✅ Agent Docker image built successfully"
else
    echo "❌ Agent Docker image build failed"
    exit 1
fi

# Test 3: Test basic functionality
echo "Testing basic functionality..."
docker run --rm zoomstudentengagement:agent R -e "cat('Background agent Docker test successful\n')"

if [ $? -eq 0 ]; then
    echo "✅ Basic functionality test passed"
else
    echo "❌ Basic functionality test failed"
    exit 1
fi

# Test 4: Test package loading
echo "Testing package loading..."
docker run --rm zoomstudentengagement:agent R -e "library(zoomstudentengagement); cat('Package loaded successfully\n')"

if [ $? -eq 0 ]; then
    echo "✅ Package loading test passed"
else
    echo "❌ Package loading test failed"
    exit 1
fi

echo "🎉 All background agent Docker tests passed!"
echo "The background agent should now be able to use Dockerfile.agent"
