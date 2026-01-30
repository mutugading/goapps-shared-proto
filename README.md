# Go Apps Shared Proto

Single source of truth for Protocol Buffer definitions.

## Structure

```
goapps-shared-proto/
├── costing/v1/         # Costing service protos
│   ├── uom.proto
│   ├── parameter.proto
│   └── common.proto
├── iam/v1/             # IAM service protos (future)
├── scripts/
│   ├── gen-go.sh       # Generate Go code for backend
│   └── gen-ts.sh       # Generate TypeScript for frontend
└── buf.yaml            # Buf configuration
```

## Generate Code

### For Backend (Go)
```bash
./scripts/gen-go.sh
```

### For Frontend (TypeScript)
```bash
./scripts/gen-ts.sh
```

Or using proto-loader:
```bash
cd ../goapps-frontend
npx proto-loader-gen-types --longs=String --enums=String --defaults --oneofs --grpcLib=@grpc/grpc-js --outDir=src/lib/grpc/generated ../goapps-shared-proto/**/*.proto
```
