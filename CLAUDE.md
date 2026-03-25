# CLAUDE.md -- GoApps Shared Proto

> Single source of truth for Protobuf API contracts across the GoApps platform.
> This repository generates Go and TypeScript code consumed by `goapps-backend` and `goapps-frontend`.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Directory Structure](#2-directory-structure)
3. [Buf Configuration Files](#3-buf-configuration-files)
4. [Build and Generate Commands](#4-build-and-generate-commands)
5. [Code Generation Targets](#5-code-generation-targets)
6. [Proto Design Patterns](#6-proto-design-patterns)
7. [Field Numbering Convention](#7-field-numbering-convention)
8. [Validation Rules (buf.validate)](#8-validation-rules-bufvalidate)
9. [HTTP Annotations Pattern](#9-http-annotations-pattern)
10. [Enum Conventions](#10-enum-conventions)
11. [Response Envelope](#11-response-envelope)
12. [Permission Code Format](#12-permission-code-format)
13. [Services Reference](#13-services-reference)
14. [Breaking Change Rules](#14-breaking-change-rules)
15. [Lint, Format, and CI](#15-lint-format-and-ci)
16. [Naming Conventions Summary](#16-naming-conventions-summary)
17. [Adding a New Service (Checklist)](#17-adding-a-new-service-checklist)

---

## 1. Overview

`goapps-shared-proto` is the contract-first API definition layer for the GoApps platform. Every gRPC service, message, enum, and REST mapping lives here. Generated code flows downstream:

- **Go** code lands in `goapps-backend/gen/` (protobuf structs, gRPC stubs, gRPC-Gateway, OpenAPI).
- **TypeScript** code lands in `goapps-frontend/src/types/generated/` (ts-proto types with JSON serialization).

No backend or frontend code should hand-write types that are defined in proto. If the shape exists in proto, use the generated output.

**Tech stack**: Protobuf v3, Buf CLI v2, `buf.validate` (protovalidate), Google API HTTP annotations, ts-proto.

**Buf module name**: `buf.build/goapps/shared-proto`

---

## 2. Directory Structure

```
goapps-shared-proto/
├── buf.yaml                     # Module config (v2), lint rules, breaking config, deps
├── buf.lock                     # Pinned dependency versions
├── buf.gen.yaml                 # Go + gRPC-Gateway + OpenAPI generation config
├── buf.gen.ts.yaml              # TypeScript generation config (ts-proto)
├── RULES.md                     # Developer guidelines and review checklists
├── common/v1/
│   └── common.proto             # BaseResponse, PaginationRequest/Response, AuditInfo, ValidationError
├── finance/v1/
│   └── uom.proto                # UOMService (8 RPCs), UOM entity, UOMCategory/ActiveFilter enums
├── iam/v1/
│   ├── auth.proto               # AuthService (11 RPCs): login, logout, 2FA, password ops
│   ├── user.proto               # UserService (16 RPCs): CRUD, roles, permissions, avatar
│   ├── role.proto               # RoleService (11 RPCs) + PermissionService (11 RPCs)
│   ├── organization.proto       # Company/Division/Department/Section/Org services (33 RPCs)
│   ├── menu.proto               # MenuService (14 RPCs): CRUD, tree, permissions, reorder
│   ├── session.proto            # SessionService (3 RPCs): current, revoke, list
│   └── audit.proto              # AuditService (4 RPCs): get, list, export, summary
└── scripts/
    ├── gen-go.sh                # Generate Go code (dep update + format + lint + generate + go mod tidy)
    ├── gen-ts.sh                # Generate TypeScript code (requires frontend node_modules)
    └── gen-all.sh               # Run both gen-go.sh and gen-ts.sh
```

### Package layout convention

```
<domain>/<version>/<resource>.proto
```

| Domain | Package | Description |
|--------|---------|-------------|
| `common` | `common.v1` | Shared types used by all services |
| `finance` | `finance.v1` | Finance module (UOM, future: parameters, accounts) |
| `iam` | `iam.v1` | Identity and Access Management |

---

## 3. Buf Configuration Files

### buf.yaml

Module definition, lint and breaking change rules.

```yaml
version: v2
modules:
  - path: .
    name: buf.build/goapps/shared-proto
breaking:
  use:
    - FILE          # Breaking change detection at file level
lint:
  use:
    - STANDARD      # Buf standard lint rules
  except:
    - PACKAGE_VERSION_SUFFIX   # We use /v1/ directories instead of package suffix
deps:
  - buf.build/googleapis/googleapis       # google.api.http annotations
  - buf.build/bufbuild/protovalidate      # buf.validate field validation
```

### buf.gen.yaml (Go backend)

Generates 4 types of output using remote Buf plugins:

| Plugin | Output | What it generates |
|--------|--------|-------------------|
| `buf.build/protocolbuffers/go` | `../goapps-backend/gen/` | `*.pb.go` -- protobuf message structs |
| `buf.build/grpc/go` | `../goapps-backend/gen/` | `*_grpc.pb.go` -- gRPC service stubs |
| `buf.build/grpc-ecosystem/gateway` | `../goapps-backend/gen/` | `*.pb.gw.go` -- REST-to-gRPC gateway |
| `buf.build/grpc-ecosystem/openapiv2` | `../goapps-backend/gen/openapi/` | `*.swagger.json` -- OpenAPI specs |

Managed mode is enabled with `go_package_prefix` set to `github.com/mutugading/goapps-backend/gen`. The `go_package` override is disabled for `protovalidate` and `googleapis` dependencies so their packages remain unchanged.

**Important**: `clean: true` is intentionally NOT set -- it would delete `go.mod` and `go.sum` in the gen directory.

Input paths: `common`, `finance`, `iam`.

### buf.gen.ts.yaml (TypeScript frontend)

Uses `protoc-gen-ts_proto` (local binary from `goapps-frontend/node_modules`):

| Option | Value | Purpose |
|--------|-------|---------|
| `esModuleInterop` | `true` | ES module compatibility |
| `outputJsonMethods` | `true` | Generates `fromJSON()` / `toJSON()` methods |
| `useExactTypes` | `false` | Allows partial objects |
| `snakeToCamel` | `true` | Converts snake_case fields to camelCase in TS |
| `outputServices` | `generic-definitions` | Generic service definitions |

Output: `../goapps-frontend/src/types/generated/`

---

## 4. Build and Generate Commands

### Generate Go code

```bash
cd goapps-shared-proto

# Full pipeline: dep update, format, lint, generate, go mod tidy
./scripts/gen-go.sh

# Or manually:
buf dep update
buf format -w
buf lint
buf generate
cd ../goapps-backend/gen && go mod tidy
```

### Generate TypeScript code

```bash
cd goapps-shared-proto

# Full pipeline (requires npm install in goapps-frontend first)
./scripts/gen-ts.sh

# Or manually:
export PATH="../goapps-frontend/node_modules/.bin:$PATH"
buf generate --template buf.gen.ts.yaml
```

### Generate both at once

```bash
cd goapps-shared-proto
./scripts/gen-all.sh
```

### Lint and format only

```bash
buf lint                                    # Check lint rules
buf format -w                               # Auto-format all proto files
buf breaking --against '.git#branch=main'   # Check for breaking changes
```

---

## 5. Code Generation Targets

### Go output (`goapps-backend/gen/`)

```
gen/
├── common/v1/
│   └── common.pb.go                 # BaseResponse, PaginationRequest/Response, etc.
├── finance/v1/
│   ├── uom.pb.go                    # Message structs
│   ├── uom_grpc.pb.go               # gRPC client/server interfaces
│   └── uom.pb.gw.go                 # REST gateway handlers
├── iam/v1/
│   ├── auth.pb.go, auth_grpc.pb.go, auth.pb.gw.go
│   ├── user.pb.go, user_grpc.pb.go, user.pb.gw.go
│   ├── role.pb.go, role_grpc.pb.go, role.pb.gw.go
│   ├── menu.pb.go, menu_grpc.pb.go, menu.pb.gw.go
│   ├── organization.pb.go, organization_grpc.pb.go, organization.pb.gw.go
│   ├── session.pb.go, session_grpc.pb.go, session.pb.gw.go
│   └── audit.pb.go, audit_grpc.pb.go, audit.pb.gw.go
└── openapi/
    └── *.swagger.json               # OpenAPI/Swagger specs per file
```

The `gen/` directory has its own `go.mod` with module path `github.com/mutugading/goapps-backend/gen`. Backend services reference it via a `replace` directive in their own `go.mod`.

### TypeScript output (`goapps-frontend/src/types/generated/`)

```
generated/
├── common/v1/common.ts
├── finance/v1/uom.ts
└── iam/v1/
    ├── auth.ts, user.ts, role.ts
    ├── menu.ts, organization.ts
    ├── session.ts, audit.ts
```

These are raw generated types. The frontend wraps them with normalizer functions in `src/types/{module}/{entity}.ts` to handle both camelCase and snake_case field names.

---

## 6. Proto Design Patterns

### Entity message

The core data object. Contains the resource fields plus audit info.

```protobuf
message UOM {
  string uom_id = 1;               // UUID primary key
  string uom_code = 2;             // Unique business code, immutable
  string uom_name = 3;             // Display name
  UOMCategory uom_category = 4;    // Enum category
  string description = 5;          // Optional
  bool is_active = 6;              // Soft-active flag
  common.v1.AuditInfo audit = 7;   // created_at/by, updated_at/by
}
```

### Create request

Only fields needed for creation. All validated. Code fields are typically immutable after creation.

```protobuf
message CreateUOMRequest {
  string uom_code = 1 [(buf.validate.field).string = {min_len: 1, max_len: 20, pattern: "^[A-Z][A-Z0-9_]*$"}];
  string uom_name = 2 [(buf.validate.field).string = {min_len: 1, max_len: 100}];
  UOMCategory uom_category = 3 [(buf.validate.field).enum = {not_in: [0]}];
  string description = 4 [(buf.validate.field).string.max_len = 500];
}
```

### Update request

ID required, all other fields `optional`. Empty/unset fields mean "no change".

```protobuf
message UpdateUOMRequest {
  string uom_id = 1 [(buf.validate.field).string.uuid = true];
  optional string uom_name = 2 [(buf.validate.field).string = {max_len: 100}];
  optional UOMCategory uom_category = 3 [(buf.validate.field).enum = {not_in: [0]}];
  optional string description = 4 [(buf.validate.field).string.max_len = 500];
  optional bool is_active = 5;
}
```

### Get request

Just the ID.

```protobuf
message GetUOMRequest {
  string uom_id = 1 [(buf.validate.field).string.uuid = true];
}
```

### Delete request

Just the ID. Backend performs soft delete.

```protobuf
message DeleteUOMRequest {
  string uom_id = 1 [(buf.validate.field).string.uuid = true];
}
```

### List request

Pagination + search + filters + sorting. Pagination is always page-based (not cursor).

```protobuf
message ListUOMsRequest {
  int32 page = 1 [(buf.validate.field).int32.gte = 1];
  int32 page_size = 2 [(buf.validate.field).int32 = {gte: 1, lte: 100}];
  string search = 3 [(buf.validate.field).string.max_len = 100];
  UOMCategory category = 4;                    // UNSPECIFIED = no filter
  ActiveFilter active_filter = 5;              // UNSPECIFIED = show all
  string sort_by = 6 [(buf.validate.field).string = {in: ["", "code", "name", "created_at"]}];
  string sort_order = 7 [(buf.validate.field).string = {in: ["", "asc", "desc"]}];
}
```

### Single-entity response

```protobuf
message GetUOMResponse {
  common.v1.BaseResponse base = 1;
  UOM data = 2;
}
```

### List response

```protobuf
message ListUOMsResponse {
  common.v1.BaseResponse base = 1;
  repeated UOM data = 2;
  common.v1.PaginationResponse pagination = 3;
}
```

### Import/Export pattern

Every CRUD service also provides:
- `Export<Entities>` -- filters to Excel bytes
- `Import<Entities>` -- Excel bytes with duplicate handling (`skip`/`update`/`error`)
- `DownloadTemplate` -- blank Excel template for import

Import response includes counts (`success_count`, `skipped_count`, `updated_count`, `failed_count`) and `repeated ImportError errors` with row numbers.

---

## 7. Field Numbering Convention

| Range | Usage | Wire encoding |
|-------|-------|---------------|
| **1-15** | Core fields (most frequently accessed) | 1 byte tag |
| **16-20** | Audit/metadata (e.g., `AuditInfo audit = 16`) | 2 byte tag |
| **21-30** | Relations (e.g., `category_id = 21`, `repeated tag_ids = 22`) | 2 byte tag |
| 19000-19999 | Reserved by protobuf -- never use | -- |

Keep the most-read fields in the 1-15 range for optimal encoding efficiency. Plan field numbers ahead -- they can never change once assigned.

---

## 8. Validation Rules (buf.validate)

All request messages MUST have validation on every field. Import `buf/validate/validate.proto`.

### Common validation patterns

```protobuf
// Required string with length bounds
string name = 1 [(buf.validate.field).string = {min_len: 1, max_len: 100}];

// UUID format
string id = 1 [(buf.validate.field).string.uuid = true];

// Email format
string email = 1 [(buf.validate.field).string.email = true];

// Regex pattern (uppercase code)
string code = 1 [(buf.validate.field).string.pattern = "^[A-Z][A-Z0-9_]*$"];

// Enum must not be UNSPECIFIED (0)
UOMCategory category = 1 [(buf.validate.field).enum = {not_in: [0]}];

// Pagination
int32 page = 1 [(buf.validate.field).int32.gte = 1];
int32 page_size = 2 [(buf.validate.field).int32 = {gte: 1, lte: 100}];

// File upload (max 10MB)
bytes file_content = 1 [(buf.validate.field).bytes = {min_len: 1, max_len: 10485760}];

// String enum (allow empty as default)
string sort_by = 6 [(buf.validate.field).string = {in: ["", "code", "name", "created_at"]}];

// Conditional validation (skip when zero value)
string totp_code = 3 [(buf.validate.field) = {
  ignore: IGNORE_IF_ZERO_VALUE
  string: {len: 6, pattern: "^[0-9]{6}$"}
}];

// Repeated field minimum items
repeated string permission_ids = 2 [(buf.validate.field).repeated.min_items = 1];
```

### Rules

- Every request field gets validation. No exceptions.
- Entity messages (responses) do NOT need validation annotations.
- Use `optional` keyword on update request fields to distinguish "not set" from "set to empty".
- Use `IGNORE_IF_ZERO_VALUE` for conditionally-required fields (e.g., TOTP code only needed when 2FA is enabled).

---

## 9. HTTP Annotations Pattern

All RPC methods include `google.api.http` annotations for gRPC-Gateway REST mapping.

### URL pattern

```
/api/v1/{domain}/{resources}
/api/v1/{domain}/{resources}/{resource_id}
```

### Method mapping

| Operation | HTTP Method | URL Pattern | Body |
|-----------|-------------|-------------|------|
| Create | POST | `/api/v1/{domain}/{resources}` | `body: "*"` |
| Get | GET | `/api/v1/{domain}/{resources}/{id}` | -- |
| List | GET | `/api/v1/{domain}/{resources}` | -- (query params) |
| Update | PUT | `/api/v1/{domain}/{resources}/{id}` | `body: "*"` |
| Delete | DELETE | `/api/v1/{domain}/{resources}/{id}` | -- |
| Export | GET | `/api/v1/{domain}/{resources}/export` | -- |
| Import | POST | `/api/v1/{domain}/{resources}/import` | `body: "*"` |
| Template | GET | `/api/v1/{domain}/{resources}/template` | -- |

### Examples from existing services

```
Finance UOM:         /api/v1/finance/uoms, /api/v1/finance/uoms/{uom_id}
IAM Auth:            /api/v1/iam/auth/login, /api/v1/iam/auth/refresh, /api/v1/iam/auth/me
IAM Users:           /api/v1/iam/users, /api/v1/iam/users/{user_id}
IAM Roles:           /api/v1/iam/roles, /api/v1/iam/roles/{role_id}
IAM Permissions:     /api/v1/iam/permissions, /api/v1/iam/permissions/{permission_id}
IAM Companies:       /api/v1/iam/companies, /api/v1/iam/companies/{company_id}
IAM Menus:           /api/v1/iam/menus, /api/v1/iam/menus/tree
IAM Sessions:        /api/v1/iam/sessions, /api/v1/iam/sessions/current
IAM Audit:           /api/v1/iam/audit-logs, /api/v1/iam/audit-logs/{log_id}
```

### Sub-resource patterns

```
/api/v1/iam/roles/{role_id}/permissions          -- GET role permissions
/api/v1/iam/roles/{role_id}/permissions/remove    -- POST remove role permissions
/api/v1/iam/users/{user_id}/detail               -- GET user detail
/api/v1/iam/sessions/{session_id}/revoke         -- POST revoke session
```

---

## 10. Enum Conventions

Every enum MUST:

1. Start with `UNSPECIFIED = 0` as the default/zero value.
2. Prefix all values with the enum name in `SCREAMING_SNAKE_CASE`.
3. Have a comment on every value.

```protobuf
enum UOMCategory {
  UOM_CATEGORY_UNSPECIFIED = 0;   // Default -- used as "no filter" in list requests
  UOM_CATEGORY_WEIGHT = 1;       // Weight-based units (KG, GR, TON)
  UOM_CATEGORY_LENGTH = 2;       // Length-based units (MTR, CM, YARD)
  UOM_CATEGORY_VOLUME = 3;       // Volume-based units (LTR, ML)
  UOM_CATEGORY_QUANTITY = 4;     // Quantity-based units (PCS, BOX, SET)
}
```

The `UNSPECIFIED = 0` value serves a dual purpose:
- In create/update requests: validated with `not_in: [0]` to require a real value.
- In list/filter requests: left without validation so `0` means "no filter" / "show all".

### Existing enums

| Enum | File | Values |
|------|------|--------|
| `UOMCategory` | `finance/v1/uom.proto` | WEIGHT, LENGTH, VOLUME, QUANTITY |
| `ActiveFilter` | `finance/v1/uom.proto`, `iam/v1/user.proto` | ACTIVE, INACTIVE |
| `EventType` | `iam/v1/audit.proto` | LOGIN, LOGOUT, LOGIN_FAILED, PASSWORD_RESET, PASSWORD_CHANGE, 2FA_ENABLED, 2FA_DISABLED, CREATE, UPDATE, DELETE, EXPORT, IMPORT |
| `MenuLevel` | `iam/v1/menu.proto` | GROUP, ITEM, SUB_ITEM |

Note: `ActiveFilter` is defined in both `finance/v1/uom.proto` and `iam/v1/user.proto` (separate packages, so no conflict).

---

## 11. Response Envelope

All responses use the same envelope from `common/v1/common.proto`:

```protobuf
message BaseResponse {
  repeated ValidationError validation_errors = 1;
  string status_code = 2;      // HTTP-like: "200", "400", "404", "500"
  bool is_success = 3;
  string message = 4;          // Human-readable result description
}

message PaginationResponse {
  int32 current_page = 1;
  int32 page_size = 2;
  int64 total_items = 3;       // NOTE: int64, serialized as string in JSON
  int32 total_pages = 4;
}
```

Every response message follows this structure:

```protobuf
message SomeResponse {
  common.v1.BaseResponse base = 1;        // Always field 1
  SomeEntity data = 2;                     // Single entity (field 2)
}

message SomeListResponse {
  common.v1.BaseResponse base = 1;        // Always field 1
  repeated SomeEntity data = 2;           // List of entities (field 2)
  common.v1.PaginationResponse pagination = 3;  // Pagination (field 3)
}
```

**Important**: `total_items` is `int64` in proto, which means it serializes to a **string** in JSON (e.g., `"123"` not `123`). Frontend code must handle this.

---

## 12. Permission Code Format

```
{service}.{module}.{entity}.{action}
```

Examples:
- `finance.master.uom.view`
- `finance.master.uom.create`
- `iam.user.create`
- `iam.role.delete`

Valid actions: `view`, `create`, `update`, `delete`, `export`, `import`

Validation pattern in proto:

```protobuf
string permission_code = 1 [(buf.validate.field).string = {
  min_len: 3
  max_len: 100
  pattern: "^[a-z][a-z0-9]*\\.[a-z][a-z0-9]*\\.[a-z][a-z0-9]*\\.[a-z]+$"
}];
```

Permission codes are always lowercase with dot separators. The four segments are: service name, module name, entity name, action type.

---

## 13. Services Reference

### common.v1 (common/v1/common.proto)

No services. Shared messages only: `BaseResponse`, `ValidationError`, `PaginationRequest`, `PaginationResponse`, `AuditInfo`.

### finance.v1 -- UOMService (finance/v1/uom.proto) -- 8 RPCs

| RPC | HTTP | Description |
|-----|------|-------------|
| `CreateUOM` | POST `/finance/uoms` | Create new UOM |
| `GetUOM` | GET `/finance/uoms/{uom_id}` | Get UOM by ID |
| `UpdateUOM` | PUT `/finance/uoms/{uom_id}` | Update UOM (code immutable) |
| `DeleteUOM` | DELETE `/finance/uoms/{uom_id}` | Soft delete |
| `ListUOMs` | GET `/finance/uoms` | List with search, filter, pagination |
| `ExportUOMs` | GET `/finance/uoms/export` | Export to Excel |
| `ImportUOMs` | POST `/finance/uoms/import` | Import from Excel |
| `DownloadTemplate` | GET `/finance/uoms/template` | Download import template |

### iam.v1 -- AuthService (iam/v1/auth.proto) -- 11 RPCs

Login, Logout, RefreshToken, ForgotPassword, VerifyResetOTP, ResetPassword, UpdatePassword, Enable2FA, Verify2FA, Disable2FA, GetCurrentUser.

### iam.v1 -- UserService (iam/v1/user.proto) -- 16 RPCs

CreateUser, GetUser, GetUserDetail, UpdateUser, UpdateUserDetail, DeleteUser, ListUsers, ExportUsers, ImportUsers, DownloadTemplate, AssignUserRoles, RemoveUserRoles, AssignUserPermissions, RemoveUserPermissions, GetUserRolesAndPermissions, UploadProfilePicture.

### iam.v1 -- RoleService (iam/v1/role.proto) -- 11 RPCs

CreateRole, GetRole, UpdateRole, DeleteRole, ListRoles, ExportRoles, ImportRoles, DownloadRoleTemplate, AssignRolePermissions, RemoveRolePermissions, GetRolePermissions.

### iam.v1 -- PermissionService (iam/v1/role.proto) -- 11 RPCs

CreatePermission, GetPermission, UpdatePermission, DeletePermission, ListPermissions, ExportPermissions, ImportPermissions, DownloadPermissionTemplate, GetPermissionsByService.

Note: 9 RPCs listed above; the `DownloadPermissionTemplate` and `GetPermissionsByService` make it 11 total with the standard CRUD set.

### iam.v1 -- Organization Services (iam/v1/organization.proto) -- 33 RPCs

5 services in one file:

| Service | RPCs | Resources |
|---------|------|-----------|
| CompanyService | 8 | CRUD + export/import/template |
| DivisionService | 8 | CRUD + export/import/template |
| DepartmentService | 8 | CRUD + export/import/template |
| SectionService | 8 | CRUD + export/import/template |
| OrganizationService | 1 | `GetOrganizationTree` (recursive tree) |

### iam.v1 -- MenuService (iam/v1/menu.proto) -- 14 RPCs

CreateMenu, GetMenu, UpdateMenu, DeleteMenu, ListMenus, ExportMenus, ImportMenus, DownloadMenuTemplate, GetMenuTree (user-filtered), GetFullMenuTree (admin), AssignMenuPermissions, RemoveMenuPermissions, GetMenuPermissions, ReorderMenus.

### iam.v1 -- SessionService (iam/v1/session.proto) -- 3 RPCs

GetCurrentSession, RevokeSession, ListActiveSessions.

### iam.v1 -- AuditService (iam/v1/audit.proto) -- 4 RPCs

GetAuditLog, ListAuditLogs, ExportAuditLogs, GetAuditSummary.

### Total: 9 proto files, 14 services, ~111 RPCs

---

## 14. Breaking Change Rules

Breaking change detection is configured as `FILE` level in `buf.yaml`.

### Allowed (non-breaking)

- Add new message
- Add new field with a NEW field number
- Add new enum value (not at position 0)
- Add new RPC method to existing service
- Add new service
- Rename proto file (if package stays the same)

### Forbidden (breaking)

- Change or reuse a field number
- Remove a field (without `reserved`)
- Rename a field
- Change a field type
- Remove an RPC method
- Remove a service
- Change package name
- Add required validation to an existing field that previously had none

### Removing a field safely

```protobuf
message UOM {
  reserved 10, 11;
  reserved "old_status", "legacy_code";
  // ... remaining fields
}
```

Always reserve both the field number AND the field name to prevent accidental reuse.

### Checking for breaking changes

```bash
buf breaking --against '.git#branch=main'
```

Run this before every commit and in CI.

---

## 15. Lint, Format, and CI

### Pre-commit checklist

```bash
buf format -w                               # 1. Auto-format
buf lint                                    # 2. Lint (STANDARD rules, except PACKAGE_VERSION_SUFFIX)
buf breaking --against '.git#branch=main'   # 3. Breaking change check
```

### Lint rules

Uses Buf STANDARD ruleset with one exception:
- `PACKAGE_VERSION_SUFFIX` is disabled -- we use directory-based versioning (`common/v1/`) instead of package name suffixes.

### What the linter enforces

- Package names match directory structure
- Message/enum/service naming conventions
- Field naming (snake_case)
- Comment requirements on services and RPCs
- Import ordering
- Enum zero values

### CI pipeline

The gen scripts (`gen-go.sh`, `gen-ts.sh`) run lint and format as part of their pipeline. CI in the backend and frontend repos validates that generated code is up to date.

---

## 16. Naming Conventions Summary

| Element | Convention | Example |
|---------|-----------|---------|
| Package | `{domain}.v1` | `finance.v1`, `iam.v1` |
| File | `{resource}.proto` | `uom.proto`, `user.proto` |
| Service | `{Entity}Service` | `UOMService`, `UserService` |
| RPC (create) | `Create{Entity}` | `CreateUOM` |
| RPC (get) | `Get{Entity}` | `GetUOM` |
| RPC (list) | `List{Entities}` | `ListUOMs` |
| RPC (update) | `Update{Entity}` | `UpdateUOM` |
| RPC (delete) | `Delete{Entity}` | `DeleteUOM` |
| Entity message | `PascalCase` noun | `UOM`, `User`, `Role` |
| Request message | `{Method}{Entity}Request` | `CreateUOMRequest` |
| Response message | `{Method}{Entity}Response` | `CreateUOMResponse` |
| Enum | `PascalCase` | `UOMCategory`, `EventType` |
| Enum value | `ENUM_NAME_SCREAMING_SNAKE` | `UOM_CATEGORY_WEIGHT` |
| Field | `snake_case` | `uom_code`, `is_active` |
| ID field | `{entity}_id` | `uom_id`, `user_id` |
| Boolean field | `is_{condition}` or `has_{thing}` | `is_active`, `has_permission` |
| Timestamp field | `{action}_at` | `created_at`, `deleted_at` |

---

## 17. Adding a New Service (Checklist)

When adding a new resource (e.g., `finance/v1/parameter.proto`):

1. Create the proto file at `{domain}/v1/{resource}.proto`.
2. Set `package {domain}.v1;` and import required deps:
   ```protobuf
   import "buf/validate/validate.proto";
   import "common/v1/common.proto";
   import "google/api/annotations.proto";
   ```
3. Define the entity message with field numbering convention (1-15 core, 16-20 audit, 21+ relations).
4. Define enums (if any) with `UNSPECIFIED = 0`.
5. Define request/response messages:
   - `Create{Entity}Request` -- only required fields, all validated.
   - `Get{Entity}Request` -- just the UUID ID.
   - `Update{Entity}Request` -- ID required, all other fields `optional`.
   - `Delete{Entity}Request` -- just the UUID ID.
   - `List{Entities}Request` -- page, page_size, search, filters, sort_by, sort_order.
   - `Export{Entities}Request` -- filters only.
   - `Import{Entities}Request` -- file_content (max 10MB), file_name, duplicate_action.
   - `DownloadTemplateRequest` -- empty.
6. Define the service with HTTP annotations following `/api/v1/{domain}/{resources}` pattern.
7. Add validation to every request field.
8. Add doc comments to every message, field, service, and RPC.
9. Run `buf format -w && buf lint && buf breaking --against '.git#branch=main'`.
10. Generate code: `./scripts/gen-all.sh`.
11. Verify generated output in both `goapps-backend/gen/` and `goapps-frontend/src/types/generated/`.
