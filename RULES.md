# Proto Development Rules

Guidelines and conventions for all developers working with `goapps-shared-proto`.

---

## 📋 Table of Contents

1. [Golden Rules](#golden-rules)
2. [File Organization](#file-organization)
3. [Naming Conventions](#naming-conventions)
4. [Message Design](#message-design)
5. [Field Numbering](#field-numbering)
6. [Validation Rules](#validation-rules)
7. [Service Design](#service-design)
8. [REST API Mapping](#rest-api-mapping)
9. [Documentation](#documentation)
10. [Breaking Changes](#breaking-changes)
11. [Git Workflow](#git-workflow)
12. [Review Checklist](#review-checklist)

---

## Golden Rules

> ⚠️ **Rules that MUST NOT be violated!**

### 1. Never Change Field Numbers

```protobuf
// ❌ WRONG - Changing field number is a breaking change
message UOM {
  string name = 3;  // Was string name = 2
}

// ✅ CORRECT - Add new field with new number
message UOM {
  string name = 2;
  string display_name = 3;  // New field
}
```

### 2. Never Remove Fields Without Reserving

```protobuf
// ❌ WRONG - Field can be reused accidentally
message UOM {
  string id = 1;
  // removed: string old_field = 2;
  string name = 3;
}

// ✅ CORRECT - Reserve removed field
message UOM {
  reserved 2;
  reserved "old_field";
  
  string id = 1;
  string name = 3;
}
```

### 3. Always Use Validation

```protobuf
// ❌ WRONG - No validation
message CreateUOMRequest {
  string code = 1;
  string name = 2;
}

// ✅ CORRECT - With protovalidate
message CreateUOMRequest {
  string code = 1 [(buf.validate.field).string = {
    min_len: 1
    max_len: 20
    pattern: "^[A-Z][A-Z0-9_]*$"
  }];
  
  string name = 2 [(buf.validate.field).string = {
    min_len: 1
    max_len: 100
  }];
}
```

### 4. Always Run Lint Before Commit

```bash
# ❌ WRONG - Commit without linting
git commit -m "feat: add new service"

# ✅ CORRECT - Lint first
buf lint
buf format -w
git commit -m "feat: add new service"
```

### 5. Never Skip Breaking Change Check

```bash
# Always check for breaking changes
buf breaking --against '.git#branch=main'
```

---

## File Organization

### Directory Structure

```
<domain>/<version>/<service>.proto
```

| Domain | Description | Example |
|--------|-------------|---------|
| `common` | Shared types | `common/v1/common.proto` |
| `finance` | Finance module | `finance/v1/uom.proto` |
| `iam` | Identity & Access | `iam/v1/user.proto` |
| `hr` | Human Resources | `hr/v1/employee.proto` |

### File Naming

| Type | Pattern | Example |
|------|---------|---------|
| Service proto | `<resource>.proto` | `uom.proto`, `user.proto` |
| Shared types | `common.proto` | `common/v1/common.proto` |
| Enums only | `<resource>_enums.proto` | `uom_enums.proto` |

---

## Naming Conventions

### Packages

```protobuf
// Pattern: <domain>.<version>
package finance.v1;
package common.v1;
package iam.v1;
```

### Messages

| Type | Convention | Example |
|------|------------|---------|
| Entity | PascalCase noun | `UOM`, `User`, `Employee` |
| Request | `<Method><Entity>Request` | `CreateUOMRequest` |
| Response | `<Method><Entity>Response` | `CreateUOMResponse` |
| Enum | PascalCase + `SCREAMING_SNAKE_CASE` values | `UOMCategory` |

### Fields

| Type | Convention | Example |
|------|------------|---------|
| Standard | `snake_case` | `uom_name`, `created_at` |
| ID fields | `<entity>_id` | `uom_id`, `user_id` |
| Boolean | `is_<condition>` or `has_<thing>` | `is_active`, `has_permission` |
| Timestamp | `<action>_at` | `created_at`, `deleted_at` |

### Enums

```protobuf
// Enum name: PascalCase
enum UOMCategory {
  // Values: ENUM_NAME_UPPER_SNAKE_CASE
  UOM_CATEGORY_UNSPECIFIED = 0;  // Always have UNSPECIFIED = 0
  UOM_CATEGORY_WEIGHT = 1;
  UOM_CATEGORY_LENGTH = 2;
  UOM_CATEGORY_VOLUME = 3;
}
```

### Services

```protobuf
// Pattern: <Entity>Service
service UOMService {}
service UserService {}
service OrderService {}
```

### RPC Methods

| Operation | Pattern | Example |
|-----------|---------|---------|
| Create | `Create<Entity>` | `CreateUOM` |
| Get one | `Get<Entity>` | `GetUOM` |
| Update | `Update<Entity>` | `UpdateUOM` |
| Delete | `Delete<Entity>` | `DeleteUOM` |
| List | `List<Entities>` | `ListUOMs` |
| Bulk create | `Batch<Entity>Create` | `BatchUOMCreate` |

---

## Message Design

### Entity Message

```protobuf
// Entity: Core data
message UOM {
  // Core fields: 1-15
  string uom_id = 1;
  string uom_code = 2;
  string uom_name = 3;
  UOMCategory uom_category = 4;
  string description = 5;
  bool is_active = 6;
  
  // Audit/metadata: 16-20
  common.v1.AuditInfo audit = 16;
}
```

### Request Message

```protobuf
// Create: Only required fields
message CreateUOMRequest {
  string uom_code = 1 [(buf.validate.field).string = {...}];
  string uom_name = 2 [(buf.validate.field).string = {...}];
  UOMCategory uom_category = 3;
  string description = 4;  // Optional
}

// Update: All fields optional
message UpdateUOMRequest {
  string uom_id = 1 [(buf.validate.field).string.uuid = true];
  optional string uom_name = 2;
  optional UOMCategory uom_category = 3;
  optional string description = 4;
  optional bool is_active = 5;
}

// Get: Only ID
message GetUOMRequest {
  string uom_id = 1 [(buf.validate.field).string.uuid = true];
}

// List: Pagination + filters
message ListUOMsRequest {
  int32 page = 1;
  int32 page_size = 2;
  string search = 3;
  UOMCategory category = 4;
  // ... more filters
}
```

### Response Message

```protobuf
// Single entity
message GetUOMResponse {
  common.v1.BaseResponse base = 1;
  UOM data = 2;
}

// List
message ListUOMsResponse {
  common.v1.BaseResponse base = 1;
  repeated UOM data = 2;
  common.v1.PaginationResponse pagination = 3;
}
```

---

## Field Numbering

### Reserved Ranges

| Range | Usage |
|-------|-------|
| 1-15 | Frequently accessed fields (1 byte) |
| 16-2047 | Normal fields (2 bytes) |
| 2048+ | Rarely used fields |
| 19000-19999 | Reserved by protobuf |

### Best Practices

```protobuf
message UOM {
  // Core fields: 1-15 (most accessed, 1-byte encoding)
  string uom_id = 1;
  string uom_code = 2;
  string uom_name = 3;
  bool is_active = 4;
  
  // Metadata: 16-20
  common.v1.AuditInfo audit = 16;
  
  // Relations: 21-30
  string category_id = 21;
  repeated string tag_ids = 22;
  
  // Reserved for removed fields
  reserved 10, 11;
  reserved "old_field", "deprecated_field";
}
```

---

## Validation Rules

### Common Patterns

```protobuf
import "buf/validate/validate.proto";

// Required string with length
string name = 1 [(buf.validate.field).string = {
  min_len: 1
  max_len: 100
}];

// UUID
string id = 1 [(buf.validate.field).string.uuid = true];

// Email
string email = 1 [(buf.validate.field).string.email = true];

// Pattern
string code = 1 [(buf.validate.field).string.pattern = "^[A-Z0-9]+$"];

// Enum not unspecified
Category category = 1 [(buf.validate.field).enum.not_in = [0]];

// Numeric range
int32 page = 1 [(buf.validate.field).int32.gte = 1];
int32 page_size = 2 [(buf.validate.field).int32 = {gte: 1, lte: 100}];

// Bytes size
bytes file = 1 [(buf.validate.field).bytes = {min_len: 1, max_len: 10485760}];
```

---

## Service Design

### CRUD Service

```protobuf
service UOMService {
  // Create
  rpc CreateUOM(CreateUOMRequest) returns (CreateUOMResponse);
  
  // Read
  rpc GetUOM(GetUOMRequest) returns (GetUOMResponse);
  rpc ListUOMs(ListUOMsRequest) returns (ListUOMsResponse);
  
  // Update
  rpc UpdateUOM(UpdateUOMRequest) returns (UpdateUOMResponse);
  
  // Delete
  rpc DeleteUOM(DeleteUOMRequest) returns (DeleteUOMResponse);
}
```

### Additional Operations

```protobuf
service UOMService {
  // CRUD methods...
  
  // Bulk operations
  rpc BatchCreateUOMs(BatchCreateUOMsRequest) returns (BatchCreateUOMsResponse);
  rpc BatchDeleteUOMs(BatchDeleteUOMsRequest) returns (BatchDeleteUOMsResponse);
  
  // Import/Export
  rpc ExportUOMs(ExportUOMsRequest) returns (ExportUOMsResponse);
  rpc ImportUOMs(ImportUOMsRequest) returns (ImportUOMsResponse);
  
  // Special operations
  rpc DownloadTemplate(DownloadTemplateRequest) returns (DownloadTemplateResponse);
}
```

---

## REST API Mapping

### HTTP Method Mapping

| gRPC Method | HTTP Method | URL Pattern |
|-------------|-------------|-------------|
| `Create*` | POST | `/api/v1/{service}/{resources}` |
| `Get*` | GET | `/api/v1/{service}/{resources}/{id}` |
| `List*` | GET | `/api/v1/{service}/{resources}` |
| `Update*` | PUT | `/api/v1/{service}/{resources}/{id}` |
| `Delete*` | DELETE | `/api/v1/{service}/{resources}/{id}` |

### Annotation Examples

```protobuf
import "google/api/annotations.proto";

service UOMService {
  rpc CreateUOM(CreateUOMRequest) returns (CreateUOMResponse) {
    option (google.api.http) = {
      post: "/api/v1/finance/uoms"
      body: "*"
    };
  }
  
  rpc GetUOM(GetUOMRequest) returns (GetUOMResponse) {
    option (google.api.http) = {
      get: "/api/v1/finance/uoms/{uom_id}"
    };
  }
  
  rpc ListUOMs(ListUOMsRequest) returns (ListUOMsResponse) {
    option (google.api.http) = {
      get: "/api/v1/finance/uoms"
      // Query params: ?page=1&page_size=10&search=kg
    };
  }
}
```

---

## Documentation

### Message Documentation

```protobuf
// UOM represents a Unit of Measure entity.
// Used for standardizing measurements across the system.
message UOM {
  // Unique identifier (UUID format).
  string uom_id = 1;
  
  // Unique code (e.g., "KG", "MTR", "PCS").
  // Immutable after creation.
  string uom_code = 2;
  
  // Display name (e.g., "Kilogram", "Meter", "Pieces").
  string uom_name = 3;
}
```

### Service Documentation

```protobuf
// UOMService provides CRUD operations for Unit of Measure master data.
// All methods require authentication.
service UOMService {
  // CreateUOM creates a new UOM.
  // Returns ALREADY_EXISTS if a UOM with the same code exists.
  rpc CreateUOM(CreateUOMRequest) returns (CreateUOMResponse);
  
  // GetUOM retrieves a UOM by ID.
  // Returns NOT_FOUND if the UOM does not exist.
  rpc GetUOM(GetUOMRequest) returns (GetUOMResponse);
}
```

### Enum Documentation

```protobuf
// UOMCategory represents the category of a unit of measure.
enum UOMCategory {
  // Default unspecified value - used as "no filter" in list requests.
  UOM_CATEGORY_UNSPECIFIED = 0;
  // Weight-based units (e.g., KG, GR, TON).
  UOM_CATEGORY_WEIGHT = 1;
  // Length-based units (e.g., MTR, CM, YARD).
  UOM_CATEGORY_LENGTH = 2;
}
```

---

## Breaking Changes

### Allowed Changes (Non-breaking)

- ✅ Add new message
- ✅ Add new field (with new field number)
- ✅ Add new enum value
- ✅ Add new RPC method
- ✅ Add new service
- ✅ Rename file (if package stays same)

### Forbidden Changes (Breaking)

- ❌ Remove field
- ❌ Rename field
- ❌ Change field number
- ❌ Change field type
- ❌ Remove RPC method
- ❌ Remove service
- ❌ Change package name
- ❌ Add required validation to existing field

### Handling Deprecated Fields

```protobuf
message UOM {
  reserved 5, 6;
  reserved "old_status", "legacy_code";
  
  // Deprecation notice in comment
  // Deprecated: Use uom_category instead.
  // Will be removed in v2.
  string category_string = 10 [deprecated = true];
}
```

---

## Git Workflow

### Branch Naming

```
feat/<service>/<description>
fix/<service>/<description>
refactor/<service>/<description>
```

Examples:
```
feat/finance/add-parameter-service
fix/common/pagination-validation
refactor/uom/simplify-enums
```

### Commit Messages

```bash
# Format: <type>(<scope>): <description>

# Features
feat(uom): add bulk delete RPC
feat(common): add DeletedInfo message

# Fixes
fix(uom): correct validation pattern
fix(pagination): allow page_size 0 for all

# Documentation
docs(uom): improve field comments
docs(readme): add validation examples

# Refactoring
refactor(common): split into multiple files
```

### Pre-commit Checklist

```bash
# 1. Format
buf format -w

# 2. Lint
buf lint

# 3. Breaking check
buf breaking --against '.git#branch=main'

# 4. Generate (optional, to verify)
buf generate --dry-run
```

---

## Review Checklist

### Message Review

- [ ] Field names follow snake_case
- [ ] Field numbers are unique and in logical order
- [ ] Required fields have validation
- [ ] Optional fields marked with `optional`
- [ ] Enums have UNSPECIFIED = 0
- [ ] Comments document purpose

### Service Review

- [ ] Method names follow conventions
- [ ] Request/Response follow naming pattern
- [ ] REST annotations are correct
- [ ] HTTP methods match operation type
- [ ] Path parameters match field names

### Validation Review

- [ ] Required fields have min_len or not_in
- [ ] String lengths are reasonable
- [ ] Numeric ranges are logical
- [ ] UUIDs validated for ID fields
- [ ] Patterns are correct regex

### Breaking Change Review

- [ ] No field removals
- [ ] No field number changes
- [ ] No type changes
- [ ] `buf breaking` passes

---

## Resources

- [Buf Style Guide](https://buf.build/docs/best-practices/style-guide)
- [Protocol Buffers Guide](https://protobuf.dev/programming-guides/proto3/)
- [Google API Design Guide](https://cloud.google.com/apis/design)
- [gRPC Best Practices](https://grpc.io/docs/guides/)
- [Protovalidate](https://github.com/bufbuild/protovalidate)
