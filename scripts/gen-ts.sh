#!/bin/bash
# Generate TypeScript types from proto files
# Run from goapps-shared-proto directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROTO_DIR="$SCRIPT_DIR/.."
OUTPUT_DIR="${1:-../../goapps-frontend/src/lib/grpc/generated}"

echo "Generating TypeScript types from proto files..."
echo "Proto directory: $PROTO_DIR"
echo "Output directory: $OUTPUT_DIR"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Generate TypeScript types using proto-loader-gen-types
cd "$PROTO_DIR"
npx proto-loader-gen-types \
  --longs=String \
  --enums=String \
  --defaults \
  --oneofs \
  --grpcLib=@grpc/grpc-js \
  --outDir="$OUTPUT_DIR" \
  costing/v1/*.proto

echo "✓ TypeScript types generated successfully!"
echo "Generated files are in: $OUTPUT_DIR"
