---
name: 🔄 Proto Change
about: Request modification to existing proto definitions
title: '[CHANGE] '
labels: 'type: change, status: needs-review'
assignees: ''
---

## Change Information

### Proto File
- **File**: (e.g., `finance/v1/uom.proto`)
- **Service**: 
- **Message**: 

## Change Type
- [ ] Add new field
- [ ] Add new RPC method
- [ ] Add new enum value
- [ ] Modify validation rules
- [ ] Deprecate field/method
- [ ] Documentation update

## Proposed Change

### Current Definition
```protobuf
// Current proto definition
```

### Proposed Definition
```protobuf
// Proposed change
```

## Breaking Change Analysis

### Is this a breaking change?
- [ ] No - Adding new field/method/enum value
- [ ] Yes - Requires new version

### If breaking, describe migration path:

## Validation Changes

| Field | Current | Proposed |
|-------|---------|----------|
| | | |

## REST API Changes (if applicable)

| Change | Before | After |
|--------|--------|-------|
| | | |

## Impact

### Affected Services
- [ ] Backend (goapps-backend)
- [ ] Frontend (goapps-frontend)
- [ ] Other: _______________

### Migration Required?
- [ ] No migration needed
- [ ] Data migration required
- [ ] Client update required

## Checklist
- [ ] I have read RULES.md
- [ ] I have checked `buf breaking`
- [ ] Field numbers are not reused
- [ ] Validation follows conventions
