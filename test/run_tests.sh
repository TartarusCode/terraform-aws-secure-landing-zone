#!/bin/bash
set -euo pipefail

echo "Terraform Secure Landing Zone Test Suite"
echo "========================================="
echo ""

cd "$(dirname "$0")"

echo "Setting up test environment..."
go mod tidy
go mod verify

echo ""
echo "Compiling test suite..."
go build ./...
go vet ./...

echo ""
echo "Running tests..."
echo ""

TEST_COUNT=$(go test -list '.' ./... 2>/dev/null | grep -c '^Test' || echo "0")
echo "Found ${TEST_COUNT} tests to run"
echo ""

go test -v -timeout 30m -count=1 ./...

echo ""
echo "All tests completed!"
echo ""
echo "Tips:"
echo "  Run specific test:    go test -v -run TestName ./..."
echo "  Run with coverage:    go test -v -cover ./..."
echo "  Compile-only check:   go build ./... && go vet ./..."
