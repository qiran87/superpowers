# Code Structure Reader - 测试指南

**测试对象**: code-structure-reader技能
**测试方法**: TDD (Test-Driven Development)

---

## 📋 测试文件说明

| 文件 | 用途 |
|------|------|
| `test-cases.md` | TDD测试用例完整文档 |
| `setup-test-scenarios.sh` | 创建4个测试场景 |
| `run-baseline-tests.sh` | 运行RED阶段基线测试 |

---

## 🚀 快速开始

### Step 1: 创建测试场景

```bash
# 在superpowers根目录执行
cd tests/claude-code-structure-reader
python3 setup-test-scenarios.py
```

**预期输出**:
- ✅ 创建 `/tmp/test-code-structure-reader/` 目录
- ✅ 4个测试场景(scenario1-4)
- ✅ 每个场景包含测试项目、README和测试要点

---

### Step 2: 生成测试记录模板 (RED阶段)

```bash
# 确保在tests目录执行
python3 run-baseline-tests.py
```

**测试流程**:
1. 脚本会为每个场景生成测试记录模板
2. 显示每个场景的手动测试指南
3. 按Enter继续下一个场景，或输入'skip'跳过
4. 自动生成测试记录: `baseline-result-*.md`

**观察要点**:
- ✅ 子代理是否执行五层分析？
- ✅ 是否生成11个领域文档？
- ✅ 文档组织是否合理(按环节而非按文件)？
- ✅ 是否创建交互式索引？
- ✅ 分析时间是否符合预期(<5分钟小项目,<20分钟中项目)?

**记录位置**:
- 测试记录会保存到: `/tmp/test-code-structure-reader/baseline-result-*.md`

---

### Step 3: 收集基线数据

运行所有4个场景后,查看生成的测试记录文件:

```bash
# 查看所有基线测试结果
ls /tmp/test-code-structure-reader/baseline-result-*.md
```

**关键信息**:
- 每个场景的"发现的问题"章节
- 每个场景的"预期合理化"章节
- 收集所有合理化借口

---

### Step 4: 更新test-cases.md

将收集到的基线数据更新到 `test-cases.md` 的Phase 3 REFACTOR章节:

```markdown
## Phase 3: REFACTOR - 识别并关闭合理化漏洞

### 基线收集的合理化

| 借口 | 来源 |
|------|------|
| "项目太特殊,不适用" | Scenario 1 |
| "分析耗时,不如直接看代码" | Scenario 2 |
| ... | ... |

### 合理化对策
[在SKILL.md中添加Red Flags列表]
```

---

## 📊 TDD循环

```
RED (观察失败) → GREEN (编写技能) → REFACTOR (优化技能)
```

### 当前状态

- ✅ **RED阶段**: 测试用例已编写,准备执行
- ⏳ **GREEN阶段**: 待基线测试完成后,基于发现的问题编写技能
- ⏳ **REFACTOR阶段**: 待GREEN阶段完成后,识别新的合理化

---

## ✅ 完成标准

### RED阶段完成标准

- ✅ 4个测试场景全部创建
- ✅ 基线测试脚本已编写
- ✅ 测试用例文档完整

### 下一步

1. ✅ 执行基线测试,收集失败数据
2. ✅ 基于收集的问题更新SKILL.md (GREEN阶段)
3. ✅ 识别新的合理化并添加到技能 (REFACTOR阶段)
4. ✅ 执行技能测试,验证改进效果

---

## 🔍 测试检查清单

执行基线测试前,确认:

- [ ] 已阅读 `test-cases.md` 理解测试目标
- [ ] 已创建测试场景 (Step 1)
- [ ] 准备好记录模板
- [ ] 清理旧的测试数据 (`rm -rf /tmp/test-code-structure-reader`)
- [ ] 确保有充足时间观察每个场景

---

## 💡 测试技巧

1. **不要干预**: 让子代理自然执行,观察真实行为
2. **记录详细**: 在测试记录文件中写下具体观察
3. **收集借口**: 注意子代理说的所有"合理化"借口
4. **时间压力**: 观察子代理在5分钟时限内的行为变化

---

**测试准备工作完成!**
