# Code Structure Reader - TDD测试用例

**创建日期**: 2025-02-11
**测试对象**: code-structure-reader技能
**测试方法**: Subagent压力测试

---

## 测试策略

### TDD流程

```
RED → GREEN → REFACTOR
  ↓        ↓         ↓
观察失败  编写技能  优化技能
```

### 测试类型

**压力测试 (Stress Testing)**:
- 时间压力："现在是6pm,晚餐在6:30pm"
- 沉没成本："你已经花了4小时在这个任务上"
- 权威压力："高级开发人员说这样做"
- 疲劳压力："连续5个任务后的第6个"

**场景测试 (Scenario Testing)**:
- 应用场景：新人入职、技术方案设计、代码审查、技术债务分析
- 变体场景：小项目(<50文件)、中项目(<500文件)、大项目(>500文件)
- 技术栈变体：JavaScript、Python、Java、Monorepo

---

## Phase 1: RED - 观察失败

### 测试场景定义

#### Scenario 1: 新人入职 - 快速理解项目

**场景描述**:
新成员加入一个React+Express项目,需要在30分钟内理解项目结构并启动开发环境。

**测试设置**:
```bash
# 创建测试项目
TEST_PROJECT_DIR="/tmp/test-code-structure-react-express"
mkdir -p "$TEST_PROJECT_DIR"

# 创建典型的React+Express项目结构
cd "$TEST_PROJECT_DIR"
cat > package.json << 'EOF'
{
  "name": "test-project",
  "dependencies": {
    "react": "^18.2.0",
    "express": "^4.18.2",
    "lodash": "^4.17.21"
  }
}
EOF

# 创建典型目录结构
mkdir -p src/{frontend/{pages,components},backend/{api,domain,repository}}
mkdir -p tests docs

# 创建一些代码文件
cat > src/frontend/pages/LoginPage.tsx << 'EOF'
export const LoginPage = () => {
  return <div>Login</div>;
};
EOF

cat > src/backend/api/auth.ts << 'EOF'
export const login = (req, res) => {
  res.json({token: 'fake'});
};
EOF

echo "✅ 测试项目创建完成: $TEST_PROJECT_DIR"
```

**基线行为 (无技能)**:

派生子代理，观察其行为：
- 子代理是否分析目录结构？
- 子代理是否生成开发指南？
- 子代理是否创建11个文档文件？
- 生成的文档是否合理？

**成功标准**:
- ❌ 没有systematic分析流程
- ❌ 可能只运行几个命令就返回
- ❌ 文档组织混乱（可能按文件生成）
- ❌ 没有增量更新机制

**预期合理化**:
- "这个项目很简单，tree命令就行了"
- "用户只要看README就够了"
- "分析这么久，不如直接看代码"

**压力类型**: 时间压力（设定5分钟完成）

---

#### Scenario 2: 技术方案设计 - 查找现有能力

**场景描述**:
需要添加"用户评论"功能，在技术方案设计阶段需要了解项目是否已有类似功能和可复用组件。

**测试设置**:
```bash
# 在测试项目中添加评论功能
cat > src/frontend/components/CommentBox.tsx << 'EOF'
export const CommentBox = ({comment}) => {
  return <div className="comment-box">{comment}</div>;
};
EOF

cat > src/backend/api/comments.ts << 'EOF'
export const getComments = (req, res) => {
  res.json([{id: 1, text: 'existing comment'}]);
};
EOF

echo "✅ 测试数据准备完成：已有评论功能"
```

**基线行为 (无技能)**:

派生子代理，观察其行为：
- 子代理是否扫描现有API发现评论功能？
- 子代理是否提示可以复用CommentBox组件？
- 子代理是否分析依赖关系？

**成功标准**:
- ❌ 没有对比现有能力
- ❌ 可能建议重新开发
- ❌ 缺少API目录和组件清单

**预期合理化**:
- "评论功能很简单，直接开发更快"
- "组件清单太耗时，先写功能再说"
- "用户知道要什么，不需要我提醒"

**压力类型**: 沉没成本（"你已经在类似项目花了4小时"）

---

#### Scenario 3: 代码审查 - 理解影响范围

**场景描述**:
审查一个PR，该PR修改了AuthService，需要了解这个改动会影响哪些其他模块。

**测试设置**:
```bash
# 创建测试场景：修改AuthService
# 假设原本的依赖关系
cat > test_scenario.txt << 'EOF'
Original dependencies:
- AuthService被以下模块依赖:
  - UserController (登录)
  - SessionManager (会话管理)
  - ApiService (第三方调用)

PR修改内容:
- AuthService添加了refreshToken方法
EOF

echo "✅ 测试场景准备完成"
```

**基线行为 (无技能)**:

派生子代理，观察其行为：
- 子代理是否分析依赖关系？
- 子代理是否识别出受影响的模块？
- 子代理是否生成影响范围报告？

**成功标准**:
- ❌ 没有分析模块依赖
- ❌ 没有识别影响范围
- ❌ 可能手动grep，遗漏隐藏依赖

**预期合理化**:
- "影响范围太复杂，用户自己看"
- "git diff就能看到改动"
- "分析依赖关系太耗时"

**压力类型**: 时间压力（3分钟完成分析）

---

#### Scenario 4: 大型项目 - 性能测试

**场景描述**:
在一个包含1000+个文件的大型项目中测试分析性能。

**测试设置**:
```bash
# 创建大型测试项目
LARGE_PROJECT_DIR="/tmp/test-large-project"
mkdir -p "$LARGE_PROJECT_DIR"

# 创建1000个模拟文件
cd "$LARGE_PROJECT_DIR"
for i in {1..1000}; do
  echo "// File $i" > "src/file$i.js"
done

# 创建子目录
mkdir -p src/{api,domain,utils,models}

echo "✅ 大型测试项目创建完成：1000个文件"
```

**基线行为 (无技能)**:

派生子代理，观察其行为：
- 分析时间是否超过20分钟？
- 内存占用是否超过2GB？
- 是否超时？

**成功标准**:
- ❌ 分析时间过长（>30分钟）
- ❌ 内存占用过高
- ❌ 可能卡住或崩溃

**预期合理化**:
- "项目太大了，分批处理吧"
- "先分析一部分，其他的以后再说"
- "可以跳过某些文件"

**压力类型**: 疲劳（连续多个任务后的第4个）

---

## Phase 2: RED - 执行基线测试

### 执行命令

```bash
# 测试辅助函数
run_baseline_test() {
  local test_name="$1"
  local project_dir="$2"

  echo "🔴 运行基线测试: $test_name"
  echo "项目路径: $project_dir"
  echo ""

  # 派生子代理
  # 注意：不加载code-structure-reader技能

  claude --prompt "
    测试项目: $project_dir
    任务: $test_name

    请分析这个项目结构。
    不要生成任何文档，只要告诉我你的分析过程和发现。
    限时5分钟。
  "
}

# 运行所有基线测试
run_baseline_test "Scenario1: 新人入职" "$TEST_PROJECT_DIR"
run_baseline_test "Scenario2: 技术方案设计" "$TEST_PROJECT_DIR"
run_baseline_test "Scenario3: 代码审查" "$TEST_PROJECT_DIR"
run_baseline_test "Scenario4: 大型项目" "$LARGE_PROJECT_DIR"
```

### 记录模板

为每个测试创建记录文件：

```markdown
# 测试记录: [场景名称]

## 场景描述
[复制上面的场景描述]

## 测试设置
[使用的测试项目结构]

## 基线行为 (观察结果)

### 分析过程
[子代理做了什么]

### 发现的问题
1. **缺失功能**: [描述]
   - 证据: [子代理的原话]

2. **文档组织混乱**: [描述]
   - 证据: [生成的文档结构]

3. **缺少智能特性**: [描述]
   - 证据: [没有增量更新、没有索引]

## 预期合理化 (子代理的借口)
[列出所有听到的合理化]

## 压力类型
[时间/沉没成本/权威/疲劳]

## 测试结论
基线测试: ❌ FAILED

需要改进的方面:
1. [具体改进点1]
2. [具体改进点2]
...
```

---

## Phase 3: GREEN - 编写技能

### 基于RED阶段发现的问题编写技能

**问题清单** (从RED阶段收集):

1. ❌ **缺乏systematic分析流程**
   - 子代理直接运行命令，没有五层分析逻辑

2. ❌ **文档按文件组织，不按领域**
   - 生成的文档难以维护

3. ❌ **没有增量更新机制**
   - 每次都全量分析，效率低

4. ❌ **缺少交互式索引**
   - 新人不知道从哪里开始

5. ❌ **没有中文友好设计**
   - 输出全是英文

**技能目标** (解决上述问题):

- ✅ 实施五层渐进式分析（Level 1-5）
- ✅ 按领域环节拆分12个文档
- ✅ 智能增量更新（10个文件阈值）
- ✅ 交互式问答索引（12-interaction-index.md）
- ✅ 中文友好输出

**实施要点**:

参考 `skills/code-structure-reader/SKILL.md` 已创建的技能文档，确保：

1. 每个Level有清晰的分析步骤
2. 文件映射逻辑明确
3. 可视化输出（Mermaid）
4. 增量更新检测和执行

---

## Phase 4: REFACTOR - 识别并关闭合理化漏洞

### 常见合理化模式预测

**Rationalization 1: "项目太特殊，通用方法不适用"**
- **现实**: 大多数项目遵循常见模式
- **对策**: 在技能中明确适用范围，但提供通用方法

**Rationalization 2: "分析耗时，不如直接看代码"**
- **现实**: 30分钟上手 vs 4小时盲目摸索
- **对策**: 强调技能的长期价值，对比一次性时间投入

**Rationalization 3: "文档太多，新人看不完"**
- **现实**: 11个文件 vs 1000+源文件
- **对策**: 强调交互索引和按需阅读

**Rationalization 4: "增量更新太复杂，容易出错"**
- **现实**: 自动检测 vs 手动维护
- **对策**: 提供清晰决策树和示例脚本

**Rationalization 5: "小项目不需要这么复杂"**
- **现实**: 小项目也受益于结构化文档
- **对策**: 提供渐进式分析，可以只运行需要的Level

### 合理化表

| 借口 | 现实 | 对策 (加入技能) |
|------|------|-------------------|
| "项目太特殊，不适用" | 大多数项目遵循常见模式 | 明确适用范围+通用方法 |
| "分析耗时，不如看代码" | 30分钟上手 vs 4小时摸索 | 强调长期价值vs一次性投入 |
| "文档太多看不完" | 11个文档 vs 1000源文件 | 强调交互索引+按需阅读 |
| "增量更新太复杂" | 自动化 vs 手动维护 | 清晰决策树+脚本示例 |
| "小项目不需要" | 小项目也受益结构化 | 渐进式分析，按需运行Level |

### 红旗列表

在SKILL.md中添加"## Red Flags"章节：

```markdown
## Red Flags - 停止并重新开始

- 跳过Level直接生成文档
- 不按领域环节组织文档
- 不生成交互式索引
- 忽略增量更新优化
- 使用英文输出中文项目
- 假设项目"太特殊"
```

---

## Phase 5: 重新测试 (GREEN+REFACTOR)

### 测试场景

使用与RED阶段相同的4个场景，但这次加载code-structure-reader技能。

### 执行命令

```bash
# 测试辅助函数
run_skill_test() {
  local test_name="$1"
  local project_dir="$2"

  echo "🟢 运行技能测试: $test_name"
  echo "项目路径: $project_dir"
  echo ""

  # 派生子代理
  # 加载code-structure-reader技能

  claude --prompt "
    使用 code-structure-reader 技能分析项目。
    项目路径: $project_dir
    任务: $test_name

    请完整执行技能中的所有步骤：
    1. 五层渐进式分析
    2. 生成11个领域文档
    3. 创建交互式索引
    4. 应用增量更新逻辑
  "
}

# 运行所有技能测试
run_skill_test "Scenario1: 新人入职" "$TEST_PROJECT_DIR"
run_skill_test "Scenario2: 技术方案设计" "$TEST_PROJECT_DIR"
run_skill_test "Scenario3: 代码审查" "$TEST_PROJECT_DIR"
run_skill_test "Scenario4: 大型项目" "$LARGE_PROJECT_DIR"
```

### 成功标准

| 检查项 | 基线(无技能) | 技能测试 | 改进幅度 |
|---------|----------------|----------|------------|
| Systematic分析流程 | ❌ 无 | ✅ 有Level 1-5 | +100% |
| 领域文档组织 | ❌ 按文件 | ✅ 按环节(00-11) | +100% |
| 增量更新机制 | ❌ 无 | ✅ 智能决策 | +100% |
| 交互式索引 | ❌ 无 | ✅ 有11-index.md | +100% |
| 中文友好 | ❌ 英文 | ✅ 中文 | +100% |
| 分析时间<5min | ❌ >20min | ✅ <5min | -75% |
| 内存占用<2GB | ⚠️ 2.5GB | ✅ <1GB | -60% |

### 记录验证

为每个场景验证技能是否解决了基线中发现的所有问题：

```markdown
# 测试验证: [场景名称]

## 技能执行过程
[子代理的执行步骤和生成的内容]

## 问题验证

### 基线问题1: 缺乏Systematic分析流程
- **基线**: 子代理直接运行命令，没有五层逻辑
- **技能测试**: 子代理执行Level 1-5分析？
- **验证结果**: ✅ PASS - 有完整的五层分析

### 基线问题2: 文档组织混乱
- **基线**: 按文件生成，难以维护
- **技能测试**: 生成11个领域文档？
- **验证结果**: ✅ PASS - 文档按00-11编号，职责明确

[... 继续验证其他问题 ...]

## 压力测试
- 时间压力: [是否按时完成]
- 沉没成本: [是否坚持按技能执行]
- 权威压力: [是否坚持完整分析]

## 测试结论
技能测试: ✅ PASSED

改进幅度:
- 问题1: ✅ 100% 解决
- 问题2: ✅ 100% 解决
- 问题3: ✅ 100% 解决
...

发现的合理化:
[新的合理化记录，需要加入SKILL.md]
```

---

## 总结

### TDD循环完成情况

| 阶段 | 状态 | 主要发现 |
|------|------|---------|
| **RED** | ⏳ 待执行 | 需要定义测试场景 |
| **GREEN** | ⏳ 待编写 | SKILL.md已创建，待实现 |
| **REFACTOR** | ⏳ 待优化 | 待GREEN阶段完成后再优化 |

### 下一步

1. ✅ 执行RED阶段基线测试
2. ✅ 基于发现的问题编写技能(GREEN)
3. ✅ 识别合理化并更新技能(REFACTOR)
4. ✅ 执行GREEN+REFACTOR阶段测试
5. ✅ 生成测试报告

### 预估时间

- RED阶段测试: 2小时
- GREEN阶段编写: 4小时（SKILL.md已创建）
- REFACTOR阶段优化: 1小时
- 重新测试: 2小时
- **总计**: ~9小时完成TDD循环

---

**测试用例文档完成**
