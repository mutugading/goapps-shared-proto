## Description
<!-- Describe the changes briefly -->

## Change Type
- [ ] ✨ New service/message
- [ ] ➕ Add field/RPC/enum value
- [ ] 🔄 Modify validation
- [ ] 📝 Documentation update
- [ ] ⚠️ Deprecation
- [ ] 🔧 Config/script changes

## Proto Files Changed
<!-- List proto files modified -->
- [ ] `common/v1/common.proto`
- [ ] `finance/v1/uom.proto`
- [ ] Other: _______________

## Changes Made
<!-- List the changes made -->
- 
- 
- 

## Related Issues
Fixes #
Related to #

## Breaking Change Check

### Is this a breaking change?
- [ ] No - `buf breaking` passes
- [ ] Yes - Requires version bump

### Breaking Change Evidence
```bash
# Output of buf breaking command
buf breaking --against '.git#branch=main'
```

## Lint Check
```bash
# Output of buf lint
buf lint
```

## Generated Code Preview (Optional)
<!-- Show relevant generated code changes -->
```go
// Generated Go code changes
```

---

### Pre-merge Checklist
- [ ] I have read and followed [RULES.md](./RULES.md)
- [ ] `buf format -w` applied
- [ ] `buf lint` passes
- [ ] `buf breaking` passes
- [ ] Comments document new messages/fields
- [ ] REST mappings follow conventions
- [ ] Validation rules are complete
- [ ] Field numbers are logical

### Impact Assessment
- [ ] Backend code regeneration required
- [ ] Frontend code regeneration required
- [ ] OpenAPI spec regeneration required

### Reviewer Notes
<!-- Notes for reviewers -->
