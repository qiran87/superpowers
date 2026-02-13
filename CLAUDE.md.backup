# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Superpowers 是一个完整的软件开发工作流技能库,为 AI 编程代理构建在可组合的"技能"集合之上。该项目提供了 TDD、调试、协作模式和经过验证的技术的核心技能库。

**当前版本:** 4.2.0

**核心架构:**
- **技能系统 (Skills/):** 核心,包含可重用的开发技能
- **命令 (Commands/):** 斜杠命令,用于触发特定工作流
- **代理 (Agents/):** 子代理配置,用于特定任务
- **钩子 (Hooks/):** SessionStart 钩子,自动注入技能上下文
- **测试 (Tests/):** 针对不同平台的技能验证测试
- **文档 (Docs/):** 针对 Codex 和 OpenCode 的安装指南

## 核心开发工作流

Superpowers 遵循一个严格的六阶段开发流程,必须按顺序执行:

### 1. **brainstorming** (头脑风暴)
- **触发条件:** 任何创造性工作之前 - 创建功能、构建组件、添加功能、修改行为
- **目的:** 通过苏格拉底式对话完善需求,探索替代方案,分节展示设计以进行验证
- **输出:** 保存到 `docs/plans/YYYY-MM-DD-<topic>-design.md` 的设计文档
- **核心原则:** 一次一个问题,多个选项,增量验证,YAGNI
- **文档结构:** 设计文档分为三部分
  - **Part 1:** 业务需求(面向产品经理和利益相关方)
  - **Part 2A:** 后端技术设计(面向后端团队)
  - **Part 2B:** 前端技术设计(面向前端团队)
  - **Part 3:** 跨领域关注点(面向所有技术方)

### 2. **using-git-worktrees** (使用 Git Worktrees)
- **触发条件:** 设计批准后,开始实施前
- **目的:** 在新分支创建隔离的工作空间,运行项目设置,验证干净的测试基线
- **目录选择优先级:**
  1. 检查现有目录 (`.worktrees` 或 `worktrees`)
  2. 检查 CLAUDE.md 中的偏好设置
  3. 询问用户
- **安全验证:** 项目本地目录必须在 .gitignore 中
- **核心原则:** 系统化目录选择 + 安全验证 = 可靠的隔离

### 3. **writing-plans** (编写计划)
- **触发条件:** 批准的设计,在实施前
- **目的:** 将工作分解为小块任务(每项 2-5 分钟),包含精确文件路径、完整代码、验证步骤
- **输出:** 保存到 `docs/plans/YYYY-MM-DD-<feature-name>.md` 的实施计划
- **任务结构:** 每个任务必须包含:
  - 精确的文件路径(创建/修改/测试)
  - 完整的代码(不是"添加验证")
  - 确切的命令和预期输出
  - 相关技能引用
- **核心原则:** DRY, YAGNI, TDD, 频繁提交

### 4. **subagent-driven-development** 或 **executing-plans** (执行计划)
- **subagent-driven-development:**
  - **触发条件:** 在当前会话中执行具有独立任务的计划
  - **工作流:** 为每个任务分派新的子代理,任务间进行双重代码审查(规范合规性,然后代码质量)
  - **核心原则:** 快速迭代,双重审查,保持上下文

- **executing-plans:**
  - **触发条件:** 在单独的会话中执行计划,批量执行和人工检查点
  - **工作流:** 批量执行任务,在检查点暂停进行人工审查
  - **核心原则:** 批量执行,人工检查点,独立会话

### 5. **test-driven-development** (测试驱动开发)
- **触发条件:** 任何功能或错误修复实施期间,在编写实施代码之前
- **铁律:**
  ```
  没有失败的测试就没有生产代码
  在测试之前编写代码? 删除它。重新开始。
  ```
- **RED-GREEN-REFACTOR 循环:**
  1. RED: 编写失败的测试并观察其失败
  2. GREEN: 编写最小代码使其通过
  3. REFACTOR: 清理代码(保持测试通过)
- **验证要求:**
  - 必须观察测试失败(确认它测试正确的东西)
  - 必须观察测试通过(确认代码有效)
  - 测试必须针对真实行为(除非不可避免,否则不使用模拟)

### 6. **requesting-code-review** (请求代码审查)
- **触发条件:** 任务之间
- **工作流:** 根据计划和编码标准审查已完成的工作
- **问题分类:** 关键(必须修复),重要(应该修复),建议(很好有)
- **输出:** 带有具体示例和可操作建议的结构化审查

### 7. **finishing-a-development-branch** (完成开发分支)
- **触发条件:** 任务完成时
- **工作流:** 验证测试,呈现选项(合并/PR/保留/放弃),清理 worktree
- **选项:**
  - 合并到主分支
  - 创建拉取请求
  - 保留分支以进一步工作
  - 放弃更改

## 技能系统架构

### 技能类型

**技术型 (Techniques):** 具体方法和步骤
- 示例: `condition-based-waiting`, `root-cause-tracing`
- 测试方法: 应用场景,变体场景,缺失信息测试

**模式型 (Patterns):** 思维问题的方法
- 示例: `flatten-with-flags`, `test-invariants`
- 测试方法: 识别场景,应用场景,反例

**参考型 (Reference):** API 文档,语法指南
- 示例: 办公文档技能,库参考
- 测试方法: 检索场景,应用场景,缺口测试

**纪律型 (Discipline):** 强制执行规则的技能
- 示例: `test-driven-development`, `verification-before-completion`
- 测试方法: 学术问题,压力场景,多种压力组合
- 核心原则: 必须抵制合理化

### 技能结构

每个技能包含:
- **SKILL.md:** 主参考文档(必需)
  - YAML frontmatter (name, description, max 1024 字符)
  - 概述(1-2 句话核心原则)
  - 使用场景(症状和用例)
  - 核心模式/快速参考
  - 实施细节
  - 常见错误
- **支持文件:** 仅当需要时(可重用工具或大量参考)
  - 可重用工具: 脚本,实用程序,模板
  - 大量参考: 100+ 行的 API 文档,综合语法

### Claude 搜索优化 (CSO)

**1. 描述字段**
- **格式:** 必须以 "Use when..." 开头
- **内容:** 仅描述触发条件,不要总结技能的工作流程
- **关键:** 描述总结工作流程会导致 Claude 跟随描述而不是读取完整技能

**2. 关键词覆盖**
- 错误消息: "Hook timed out", "race condition"
- 症状: "flaky", "hanging", "zombie"
- 同义词: "timeout/hang/freeze", "cleanup/teardown"
- 工具: 实际命令,库名,文件类型

**3. 令牌效率**
- 入门级工作流: <150 词
- 频繁加载的技能: <200 词
- 其他技能: <500 词

**4. 描述性命名**
- 使用主动语态,动词优先
- `creating-skills` 而非 `skill-creation`
- `condition-based-waiting` 而非 `async-test-helpers`

### 技能测试 (TDD 方法)

**铁律:**
```
没有失败的测试就没有技能
```

**RED-GREEN-REFACTOR 循环:**
1. **RED:** 在没有技能的情况下运行压力场景,记录确切失败
2. **GREEN:** 编写解决特定失败的技能
3. **REFACTOR:** 找到新的合理化,添加计数器,重新验证

**压力类型:**
- 时间压力("现在是 6pm,晚餐在 6:30pm")
- 沉没成本("你已经花了 4 小时")
- 权威("高级开发人员说这样做")
- 疲劳(多个连续任务)

**合理化表:**
| 借口 | 现实 |
|------|------|
| "太简单而不需要测试" | 简单的代码会出错。测试需要 30 秒。 |
| "我会在之后测试" | 测试立即通过证明不了什么。 |
| "测试后实现相同的目标" | 测试后 = "这做什么?" 测试前 = "这应该做什么?" |

## 测试框架

### 测试目录结构

```
tests/
  claude-code/              # Claude Code 特定测试
    test-helpers.sh         # 共享测试辅助函数
    run-skill-tests.sh      # 技能测试运行器
  explicit-skill-requests/  # 显式技能请求测试
  skill-triggering/         # 技能触发测试
  subagent-driven-dev/      # 子代理开发工作流测试
    go-fractals/            # 完整工作流示例项目
    svelte-todo/            # 完整工作流示例项目
```

### 测试辅助函数

**运行 Claude Code:**
```bash
run_claude "prompt text" [timeout] [allowed_tools]
```

**断言函数:**
```bash
assert_contains "output" "pattern" "test name"
assert_not_contains "output" "pattern" "test name"
assert_count "output" "pattern" expected_count "test name"
assert_order "output" "pattern_a" "pattern_b" "test name"
```

**测试项目管理:**
```bash
create_test_project  # 创建临时测试目录
cleanup_test_project "$dir"  # 清理测试目录
create_test_plan "$dir" "$name"  # 创建测试计划文件
```

### 运行测试

**所有 Claude Code 测试:**
```bash
cd tests/claude-code
./run-skill-tests.sh
```

**特定技能测试:**
```bash
./test-subagent-driven-development.sh
```

## 插件系统

### Claude Code 插件配置

**plugin.json:** 插件清单
```json
{
  "name": "superpowers",
  "description": "Core skills library for Claude Code",
  "version": "4.2.0",
  "keywords": ["skills", "tdd", "debugging", "collaboration"]
}
```

**hooks.json:** SessionStart 钩子配置
- 自动注入 `using-superpowers` 技能内容
- 检测遗留的 `~/.config/superpowers/skills` 目录并发出警告
- 异步执行以防止 Windows 上的终端冻结

**session-start.sh:** 钩子实现
- 读取 `using-superpowers` 技能内容
- 转义为 JSON 嵌入
- 输出附加上下文到系统提示

### 斜杠命令

**/brainstorm:** 触发头脑风暴技能
- 用途: 任何创造性工作之前
- 禁用模型调用以直接调用技能

**/write-plan:** 触发编写计划技能
- 用途: 为多步骤任务创建详细实施计划

**/execute-plan:** 触发执行计划技能
- 用途: 以批量方式执行计划并审查检查点

## 子代理系统

### 代理类型

**code-reviewer:** 高级代码审查代理
- 审查已完成的工作与原始计划的一致性
- 评估代码质量(SOLID 原则,错误处理,类型安全)
- 分类问题: 关键,重要,建议
- 提供具体示例和可操作的建议

### 代理提示模板

**spec-reviewer-prompt.md:** 规范合规性审查
- 验证实施与计划的一致性
- 识别偏差
- 确认所有计划的功能已实施

**code-quality-reviewer-prompt.md:** 代码质量审查
- 审查编码模式和约定
- 检查错误处理,类型安全,防御性编程
- 评估代码组织和可维护性

**implementer-prompt.md:** 实施者指令
- 假设零上下文和有问题的品味
- 精确的文件路径,完整代码,确切命令
- TDD,DRY,YAGNI,频繁提交

## Git 工作流

### 分支策略

**worktree 目录优先级:**
1. `.worktrees/` (项目本地,隐藏,首选)
2. `worktrees/` (项目本地,替代)
3. `~/.config/superpowers/worktrees/<project>/` (全局)

### 安全验证

**项目本地目录必须:**
```bash
# 验证目录被 gitignore 忽略
git check-ignore -q .worktrees 2>/dev/null
```

**如果未被忽略:**
1. 添加到 .gitignore
2. 提交更改
3. 继续创建 worktree

### Worktree 创建

```bash
# 创建具有新分支的 worktree
git worktree add "$path" -b "$branch_name"
cd "$path"

# 运行项目设置
npm install  # 或项目特定的设置命令

# 验证干净的测试基线
npm test
```

## Graphviz 约定

### 节点类型

- **钻石 (diamond):** 问题/决策("测试通过吗?")
- **盒子 (box):** 动作("编写测试")
- **纯文本 (plaintext):** 命令("npm test")
- **椭圆 (ellipse):** 状态("测试失败")
- **八边形 (octagon):** 警告("停止: 不要这样做")
- **双圆 (doublecircle):** 入口/出口("进程开始")

### 边标签

- **二元决策:** "yes", "no"
- **多选项:** 具体条件或 "otherwise"
- **触发器:** "triggers" (虚线)

### 命名模式

- **问题:** 以 "?" 结尾("这应该做 X 吗?")
- **动作:** 以动词开头("编写测试")
- **命令:** 字面("grep -r 'pattern' .")
- **状态:** 描述情况("测试通过")

## 文档约定

### Markdown 文档

**设计文档 (docs/plans/YYYY-MM-DD-<name>-design.md):**
- 200-300 字的小节
- 每节后验证是否正确
- 覆盖: 架构,组件,数据流,错误处理,测试

**实施计划 (docs/plans/YYYY-MM-DD-<name>.md):**
- 以强制标题开始
- 带有完整代码的逐个任务
- 精确的文件路径
- 确切的命令和预期输出

### 代码注释

- **始终:** 与现有代码库注释语言保持一致
- **函数签名:** 静态类型语言的公共 API
- **复杂逻辑:** 解释"为什么"而不是"什么"
- **TODO/FIXME:** 使用具体的问题跟踪引用

## 平台特定安装

### Codex (本地技能发现)

**安装:**
```bash
git clone https://github.com/obra/superpowers.git ~/.codex/superpowers
mkdir -p ~/.agents/skills
ln -s ~/.codex/superpowers/skills ~/.agents/skills/superpowers
```

**更新:**
```bash
cd ~/.codex/superpowers && git pull
```

### OpenCode (本地技能发现)

**安装:**
```bash
git clone https://github.com/obra/superpowers.git ~/.config/opencode/superpowers
mkdir -p ~/.config/opencode/plugins ~/.config/opencode/skills
ln -s ~/.config/opencode/superpowers/.opencode/plugins/superpowers.js ~/.config/opencode/plugins/superpowers.js
ln -s ~/.config/opencode/superpowers/skills ~/.config/opencode/skills/superpowers
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/obra/superpowers.git "$env:USERPROFILE\.config\opencode\superpowers"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\opencode\plugins"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\opencode\skills"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\opencode\plugins\superpowers.js" -Target "$env:USERPROFILE\.config\opencode\superpowers\.opencode\plugins\superpowers.js"
New-Item -ItemType Junction -Path "$env:USERPROFILE\.config\opencode\skills\superpowers" -Target "$env:USERPROFILE\.config\opencode\superpowers\skills"
```

## 核心哲学

### 测试驱动开发 (TDD)
- 先编写测试,始终如一
- 观察 RED,编写 GREEN,然后 REFACTOR
- 没有失败的测试 = 没有生产代码

### 系统化而非临时
- 流程胜过猜测
- 使用经过验证的技术和模式
- 遵循既定的工作流

### 复杂性降低
- 简单性是主要目标
- YAGNI(你不需要它)
- DRY(不要重复自己)

### 证据胜于声明
- 在声明成功之前进行验证
- 观察测试失败/通过
- 使用压力场景测试技能

## 常见任务

### 创建新技能

1. **RED 阶段:**
   - 创建压力场景(3+ 组合压力)
   - 在没有技能的情况下运行场景
   - 记录确切的选择和合理化

2. **GREEN 阶段:**
   - 编写解决特定失败的技能
   - YAML frontmatter (name, description)
   - 清晰的概述,特定解决方案
   - 一个优秀的例子
   - 使用技能运行场景 - 验证合规性

3. **REFACTOR 阶段:**
   - 识别新的合理化
   - 添加显式计数器(如果是纪律技能)
   - 构建合理化表
   - 创建红色标志列表
   - 重新测试直到防弹

4. **部署:**
   - 将技能提交到 git
   - 如果配置,推送到 fork
   - 如果广泛有用,考虑通过 PR 贡献

### 测试技能

**运行完整测试套件:**
```bash
cd tests/claude-code
./run-skill-tests.sh
```

**运行特定技能测试:**
```bash
./test-subagent-driven-development.sh
```

**使用辅助函数创建新测试:**
```bash
source test-helpers.sh
test_dir=$(create_test_project)
# ... 运行测试 ...
cleanup_test_project "$test_dir"
```

### 验证技能触发

**在 Claude Code 中:**
```
/help
```

查找 `/brainstorm`, `/write-plan`, `/execute-plan` 命令

**测试技能加载:**
```
使用 brainstorming 技能创建新功能设计
```

应该触发 brainstorming 技能

## 故障排除

### SessionStart 钩子失败

**症状:** 技能上下文未注入

**检查:**
1. 验证 hooks.json 配置
2. 检查 session-start.sh 权限(`chmod +x`)
3. 查看 Claude Code 日志
4. 验证 JSON 转义

### 技能未触发

**症状:** 技能未自动调用

**检查:**
1. 验证技能描述触发条件
2. 检查 YAML frontmatter 语法
3. 验证技能在技能目录中
4. 重新启动 Claude Code

### Worktree 问题

**症状:** Worktree 创建失败

**检查:**
1. 验证目录在 .gitignore 中
2. 检查分支名称是否已存在
3. 验证 git worktree add 语法
4. 检查磁盘空间

## 相关资源

**主要文档:**
- README.md - 项目概述和基本工作流
- RELEASE-NOTES.md - 版本历史和更改
- LICENSE - MIT 许可证

**平台特定文档:**
- docs/README.codex.md - Codex 完整指南
- docs/README.opencode.md - OpenCode 完整指南

**技能开发参考:**
- skills/writing-skills/SKILL.md - 创建技能的完整指南
- skills/writing-skills/testing-skills-with-subagents.md - 技能测试方法
- skills/writing-skills/anthropic-best-practices.md - 官方技能作者最佳实践
- skills/writing-skills/graphviz-conventions.dot - Graphviz 样式指南

**测试参考:**
- tests/claude-code/test-helpers.sh - 测试辅助函数
- tests/subagent-driven-dev/ - 完整工作流示例

## 贡献指南

1. Fork 项目
2. 为技能创建分支
3. 按照 `writing-skills` 技能创建和测试新技能
4. 提交 PR

**关键:**
- 所有新技能必须经过 TDD 方法测试
- 使用 `writing-skills` 技能作为指导
- 在提交之前验证技能触发
- 包含测试用例

## 许可证

MIT License - 详见 LICENSE 文件
