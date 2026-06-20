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
echo "Step 5: Stripping _unknownFields from service definitions..."
# _unknownFields contain binary-encoded google.api.http annotations (HTTP paths).
# These are not needed by the BFF gRPC client and inflate file sizes significantly.
python3 - "$OUTPUT_DIR" << 'PYEOF'
import sys, os

output_dir = sys.argv[1]
total_removed = 0

for root, dirs, files in os.walk(output_dir):
    for fname in files:
        if not fname.endswith('.ts'):
            continue
        path = os.path.join(root, fname)
        with open(path, 'r') as f:
            lines = f.readlines()

        out = []
        i = 0
        removed = 0
        while i < len(lines):
            line = lines[i]
            # Detect start of: options: {
            stripped = line.rstrip()
            if stripped.endswith('options: {') and i + 1 < len(lines):
                next_stripped = lines[i + 1].strip()
                if next_stripped.startswith('_unknownFields:'):
                    # Replace the entire options: { _unknownFields: {...}, } block with options: {}
                    indent = len(line) - len(line.lstrip())
                    out.append(' ' * indent + 'options: {},\n')
                    # Skip lines until we find the closing brace matching 'options: {'
                    depth = 1
                    i += 1
                    while i < len(lines) and depth > 0:
                        for ch in lines[i]:
                            if ch == '{':
                                depth += 1
                            elif ch == '}':
                                depth -= 1
                        removed += 1
                        i += 1
                    continue
            out.append(line)
            i += 1

        if removed > 0:
            with open(path, 'w') as f:
                f.writelines(out)
            total_removed += removed
            print(f"  {fname}: removed {removed} lines of _unknownFields")

print(f"  Total lines removed: {total_removed}")
PYEOF

echo ""
echo "============================================"
echo "✓ TypeScript types generated successfully!"
echo "============================================"
echo "Generated files:"
find "$OUTPUT_DIR" -name "*.ts" -type f | head -20
