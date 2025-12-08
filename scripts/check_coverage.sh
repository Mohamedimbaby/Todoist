#!/bin/bash

# Script to check code coverage threshold
# Usage: ./scripts/check_coverage.sh [threshold]

THRESHOLD=${1:-90}
LCOV_FILE="coverage/lcov.info"

# Check if lcov file exists
if [ ! -f "$LCOV_FILE" ]; then
    echo "Error: Coverage file not found at $LCOV_FILE"
    echo "Run 'flutter test --coverage' first"
    exit 1
fi

# Calculate coverage
COVERAGE=$(lcov --summary "$LCOV_FILE" 2>&1 | grep "lines" | awk '{print $2}' | sed 's/%//')

echo "========================================"
echo "Code Coverage Report"
echo "========================================"
echo "Current coverage: $COVERAGE%"
echo "Required threshold: $THRESHOLD%"
echo "========================================"

# Compare using bc for floating point
if (( $(echo "$COVERAGE < $THRESHOLD" | bc -l) )); then
    echo "FAILED: Coverage is below threshold!"
    echo "Please add more tests to increase coverage."
    exit 1
else
    echo "PASSED: Coverage meets threshold!"
    exit 0
fi

