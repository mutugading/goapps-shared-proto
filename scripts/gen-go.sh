#!/bin/bash
# Generate Go code from proto files
# Run from goapps-shared-proto directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROTO_DIR="$SCRIPT_DIR/.."
OUTPUT_DIR="${1:-../../goapps-backend/pb}"

echo "Generating Go code from proto files..."
echo "Proto directory: $PROTO_DIR"
echo "Output directory: $OUTPUT_DIR"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Generate Go code using protoc
cd "$PROTO_DIR"
protoc \
  --go_out="$OUTPUT_DIR" \
  --go_opt=paths=source_relative \
  --go-grpc_out="$OUTPUT_DIR" \
  --go-grpc_opt=paths=source_relative \
  costing/v1/*.proto

echo "✓ Go code generated successfully!"
echo "Generated files are in: $OUTPUT_DIR"
