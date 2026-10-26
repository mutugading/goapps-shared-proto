# Contributing to goapps-shared-proto

Thank you for your interest in contributing to `goapps-shared-proto`! This document contains guidelines for contributing to the Protocol Buffer definitions repository.

---

## 📋 Table of Contents

1. [Getting Started](#getting-started)
2. [Development Environment](#development-environment)
3. [Contribution Workflow](#contribution-workflow)
4. [Adding New Protos](#adding-new-protos)
5. [Modifying Existing Protos](#modifying-existing-protos)
6. [Pull Request Guidelines](#pull-request-guidelines)
7. [Code Review Process](#code-review-process)
8. [Getting Help](#getting-help)

---

## Getting Started

### Prerequisites

- **Buf CLI** - [Install](https://buf.build/docs/installation)
- **Git** - Version control

### Install Buf CLI

```bash
# macOS
brew install bufbuild/buf/buf

# Linux
curl -sSL "https://github.com/bufbuild/buf/releases/download/v1.47.2/buf-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/buf && chmod +x /usr/local/bin/buf

# Verify
buf --version
```

### Clone Repository

GoApps uses a **fork + upstream** model: `origin` is your fork (you push here), `upstream` is `mutugading/goapps-shared-proto` (fetch only, changes go in through PRs). The full guide is in [Git Workflow](https://github.com/mutugading/goapps-workspace/blob/main/docs/GIT-WORKFLOW.md).

Recommended: set up all four repos at once with the workspace tool:

```bash
git clone https://github.com/mutugading/goapps-workspace.git
cd goapps-workspace
make setup        # forks, clones and adds the upstream remote for every repo
```

Working on this repo only: fork it on GitHub, then

```bash
git clone https://github.com/<your-user>/goapps-shared-proto.git
cd goapps-shared-proto
git remote add upstream https://github.com/mutugading/goapps-shared-proto.git
git remote set-url --push upstream DISABLED   # never push to the org directly

# Update dependencies
buf dep update
```

---

## Development Environment

### Verify Setup

```bash
# Lint proto files
buf lint

# Format proto files
buf format -w

# Check for breaking changes
buf breaking --against '.git#branch=main'
```

### VSCode Extensions

```json
{
  "recommendations": [
    "zxh404.vscode-proto3",
    "bufbuild.vscode-buf"
  ]
}
```

---

## Contribution Workflow

### 1. Create Issue (Recommended)

For major changes, create an issue first:

| Template | Usage |
|----------|-------|
| [✨ New Proto Service](.github/ISSUE_TEMPLATE/new_service.md) | Request new service |
| [🔄 Proto Change](.github/ISSUE_TEMPLATE/proto_change.md) | Modify existing proto |
| [🐛 Bug Report](.github/ISSUE_TEMPLATE/bug_report.md) | Report issues |

### 2. Create Feature Branch

Never work on `main`; it only mirrors `upstream/main`. Always branch from the latest `upstream/main`:

```bash
# From goapps-workspace (add REPOS=... to span several repos with the same branch name)
make feat NAME=finance/add-parameter-service REPOS=proto

# Or manually in this repo
git fetch upstream
git switch -c feat/finance/add-parameter-service upstream/main

# Other examples:
#   fix/uom/validation-pattern
```

Branch types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `ci`.

### 3. Make Changes

```bash
# 1. Edit proto files

# 2. Format
buf format -w

# 3. Lint
buf lint

# 4. Check breaking changes (local main mirrors upstream/main; run `make sync` first)
buf breaking --against '.git#branch=main'
```

### 4. Commit and Push

```bash
git add .
git commit -m "feat(uom): add bulk import RPC"
git push origin <branch-name>
```

### 5. Create Pull Request

Create PR via GitHub UI using the PR template.

Shortcut from goapps-workspace: `make push && make pr` opens the PR form for every repo whose branch has new commits.

> **Keeping up to date**: rebase on the latest org code with `make update` (or `git fetch upstream && git rebase upstream/main`), then `git push --force-with-lease`. After your PR is merged, run `make sync && make cleanup` from goapps-workspace. Do **not** use GitHub's "Sync fork → Update branch" on `main` after a squash merge; it creates duplicate commits. Conflicts and other edge cases: see [Git Workflow](https://github.com/mutugading/goapps-workspace/blob/main/docs/GIT-WORKFLOW.md#6-konflik-dan-kasus-yang-sering-terjadi).

---

## Adding New Protos

### 1. Create Directory Structure

```bash
# For new domain
mkdir -p <domain>/v1

# Example
mkdir -p inventory/v1
```

### 2. Create Proto File

```protobuf
// inventory/v1/item.proto
syntax = "proto3";

package inventory.v1;

import "buf/validate/validate.proto";
import "common/v1/common.proto";
import "google/api/annotations.proto";

// Item represents an inventory item.
message Item {
  string item_id = 1;
  string item_code = 2;
  string item_name = 3;
  // ... more fields
}

// CreateItemRequest is the request for creating an item.
message CreateItemRequest {
  string item_code = 1 [(buf.validate.field).string = {
    min_len: 1
    max_len: 50
  }];
  // ... more fields
}

// ItemService provides CRUD for inventory items.
service ItemService {
  rpc CreateItem(CreateItemRequest) returns (CreateItemResponse) {
    option (google.api.http) = {
      post: "/api/v1/inventory/items"
      body: "*"
    };
  }
  // ... more RPCs
}
```

### 3. Update buf.gen.yaml

```yaml
inputs:
  - directory: .
    paths:
      - common
      - finance
      - inventory  # Add new domain
```

### 4. Verify

```bash
buf lint
buf generate --dry-run
```

---

## Modifying Existing Protos

### Adding Fields

```protobuf
message UOM {
  string uom_id = 1;
  string uom_code = 2;
  string uom_name = 3;
  // New field - use next available number
  string notes = 7;  // ✅ Safe
}
```

### Adding Enum Values

```protobuf
enum UOMCategory {
  UOM_CATEGORY_UNSPECIFIED = 0;
  UOM_CATEGORY_WEIGHT = 1;
  UOM_CATEGORY_LENGTH = 2;
  UOM_CATEGORY_AREA = 5;  // ✅ Safe - new value
}
```

### Deprecating Fields

```protobuf
message UOM {
  // Deprecated: Use uom_category instead.
  string category_string = 10 [deprecated = true];
}
```

### Removing Fields (Carefully!)

```protobuf
message UOM {
  reserved 5, 6;
  reserved "old_field", "deprecated_field";
  // ... remaining fields
}
```

---

## Pull Request Guidelines

### PR Requirements

| Requirement | Description |
|-------------|-------------|
| **Lint Pass** | `buf lint` must pass |
| **No Breaking Changes** | `buf breaking` must pass |
| **Formatted** | `buf format -w` applied |
| **Documented** | Comments on new messages/fields |

### PR Template

The repository uses an automatic PR template with:

- Change description
- Breaking change check
- Documentation updates
- Review checklist

---

## Code Review Process

### Review Checklist

**For Reviewers:**

- [ ] Naming follows conventions
- [ ] Field numbers are logical
- [ ] Validation rules present
- [ ] REST mappings correct
- [ ] Comments document purpose
- [ ] No breaking changes
- [ ] `buf lint` passes

### Review SLA

| PR Type | SLA |
|---------|-----|
| New field | 24 hours |
| New RPC | 48 hours |
| New service | 48-72 hours |
| Breaking change | Requires team discussion |

---

## Getting Help

### Channels

| Channel | Purpose |
|---------|---------|
| GitHub Issues | Bug reports, feature requests |
| Slack #goapps-proto | Quick questions |

### Before Asking

1. ✅ Read RULES.md
2. ✅ Check Buf documentation
3. ✅ Search existing issues
4. ✅ Verify lint/format

---

## Code of Conduct

- 🤝 Be respectful
- 📝 Document your changes
- ✅ Test before pushing
- 🙋 Ask if unsure about breaking changes

---

Thank you for contributing! 🚀
