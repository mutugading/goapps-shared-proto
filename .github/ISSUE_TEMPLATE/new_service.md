---
name: ✨ New Proto Service
about: Request a new gRPC service definition
title: '[SERVICE] '
labels: 'type: feature, scope: new-service'
assignees: ''
---

## Service Information

### Basic Info
- **Domain**: [ ] finance [ ] iam [ ] hr [ ] it [ ] Other: _______
- **Service Name**: 
- **Entity Name**: 

## Service Definition

### Entity Message
```protobuf
// Example entity
message Item {
  string item_id = 1;
  string item_code = 2;
  string item_name = 3;
  bool is_active = 4;
  common.v1.AuditInfo audit = 16;
}
```

### RPC Methods
| Method | Description |
|--------|-------------|
| `Create*` | |
| `Get*` | |
| `Update*` | |
| `Delete*` | |
| `List*` | |
| Other: | |

### REST Endpoints
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/<domain>/<resources>` | Create |
| GET | `/api/v1/<domain>/<resources>/{id}` | Get by ID |
| PUT | `/api/v1/<domain>/<resources>/{id}` | Update |
| DELETE | `/api/v1/<domain>/<resources>/{id}` | Delete |
| GET | `/api/v1/<domain>/<resources>` | List |

## Validation Requirements

| Field | Validation |
|-------|------------|
| code | Required, 1-50 chars, pattern |
| name | Required, 1-100 chars |
| id | UUID format |

## Dependencies

- [ ] Uses common/v1/common.proto
- [ ] Uses google/api/annotations.proto
- [ ] Uses buf/validate/validate.proto
- [ ] Other domain protos: _______________

## Checklist
- [ ] I have read RULES.md
- [ ] Field names follow snake_case
- [ ] Enums have UNSPECIFIED = 0
- [ ] REST mappings follow conventions
