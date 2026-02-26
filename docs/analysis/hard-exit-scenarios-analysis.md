# 全项目硬性退出场景分析

> **分析日期:** 2026-02-26
> **目的:** 找出所有可能使用 `exit 1` 硬性阻断流程的场景
> **目标:** 区分哪些需要修改，哪些可以保留

---

## 📊 搜索结果汇总

### 按文件类型分类

| 类型 | 文件数 | `exit 1` 数量 | 是否需要修改 |
|-----|--------|--------------|-------------|
| **文档类 (docs/)** | 5+ | ~10 | ❌ 不需要（说明文档） |
| **测试脚本 (tests/*.sh)** | 21 | ~30+ | ❌ 不需要（测试失败应停止） |
| **技能文件 (skills/*.md)** | 3 | ~20+ | ⚠️ 需要评估 |
| **代理文件 (agents/*.md)** | 0 | 0 | ✅ 无问题 |

---

## 🔍 技能文件详细分析

### 1. verification-before-completion/SKILL.md

**`exit 1` 数量:** ~20 处

**场景分类:**

#### 类型 A: 验证命令示例（可保留 ✅）

这些是**示例代码**，展示如何在脚本中验证：

```bash
# 示例 1: 服务健康检查
curl -f http://localhost:3000/health || exit 1

# 示例 2: 文件内容验证
grep "expected_string" output.log || exit 1

# 示例 3: 进程验证
pgrep -f "my_service" || exit 1
```

**判断:** ✅ **应该保留**
- 这些是用户脚本示例，不是技能本身
- 在用户脚本中 `exit 1` 是合理的（验证失败应该停止）
- 技能只是展示最佳实践

#### 类型 B: 技能核心逻辑（需评估 ⚠️）

需要检查技能核心逻辑中是否有硬性退出。

---

### 2. protocol-compliance-check/SKILL.md

**`exit 1` 数量:** 1 处（第 140 行）

**场景:**
```bash
# Step 1: Read Protocol Documentation
if [ ! -d "docs/project-analysis" ]; then
    echo "❌ Missing project-analysis. Run superpowers:code-structure-reader first"
    exit 1
fi
```

**判断:** ⚠️ **需要讨论**

**问题分析:**
- 这是**前置条件检查**
- 缺少必需的文档确实无法继续
- 但是 `exit 1` 会杀死整个技能进程

**改进选项:**
- **选项 1:** 改为 `return 100` + 引导用户运行 code-structure-reader
- **选项 2:** 保留 `exit 1`（因为缺少前置条件确实无法继续）
- **选项 3:** 添加自动调用 code-structure-reader 的逻辑

---

### 3. design-with-existing-modules/SKILL.md

**`exit 1` 数量:** 1 处（第 124 行）

**场景:**
```bash
# Verify project-analysis directory exists
if [ -d "docs/project-analysis" ]; then
    echo "✓ Project analysis found"
else
    echo "✗ No project analysis. Run superpowers:code-structure-reader first"
    exit 1
fi
```

**判断:** ⚠️ **需要讨论**（同上）

---

### 4. finishing-a-development-branch/SKILL.md

**`exit 1` 数量:** 0 处（已修改 ✅）

**状态:** 已在本次改进中修改为 `return 100/101`

---

## 📋 需要讨论的场景汇总

### 场景 1: 前置条件检查失败

**文件:**
- `protocol-compliance-check/SKILL.md` (第 140 行)
- `design-with-existing-modules/SKILL.md` (第 124 行)

**当前行为:**
```bash
if [ ! -d "docs/project-analysis" ]; then
    echo "❌ Missing project-analysis. Run superpowers:code-structure-reader first"
    exit 1  # ← 硬性退出
fi
```

**问题:**
- 缺少必需的前置条件（文档分析）
- `exit 1` 会杀死技能进程
- 用户被困，不知道如何恢复

**改进选项:**

| 选项 | 改动 | 优点 | 缺点 |
|-----|------|------|------|
| **A. 引导式返回** | 改为 `return 100` + 清晰指引 | 进程存活，可恢复 | 需要用户手动运行前置技能 |
| **B. 自动调用** | 自动调用 code-structure-reader | 一键解决，无需手动 | 可能覆盖用户意图 |
| **C. 保留 exit** | 保持现状 | 简单明确 | 会卡住流程 |

**推荐:** **选项 A** - 引导式返回
- 保持用户控制权
- 提供清晰的下一步指引
- 可以在修复后继续

---

### 场景 2: 验证命令示例

**文件:**
- `verification-before-completion/SKILL.md`

**`exit 1` 用途:** 示例代码

**判断:** ✅ **应该保留**
- 这些是**用户脚本示例**，不是技能逻辑
- 在验证脚本中 `exit 1` 是合理的
- 技能只是展示最佳实践

**建议:** 在文档中添加说明
```markdown
**Note:** These are example verification scripts. In your scripts,
`exit 1` is appropriate for verification failures. The skill itself
uses `return 100` for graceful pause.
```

---

### 场景 3: 测试脚本

**文件:**
- `tests/*.sh` (21 个文件)

**判断:** ❌ **不需要修改**
- 测试脚本失败应该停止
- 这是测试的预期行为
- 不影响技能工作流

---

### 场景 4: 文档和说明

**文件:**
- `docs/analysis/*.md`
- `docs/implementation/*.md`

**判断:** ❌ **不需要修改**
- 这些是说明文档
- 记录问题和解决方案
- 不是可执行代码

---

## 🎯 推荐修改清单

### 高优先级（建议修改）

| # | 文件 | 行号 | 场景 | 当前行为 | 建议行为 | 原因 |
|---|------|------|------|---------|---------|------|
| 1 | `protocol-compliance-check/SKILL.md` | 140 | 前置条件检查 | `exit 1` | `return 100` + 引导 | 避免卡住流程 |
| 2 | `design-with-existing-modules/SKILL.md` | 124 | 前置条件检查 | `exit 1` | `return 100` + 引导 | 避免卡住流程 |

### 低优先级（可选改进）

| # | 文件 | 场景 | 当前行为 | 建议行为 | 原因 |
|---|------|------|---------|---------|------|
| 3 | `verification-before-completion/SKILL.md` | 验证示例 | `exit 1` | 添加说明文档 | 澄清示例 vs 技能逻辑 |

### 不需要修改

| 类型 | 原因 |
|-----|------|
| 测试脚本 (`tests/*.sh`) | 测试失败应该停止 |
| 文档 (`docs/*.md`) | 说明文档，不是可执行代码 |
| 已修改文件 | `finishing-a-development-branch` 已修复 |

---

## 💡 改进建议详情

### 建议 1: protocol-compliance-check 前置条件检查

**Before:**
```bash
if [ ! -d "docs/project-analysis" ]; then
    echo "❌ Missing project-analysis. Run superpowers:code-structure-reader first"
    exit 1
fi
```

**After:**
```bash
if [ ! -d "docs/project-analysis" ]; then
    echo "❌ Missing project-analysis"
    echo ""
    echo "🔧 To fix:"
    echo "   Required: Project structure analysis"
    echo "   Action: Use superpowers:code-structure-reader skill"
    echo ""
    echo "   Example workflow:"
    echo "   1. Run: superpowers:code-structure-reader"
    echo "   2. Wait for analysis to complete (~5-10 min)"
    echo "   3. Re-run this skill"
    echo ""
    echo "⏸️  Paused - Run code-structure-reader first"
    echo ""

    return 100  # Custom code: prerequisite missing
fi
```

---

### 建议 2: design-with-existing-modules 前置条件检查

**Before:**
```bash
if [ ! -d "docs/project-analysis" ]; then
    echo "✗ No project analysis. Run superpowers:code-structure-reader first"
    exit 1
fi
```

**After:**
```bash
if [ ! -d "docs/project-analysis" ]; then
    echo "✗ No project analysis found"
    echo ""
    echo "🔧 To fix:"
    echo "   Required: Project structure analysis for module discovery"
    echo "   Action: Use superpowers:code-structure-reader skill"
    echo ""
    echo "   Why needed: Cannot design with existing modules without"
    echo "   knowing what modules exist"
    echo ""
    echo "   Example workflow:"
    echo "   1. Run: superpowers:code-structure-reader"
    echo "   2. Wait for analysis to complete"
    echo "   3. Re-run this skill"
    echo ""
    echo "⏸️  Paused - Run code-structure-reader first"
    echo ""

    return 100  # Custom code: prerequisite missing
fi
```

---

### 建议 3: verification-before-completion 添加说明

在 `Verification Methods` 部分添加说明：

```markdown
## Verification Methods

**Note on exit codes in verification scripts:**

The examples below use `exit 1` for verification failures. This is
**intentional and correct** for standalone verification scripts:

```bash
# In your verification script
curl -f http://localhost:3000/health || exit 1  # ✅ Correct
```

**However**, the skill itself uses `return 100` for graceful pause:

```bash
# In the skill logic
if ! verification_passes; then
    return 100  # ✅ Graceful pause, not exit
fi
```

**Difference:**
- **`exit 1`** in scripts: Terminate the script (correct for verification)
- **`return 100`** in skills: Pause the skill, allow recovery
```

---

## 🤔 需要讨论的问题

### 问题 1: 是否应该自动调用前置技能？

**场景:** `protocol-compliance-check` 需要 `code-structure-reader` 先运行

**选项 A: 引导用户手动运行**
```bash
echo "Run: superpowers:code-structure-reader"
return 100
```
- ✅ 保持用户控制权
- ❌ 需要手动操作

**选项 B: 自动调用前置技能**
```bash
echo "Missing project-analysis, auto-generating..."
Skill superpowers:code-structure-reader
# 等待完成，然后继续
```
- ✅ 一键解决
- ❌ 可能覆盖用户意图
- ❌ 增加复杂度

**你的意见?**

---

### 问题 2: 前置条件检查是硬性阻断还是可绕过？

**场景:** 缺少 `docs/project-analysis`

**选项 A: 硬性要求（当前）**
```bash
if [ ! -d "docs/project-analysis" ]; then
    return 100  # 必须先运行 code-structure-reader
fi
```

**选项 B: 可选但有警告**
```bash
if [ ! -d "docs/project-analysis" ]; then
    echo "⚠️  No project-analysis found, continuing without it"
    echo "   Results may be incomplete"
    # 继续执行，但标记结果为"部分"
fi
```

**你的意见?**

---

## 📊 决策矩阵

| 场景 | 影响范围 | 用户控制 | 改动成本 | 推荐优先级 |
|-----|---------|---------|---------|-----------|
| protocol-compliance-check 前置条件 | 中 | 高 | 低 | **高** |
| design-with-existing-modules 前置条件 | 中 | 高 | 低 | **高** |
| verification-before-completion 说明 | 低 | N/A | 低 | 低 |

---

## ✅ 你的决策

请告诉我：

1. **protocol-compliance-check 和 design-with-existing-modules 的前置条件检查**
   - [ ] 修改为 `return 100` + 引导（推荐）
   - [ ] 保留 `exit 1`
   - [ ] 添加自动调用逻辑
   - [ ] 其他：______

2. **前置条件是否应该可绕过**
   - [ ] 硬性要求（必须先运行前置技能）
   - [ ] 可选但有警告（可以绕过，结果不完整）

3. **verification-before-completion 的示例说明**
   - [ ] 添加说明文档（推荐）
   - [ ] 不需要

4. **其他你关心的问题**
   - ________
