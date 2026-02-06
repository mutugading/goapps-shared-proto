#!/bin/bash
# Generate all code from proto files (Go + TypeScript)
# Run from goapps-shared-proto directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo "Generating all code from proto files"
echo "============================================"
echo ""

# Run Go generation
echo ">>> Running Go generation..."
"$SCRIPT_DIR/gen-go.sh"

echo ""
echo ">>> Running TypeScript generation..."
"$SCRIPT_DIR/gen-ts.sh"

echo ""
echo "============================================"
echo "✓ All code generation completed!"
echo "============================================"
