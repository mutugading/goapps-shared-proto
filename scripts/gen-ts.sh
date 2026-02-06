#!/bin/bash
# Generate TypeScript types from proto files using ts-proto
# Run from goapps-shared-proto directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROTO_DIR="$SCRIPT_DIR/.."
FRONTEND_DIR="$PROTO_DIR/../goapps-frontend"
OUTPUT_DIR="$FRONTEND_DIR/src/types/generated"

echo "============================================"
echo "Generating TypeScript types from proto files"
echo "============================================"
echo "Proto directory: $PROTO_DIR"
echo "Output directory: $OUTPUT_DIR"
echo ""

# Check if ts-proto is installed in frontend
if [ ! -f "$FRONTEND_DIR/node_modules/.bin/protoc-gen-ts_proto" ]; then
    echo "Error: ts-proto not found in frontend node_modules"
    echo "Run 'npm install' in goapps-frontend first"
    exit 1
fi

# Add frontend node_modules/.bin to PATH for buf to find protoc-gen-ts_proto
export PATH="$FRONTEND_DIR/node_modules/.bin:$PATH"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Change to proto directory
cd "$PROTO_DIR"

echo "Step 1: Updating buf dependencies..."
buf dep update

echo ""
echo "Step 2: Formatting proto files..."
buf format -w

echo ""
echo "Step 3: Linting proto files..."
buf lint

echo ""
echo "Step 4: Generating TypeScript types..."
buf generate --template buf.gen.ts.yaml

echo ""
echo "============================================"
echo "✓ TypeScript types generated successfully!"
echo "============================================"
echo "Generated files:"
find "$OUTPUT_DIR" -name "*.ts" -type f | head -20
