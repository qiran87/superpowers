---
name: code-structure-reader
description: Use when joining a new project, onboarding team members, designing technical solutions, conducting code reviews, analyzing technical debt, or needing to understand codebase structure, module dependencies, call chains, data flow, architecture patterns, testing strategy, security risks, or third-party dependencies in Chinese-friendly documentation
---

# Code Structure Reader

## Overview

**Systematically analyze codebase across 5 levels (structure → dependencies → call chains → data flow → architecture) and generate 12 maintainable, incremental-updateable Markdown documents with interaction index for fast project understanding.**

Core principle: One analysis pass generates organized documentation by domain layer (frontend/API/domain/database/quality/dev-guide), not by file, with smart incremental updates based on code changes.

## When to Use

### Primary Scenarios

**Symptoms indicating you need this skill:**

- **新人入职**: "这个项目结构太复杂,不知道从哪开始理解"
- **技术方案设计**: "不知道项目是否已有类似功能,可能重复开发"
- **代码审查**: "不清楚这个改动会影响哪些其他模块"
- **技术债务**: "需要量化代码质量问题,确定重构优先级"
- **文档维护**: "项目文档过时,需要系统性更新"
- **安全审计**: "需要了解依赖漏洞和安全风险"
- **测试理解**: "不知道项目的测试策略和覆盖率"

**Use cases:**
- 新成员快速 onboarding (30分钟上手)
- 技术方案设计时查找可复用能力
- 代码审查前理解影响范围
- 定期代码健康检查和技术债务分析
- 生成项目架构文档
- 安全扫描和合规性检查

### When NOT to Use

- ❌ 单个文件的简单查询 (使用 `Grep` 工具更直接)
- ❌ 只需要生成 README (使用其他文档技能)
- ❌ 分析很小的项目 (<10 文件)
- ❌ 不需要增量更新的文档

## Core Pattern

### Five-Level Progressive Analysis

```
Level 1: Directory Structure
    ↓
Level 2: Module Dependencies
    ↓
Level 3: Call Relationships
    ↓
Level 4: Data Flow
    ↓
Level 5: Architecture Patterns
```

**Key insight**: Each level builds on previous analysis - don't skip levels if you need deep understanding.

### Domain-Layered Documentation (12 Files)

```
Analysis Layer           → Document File
─────────────────────────────────────────
Project Overview       → 00-overview.md
Frontend Components   → 01-frontend-components.md
Backend APIs          → 02-backend-apis.md
Domain Models         → 03-backend-domains.md
Database Schemas      → 04-database-schemas.md
Third-party Deps      → 05-third-party-deps.md
External APIs*        → 06-external-apis.md (external services)
Dev Guide            → 07-dev-guide.md
Code Relations**      → 08-code-relations.md (deps + calls + flows)
Architecture Patterns  → 09-architecture-patterns.md
Testing Strategy      → 10-testing-strategy.md
Quality Reports**      → 11-quality-reports.md (debt + security)
Interaction Index***   → 12-interaction-index.md
```

*Merged files for better maintainability
**New file for external API documentation

### Smart Incremental Update

```bash
# Detect changes
git diff --name-only HEAD~1 HEAD

# Smart decision
CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD | wc -l)
if [ $CHANGED_FILES -lt 10 ]; then
    → Incremental: Update only affected docs
else
    → Full: Re-run complete analysis
fi
```

**Change type → File mapping:**
| Change | Affected Files |
|---------|---------------|
| Frontend components | `01-frontend-components.md` |
| API routes | `02-backend-apis.md` + `08-code-relations.md` |
| Domain logic | `03-backend-domains.md` + `08-code-relations.md` |
| Database/models | `04-database-schemas.md` |
| package.json | `05-third-party-deps.md` + `11-quality-reports.md` |
| External API calls | `06-external-apis.md` |
| Config/scripts | `07-dev-guide.md` |
| **Code logic** | **`08-code-relations.md`** (unified) |
| Test files | `10-testing-strategy.md` |
| Architecture | `09-architecture-patterns.md` |
| Quality/Security | `11-quality-reports.md` (unified) |

## Quick Reference

### Analysis Commands by Level

**Level 1: Directory Structure**
```bash
# Generate tree structure
tree -L 3 -I 'node_modules|.git' > docs/structure.txt

# Or use find
find . -type f -name "*.ts" -o -name "*.js" | head -50
```

**Level 2: Module Dependencies**
```bash
# JavaScript/TypeScript
grep -r "import.*from" src/ --include="*.ts,*.tsx" | deps-graph

# Python
pdepend src/ | dot -T png > deps.png

# External API Detection (for 06-external-apis.md)
grep -r "fetch\|axios\|https://" src/ --include="*.ts,*.tsx,*.js" | external-calls
grep -r "import.*api\|from '.*api'" src/ --include="*.ts,*.tsx" | third-party-sdk
```

**Level 3: Call Chains**
```bash
# Static analysis (entry points)
grep -r "app.use\|router." src/ --include="*.ts"

# Dynamic tracing (if code is running)
# Use debugger/profiler tools
```

**Level 4: Data Flow**
```bash
# Trace request flow
# Follow HTTP request → middleware → controller → service → repository
```

**Level 5: Architecture Patterns**
```bash
# Detect patterns
grep -r "class.*Controller" src/  # MVC
grep -r "Repository" src/          # Repository
grep -r "Service" src/             # Service Layer
```

### Tech Stack Detection

```javascript
// package.json exists → Node.js
// pom.xml → Java/Maven
// requirements.txt → Python
// go.mod → Go
// Cargo.toml → Rust

// Further detect frameworks
"react" → React frontend
"vue" → Vue frontend
"express" → Express backend
"fastapi" → FastAPI backend
"spring-boot" → Spring Boot backend
```

### Output Locations

```bash
# Default location
./docs/project-analysis/

# Custom location via env
PROJECT_ANALYSIS_DIR=${PROJECT_ANALYSIS_DIR:-"./docs/project-analysis"}

# Or pass as argument
--output-dir /custom/path
```

## Implementation

### Step 1: Project Detection

```bash
# Detect project type
detect_project_type() {
    if [ -f "package.json" ]; then
        echo "nodejs"
    elif [ -f "requirements.txt" ]; then
        echo "python"
    elif [ -f "pom.xml" ]; then
        echo "java"
    fi
}

PROJECT_TYPE=$(detect_project_type)
echo "Detected: $PROJECT_TYPE"
```

### Step 2: Level-by-Level Analysis

**For each level, create corresponding output:**

```python
# Pseudo-code
levels = [
    {"name": "structure", "file": "00-overview.md"},
    {"name": "dependencies", "file": "08-code-relations.md"},
    {"name": "external-apis", "file": "06-external-apis.md"},
    {"name": "callchains", "file": "08-code-relations.md"},
    {"name": "dataflow", "file": "08-code-relations.md"},
    {"name": "architecture", "file": "09-architecture-patterns.md"}
]

for level in levels:
    analyze_level(level["name"])
    generate_doc(level["file"])
```

### Step 3: Generate 12 Files

```bash
# Create output directory
mkdir -p docs/project-analysis

# Generate files in order
create_file "00-overview.md" "# Project Overview\n..."
create_file "01-frontend-components.md" "# Frontend Components\n..."
create_file "06-external-apis.md" "# External APIs\n..."
# ... continue for all 12 files
```

**06-external-apis.md Template:**
```markdown
# External APIs

> **Purpose:** Document external service interfaces for design, development, and testing reference

## Detection Method

Auto-detected from code by scanning for:
- `fetch()`, `axios()` calls with external URLs
- Third-party SDK imports (e.g., `import S3 from 'aws-sdk'`)
- HTTP client libraries (e.g., `import { HttpClient } from '@angular/common/http'`)

## External Services

### [Service Name]

**Base URL:** `https://api.example.com`

**Authentication:**
- Method: API Key / OAuth 2.0 / Bearer Token
- Header Name: `Authorization` / `X-API-Key`
- Token Location: Environment variable / Config file

**Endpoints:**

| Method | Path | Purpose | Request Fields | Response Fields |
|--------|------|---------|----------------|-----------------|
| GET | `/api/users/:id` | Get user by ID | `id` | `id`, `name`, `email` |
| POST | `/api/users` | Create user | `name`, `email` | `id`, `createdAt` |

**Field Mapping (External → Internal):**

| External Field | Internal Field | Type | Transformation |
|----------------|----------------|------|----------------|
| `n` | `name` | string | Direct mapping |
| `ts` | `timestamp` | number | Convert to Date |

**Adapter Implementation:** `src/adapters/[ServiceName]Adapter.ts`

**Usage in Code:**
- `src/services/[ServiceName]Service.ts:45`
- `src/controllers/[Controller]Controller.ts:123`

---
```

**File content templates** are in design document: `docs/plans/2025-02-11-code-structure-reader-design-v3.md`

### Step 4: Incremental Update Detection

```bash
#!/bin/bash
# analyze-with-incremental.sh

# Get changed files
CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)

# Count changes
COUNT=$(echo "$CHANGED_FILES" | wc -l)

# Decide analysis mode
if [ $COUNT -lt 10 ]; then
    echo "Running incremental analysis..."
    # Map changes to affected docs
    update_affected_docs "$CHANGED_FILES"
else
    echo "Running full analysis..."
    # Re-run complete 5-level analysis
    run_full_analysis
fi
```

### Step 5: Generate Visualization

```markdown
<!-- In generated docs -->

## 依赖关系图
\`\`\`mermaid
graph LR
    A[AuthService] --> B[UserService]
    B --> C[Database]
    A --> C
\`\`\`

## 调用序列图
\`\`\`mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant API
    User->>Frontend: 点击登录
    Frontend->>API: POST /auth/login
    API->>Frontend: 返回token
\`\`\`
```

## Common Mistakes

### ❌ Analyzing by File Instead of Domain

**Wrong:**
```
Looking at src/utils/logger.ts in isolation
→ Missing how it connects to other modules
```

**Right:**
```
Understand logger is used by:
- src/backend/api/auth.ts
- src/backend/domain/user/service.ts
→ Update 02-backend-apis.md and 03-backend-domains.md
```

### ❌ Skipping Levels

**Wrong:**
```
Only doing Level 1 (structure)
→ Missing dependencies, call chains, architecture insights
```

**Right:**
```
Always complete all 5 levels progressively
Each level provides unique insights
```

### ❌ Not Generating Interaction Index

**Wrong:**
```
Generated 11 docs but no entry point
→ Users don't know where to start
```

**Right:**
```
ALWAYS create 12-interaction-index.md
Include common questions with links to specific docs
```

### ❌ Full Re-analysis on Small Changes

**Wrong:**
```
Changed 2 files → Re-running full 5-level analysis (takes 10+ minutes)
```

**Right:**
```
Changed 2 files → Update only affected docs (takes <30 seconds)
Use 10-file threshold for smart decision
```

### ❌ Merging Unrelated Content

**Wrong:**
```
Putting frontend components and database schemas in same doc
→ Hard to maintain, different update frequencies
```

**Right:**
```
Keep separate files:
- 01-frontend-components.md (updates on component changes)
- 04-database-schemas.md (updates on migration changes)
- 06-external-apis.md (updates on external API integration)
Merge only semantically related content (like 08-code-relations.md)
```

## Real-World Impact

**Expected results:**

- ✅ **新员工上手时间**: 从4小时减少到30分钟 (-87.5%)
- ✅ **重复功能识别**: 在设计阶段发现现有能力,节省20%开发时间
- ✅ **代码审查效率**: 影响分析提前发现90%的潜在问题
- ✅ **技术债务可视化**: 量化质量指标,支持数据驱动的重构决策
- ✅ **文档维护成本**: 增量更新机制将文档同步时间从1小时减少到5分钟 (-92%)

**Team feedback:** [待补充实际使用后的反馈]

## Related Skills

**REQUIRED SUB-SKILLS:**
- Use **superpowers:writing-plans** for creating detailed implementation plans
- Use **superpowers:test-driven-development** when implementing analysis features
- Use **superpowers:brainstorming** when designing new analysis capabilities

**Optional complementary skills:**
- **superpowers:systematic-debugging** for understanding complex code behavior
- **superpowers:verification-before-completion** to ensure all docs are generated

## See Also

- Design document: `docs/plans/2025-02-11-code-structure-reader-design-v3.md`
- Implementation plan: `docs/plans/2025-02-11-code-structure-reader-plan.md` (to be created)
- Test cases: `tests/claude-code-structure-reader/` (to be created)
