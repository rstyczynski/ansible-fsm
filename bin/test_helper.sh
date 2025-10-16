#!/bin/bash

# Enhanced Test framework for bash commands
# Captures error codes and creates summary with support for negative tests

# Initialize test tracking
declare -a test_names=()
declare -a test_results=()
declare -a test_commands=()
declare -a test_expected=()  # Track expected results (0=success, 1=failure)
test_count=0
failed_tests=0
passed_tests=0
negative_tests=0

# Function to run a positive test (expected to succeed)
run_test() {
    local test_name="$1"
    local command="$2"
    _run_test_internal "$test_name" "$command" 0
}

# Function to run a negative test (expected to fail)
run_negative_test() {
    local test_name="$1"
    local command="$2"
    _run_test_internal "$test_name" "$command" 1
}

# Internal function to run a test and capture results
_run_test_internal() {
    local test_name="$1"
    local command="$2"
    local expected_result="$3"  # 0=success, 1=failure
    
    echo "=========================================="
    echo "Running test: $test_name"
    echo "Command: $command"
    if [ $expected_result -eq 1 ]; then
        echo "Expected: FAILURE (negative test)"
    else
        echo "Expected: SUCCESS"
    fi
    echo "=========================================="
    
    # Execute the command and capture exit code
    eval "$command"
    local exit_code=$?
    
    # Store test information
    test_names[$test_count]="$test_name"
    test_commands[$test_count]="$command"
    test_results[$test_count]=$exit_code
    test_expected[$test_count]=$expected_result
    test_count=$((test_count + 1))
    
    # Determine if test passed based on expectation
    local test_passed=false
    if [ $expected_result -eq 1 ]; then
        # Negative test: should fail (non-zero exit code)
        if [ $exit_code -ne 0 ]; then
            test_passed=true
            negative_tests=$((negative_tests + 1))
        fi
    else
        # Positive test: should succeed (zero exit code)
        if [ $exit_code -eq 0 ]; then
            test_passed=true
        fi
    fi
    
    if [ "$test_passed" = true ]; then
        if [ $expected_result -eq 1 ]; then
            echo "✅ PASSED (negative): $test_name (exit code: $exit_code)"
        else
            echo "✅ PASSED: $test_name"
        fi
        passed_tests=$((passed_tests + 1))
    else
        if [ $expected_result -eq 1 ]; then
            echo "❌ FAILED (negative): $test_name (expected failure but succeeded)"
        else
            echo "❌ FAILED: $test_name (exit code: $exit_code)"
        fi
        failed_tests=$((failed_tests + 1))
    fi
    
    echo ""
}

# Function to print test summary
print_summary() {
    echo "=========================================="
    echo "TEST SUMMARY"
    echo "=========================================="
    echo "Total tests: $test_count"
    echo "Passed: $passed_tests"
    echo "Failed: $failed_tests"
    echo "Negative tests: $negative_tests"
    echo ""
    echo "Detailed Results:"
    echo "-----------------"
    
    for i in "${!test_names[@]}"; do
        local status="✅ PASS"
        local test_type="(+)"
        
        # Determine test result based on expectation
        if [ ${test_expected[$i]} -eq 1 ]; then
            # Negative test
            if [ ${test_results[$i]} -ne 0 ]; then
                status="✅ PASS"
                test_type="(-)"
            else
                status="❌ FAIL"
                test_type="(-)"
            fi
        else
            # Positive test
            if [ ${test_results[$i]} -eq 0 ]; then
                status="✅ PASS"
            else
                status="❌ FAIL"
            fi
        fi
        
        echo "$status $test_type | ${test_names[$i]} | Exit code: ${test_results[$i]}"
    done
    
    echo ""
    if [ $failed_tests -eq 0 ]; then
        echo "🎉 All tests passed!"
        exit 0
    else
        echo "💥 $failed_tests test(s) failed!"
        exit 1
    fi
}

# Trap to ensure summary is printed even if script exits early
trap print_summary EXIT