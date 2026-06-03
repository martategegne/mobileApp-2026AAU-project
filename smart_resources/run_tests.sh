#!/bin/bash
# Test Execution Script for Smart Resources App
# This script runs all tests with proper configuration

set -e

echo "==============================================="
echo "Smart Resources - Test Execution Script"
echo "==============================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse command line arguments
TEST_TYPE="${1:-all}"
VERBOSE="${2:-false}"

# Function to run tests
run_tests() {
    local test_type=$1
    local verbose_flag=$2
    
    case $test_type in
        all)
            echo -e "${BLUE}Running ALL tests...${NC}"
            flutter test ${verbose_flag:+--verbose} --coverage
            ;;
        unit)
            echo -e "${BLUE}Running UNIT tests...${NC}"
            flutter test test/unit/ ${verbose_flag:+--verbose}
            ;;
        widget)
            echo -e "${BLUE}Running WIDGET tests...${NC}"
            flutter test test/widget/ ${verbose_flag:+--verbose}
            ;;
        riverpod)
            echo -e "${BLUE}Running RIVERPOD tests...${NC}"
            flutter test test/riverpod/ ${verbose_flag:+--verbose}
            ;;
        integration)
            echo -e "${BLUE}Running INTEGRATION tests...${NC}"
            flutter test integration_test/ ${verbose_flag:+--verbose}
            ;;
        auth)
            echo -e "${BLUE}Running AUTH tests...${NC}"
            flutter test -k "Auth" ${verbose_flag:+--verbose}
            ;;
        resources)
            echo -e "${BLUE}Running RESOURCE tests...${NC}"
            flutter test -k "Resource" ${verbose_flag:+--verbose}
            ;;
        *)
            echo -e "${YELLOW}Unknown test type: $test_type${NC}"
            echo "Available options: all, unit, widget, riverpod, integration, auth, resources"
            exit 1
            ;;
    esac
}

# Function to generate coverage report
generate_coverage() {
    echo ""
    echo -e "${BLUE}Generating coverage report...${NC}"
    
    if command -v lcov &> /dev/null; then
        lcov --list coverage/lcov.info
        echo -e "${GREEN}Coverage report generated successfully!${NC}"
    else
        echo -e "${YELLOW}lcov not found. Install it to generate detailed coverage reports.${NC}"
        echo "Coverage data available at: coverage/lcov.info"
    fi
}

# Function to display usage
show_usage() {
    echo "Usage: ./run_tests.sh [TEST_TYPE] [--verbose]"
    echo ""
    echo "TEST_TYPE Options:"
    echo "  all          - Run all tests (default)"
    echo "  unit         - Run unit tests only"
    echo "  widget       - Run widget tests only"
    echo "  riverpod     - Run riverpod tests only"
    echo "  integration  - Run integration tests only"
    echo "  auth         - Run authentication tests"
    echo "  resources    - Run resource tests"
    echo ""
    echo "Examples:"
    echo "  ./run_tests.sh                    # Run all tests"
    echo "  ./run_tests.sh unit               # Run unit tests"
    echo "  ./run_tests.sh widget --verbose   # Run widget tests with verbose output"
}

# Check if help is requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# Check Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${BLUE}Flutter version:${NC}"
flutter --version
echo ""

# Clean and prepare
echo -e "${BLUE}Cleaning build artifacts...${NC}"
flutter clean

echo -e "${BLUE}Getting dependencies...${NC}"
flutter pub get

echo ""

# Run tests
if [[ "$VERBOSE" == "--verbose" ]]; then
    run_tests "$TEST_TYPE" "true"
else
    run_tests "$TEST_TYPE" "false"
fi

# Generate coverage if running all tests
if [[ "$TEST_TYPE" == "all" ]]; then
    generate_coverage
fi

echo ""
echo -e "${GREEN}✓ Test execution completed successfully!${NC}"
echo "==============================================="
