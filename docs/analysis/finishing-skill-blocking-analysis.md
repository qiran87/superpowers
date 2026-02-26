# Finishing Skill "卡人"问题分析与改进方案

> **分析日期:** 2026-02-26
> **问题:** finishing-a-development-branch 技能在验收失败时"卡住"用户

---

## 🔴 问题诊断

### 当前设计的问题

**Step 1.5: Spec Workflow Final Acceptance** 中的硬性阻断：

```bash
# 当前代码 (第 111-119 行)
if [ "$IN_PROGRESS" -gt 0 ] || [ "$NOT_STARTED" -gt 0 ]; then
    echo "❌ Incomplete tasks detected:"
    [ "$IN_PROGRESS" -gt 0 ] && echo "   - In Progress: $IN_PROGRESS"
    [ "$NOT_STARTED" -gt 0 ] && echo "   - Not Started: $NOT_STARTED"
    echo ""
    echo "Cannot proceed with merge/PR until all tasks are complete."
    echo "Please complete remaining tasks or update tasks.md status."
    exit 1  # ← 这里卡住了！
fi
```

**问题链：**

1. **硬性阻断 (`exit 1`)**
   - 整个技能停止
   - 用户被困在验收环节
   - 无法返回任何工作流

2. **无修复路径**
   - 只说"不能继续"
   - 没说"下一步该做什么"
   - 没说"返回哪个技能"

3. **用户困惑**
   - ❓ 我应该手动编辑 tasks.md 吗？
   - ❓ 我应该返回 executing-plans 吗？
   - ❓ 我应该运行某个命令吗？
   - ❓ 我应该重启整个流程吗？

---

## 📊 问题影响分析

### 用户视角的"卡住"场景

**场景 1: 任务未完成**
```
用户 → 运行 finishing-a-development-branch
      ↓
      检测到 3 个 Not Started 任务
      ↓
      ❌ Cannot proceed... exit 1
      ↓
      🤷 用户：现在该干嘛？
```

**场景 2: verification.md 未签署**
```
用户 → 运行 finishing-a-development-branch
      ↓
      检测到 verification.md 未签署
      ↓
      ❌ Final sign-off not completed... exit 1
      ↓
      🤷 用户：我该用哪个技能完成签署？
```

**场景 3: P0 TODO 未处理**
```
用户 → 运行 finishing-a-development-branch
      ↓
      检测到 2 个 P0 TODO
      ↓
      ❌ P0 TODOs remain unaddressed... exit 1
      ↓
      🤷 用户：这些 TODO 该怎么处理？
```

---

## ✅ 改进方案对比

### 方案 A: 渐进式修复引导 ⭐ 推荐

**核心思想:** 检查 → 报告 → 提供修复选项 → 自动引导

```bash
# 改进后的代码
if [ "$IN_PROGRESS" -gt 0 ] || [ "$NOT_STARTED" -gt 0 ]; then
    echo "❌ Incomplete tasks detected:"
    [ "$IN_PROGRESS" -gt 0 ] && echo "   - In Progress: $IN_PROGRESS"
    [ "$NOT_STARTED" -gt 0 ] && echo "   - Not Started: $NOT_STARTED"
    echo ""
    echo "🔧 Fix Options:"
    echo ""
    echo "1. Complete remaining tasks"
    echo "   → Use: executing-plans skill (continue from task N)"
    echo ""
    echo "2. Update tasks.md status (if tasks are actually done)"
    echo "   → Mark tasks as ✅ Complete"
    echo "   → Re-run finishing-a-development-branch"
    echo ""
    echo "3. Defer incomplete tasks"
    echo "   → Mark as ⏸️ Deferred in tasks.md"
    echo "   → Re-run finishing-a-development-branch"
    echo ""
    echo "4. Skip this check (not recommended)"
    echo "   → Re-run with --skip-spec-workflow flag"
    echo ""

    # 询问用户下一步
    echo "Which action would you like to take?"
    echo "1-4, or 'cancel' to exit:"

    # 不再 exit 1，而是返回一个特殊代码
    # 让调用者知道需要修复
    return 1  # 而不是 exit 1
fi
```

**优点:**
- ✅ 提供清晰的修复路径
- ✅ 用户知道下一步该做什么
- ✅ 可以返回继续修复
- ✅ 保留强制跳过选项（风险明确）

**缺点:**
- ⚠️ 需要修改技能调用逻辑
- ⚠️ 增加了交互复杂度

---

### 方案 B: 自动修复尝试

**核心思想:** 尝试自动修复简单问题

```bash
# 检测简单可修复的问题
if [ "$IN_PROGRESS" -eq 0 ] && [ "$NOT_STARTED" -eq 1 ]; then
    # 只有一个未开始任务，可能是误标记
    echo "⚠️  Only 1 task not started - possibly mislabeled?"
    echo ""
    echo "Attempt auto-fix?"
    echo "y/n:"

    # 如果用户同意，尝试自动标记为完成
    # （如果有验证命令通过的话）
fi
```

**优点:**
- ✅ 自动化修复简单问题
- ✅ 减少用户手动操作

**缺点:**
- ❌ 只能处理简单场景
- ❌ 可能掩盖真实问题
- ❌ 复杂场景仍需人工介入

---

### 方案 C: 柔性检查模式

**核心思想:** 提供强制跳过选项（需确认风险）

```bash
# 检查 --skip-spec-workflow 标志
if [ "$SKIP_SPEC_WORKFLOW" = "true" ]; then
    echo "⚠️  WARNING: Skipping spec workflow verification!"
    echo ""
    echo "Risks:"
    echo "  - Merging incomplete work"
    echo "  - Missing verification"
    echo "  - Unaddressed P0/P1 TODOs"
    echo ""
    echo "Type 'I understand the risks' to proceed:"

    # 等待确认
    read -r CONFIRMATION
    if [ "$CONFIRMATION" = "I understand the risks" ]; then
        echo "⚠️  Proceeding without verification..."
    else
        echo "Cancelled."
        return 1
    fi
else
    # 正常检查逻辑
    ...
fi
```

**优点:**
- ✅ 保留专家用户的选择权
- ✅ 紧急情况下可以快速推进
- ✅ 风险明确告知

**缺点:**
- ❌ 可能被滥用
- ❌ 降低质量保障效果

---

### 方案 D: 智能修复建议 ⭐ 最优

**核心思想:** 根据问题类型提供定制化的修复建议

```bash
# 问题 1: 未完成任务
if [ "$IN_PROGRESS" -gt 0 ] || [ "$NOT_STARTED" -gt 0 ]; then
    echo "❌ Incomplete tasks detected"
    echo ""

    # 判断任务类型
    if [ "$IN_PROGRESS" -gt 0 ]; then
        # 有进行中任务 - 可能是状态更新问题
        echo "🔍 Diagnosis: $IN_PROGRESS task(s) marked as In Progress"
        echo ""
        echo "💡 Most likely cause: Task status not updated after completion"
        echo ""
        echo "🔧 Suggested fix:"
        echo "   1. Check if the tasks are actually complete"
        echo "   2. If yes, update status: ⏳ → ✅"
        echo "   3. Re-run: finishing-a-development-branch"
        echo ""
    fi

    if [ "$NOT_STARTED" -gt 0 ]; then
        # 有未开始任务
        echo "🔍 Diagnosis: $NOT_STARTED task(s) not started"
        echo ""

        if [ "$NOT_STARTED" -le 2 ]; then
            # 少量任务 - 可以快速完成
            echo "💡 Quick fix available: Complete remaining tasks"
            echo ""
            echo "🔧 Suggested action:"
            echo "   → Use: executing-plans skill"
            echo "   → Tasks will be auto-resumed from first Not Started"
            echo ""
        else
            # 大量任务 - 可能是计划问题
            echo "💡 Possible cause: Large number of incomplete tasks"
            echo ""
            echo "🔧 Options:"
            echo "   1. Complete remaining tasks (may take time)"
            echo "   2. Defer non-critical tasks to next iteration"
            echo "   3. Split work into smaller phases"
            echo ""
        fi
    fi

    # 提供快速修复命令
    echo "🚀 Quick actions:"
    echo "   a) Continue execution (executing-plans)"
    echo "   b) Edit tasks.md manually"
    echo "   c) Defer tasks to next iteration"
    echo "   d) Show task details"
    echo ""
    echo "Select option (a/b/c/d) or 'cancel':"

    return 1  # 允许返回和修复
fi

# 问题 2: verification.md 未签署
if [ -f "$VERIFICATION_FILE" ] && ! grep -qE "Implementation Complete.*✅" "$VERIFICATION_FILE"; then
    echo "❌ verification.md not signed"
    echo ""
    echo "🔍 Diagnosis: Final sign-off incomplete"
    echo ""
    echo "💡 Cause: Verification checklist not fully completed"
    echo ""
    echo "🔧 Suggested actions:"
    echo ""
    echo "1. Complete verification checklist"
    echo "   → Open: $VERIFICATION_FILE"
    echo "   → Complete Part 6: Final Sign-Off"
    echo "   → Mark: Implementation Complete: ✅"
    echo ""
    echo "2. Auto-complete verification (if all checks actually pass)"
    echo "   → Run: verification-before-completion skill"
    echo "   → It will auto-populate verification results"
    echo ""
    echo "3. Skip verification (not recommended)"
    echo "   → Re-run with --skip-verification flag"
    echo ""

    return 1
fi

# 问题 3: P0 TODO 未处理
if [ "$P0_COUNT" -gt 0 ]; then
    echo "❌ $P0_COUNT P0 TODO(s) found"
    echo ""
    echo "🔍 Diagnosis: Critical issues unresolved"
    echo ""

    # 显示具体 TODO
    echo "📋 Found P0 TODOs:"
    sed -n '/## TODOs & Gaps/,$ p' "$TASKS_FILE" | \
        grep -iE "Priority.*P0|P0.*Critical" | \
        grep -vE "^\s*-\s*\[x\]" | \
        head -5  # 只显示前5个
    echo ""

    echo "🔧 Options:"
    echo ""
    echo "1. Address P0 TODOs now"
    echo "   → Use: executing-plans skill with --focus-todos flag"
    echo ""
    echo "2. Defer to next iteration (only if not actually blocking)"
    echo "   → Re-evaluate priority in tasks.md"
    echo "   → Change P0 → P2 if appropriate"
    echo ""
    echo "3. Document as known limitation"
    echo "   → Add to verification.md Part 5: Known Limitations"
    echo "   → Requires explicit approval"
    echo ""

    return 1
fi
```

**优点:**
- ✅ 针对每种问题类型提供定制化建议
- ✅ 诊断原因，而不只是报告问题
- ✅ 提供多个修复选项
- ✅ 包含快速命令和详细指导
- ✅ 不硬性阻断，允许返回修复

**缺点:**
- ⚠️ 实现复杂度较高
- ⚠️ 需要更详细的错误分类

---

## 📋 推荐实施方案

### 阶段 1: 最小可行改进（立即实施）

**目标:** 解决"卡住"问题，提供基本修复路径

**改动:**
1. 将所有 `exit 1` 改为 `return 1`
2. 在每个检查失败后添加基本修复建议
3. 不改变技能调用逻辑

**示例:**
```bash
# Before
if [ "$IN_PROGRESS" -gt 0 ]; then
    echo "❌ Incomplete tasks"
    exit 1
fi

# After
if [ "$IN_PROGRESS" -gt 0 ]; then
    echo "❌ Incomplete tasks detected: $IN_PROGRESS"
    echo ""
    echo "🔧 To fix:"
    echo "   1. Complete tasks: Use 'executing-plans' skill"
    echo "   2. Update status: Edit tasks.md, mark as ✅ Complete"
    echo "   3. Defer tasks: Mark as ⏸️ Deferred if not critical"
    echo ""
    return 1
fi
```

### 阶段 2: 智能诊断（短期优化）

**目标:** 提供问题诊断和针对性建议

**改动:**
1. 添加问题分类逻辑
2. 针对每种问题类型提供定制建议
3. 添加交互式修复选项

### 阶段 3: 自动修复集成（长期优化）

**目标:** 集成自动修复能力

**改动:**
1. 检测可自动修复的问题
2. 提供自动修复选项
3. 集成到相关工作流技能

---

## 🎯 核心设计原则

### 从 "阻止" 到 "引导"

| 当前设计 | 改进设计 |
|---------|---------|
| ❌ 检查失败 → exit 1 → 停止 | ✅ 检查失败 → 报告 → 引导修复 |
| "不能继续" | "问题：X，修复：Y，命令：Z" |
| 用户被困 | 用户知道下一步 |
| 退出码无意义 | 返回码指示修复路径 |

### 从 "检测" 到 "诊断"

| 当前设计 | 改进设计 |
|---------|---------|
| "未完成任务: 3" | "诊断：3个任务未开始" |
| "可能原因: ?" | "最可能原因：任务状态未更新" |
| "修复: ?" | "建议修复：检查并更新状态" |

### 从 "单一" 到 "多选"

| 当前设计 | 改进设计 |
|---------|---------|
| 只有一种退出方式 | 多个修复选项 |
| 强制执行 | 用户选择 |
| 无灵活性 | 有紧急跳过选项 |

---

## 📝 实施检查清单

### 阶段 1 实施清单

- [ ] 将所有 `exit 1` 改为 `return 1`
- [ ] 添加基本修复建议（每个检查点）
- [ ] 更新技能文档
- [ ] 测试所有失败场景

### 阶段 2 实施清单

- [ ] 实现问题分类逻辑
- [ ] 添加诊断信息
- [ ] 实现交互式修复选项
- [ ] 更新技能文档

### 阶段 3 实施清单

- [ ] 集成自动修复检测
- [ ] 实现修复建议算法
- [ ] 添加工作流集成
- [ ] 完整测试覆盖

---

## 🔄 工作流集成

### 改进后的完整流程

```
用户运行 finishing-a-development-branch
    ↓
Step 1.5: Spec Workflow 检查
    ↓
    ├─ 通过 ✅ → 继续 Step 2
    │
    └─ 失败 ❌ → 报告 + 引导
                  ↓
                  用户选择:
                  ├─ a) 继续执行 (executing-plans)
                  ├─ b) 手动编辑 (tasks.md)
                  ├─ c) 延后处理 (标记 Deferred)
                  └─ d) 查看详情 (显示任务)
                  ↓
                  修复后重新运行
                  ↓
                  Step 1.5: Spec Workflow 检查
                  ↓
                  (循环直到通过或用户取消)
```

---

## 📊 预期效果

### 用户体验改进

**Before:**
```
$ finishing-a-development-branch
❌ Incomplete tasks: 3
Cannot proceed with merge/PR
[进程退出]
$ # 用户被困，不知道下一步
```

**After:**
```
$ finishing-a-development-branch
❌ Incomplete tasks detected: 3

🔍 Diagnosis: 2 tasks In Progress, 1 task Not Started
💡 Most likely cause: Task status not updated after completion

🔧 Suggested actions:
1. Complete remaining tasks
   → Use: executing-plans skill (continue from task 5)

2. Update task status (if tasks are actually done)
   → Mark tasks as ✅ Complete in tasks.md
   → Re-run: finishing-a-development-branch

3. Show task details
   → List all incomplete tasks with descriptions

Select action (1/2/3) or 'cancel': 1

[自动继续执行剩余任务]
```

---

## 结论

**当前"卡人"问题的根本原因:**
- 硬性阻断 (`exit 1`) 而不是柔性引导
- 缺少修复路径和下一步指导
- 用户不知道如何继续

**推荐改进方案:**
- **短期:** 阶段 1 - 改 `exit 1` 为 `return 1`，添加基本修复建议
- **中期:** 阶段 2 - 添加智能诊断和交互式修复选项
- **长期:** 阶段 3 - 集成自动修复能力

**核心设计理念转变:**
- 从 "检查 → 阻止" 到 "检查 → 诊断 → 引导"
- 从 "用户被困" 到 "用户知道下一步"
- 从 "单一失败模式" 到 "多个修复选项"
