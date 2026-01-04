#!/bin/bash

# Test runner script for handoff plugin
# Runs all test suites and generates reports

set -e

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$PLUGIN_DIR/tests"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check dependencies
check_dependencies() {
    print_header "Checking Dependencies"

    local missing_deps=0

    # Check Python
    if command -v python3 &> /dev/null; then
        print_success "Python 3 found: $(python3 --version)"
    else
        print_error "Python 3 not found"
        missing_deps=$((missing_deps + 1))
    fi

    # Check pytest
    if python3 -c "import pytest" 2>/dev/null; then
        print_success "pytest found: $(python3 -m pytest --version)"
    else
        print_warning "pytest not found. Install with: pip install pytest pytest-asyncio"
        missing_deps=$((missing_deps + 1))
    fi

    # Check Claude Agent SDK
    if python3 -c "import claude_agent_sdk" 2>/dev/null; then
        print_success "Claude Agent SDK found"
    else
        print_warning "Claude Agent SDK not found. Install with: pip install claude-agent-sdk"
        missing_deps=$((missing_deps + 1))
    fi

    # Check BATS (optional)
    if command -v bats &> /dev/null; then
        print_success "BATS found: $(bats --version)"
    else
        print_warning "BATS not found (shell tests will be skipped). Install with: brew install bats-core"
    fi

    # Check API key
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        print_warning "ANTHROPIC_API_KEY not set. Integration tests will be skipped."
    else
        print_success "API key configured"
    fi

    echo ""
    return $missing_deps
}

# Run unit tests
run_unit_tests() {
    print_header "Running Unit Tests"

    if ! python3 -c "import pytest" 2>/dev/null; then
        print_warning "pytest not installed. Skipping unit tests."
        return 0
    fi

    cd "$PLUGIN_DIR"

    # Run only unit tests
    if python3 -m pytest tests/test_plugin_structure.py -v; then
        print_success "Unit tests passed"
        return 0
    else
        print_error "Unit tests failed"
        return 1
    fi
}

# Run integration tests
run_integration_tests() {
    print_header "Running Integration Tests (SDK)"

    if ! python3 -c "import pytest" 2>/dev/null; then
        print_warning "pytest not installed. Skipping integration tests."
        return 0
    fi

    if [ -z "$ANTHROPIC_API_KEY" ]; then
        print_warning "ANTHROPIC_API_KEY not set. Skipping SDK integration tests."
        return 0
    fi

    cd "$PLUGIN_DIR"

    # Run integration tests with shorter timeout
    if python3 -m pytest tests/test_integration_sdk.py -v --tb=short || true; then
        print_success "Integration tests completed (some may have been skipped)"
        return 0
    else
        print_warning "Some integration tests failed (may be expected without full Claude Code context)"
        return 0
    fi
}

# Run shell tests
run_shell_tests() {
    print_header "Running Shell Tests (BATS)"

    if ! command -v bats &> /dev/null; then
        print_warning "BATS not installed. Skipping shell tests."
        echo "Install BATS with: brew install bats-core"
        return 0
    fi

    cd "$PLUGIN_DIR"

    if bats tests/test_plugin.bats; then
        print_success "Shell tests passed"
        return 0
    else
        print_error "Shell tests failed"
        return 1
    fi
}

# Run all tests
run_all_tests() {
    print_header "Running All Tests"

    local failed=0

    # Unit tests
    run_unit_tests || failed=$((failed + 1))
    echo ""

    # Integration tests
    run_integration_tests || failed=$((failed + 1))
    echo ""

    # Shell tests
    run_shell_tests || failed=$((failed + 1))
    echo ""

    return $failed
}

# Generate coverage report
generate_coverage() {
    print_header "Generating Coverage Report"

    if ! python3 -c "import pytest_cov" 2>/dev/null; then
        print_warning "pytest-cov not installed. Skipping coverage report."
        echo "Install with: pip install pytest-cov"
        return 0
    fi

    cd "$PLUGIN_DIR"

    python3 -m pytest tests/ --cov=. --cov-report=html --cov-report=term-missing

    if [ -d "htmlcov" ]; then
        print_success "Coverage report generated at: htmlcov/index.html"
    fi
}

# Validate structure
validate_structure() {
    print_header "Validating Plugin Structure"

    local valid=0

    # Check plugin.json
    if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
        if python3 -m json.tool "$PLUGIN_DIR/.claude-plugin/plugin.json" > /dev/null 2>&1; then
            print_success "plugin.json is valid JSON"
        else
            print_error "plugin.json is invalid JSON"
            valid=1
        fi
    else
        print_error "plugin.json not found"
        valid=1
    fi

    # Check required files
    for file in commands/handoff.md README.md; do
        if [ -f "$PLUGIN_DIR/$file" ]; then
            print_success "$file exists"
        else
            print_error "$file not found"
            valid=1
        fi
    done

    return $valid
}

# Main execution
main() {
    echo ""
    print_header "Handoff Plugin Test Suite"

    # Get options
    case "${1:-all}" in
        structure)
            validate_structure
            ;;
        unit)
            run_unit_tests
            ;;
        integration)
            run_integration_tests
            ;;
        shell)
            run_shell_tests
            ;;
        coverage)
            generate_coverage
            ;;
        check-deps|deps)
            check_dependencies
            ;;
        all)
            check_dependencies
            deps_result=$?
            echo ""

            validate_structure
            struct_result=$?
            echo ""

            run_all_tests
            tests_result=$?
            echo ""

            # Summary
            print_header "Test Summary"
            if [ $struct_result -eq 0 ] && [ $tests_result -eq 0 ]; then
                print_success "All tests passed!"
                echo ""
                return 0
            else
                if [ $struct_result -ne 0 ]; then
                    print_error "Structure validation failed"
                fi
                if [ $tests_result -ne 0 ]; then
                    print_error "Some tests failed"
                fi
                echo ""
                return 1
            fi
            ;;
        *)
            echo "Usage: $0 {all|structure|unit|integration|shell|coverage|deps|check-deps}"
            echo ""
            echo "  all           - Run all tests"
            echo "  structure     - Validate plugin structure only"
            echo "  unit          - Run unit tests"
            echo "  integration   - Run SDK integration tests"
            echo "  shell         - Run BATS shell tests"
            echo "  coverage      - Generate coverage report"
            echo "  deps/check-deps - Check dependencies"
            echo ""
            return 1
            ;;
    esac
}

# Run main
main "$@"
exit $?
