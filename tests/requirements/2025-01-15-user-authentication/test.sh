#!/usr/bin/env bash
# test.sh - Run all tests for this requirement
#
# Usage:
#   ./test.sh              # Run all tests
#   ./test.sh unit         # Run only unit tests
#   ./test.sh integration  # Run only integration tests
#   ./test.sh verbose      # Run with detailed output
#   ./test.sh help         # Show help

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REQUIREMENT_DIR="$(basename "$SCRIPT_DIR")"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Test results array
declare -a FAILED_TESTS=()
declare -a PASSED_CATEGORIES=()

# Output functions
print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Requirement Test Suite: ${REQUIREMENT_DIR}${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_section() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Help function
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Run all tests for the '${REQUIREMENT_DIR}' requirement.

OPTIONS:
    unit            Run only unit tests (tests in unit/ directory)
    integration     Run only integration tests (tests in integration/ directory)
    verbose         Show detailed test output
    help            Show this help message

EXAMPLES:
    $0                      # Run all tests
    $0 unit                 # Run only unit tests
    $0 integration verbose  # Run integration tests with detailed output

EOF
    exit 0
}

# Detect test framework
detect_test_framework() {
    if [ -f "package.json" ]; then
        if grep -q '"vitest"' package.json 2>/dev/null || \
           grep -q '"test":.*vitest' package.json 2>/dev/null; then
            echo "vitest"
        elif grep -q '"jest"' package.json 2>/dev/null || \
             grep -q '"test":.*jest' package.json 2>/dev/null; then
            echo "jest"
        elif grep -q '"mocha"' package.json 2>/dev/null || \
             grep -q '"test":.*mocha' package.json 2>/dev/null; then
            echo "mocha"
        else
            echo "npm"
        fi
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
        echo "pytest"
    elif [ -f "Cargo.toml" ]; then
        echo "cargo"
    else
        echo "unknown"
    fi
}

# Get test command for framework
get_test_command() {
    local framework=$1
    local test_file=$2
    local verbose=$3

    case $framework in
        vitest)
            if [ "$verbose" = "true" ]; then
                echo "npx vitest run $test_file --reporter=verbose"
            else
                echo "npx vitest run $test_file --reporter=dot"
            fi
            ;;
        jest)
            if [ "$verbose" = "true" ]; then
                echo "npx jest $test_file --verbose"
            else
                echo "npx jest $test_file"
            fi
            ;;
        mocha)
            if [ "$verbose" = "true" ]; then
                echo "npx mocha $test_file --reporter spec"
            else
                echo "npx mocha $test_file --reporter dot"
            fi
            ;;
        go)
            echo "go test $test_file -v"
            ;;
        pytest)
            if [ "$verbose" = "true" ]; then
                echo "pytest $test_file -v"
            else
                echo "pytest $test_file -q"
            fi
            ;;
        cargo)
            if [ "$verbose" = "true" ]; then
                echo "cargo test --test-flags='$test_file' -- --nocapture"
            else
                echo "cargo test --test-flags='$test_file'"
            fi
            ;;
        npm)
            echo "npm test -- $test_file"
            ;;
        *)
            echo "echo 'Unknown test framework' && exit 1"
            ;;
    esac
}

# Run tests for a directory
run_tests_in_directory() {
    local test_type=$1  # "unit" or "integration"
    local verbose=$2
    local dir_path="${SCRIPT_DIR}/${test_type}"

    # Check if directory exists
    if [ ! -d "$dir_path" ]; then
        print_warning "No ${test_type} tests directory found"
        return
    fi

    # Find test files
    local test_files=()
    case $(detect_test_framework) in
        vitest|jest|mocha)
            test_files=($(find "$dir_path" -type f -name "*.test.ts" -o -name "*.test.js" -o -name "*.spec.ts" -o -name "*.spec.js" 2>/dev/null))
            ;;
        go)
            test_files=($(find "$dir_path" -type f -name "*_test.go" 2>/dev/null))
            ;;
        pytest)
            test_files=($(find "$dir_path" -type f -name "test_*.py" 2>/dev/null))
            ;;
        cargo)
            test_files=($(find "$dir_path" -type f -name "*test*.rs" 2>/dev/null))
            ;;
        *)
            print_warning "Unknown test framework, searching for common patterns"
            test_files=($(find "$dir_path" -type f \( -name "*.test.*" -o -name "*_test.go" -o -name "test_*.py" \) 2>/dev/null))
            ;;
    esac

    # Check if any test files found
    if [ ${#test_files[@]} -eq 0 ]; then
        print_warning "No test files found in ${test_type}/ directory"
        return
    fi

    print_section "${test_type^} Tests (${#test_files[@]} files)"

    # Detect test framework (from project root)
    local framework
    if [ -f "$SCRIPT_DIR/../../package.json" ]; then
        framework=$(detect_test_framework)
    elif [ -f "$SCRIPT_DIR/../../go.mod" ]; then
        framework="go"
    elif [ -f "$SCRIPT_DIR/../../requirements.txt" ]; then
        framework="pytest"
    else
        framework=$(detect_test_framework)
    fi

    print_info "Test framework: ${framework}"
    echo ""

    # Run each test file
    for test_file in "${test_files[@]}"; do
        local relative_path="${test_file#$SCRIPT_DIR/}"
        local test_name=$(basename "$test_file")

        echo -e "${BLUE}Running:${NC} $relative_path"

        # Get test command
        local cmd=$(get_test_command "$framework" "$test_file" "$verbose")

        # Change to project root for running tests
        local project_root="$SCRIPT_DIR/../../"
        cd "$project_root" || { print_error "Cannot cd to project root"; exit 1; }

        # Run test and capture output
        local test_output
        local test_exit_code=0

        if test_output=$(eval "$cmd" 2>&1); then
            test_exit_code=0
        else
            test_exit_code=$?
        fi

        # Parse results
        if [ $test_exit_code -eq 0 ]; then
            print_success "$test_name - PASSED"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            PASSED_CATEGORIES+=("$test_type")

            # Try to extract test count
            local test_count=$(echo "$test_output" | grep -oE '[0-9]+\s+passing' | grep -oE '[0-9]+' || echo "1")
            TOTAL_TESTS=$((TOTAL_TESTS + test_count))
        else
            print_error "$test_name - FAILED"
            FAILED_TESTS+=("$relative_path")
            FAILED_TESTS+=("$test_output")
            FAILED_TESTS+=("---")
            FAILED_TESTS=$((FAILED_TESTS + 1))

            # Try to extract test count
            local test_count=$(echo "$test_output" | grep -oE '[0-9]+\s+failing' | grep -oE '[0-9]+' || echo "1")
            TOTAL_TESTS=$((TOTAL_TESTS + test_count))
        fi

        echo ""
    done
}

# Print summary
print_summary() {
    print_section "Test Summary"

    echo "Total Tests:  $TOTAL_TESTS"
    echo -e "${GREEN}Passed:       $PASSED_TESTS${NC}"

    if [ $FAILED_TESTS -gt 0 ]; then
        echo -e "${RED}Failed:       $FAILED_TESTS${NC}"
    else
        echo "Failed:       $FAILED_TESTS"
    fi

    echo ""

    # Print failed tests details
    if [ $FAILED_TESTS -gt 0 ]; then
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}  Failed Tests Details${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""

        local i=0
        while [ $i -lt ${#FAILED_TESTS[@]} ]; do
            local item="${FAILED_TESTS[$i]}"
            if [[ "$item" == *.test.* ]] || [[ "$item" == *_test.go ]] || [[ "$item" == test_*.py ]]; then
                echo -e "${RED}Failed File:${NC} $item"
                echo ""
            elif [ "$item" == "---" ]; then
                echo ""
                echo "......................................................................"
                echo ""
            else
                echo "$item"
            fi
            i=$((i + 1))
        done
    fi

    # Print category breakdown
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Category Breakdown${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Count passed tests per category
    local unit_count=0
    local integration_count=0
    for category in "${PASSED_CATEGORIES[@]}"; do
        if [ "$category" == "unit" ]; then
            unit_count=$((unit_count + 1))
        elif [ "$category" == "integration" ]; then
            integration_count=$((integration_count + 1))
        fi
    done

    echo "Unit Tests:       $unit_count passed"
    echo "Integration Tests: $integration_count passed"
    echo ""

    # Final status
    print_section "Final Status"

    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        echo ""
        return 1
    fi
}

# Main execution
main() {
    local run_unit=false
    local run_integration=false
    local verbose=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            unit)
                run_unit=true
                shift
                ;;
            integration)
                run_integration=true
                shift
                ;;
            verbose)
                verbose=true
                shift
                ;;
            help|--help|-h)
                show_help
                ;;
            *)
                echo "Unknown option: $1"
                echo "Run '$0 help' for usage"
                exit 1
                ;;
        esac
    done

    # If no specific type requested, run both
    if [ "$run_unit" = false ] && [ "$run_integration" = false ]; then
        run_unit=true
        run_integration=true
    fi

    # Print header
    print_header

    # Get start time
    local start_time=$(date +%s)

    # Run tests
    if [ "$run_unit" = true ]; then
        run_tests_in_directory "unit" "$verbose"
    fi

    if [ "$run_integration" = true ]; then
        run_tests_in_directory "integration" "$verbose"
    fi

    # Get end time
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Print summary
    print_summary

    echo "Time taken: ${duration}s"
    echo ""

    # Exit with appropriate code
    if [ $FAILED_TESTS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Run main
main "$@"
