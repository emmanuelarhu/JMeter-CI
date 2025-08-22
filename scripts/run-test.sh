#!/bin/bash

# JMeter Performance Test Runner
# Usage: ./run-test.sh [test-type] [users] [duration]

TEST_TYPE=${1:-load-test}
USERS=${2:-50}
DURATION=${3:-300}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Check if JMeter is installed
if ! command -v jmeter &> /dev/null; then
    echo "Error: JMeter not found. Please install JMeter and add to PATH"
    exit 1
fi

# Check if test plan exists
if [ ! -f "test-plans/${TEST_TYPE}.jmx" ]; then
    echo "Error: Test plan test-plans/${TEST_TYPE}.jmx not found"
    echo "Available test plans:"
    ls test-plans/*.jmx 2>/dev/null || echo "No test plans found"
    exit 1
fi

# Create results directory
mkdir -p results

echo "Starting JMeter test..."
echo "Test Type: ${TEST_TYPE}"
echo "Users: ${USERS}"
echo "Duration: ${DURATION}s"
echo "Timestamp: ${TIMESTAMP}"

# Run JMeter test
jmeter -n \
    -t test-plans/${TEST_TYPE}.jmx \
    -l results/${TEST_TYPE}_${TIMESTAMP}.jtl \
    -j results/${TEST_TYPE}_${TIMESTAMP}.log \
    -e -o results/${TEST_TYPE}_${TIMESTAMP}_report \
    -Jusers=${USERS} \
    -Jduration=${DURATION} \
    -q config/test.properties

# Check if test was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "Test completed successfully!"
    echo "Results saved to: results/${TEST_TYPE}_${TIMESTAMP}_report/"
    echo "View report: open results/${TEST_TYPE}_${TIMESTAMP}_report/index.html"
    
    # Show quick summary
    echo ""
    echo "Quick Summary:"
    awk -F',' 'NR>1 {total++; rt+=$2; if($8=="true") errors++} 
    END {printf "Total Requests: %d\nAverage Response Time: %.0f ms\nErrors: %d (%.1f%%)\n", 
    total, rt/total, errors, errors/total*100}' results/${TEST_TYPE}_${TIMESTAMP}.jtl
else
    echo "Test failed! Check the log file: results/${TEST_TYPE}_${TIMESTAMP}.log"
    exit 1
fi