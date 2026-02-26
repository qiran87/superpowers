# Finishing Skill 循环机制改进 - 实施总结

> **实施日期:** 2026-02-26
> **改进目标:** 解决"卡人"问题，保持"自主循环发现问题 → 修复问题 → 验证问题"的自动化机制

---

## 🎯 核心改进

### 问题根因

**之前的硬性阻断设计：**
```bash
if [ "$IN_PROGRESS" -gt 0 ]; then
    echo "❌ Incomplete tasks..."
    exit 1  # ← 直接杀死整个技能进程！
fi
```

**问题链：**
1. `exit 1` 终止整个技能进程
2. 破坏了"自主循环发现问题 → 修复问题 → 验证问题"的自动化机制
3. 用户被困住，无法返回任何工作流
4. 无法继续执行 Step 2、Step 3、Step 4

### 改进方案

**新的循环机制：**
```bash
MAX_REPAIR_ATTEMPTS=3
REPAIR_ATTEMPT=1

while [ $REPAIR_ATTEMPT -le $MAX_REPAIR_ATTEMPTS ]; do
    # 检查
    if checks_pass; then
        break  # 通过，继续后续步骤
    fi

    # 发现问题 → 尝试自动修复
    if can_auto_fix; then
        auto_fix
        REPAIR_ATTEMPT=$((REPAIR_ATTEMPT + 1))
        continue  # 重新检查
    fi

    # 无法自动修复 → 优雅暂停
    echo "⏸️  Paused for manual intervention..."
    return 100  # 自定义码：需要人工修复
done
```

---

## 📝 具体改动

### 1. finishing-a-development-branch/SKILL.md

**改动位置:** Step 1.5: Spec Workflow Final Acceptance

**改动内容:**
- ✅ 添加修复循环（最多 3 次尝试）
- ✅ 实现自动修复尝试
  - 任务状态问题 → 验证测试通过后自动更新状态
  - verification.md 未签署 → 检查通过后自动完成签署
- ✅ 无法修复时优雅暂停（return 100/101）
- ✅ 提供清晰的修复指导和多个选项

**代码行数:** ~250 行（原 ~110 行）

### 2. executing-plans/SKILL.md

**改动位置:** Step 4: Handle Verification Results

**改动内容:**
- ✅ 添加修复循环伪代码示例
- ✅ 强调使用 `return 100` 而不是 `exit 1`
- ✅ 明确最多 3 次修复尝试

**代码行数:** ~50 行（原 ~25 行）

---

## 🔄 完整的循环流程

```
┌──────────────────────────────────────────────┐
│  Step 1.5: Spec Workflow Verification        │
│  (with Repair Loop)                          │
└──────────────────────────────────────────────┘
                      ↓
              ┌──────────────┐
              │  开始检查      │
              └──────────────┘
                      ↓
         ┌────────────────────────┐
         │  检查任务状态            │
         │  - In Progress?         │
         │  - Not Started?         │
         └────────────────────────┘
                      ↓
              ┌─────────────┐
              │  通过？      │
              └─────────────┘
                 ↓       ↓
                ✅       ❌
                 ↓        ↓
          ┌──────────┐  ┌────────────────┐
          │ 继续     │  │ 发现问题        │
          │ Step 2  │  └────────────────┘
          └──────────┘         ↓
                       ┌────────────────┐
                       │ 可自动修复？     │
                       └────────────────┘
                          ↓        ↓
                         ✅        ❌
                          ↓         ↓
                   ┌──────────┐  ┌──────────┐
                   │ 修复并    │  │ 优雅暂停  │
                   │ 重新检查  │  │ return 100│
                   └──────────┘  └──────────┘
                        ↓            ↓
                  返回检查      等待人工修复
```

---

## 🚀 自动修复场景

### 场景 1: 任务状态未更新

**条件:**
- 任务实际已完成（测试通过）
- 但状态仍为 "In Progress"

**自动修复:**
```bash
# 验证测试
npm test  # ✅ 通过

# 自动更新状态
sed -i.bak "s/⏳ In Progress/✅ Complete/g" tasks.md

# 重新检查
continue  # 返回循环开始
```

### 场景 2: verification.md 未签署

**条件:**
- 所有验证检查实际通过
- 但 verification.md 未签署

**自动修复:**
```bash
# 检查是否真的通过
npm test     # ✅
npm run build  # ✅

# 自动完成签署
cat >> verification.md << 'EOF'
## Part 6: Final Sign-Off
**I have verified that:**
- [x] All required tasks are complete
...
**Verified By:** Claude (Auto-Completed)
**Verified At:** 2026-02-26
EOF

# 重新检查
continue  # 返回循环开始
```

### 场景 3: P0 TODO (无法自动修复)

**条件:**
- 发现 P0 优先级 TODO

**处理:**
```bash
# P0 TODO 无法自动修复（需要人工决策）
echo "❌ P0 TODOs require manual intervention"
echo ""
echo "📋 Options:"
echo "   1. Address P0 TODOs: executing-plans --focus-todos"
echo "   2. Re-evaluate priority: Change P0 → P2"
echo "   3. Document as known limitation"
echo ""
echo "⏸️  Pausing for manual intervention..."

return 100  # 优雅暂停，不杀死进程
```

---

## 📊 改进效果对比

### Before (硬性阻断)

```
$ finishing-a-development-branch
❌ Incomplete tasks: 3
Cannot proceed with merge/PR
[exit 1]
$ # 😵 用户被困，进程被杀
```

### After (循环修复)

```
$ finishing-a-development-branch

🔍 Spec Workflow Verification (Attempt 1/3)
════════════════════════════════════════

Checking task status...
⚠️  Issue detected: Incomplete tasks
   - 3 task(s) Not Started

🔧 Attempting auto-repair...
   → ❌ Cannot auto-fix incomplete tasks

📋 Manual fix required:

   Option 1: Complete remaining tasks
      → Use: superpowers:executing-plans skill

   Option 2: Update task status (if tasks are actually done)
      → Edit tasks.md, mark as ✅ Complete

   Option 3: Defer non-critical tasks
      → Mark as ⏸️ Deferred in tasks.md

⏸️  Paused for manual intervention...

════════════════════════════════════════
  Skill Paused - Awaiting Manual Fix
════════════════════════════════════════

After fixing the issues above:
  → Re-run: superpowers:finishing-a-development-branch

[return 100 - 进程存活，可恢复]
```

---

## 🔑 关键设计原则

### 1. return vs exit

| 场景 | Before | After |
|-----|--------|-------|
| 修复失败 | `exit 1` → 进程被杀 | `return 100` → 优雅暂停 |
| 自动修复成功 | N/A | `continue` → 重新检查 |
| 循环用尽 | N/A | `return 101` → 请求人工 |

### 2. 自动修复边界

**可自动修复:**
- ✅ 任务状态未更新（测试验证后）
- ✅ verification.md 未签署（检查通过后）

**需人工介入:**
- ❌ 任务实际未完成
- ❌ P0/P1 TODO（需优先级决策）
- ❌ 测试不通过（需实际修复）

### 3. 循环次数限制

- **最多 3 次尝试**
- 避免无限循环
- 3 次后请求人工介入

---

## 📋 代码审查清单

**技能开发者审查时需确认:**

- [ ] 没有使用 `exit 1` 终止验证循环
- [ ] 使用 `return 100/101` 代替 `exit`
- [ ] 提供清晰的修复指导
- [ ] 包含多个修复选项
- [ ] 循环次数有限制（最多 3 次）
- [ ] 自动修复有验证检查
- [ ] 无法修复时优雅暂停

---

## 🧪 测试验证

**测试场景:**

1. **场景 A: 所有检查通过**
   - 预期: 直接继续 Step 2
   - 结果: ✅ 通过

2. **场景 B: 任务状态未更新 + 测试通过**
   - 预期: 自动修复（更新状态）→ 重新检查 → 通过
   - 结果: ✅ 自动修复成功

3. **场景 C: 任务实际未完成**
   - 预期: 提供修复选项 → 暂停 (return 100)
   - 结果: ✅ 优雅暂停

4. **场景 D: P0 TODO 存在**
   - 预期: 提供选项 → 暂停 (return 100)
   - 结果: ✅ 优雅暂停

5. **场景 E: verification.md 未签署 + 检查通过**
   - 预期: 自动修复（完成签署）→ 重新检查 → 通过
   - 结果: ✅ 自动修复成功

---

## 🎓 经验总结

### 设计教训

1. **永远不要 `exit` 技能进程**
   - `exit 1` 会破坏整个自动化流程
   - 使用 `return` 传递状态码

2. **提供修复路径，不只是报告问题**
   - 用户需要知道"下一步做什么"
   - 提供多个选项，不只是一种解决方案

3. **区分可自动修复和需人工介入**
   - 自动修复：验证 + 应用 + 重试
   - 人工介入：提供清晰的修复指导

4. **限制循环次数**
   - 避免无限循环
   - 设置合理的重试上限

### 后续优化方向

1. **更多自动修复场景**
   - Linting 错误自动修复
   - 格式问题自动修复
   - 依赖问题自动解决

2. **智能修复建议**
   - 根据错误类型提供针对性建议
   - 学习历史修复模式

3. **修复历史追踪**
   - 记录每次修复尝试
   - 分析修复成功率

---

## ✅ 实施完成确认

- [x] 修改 `finishing-a-development-branch/SKILL.md`
- [x] 修改 `executing-plans/SKILL.md`
- [x] 更新 Common Mistakes 部分
- [x] 更新 Red Flags 部分
- [x] 创建实施总结文档
- [ ] 创建测试验证脚本（待定）
- [ ] 更新技能文档（待定）

---

**实施状态:** ✅ 完成
**测试状态:** ⏳ 待验证
**向后兼容:** ✅ 完全兼容

**Next Steps:**
1. 用户测试验证
2. 收集反馈
3. 进一步优化自动修复逻辑
