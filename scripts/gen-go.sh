#!/bin/bash
# Generate code from proto files using Buf
# Run from goapps-shared-proto directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROTO_DIR="$SCRIPT_DIR/.."

echo "🔧 Generating code from proto files..."
echo "Proto directory: $PROTO_DIR"

cd "$PROTO_DIR"

# Update buf dependencies
echo "📦 Updating buf dependencies..."
buf dep update

# Format proto files
echo "📝 Formatting proto files..."
buf format -w

# Lint proto files
echo "🔍 Linting proto files..."
buf lint

# Generate code
echo "⚙️  Generating code..."
buf generate

# Update Go module dependencies
echo "📦 Running go mod tidy in gen directory..."
cd ../goapps-backend/gen
go mod tidy

echo "✅ Code generation completed successfully!"
echo ""
echo "Generated files:"
echo "  - Go code: ../goapps-backend/gen/"
echo "  - OpenAPI spec: ../goapps-backend/gen/openapi/api.swagger.json"

