---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Save plans to:**
- **Plan:** `docs/plans/YYYY-MM-DD-<feature-name>.md`
- **Tasks:** `.spec-workflow/specs/<feature-name>/tasks.md` (使用增强的 tasks-template.md)
- **Verification:** `.spec-workflow/specs/<feature-name>/verification.md` (使用 verification-template.md)

## ⭐ NEW: Enhanced Spec Workflow System

**从 v4.2.0 开始,所有实施计划必须使用增强的 `.spec-workflow` 系统:**

### 必需文件结构

```
.spec-workflow/
├── specs/<feature-name>/
│   ├── tasks.md          # 任务清单(带状态跟踪)
│   └── verification.md   # 验证检查表
└── active/
    └── status.md         # 全局状态跟踪
```

### 任务文档结构 (tasks.md)

**使用增强模板:** `.spec-workflow/templates/tasks-template.md`

**每个任务必须包含:**
- **Status:** 🔵 Not Started | ⏳ In Progress | ✅ Complete | ⚠️ Blocked | ⏸️ Deferred
- **Priority:** P0 (Critical) | P1 (High) | P2 (Medium) | P3 (Low)
- **Verification:** 验证命令、预期输出、验收标准
- **TODO Items:** 发现的待办事项
- **Acceptance Criteria:** 完成标准

**示例任务格式:**
```markdown
### Task 1: Create User Model

- [ ] **Status:** 🔵 Not Started
- **Priority:** P0 (Critical)
- **Estimated:** 30 minutes
- **Dependencies:** None

**Verification:**
- **Command:** `npm run type-check`
- **Expected:** Exit code 0, no type errors
- **Acceptance Criteria:**
  - [ ] Model extends BaseModel
  - [ ] Validation methods implemented
  - [ ] Tests pass

**TODO Items:**
- [ ] Fix relationship handling - Priority: P1
```

### 验证文档结构 (verification.md)

**使用模板:** `.spec-workflow/templates/verification-template.md`

**6部分验证检查表:**
1. **Pre-Verification Checklist** - 任务完成、代码质量、测试验证
2. **Functional Requirements Checklist** - 验收标准验证
3. **Documentation Checklist** - 文档完整性
4. **Integration & Deployment Checklist** - 集成和部署就绪
5. **TODOs & Gaps Summary** - 待办事项和已知限制
6. **Final Sign-Off** - 最终验收确认

### 工作流程

**1. 计划阶段 (Planning)**
- 创建 `tasks.md` 使用增强模板
- 定义每个任务的状态、优先级、验证方法
- 创建 `verification.md` 使用验证模板

**2. 执行阶段 (Execution)**
- 更新任务状态: 🔵 → ⏳ → ✅
- 添加发现的 TODO 到相应任务
- 遇到阻塞时标记为 ⚠️ 并记录变通方法

**3. 验证阶段 (Verification)**
- 使用 `verification.md` 检查表
- 验证所有功能需求
- 检查代码质量(测试、linting、类型检查)
- 处理待办事项和已知限制

**4. 修复循环 (Repair Loop)**
- 如果验证失败,修复问题
- 更新相关任务状态
- 重新运行验证检查表
- 重复直到所有检查通过

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

**⭐ IMPORTANT: 使用增强的任务格式,包含状态跟踪和验证**

### 新格式 (推荐) - 用于 tasks.md

```markdown
### Task N: [Component Name]

- [ ] **Status:** 🔵 Not Started | ⏳ In Progress | ✅ Complete | ⚠️ Blocked | ⏸️ Deferred
- **Priority:** P0 (Critical) | P1 (High) | P2 (Medium) | P3 (Low)
- **Assigned To:** [Agent Name]
- **Estimated:** 30 minutes
- **Actual:** [Time spent when complete]
- **Dependencies:** Task 0, Task 2
- **Files:**
  - Create: `exact/path/to/file.py`
  - Modify: `exact/path/to/existing.py:123-145`
  - Test: `tests/exact/path/to/test.py`

**Description:** [Brief description of what this task accomplishes]

**Implementation Details:**
- [Step-by-step implementation details]
- Purpose: [Why this is needed]

**Leverage:**
- `src/existing/module.py` - Existing patterns to follow

**Requirements:**
- 1.1 - Requirement reference
- 1.2 - Requirement reference

**Verification:** ⭐ NEW
- **Command:** `pytest tests/path/test.py::test_name -v`
- **Expected:** PASS (0 failures)
- **Manual Test:** [How to manually verify]
- **Acceptance Criteria:**
  - [ ] Test passes with correct output
  - [ ] Code follows existing patterns
  - [ ] No regressions in related tests

**TODO Items:** ⭐ NEW
- [ ] [TODO 1] - Priority: P1 - Discovered at [timestamp]
- [ ] [TODO 2] - Priority: P2 - Optimization opportunity

**Notes:** [Any additional notes or edge cases]
```

### 传统格式 (向后兼容) - 用于 plans.md

```markdown
### Task N: [Component Name]

**Protocol Documentation Reference:**
> **⚠️ CRITICAL: Implementer MUST verify against these documents BEFORE coding**
>
> **Required reading:**
> - API Definitions: `docs/project-analysis/02-backend-apis.md`
> - Domain Models: `docs/project-analysis/03-backend-domains.md`
> - Database Schema: `docs/project-analysis/04-database-schemas.md`
>
> **What to verify:**
> - ✅ Field names: Use `symbol` (not `ts_code`), `email` (not `username`)
> - ✅ API paths: Use `/api/users/:id/profile` (not `/api/user/profile`)
> - ✅ Request/response: Match protocol structure exactly
> - ✅ Database: Column names and types match schema
>
> **If documentation doesn't exist:**
> 1. Use `superpowers:code-structure-reader` to generate it first
> 2. Wait for generation to complete
> 3. Read the generated documents
> 4. Then proceed with implementation

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Step 0: Verify protocol compliance (MANDATORY)**
> BEFORE writing any code:
> 1. Read the protocol documents listed above
> 2. Verify all field names, API paths, structures
> 3. Document: "Field X is named 'symbol' in protocol"
> 4. Only then proceed to Step 1

**Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

**Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
```

## Remember
- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- Reference relevant skills with @ syntax
- DRY, YAGNI, TDD, frequent commits

## Execution Handoff

After saving the plan, offer execution choice:

**"计划已完成并保存到:**
- **Plan:** `docs/plans/YYYY-MM-DD-<feature-name>.md`
- **Tasks:** `.spec-workflow/specs/<feature-name>/tasks.md`
- **Verification:** `.spec-workflow/specs/<feature-name>/verification.md`

**两种执行选项:**

**1. Subagent-Driven (当前会话)** - 每个任务分派新的子代理,任务间审查,快速迭代
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- 优点: 保持上下文,快速迭代
- 缺点: 在同一个会话中执行

**2. Parallel Session (独立会话)** - 在新会话中使用 executing-plans,批量执行并检查点
- **REQUIRED SUB-SKILL:** 新会话使用 superpowers:executing-plans
- 优点: 独立执行,批量处理
- 缺点: 需要切换会话

**Which approach?"**

**If Subagent-Driven chosen:**
- Stay in this session
- Use Task tool to dispatch fresh subagent per task
- Review progress between tasks
- Update task status in tasks.md after each task

**If Parallel Session chosen:**
- Guide them to open new session in worktree
- Provide instructions to use executing-plans skill
- Remind them to update status in tasks.md

## ⭐ NEW: Execution Phase Guidelines

### 任务状态更新 (MANDATORY)

**执行过程中必须更新 tasks.md 中的任务状态:**

```markdown
### Task 1: [Component Name]

- [x] **Status:** ✅ Complete  # 从 🔵 → ⏳ → ✅
- **Actual:** 25 minutes  # 记录实际时间
```

### 发现 TODO 时的处理

**如果在开发过程中发现新的 TODO:**

1. **立即添加到当前任务的 TODO Items 部分:**
```markdown
**TODO Items:**
- [ ] Fix edge case in input validation - Priority: P1 - Discovered at 2026-02-26 14:45
```

2. **如果是高优先级(P0/P1)且影响多个任务,添加到 .spec-workflow/global-todos.md**

3. **如果阻塞当前任务,将任务状态改为 ⚠️ Blocked:**
```markdown
- [ ] **Status:** ⚠️ Blocked
**Blocker:** Need external API documentation
**Workaround:** Using mock data for now
**ETA:** 2026-02-27 10:00
```

### 验证阶段 (MANDATORY)

**所有任务完成后,必须运行验证检查表:**

1. **读取 `.spec-workflow/specs/<feature-name>/verification.md`**

2. **逐项检查并标记:**
```markdown
### 1.1 Task Completion Check
- [x] **All tasks marked as Complete** in tasks.md
- [x] **No blocking TODOs remain**
- [x] **No blocking issues**

### 1.2 Code Quality Verification
- [x] **All linting passes**
  - **Command:** `npm run lint`
  - **Output:** 0 errors, 0 warnings
```

3. **如果验证失败,进入修复循环:**
   - 修复问题
   - 更新相关任务状态
   - 重新运行验证
   - 重复直到所有检查通过

4. **验证通过后,更新 Sign-Off 部分:**
```markdown
## Part 6: Final Sign-Off

**I have verified that:**
- [x] All required tasks are complete
- [x] All acceptance criteria are satisfied
- [x] All quality gates pass
- [x] All documentation is up to date
- [x] No critical TODOs remain

**Overall Assessment:**
- **Functional Completeness:** 100% complete
- **Quality Status:** 🟢 Excellent
- **Ready for:** Merge | PR

**Verified By:** [Agent Name]
**Verified At:** [Timestamp]
```
