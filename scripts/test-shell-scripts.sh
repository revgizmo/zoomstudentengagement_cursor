#!/bin/bash
set -euo pipefail

# Shell Script Testing Framework
# Tests for common issues including floating point comparisons

echo "🧪 Testing Shell Scripts..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_exit="$3"
    
    echo -n "Testing: $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        exit_code=0
    else
        exit_code=1
    fi
    
    if [ "$exit_code" -eq "$expected_exit" ]; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Check for floating point comparison issues
echo "📊 Testing floating point comparison detection..."
run_test "Floating point comparison detection" \
    "grep -r '\\[.*\\$.*\\..*\\s+[-][lg][te]\\s+[0-9]' scripts/" \
    1

# Test 2: Test coverage comparison logic with decimal values
echo "📈 Testing coverage comparison logic..."
test_coverage_comparison() {
    local test_value="$1"
    local expected_result="$2"
    
    # Create a temporary test script
    cat > /tmp/test_coverage.sh << 'EOF'
#!/bin/bash
set -euo pipefail

COVERAGE_OUTPUT="$1"

# Test the actual logic from context-for-new-chat.sh
if [ "$COVERAGE_OUTPUT" != "N/A" ] && [ -n "$COVERAGE_OUTPUT" ] && echo "$COVERAGE_OUTPUT" | awk '{exit $1 < 90}' 2>/dev/null; then
    echo "NEEDS_IMPROVEMENT"
else
    echo "OK"
fi
EOF
    
    chmod +x /tmp/test_coverage.sh
    result=$(/tmp/test_coverage.sh "$test_value")
    
    if [ "$result" = "$expected_result" ]; then
        echo -e "${GREEN}PASS${NC}: $test_value → $result"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}: $test_value → $result (expected $expected_result)"
        ((TESTS_FAILED++))
    fi
    
    rm -f /tmp/test_coverage.sh
}

echo "Testing coverage comparison with various values:"
test_coverage_comparison "78.15" "NEEDS_IMPROVEMENT"
test_coverage_comparison "95.0" "OK"
test_coverage_comparison "90.0" "OK"
test_coverage_comparison "89.99" "NEEDS_IMPROVEMENT"
test_coverage_comparison "N/A" "OK"
test_coverage_comparison "" "OK"

# Test 3: Test shell script syntax
echo "🔍 Testing shell script syntax..."
for script in scripts/*.sh; do
    if [ -f "$script" ]; then
        echo -n "Testing syntax: $(basename "$script")... "
        if bash -n "$script" 2>/dev/null; then
            echo -e "${GREEN}PASS${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}FAIL${NC}"
            ((TESTS_FAILED++))
        fi
    fi
done

# Test 4: Test for common shell script issues
echo "⚠️  Testing for common shell script issues..."

# Check for missing set -euo pipefail
run_test "Missing set -euo pipefail" \
    "grep -L 'set -euo pipefail' scripts/*.sh" \
    0

# Check for unquoted variables
run_test "Unquoted variables" \
    "grep -r '\\$[A-Z_][A-Z0-9_]*[^\"\\'\\s]' scripts/" \
    1

# Check for missing error handling
run_test "Missing error handling" \
    "grep -r '2>/dev/null' scripts/ | grep -v 'awk'" \
    0

# Test 5: Test context script functionality
echo "🔄 Testing context script functionality..."
test_context_script() {
    echo -n "Testing context script execution... "
    
    # Test that the script runs without errors
    if ./scripts/context-for-new-chat.sh >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}"
        ((TESTS_FAILED++))
    fi
}

test_context_script

# Test 6: Test for proper error handling
echo "🛡️  Testing error handling..."
test_error_handling() {
    echo -n "Testing error handling with invalid inputs... "
    
    # Test with invalid coverage value
    COVERAGE_OUTPUT="invalid_value" ./scripts/context-for-new-chat.sh >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}"
        ((TESTS_FAILED++))
    fi
}

test_error_handling

# Summary
echo ""
echo "📊 Test Summary:"
echo "================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Please review the issues above.${NC}"
    exit 1
fi 
