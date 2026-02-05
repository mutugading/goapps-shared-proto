# GoApps Shared Proto

**Single source of truth** for Protocol Buffer definitions used across the GoApps Platform.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Repository Structure](#repository-structure)
3. [Quick Start](#quick-start)
4. [Proto Organization](#proto-organization)
5. [Services](#services)
6. [Common Types](#common-types)
7. [Code Generation](#code-generation)
8. [Buf Configuration](#buf-configuration)
9. [Validation Rules](#validation-rules)
10. [REST API Mapping](#rest-api-mapping)
11. [CI/CD Pipeline](#cicd-pipeline)
12. [Breaking Changes](#breaking-changes)
13. [Related Documentation](#related-documentation)

---

## Overview

This repository contains all Protocol Buffer (`.proto`) definitions for the GoApps microservices ecosystem. It serves as the single source of truth for API contracts between:

- **Backend Services** (Go gRPC servers)
- **Frontend Application** (Next.js with gRPC client)
- **API Documentation** (OpenAPI/Swagger)

### GoApps Ecosystem

```
goapps/
├── goapps-shared-proto/   # 📝 Proto definitions (this repo)
├── goapps-backend/        # 🖥️  Backend microservices
├── goapps-frontend/       # 🌐 Frontend application
└── goapps-infra/          # 🔧 Infrastructure as Code
```

### Generated Outputs

| Target | Output Directory | Plugin |
|--------|-----------------|--------|
| Go Structs | `goapps-backend/gen/` | protocolbuffers/go |
| gRPC Stubs | `goapps-backend/gen/` | grpc/go |
| REST Gateway | `goapps-backend/gen/` | grpc-ecosystem/gateway |
| OpenAPI Spec | `goapps-backend/gen/openapi/` | grpc-ecosystem/openapiv2 |

---

## Repository Structure

```
goapps-shared-proto/
│
├── 📁 common/                    # Shared types across services
│   └── v1/
│       └── common.proto          # BaseResponse, Pagination, AuditInfo
│
├── 📁 finance/                   # Finance domain protos
│   └── v1/
│       └── uom.proto             # UOM service (CRUD, Import, Export)
│
├── 📁 iam/                       # IAM domain (future)
│   └── v1/
│       └── ...                   # User, Role, Permission
│
├── 📁 scripts/
│   ├── gen-go.sh                 # Generate Go code
│   └── gen-ts.sh                 # Generate TypeScript types
│
├── 📁 .github/
│   └── workflows/
│       └── ci.yml                # Lint, breaking check, auto-generate
│
├── buf.yaml                      # Buf module configuration
├── buf.gen.yaml                  # Code generation config
├── buf.lock                      # Dependency lock file
├── README.md                     # This file
├── RULES.md                      # Development conventions
├── CONTRIBUTING.md               # Contribution guide
└── LICENSE                       # Proprietary license
```

---

## Quick Start

### Prerequisites

- **Buf CLI** - [Install](https://buf.build/docs/installation)
- **Go 1.24+** - For generated code (optional)

### Install Buf

```bash
# macOS
brew install bufbuild/buf/buf

# Linux
BIN="/usr/local/bin" && \
VERSION="1.47.2" && \
curl -sSL \
  "https://github.com/bufbuild/buf/releases/download/v${VERSION}/buf-$(uname -s)-$(uname -m)" \
  -o "${BIN}/buf" && \
chmod +x "${BIN}/buf"

# Verify installation
buf --version
```

### Clone and Setup

```bash
# Clone repository
git clone https://github.com/mutugading/goapps-shared-proto.git
cd goapps-shared-proto

# Update dependencies
buf dep update

# Lint proto files
buf lint

# Format proto files
buf format -w
```

---

## Proto Organization

### Package Naming

```
<domain>/<version>/<service>.proto
```

| Pattern | Example |
|---------|---------|
| `{domain}/v{n}/` | `finance/v1/`, `iam/v1/` |
| `common/v{n}/` | `common/v1/` (shared types) |

### Versioning Strategy

| Version | Description | Breaking Changes |
|---------|-------------|------------------|
| `v1` | Initial stable version | Not allowed |
| `v2` | Major revision | Allowed (parallel support) |
| `v1alpha1` | Experimental | Allowed anytime |
| `v1beta1` | Pre-release | Discouraged |

---

## Services

### Finance Module

#### UOMService

Manages Units of Measure (UOM) master data.

| Method | Description | REST Endpoint |
|--------|-------------|---------------|
| `CreateUOM` | Create new UOM | `POST /api/v1/finance/uoms` |
| `GetUOM` | Get UOM by ID | `GET /api/v1/finance/uoms/{uom_id}` |
| `UpdateUOM` | Update UOM | `PUT /api/v1/finance/uoms/{uom_id}` |
| `DeleteUOM` | Soft delete UOM | `DELETE /api/v1/finance/uoms/{uom_id}` |
| `ListUOMs` | List with search/filter | `GET /api/v1/finance/uoms` |
| `ExportUOMs` | Export to Excel | `GET /api/v1/finance/uoms/export` |
| `ImportUOMs` | Import from Excel | `POST /api/v1/finance/uoms/import` |
| `DownloadTemplate` | Get import template | `GET /api/v1/finance/uoms/template` |

**Proto file**: `finance/v1/uom.proto`

#### UOM Message

```protobuf
message UOM {
  string uom_id = 1;          // UUID
  string uom_code = 2;        // e.g., "KG", "MTR", "PCS"
  string uom_name = 3;        // e.g., "Kilogram", "Meter"
  UOMCategory uom_category = 4;  // WEIGHT, LENGTH, VOLUME, QUANTITY
  string description = 5;
  bool is_active = 6;
  common.v1.AuditInfo audit = 7;
}
```

---

## Common Types

Located in `common/v1/common.proto`:

### BaseResponse

Standard response wrapper for all API responses.

```protobuf
message BaseResponse {
  repeated ValidationError validation_errors = 1;
  string status_code = 2;     // "200", "400", "404", "500"
  bool is_success = 3;
  string message = 4;
}
```

### PaginationRequest / PaginationResponse

```protobuf
message PaginationRequest {
  int32 page = 1;             // 1-indexed
  int32 page_size = 2;
}

message PaginationResponse {
  int32 current_page = 1;
  int32 page_size = 2;
  int64 total_items = 3;
  int32 total_pages = 4;
}
```

### AuditInfo

Audit trail for all entities.

```protobuf
message AuditInfo {
  string created_at = 1;      // ISO 8601
  string created_by = 2;
  string updated_at = 3;
  string updated_by = 4;
}
```

---

## Code Generation

### Generate All (Go + OpenAPI)

```bash
# From goapps-shared-proto directory
./scripts/gen-go.sh
```

This script:
1. Updates buf dependencies
2. Formats proto files
3. Lints proto files
4. Generates code to `goapps-backend/gen/`
5. Runs `go mod tidy`

### Generate TypeScript (Optional)

```bash
./scripts/gen-ts.sh
```

Or manually with proto-loader:

```bash
cd ../goapps-frontend
npx proto-loader-gen-types \
  --longs=String \
  --enums=String \
  --defaults \
  --oneofs \
  --grpcLib=@grpc/grpc-js \
  --outDir=src/lib/grpc/generated \
  ../goapps-shared-proto/**/*.proto
```

### Generated File Structure

```
goapps-backend/gen/
├── common/
│   └── v1/
│       └── common.pb.go
├── finance/
│   └── v1/
│       ├── uom.pb.go           # Messages
│       ├── uom_grpc.pb.go      # gRPC service
│       └── uom.pb.gw.go        # REST gateway
├── openapi/
│   └── finance/
│       └── v1/
│           └── uom.swagger.json
├── go.mod
└── go.sum
```

---

## Buf Configuration

### buf.yaml

```yaml
version: v2
modules:
  - path: .
    name: buf.build/goapps/shared-proto
breaking:
  use:
    - FILE                    # Breaking change detection strategy
lint:
  use:
    - STANDARD                # Standard lint rules
  except:
    - PACKAGE_VERSION_SUFFIX  # Allow finance/v1 instead of finance.v1
deps:
  - buf.build/googleapis/googleapis      # google/api/annotations.proto
  - buf.build/bufbuild/protovalidate     # buf/validate/validate.proto
```

### buf.gen.yaml

```yaml
version: v2
managed:
  enabled: true
  override:
    - file_option: go_package_prefix
      value: github.com/mutugading/goapps-backend/gen
      path: .
plugins:
  # Go protobuf structs
  - remote: buf.build/protocolbuffers/go
    out: ../goapps-backend/gen
    opt: paths=source_relative
  
  # gRPC service stubs
  - remote: buf.build/grpc/go
    out: ../goapps-backend/gen
    opt: paths=source_relative
  
  # gRPC-Gateway for REST API
  - remote: buf.build/grpc-ecosystem/gateway
    out: ../goapps-backend/gen
    opt: paths=source_relative
  
  # OpenAPI/Swagger documentation
  - remote: buf.build/grpc-ecosystem/openapiv2
    out: ../goapps-backend/gen/openapi

inputs:
  - directory: .
    paths:
      - common
      - finance
```

---

## Validation Rules

Using [buf/validate](https://buf.build/bufbuild/protovalidate):

### String Validation

```protobuf
import "buf/validate/validate.proto";

message CreateUOMRequest {
  // Required, 1-20 chars, uppercase alphanumeric
  string uom_code = 1 [(buf.validate.field).string = {
    min_len: 1
    max_len: 20
    pattern: "^[A-Z][A-Z0-9_]*$"
  }];
  
  // Required, 1-100 chars
  string uom_name = 2 [(buf.validate.field).string = {
    min_len: 1
    max_len: 100
  }];
}
```

### UUID Validation

```protobuf
string uom_id = 1 [(buf.validate.field).string.uuid = true];
```

### Enum Validation

```protobuf
// Cannot be UNSPECIFIED (0)
UOMCategory uom_category = 3 [(buf.validate.field).enum = {
  not_in: [0]
}];
```

### Numeric Validation

```protobuf
// Page number: minimum 1
int32 page = 1 [(buf.validate.field).int32.gte = 1];

// Page size: 1-100
int32 page_size = 2 [(buf.validate.field).int32 = {
  gte: 1
  lte: 100
}];
```

### Bytes Validation

```protobuf
// File upload: 1 byte to 10MB
bytes file_content = 1 [(buf.validate.field).bytes = {
  min_len: 1
  max_len: 10485760
}];
```

---

## REST API Mapping

Using [google/api/annotations.proto](https://buf.build/googleapis/googleapis):

### CRUD Mapping

```protobuf
import "google/api/annotations.proto";

service UOMService {
  // Create: POST with body
  rpc CreateUOM(CreateUOMRequest) returns (CreateUOMResponse) {
    option (google.api.http) = {
      post: "/api/v1/finance/uoms"
      body: "*"
    };
  }
  
  // Read: GET with path parameter
  rpc GetUOM(GetUOMRequest) returns (GetUOMResponse) {
    option (google.api.http) = {
      get: "/api/v1/finance/uoms/{uom_id}"
    };
  }
  
  // Update: PUT with path parameter and body
  rpc UpdateUOM(UpdateUOMRequest) returns (UpdateUOMResponse) {
    option (google.api.http) = {
      put: "/api/v1/finance/uoms/{uom_id}"
      body: "*"
    };
  }
  
  // Delete: DELETE with path parameter
  rpc DeleteUOM(DeleteUOMRequest) returns (DeleteUOMResponse) {
    option (google.api.http) = {
      delete: "/api/v1/finance/uoms/{uom_id}"
    };
  }
  
  // List: GET with query parameters
  rpc ListUOMs(ListUOMsRequest) returns (ListUOMsResponse) {
    option (google.api.http) = {
      get: "/api/v1/finance/uoms"
    };
  }
}
```

### Query Parameter Mapping

For `GET /api/v1/finance/uoms?page=1&page_size=10&search=kg`:

```protobuf
message ListUOMsRequest {
  int32 page = 1;        // ?page=1
  int32 page_size = 2;   // ?page_size=10
  string search = 3;     // ?search=kg
  UOMCategory category = 4;  // ?category=WEIGHT
}
```

---

## CI/CD Pipeline

### Workflow Triggers

| Event | Jobs |
|-------|------|
| Push to `main` | Lint → Breaking Check → Generate |
| Pull Request | Lint → Breaking Check |

### Jobs

#### Lint & Breaking Changes

```yaml
- name: Lint proto files
  run: buf lint

- name: Check breaking changes
  run: buf breaking --against 'https://github.com/mutugading/goapps-shared-proto.git#branch=main'
```

#### Auto-Generate (main only)

On push to main, automatically:
1. Generates code
2. Commits to `goapps-backend` repo
3. Creates commit: `chore(proto): regenerate from shared-proto`

---

## Breaking Changes

### What is a Breaking Change?

| Change Type | Breaking? | Example |
|-------------|-----------|---------|
| Remove field | ✅ Yes | Removing `description` field |
| Rename field | ✅ Yes | `uom_code` → `code` |
| Change field number | ✅ Yes | `string name = 2` → `string name = 3` |
| Change field type | ✅ Yes | `string id` → `int64 id` |
| Add required validation | ✅ Yes | Adding `min_len: 1` |
| Add field | ❌ No | Adding optional `notes` field |
| Add enum value | ❌ No | Adding `UOM_CATEGORY_AREA` |
| Add RPC method | ❌ No | Adding `BulkDeleteUOMs` |

### How to Handle Breaking Changes

1. **Option A: New Version**
   ```
   finance/v2/uom.proto  # New version with breaking changes
   finance/v1/uom.proto  # Keep v1 for backward compatibility
   ```

2. **Option B: Deprecate and Add**
   ```protobuf
   message UOM {
     reserved 5;              // Reserved old field number
     reserved "old_field";    // Reserved old field name
     string new_field = 6;    // New field
   }
   ```

### Checking Locally

```bash
# Check against main branch
buf breaking --against '.git#branch=main'

# Check against specific commit
buf breaking --against '.git#ref=abc123'
```

---

## Related Documentation

| Document | Path | Description |
|----------|------|-------------|
| Development Rules | [RULES.md](./RULES.md) | Proto conventions |
| Contributing Guide | [CONTRIBUTING.md](./CONTRIBUTING.md) | How to contribute |
| License | [LICENSE](./LICENSE) | Proprietary license |

### External Resources

- [Buf Documentation](https://buf.build/docs)
- [Protocol Buffers](https://protobuf.dev)
- [gRPC Documentation](https://grpc.io/docs)
- [gRPC-Gateway](https://grpc-ecosystem.github.io/grpc-gateway)
- [Protovalidate](https://github.com/bufbuild/protovalidate)
- [Google API Guidelines](https://google.aip.dev)

---

## Support & Contact

- **Team**: GoApps Platform
- **Organization**: PT Mutu Gading Tekstil
- **Repository Issues**: [GitHub Issues](https://github.com/mutugading/goapps-shared-proto/issues)

---

## License

This project is proprietary software. See the [LICENSE](./LICENSE) file for details.

**© 2024-2026 PT Mutu Gading Tekstil. All Rights Reserved.**
