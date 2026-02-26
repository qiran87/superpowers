# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Superpowers 是一个完整的软件开发工作流技能库,为 AI 编程代理构建在可组合的"技能"(skills)集合之上。该项目提供了 TDD、调试、协作模式和经过验证的技术的核心技能库。

**当前版本:** 4.2.0

## 项目目录结构

```
superpowers/
├── skills/                    # 核心技能系统(17 个技能)
│   ├── brainstorming/         # 头脑风暴技能
│   ├── test-driven-development/
│   ├── writing-skills/        # 技能创建指南
│   └── ...
├── commands/                  # 斜杠命令定义(快捷方式)
│   ├── brainstorm.md          # /brainstorm 命令
│   ├── write-plan.md          # /write-plan 命令
│   └── execute-plan.md        # /execute-plan 命令
├── agents/                    # 子代理配置
│   └── code-reviewer.md       # 代码审查代理配置
├── hooks/                     # 钩子脚本
│   ├── session-start.sh       # SessionStart 钩子
│   ├── run-hook.cmd           # Windows polyglot wrapper
│   └── hooks.json             # 钩子配置
├── tests/                     # 测试框架
│   └── claude-code/
│       ├── run-skill-tests.sh # 主测试脚本
│       ├── test-helpers.sh    # 测试辅助函数
│       └── test-*.sh          # 各技能测试文件
├── .spec-workflow/            # 规范工作流管理(可选)
│   ├── specs/                 # 规范文档存储
│   ├── steering/              # 指导文档(product.md, tech.md)
│   ├── approvals/             # 审批请求历史
│   ├── archive/               # 归档的规范
│   ├── templates/             # 规范和计划模板
│   └── user-templates/        # 用户自定义模板
├── docs/
│   ├── plans/                 # 设计文档和实施计划
│   │   └── YYYY-MM-DD-*.md    # 按日期组织
│   ├── README.codex.md        # Codex 平台指南
│   └── README.opencode.md     # OpenCode 平台指南
├── .claude-plugin/            # 插件配置
│   ├── plugin.json            # 插件清单
│   ├── hooks.json             # 钩子配置(符号链接到 hooks/hooks.json)
│   └── marketplace.json       # 市场发布配置
├── .worktrees/                # Git worktree 目录(首选)
├── .gitignore                 # 忽略 .worktrees/, .claude/, node_modules/
├── CLAUDE.md                  # 本文件
└── README.md                  # 项目概述
```

**核心架构:**
- **技能系统 (skills/):** 核心,包含可重用的开发技能,每个技能都是独立的参考文档
- **命令 (commands/):** 斜杠命令定义文件,提供工作流的快捷方式
- **代理 (agents/):** 子代理配置文件,定义特定任务行为(如代码审查)
- **钩子 (hooks/):** SessionStart 钩子脚本,自动注入技能上下文到每个会话
- **插件配置 (.claude-plugin/):** 插件清单和钩子配置
- **测试 (tests/):** 针对不同平台的技能验证测试
- **文档 (docs/):** 针对 Codex 和 OpenCode 的安装指南、设计文档和实施计划
- **规范工作流 (.spec-workflow/):** 可选的规范管理、审批和模板系统

## 开发命令

### 测试命令

```bash
# 运行所有快速技能测试
cd tests/claude-code
./run-skill-tests.sh

# 运行特定技能测试
./test-subagent-driven-development.sh

# 运行完整的集成测试(耗时 10-30 分钟)
./run-skill-tests.sh --integration

# 详细输出模式
./run-skill-tests.sh --verbose

# 自定义超时时间
./run-skill-tests.sh --timeout 1800
```

### 插件命令

Superpowers 作为 Claude Code 插件运行,通过斜杠命令提供快捷方式:

```bash
/brainstorm      # 触发头脑风暴技能(任何创造性工作之前)
/write-plan      # 触发编写计划技能(为多步骤任务创建详细实施计划)
/execute-plan    # 触发执行计划技能(以批量方式执行计划并审查)
```

**注意:** 技能主要通过描述其用途自动触发,斜杠命令只是快捷方式。

### 命令目录 (commands/)

**命令结构:**
- 每个命令是一个 Markdown 文件,包含 YAML frontmatter 和命令提示
- **frontmatter 字段:**
  - `name`: 命令名称
  - `description`: 命令描述
  - `prompt`: 要发送给 Claude 的提示内容

**可用命令:**
- `brainstorm.md` - 头脑风暴命令快捷方式
- `write-plan.md` - 编写计划命令快捷方式
- `execute-plan.md` - 执行计划命令快捷方式
- `debug.md` - 调试工作流命令
- `protocol-change.md` - 协议变更工作流命令

## 核心架构概念

### 技能(Skills)系统

**技能类型:**
- **技术型(Techniques):** 具体方法和步骤(如 `test-driven-development`, `root-cause-tracing`)
- **模式型(Patterns):** 思维问题的方法(如 `flatten-with-flags`, `test-invariants`)
- **参考型(Reference):** API 文档,语法指南
- **纪律型(Discipline):** 强制执行规则的技能(如 `test-driven-development`, `verification-before-completion`)

**完整技能列表 (v4.2.0):**
- **brainstorming** - 在任何创造性工作之前使用,通过苏格拉底式对话完善需求
- **code-structure-reader** - 系统化分析代码库结构,生成11份增量可维护的中文文档
- **design-with-existing-modules** - 设计技术方案时检查现有可复用模块,避免重复开发
- **dispatching-parallel-agents** - 将2+个独立任务分派给并行子代理
- **executing-plans** - 在单独会话中批量执行计划,在检查点暂停审查
- **finishing-a-development-branch** - 任务完成后验证测试,呈现合并/PR选项
- **protocol-compliance-check** - 验证代码实现与协议文档的一致性
- **receiving-code-review** - 接收代码审查反馈时的技术严谨性验证
- **requesting-code-review** - 任务完成后根据计划和编码标准审查工作
- **subagent-driven-development** - 在当前会话中执行计划,每个任务分派新子代理
- **systematic-debugging** - 系统化调试四阶段流程(根因追溯、防御深度、条件等待)
- **test-driven-development** - 强制 RED-GREEN-REFACTOR 循环
- **using-git-worktrees** - 创建隔离的 Git 工作树用于并行开发
- **using-superpowers** - 技能系统介绍和使用指南
- **verification-before-completion** - 在声明完成前验证问题已解决
- **writing-plans** - 将批准的设计分解为2-5分钟的小任务
- **writing-skills** - 创建新技能的最佳实践和测试方法

**技能结构:**
- 每个技能目录包含必需的 `SKILL.md` 文件
- YAML frontmatter 定义 `name` 和 `description`(最多 1024 字符)
- Description 必须以 "Use when..." 开头,仅描述触发条件,不总结工作流程
- 可选的支持文件用于大量参考内容或可重用工具

**技能触发机制:**
- SessionStart 钩子自动注入 `using-superpowers` 技能内容
- Claude 通过 Skill 工具加载技能内容(不使用 Read 工具)
- 技能描述优化搜索,确保正确的技能被自动调用
- 技能优先级:流程技能(brainstorming, debugging) > 实现技能

### 子代理(Subagent)系统

**代理类型:**
- **code-reviewer:** 高级代码审查代理,审查已完成工作与计划的一致性

**code-reviewer 工作流:**
1. **协议合规性检查:** 使用 `protocol-compliance-check` 技能验证实现与协议文档一致
2. **代码质量评估:** 审查代码质量、测试覆盖、TDD 合规性
3. **架构设计审查:** 验证 SOLID 原则和架构模式
4. **问题分类:** Critical (必须修复), Important (应该修复), Suggestions (建议)
5. **沟通协议:** 发现重大偏差时要求编码代理确认

**子代理工作流:**
- `subagent-driven-development`: 在当前会话中执行计划,每个任务分派新的子代理
- 双重代码审查:规范合规性审查 → 代码质量审查
- 使用 Task 工具分派子代理,每个子代理有独立的上下文

**Agents 目录结构:**
```
agents/
└── code-reviewer.md    # 代码审查代理配置
```

### 钩子(Hooks)系统

**SessionStart 钩子** (`hooks/session-start.sh`):
- 自动注入 `using-superpowers` 技能内容
- 检测遗留的 `~/.config/superpowers/skills` 目录并发出警告
- 使用高效的参数转义方法(JSON 嵌入)
- 在 `hooks/hooks.json` 和 `.claude-plugin/hooks.json` 中配置

**Hooks 配置** (`hooks/hooks.json`):
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh",
            "async": true
          }
        ]
      }
    ]
  }
}
```

**关键配置:**
- **matcher:** 匹配模式 (startup|resume|clear|compact)
- **async:** true - 异步执行以防止 Windows 终端冻结
- **command:** 钩子脚本路径,使用 `${CLAUDE_PLUGIN_ROOT}` 变量

### 插件配置

**plugin.json** - 插件清单:
- 定义插件名称、描述、版本和关键词
- 关键词用于插件发现:"skills", "tdd", "debugging", "collaboration", "best-practices", "workflows"

**hooks.json** - 钩子配置 (位于 `.claude-plugin/hooks.json`):
- 符号链接到 `hooks/hooks.json`
- 定义 SessionStart 钩子
- 异步执行以防止 Windows 终端冻结

**marketplace.json** - 市场发布配置 (位于 `.claude-plugin/marketplace.json`):
- 定义插件市场信息
- 列出所有可用技能

### 规范工作流 (可选)

**.spec-workflow 目录** - 规范管理和审批系统:
- **specs/** - 规范文档存储,按规范名称组织
- **steering/** - 项目指导文档(product.md, tech.md, structure.md)
- **approvals/** - 审批请求历史记录
- **archive/** - 已归档的规范文档
- **templates/** - 规范和计划模板
- **user-templates/** - 用户自定义模板

**当项目使用规范工作流时:**
- 设计文档应保存到 `.spec-workflow/specs/<name>/`
- 审批请求通过 MCP 工具管理
- 实施日志自动记录到规范中

### Git 配置

**.gitignore 配置:**
```gitignore
.worktrees/           # Git worktree 目录(项目本地,隐藏)
.private-journal/     # 私人日志
.claude/              # Claude 临时文件
node_modules/         # Node.js 依赖
```

**安全验证:**
```bash
# 验证 worktree 目录被 gitignore
git check-ignore -q .worktrees 2>/dev/null
```

## 核心开发工作流

Superpowers 遵循严格的七阶段开发流程,必须按顺序执行:

### 1. **brainstorming** (头脑风暴)
- **触发:** 任何创造性工作之前 - 创建功能、构建组件、添加功能
- **目的:** 通过苏格拉底式对话完善需求,探索替代方案
- **输出:** 保存到 `docs/plans/YYYY-MM-DD-<topic>-design.md` 的设计文档
- **结构:**
  - Part 1: 业务需求(面向产品经理)
  - Part 2A: 后端技术设计
  - Part 2B: 前端技术设计
  - Part 3: 跨领域关注点
- **验证:** 每节 200-300 字,每节后验证是否正确

### 2. **using-git-worktrees** (使用 Git Worktrees)
- **触发:** 设计批准后,开始实施前
- **目的:** 在新分支创建隔离的工作空间
- **目录优先级:**
  1. 检查现有目录(`.worktrees` 或 `worktrees`)
  2. 检查 CLAUDE.md 中的偏好设置
  3. 询问用户
- **安全验证:** 项目本地目录必须在 .gitignore 中
- **命令:** `git worktree add "$path" -b "$branch_name"`

### 3. **writing-plans** (编写计划)
- **触发:** 批准的设计,在实施前
- **目的:** 将工作分解为小块任务(每项 2-5 分钟)
- **输出:** 保存到 `docs/plans/YYYY-MM-DD-<feature-name>.md` 的实施计划
- **任务结构:**
  - 精确的文件路径(创建/修改/测试)
  - 完整的代码(不是"添加验证"这样的模糊指令)
  - 确切的命令和预期输出
  - 相关技能引用

### 4. **执行计划** - 两种模式

**模式 A: subagent-driven-development**
- **触发:** 在当前会话中执行具有独立任务的计划
- **工作流:**
  - 为每个任务分派新的子代理
  - 双重代码审查(规范合规性 → 代码质量)
  - 快速迭代,保持上下文

**模式 B: executing-plans**
- **触发:** 在单独的会话中执行计划
- **工作流:** 批量执行任务,在检查点暂停进行人工审查

### 5. **test-driven-development** (测试驱动开发)
- **触发:** 任何功能或错误修复实施期间
- **铁律:** 没有失败的测试就没有生产代码
- **RED-GREEN-REFACTOR 循环:**
  1. RED: 编写失败的测试并观察其失败
  2. GREEN: 编写最小代码使其通过
  3. REFACTOR: 清理代码(保持测试通过)

### 6. **requesting-code-review** (请求代码审查)
- **触发:** 任务之间
- **工作流:** 根据计划和编码标准审查已完成的工作
- **问题分类:** 关键(必须修复),重要(应该修复),建议(很好有)

### 7. **finishing-a-development-branch** (完成开发分支)
- **触发:** 任务完成时
- **工作流:** 验证测试,呈现选项(合并/PR/保留/放弃),清理 worktree

## 技能测试方法(TDD)

**铁律:** 没有失败的测试就没有技能

**RED-GREEN-REFACTOR 循环:**
1. **RED:** 在没有技能的情况下运行压力场景,记录确切失败
2. **GREEN:** 编写解决特定失败的技能
3. **REFACTOR:** 找到新的合理化,添加计数器,重新验证

**压力类型:**
- 时间压力("现在是 6pm,晚餐在 6:30pm")
- 沉没成本("你已经花了 4 小时")
- 权威("高级开发人员说这样做")
- 疲劳(多个连续任务)

**测试框架:**
- `tests/claude-code/test-helpers.sh` - 共享测试辅助函数
- `run_claude` - 运行 Claude Code 并捕获输出
- `assert_*` 函数 - 断言函数(contains, not_contains, count, order)
- `create_test_project` - 创建临时测试目录

**测试辅助函数:**
```bash
source test-helpers.sh

# 运行 Claude 并捕获输出
output=$(run_claude "提示内容" [超时秒数])

# 断言函数
assert_contains "$output" "模式" "测试名称"
assert_not_contains "$output" "模式" "测试名称"
assert_count "$output" "模式" 数量 "测试名称"
assert_order "$output" "模式A" "模式B" "测试名称"

# 创建测试项目
test_dir=$(create_test_project)
cleanup_test_project "$test_dir"
```

## Graphviz 流程图约定

Superpowers 使用 DOT/GraphViz 流程图作为可执行规范定义:

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

## Git 工作流

### 分支策略

**worktree 目录优先级:**
1. `.worktrees/` (项目本地,隐藏,首选)
2. `worktrees/` (项目本地,替代)
3. `~/.config/superpowers/worktrees/<project>/` (全局)

**安全验证:**
```bash
# 验证目录被 gitignore 忽略
git check-ignore -q .worktrees 2>/dev/null
```

**Worktree 创建:**
```bash
# 创建具有新分支的 worktree
git worktree add "$path" -b "$branch_name"
cd "$path"

# 运行项目设置
npm install  # 或项目特定的设置命令

# 验证干净的测试基线
npm test
```

**Worktree 清理:**
```bash
# 完成后清理 worktree
git worktree remove "$path"
```

## 文档约定

### Markdown 文档

**设计文档** (`docs/plans/YYYY-MM-DD-<name>-design.md`):
- 200-300 字的小节
- 每节后验证是否正确
- 覆盖: 架构,组件,数据流,错误处理,测试

**实施计划** (`docs/plans/YYYY-MM-DD-<name>.md`):
- 以强制标题开始
- 带有完整代码的逐个任务
- 精确的文件路径
- 确切的命令和预期输出

### 代码注释

- **始终:** 与现有代码库注释语言保持一致
- **函数签名:** 静态类型语言的公共 API
- **复杂逻辑:** 解释"为什么"而不是"什么"
- **TODO/FIXME:** 使用具体的问题跟踪引用

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

## 平台特定注意事项

### SessionStart 钩子性能优化
- Windows 上的 `escape_for_json` 函数使用参数替换而非字符循环
- 异步执行防止终端冻结
- LF 行结尾通过 .gitattributes 强制执行

### 跨平台兼容性
- shell 脚本使用 POSIX 兼容语法(`${BASH_SOURCE[0]:-$0}`)
- 路径处理使用双引号和正斜杠
- PowerShell 和 Git Bash 的特殊处理

### Windows 特定注意事项
- 使用 `run-hook.cmd` polyglot wrapper 处理钩子执行
- SessionStart 钩子必须异步执行以防止 TUI 冻结
- JSON 转义使用 bash 参数替换而非字符循环

## 常见任务

### 创建新技能

1. **RED 阶段:**
   - 创建压力场景(3+ 组合压力)
   - 在没有技能的情况下运行场景
   - 记录确切的选择和合理化

2. **GREEN 阶段:**
   - 编写解决特定失败的技能
   - YAML frontmatter(name, description)
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

```bash
# 运行完整测试套件
cd tests/claude-code
./run-skill-tests.sh

# 运行特定技能测试
./test-subagent-driven-development.sh

# 使用辅助函数创建新测试
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

### 创建新命令

1. 在 `commands/` 目录创建新的 Markdown 文件
2. 添加 YAML frontmatter:
   ```yaml
   ---
   name: command-name
   description: 简短描述
   prompt: |
     要发送给 Claude 的提示内容
   ---
   ```
3. 命令会自动被插件系统发现

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

### Windows 特定问题

**症状:** 终端冻结、钩子不执行

**检查:**
1. 验证 hooks.json 中 `async: true`
2. 检查 run-hook.cmd 文件存在
3. 验证 LF 行结尾(.gitattributes)
4. 检查 PowerShell 或 Git Bash 兼容性

## 相关资源

**主要文档:**
- README.md - 项目概述和基本工作流
- RELEASE-NOTES.md - 版本历史和更改
- LICENSE - MIT 许可证

**平台特定文档:**
- docs/README.codex.md - Codex 完整指南
- docs/README.opencode.md - OpenCode 完整指南

**插件配置:**
- .claude-plugin/plugin.json - 插件清单
- .claude-plugin/hooks.json - 钩子配置
- .claude-plugin/marketplace.json - 市场发布配置

**技能开发参考:**
- skills/writing-skills/SKILL.md - 创建技能的完整指南
- skills/writing-skills/testing-skills-with-subagents.md - 技能测试方法
- skills/writing-skills/anthropic-best-practices.md - 官方技能作者最佳实践
- skills/writing-skills/graphviz-conventions.dot - Graphviz 样式指南

**新增技能参考:**
- skills/brainstorming/SKILL.md - 头脑风暴工作流
- skills/code-structure-reader/SKILL.md - 代码库结构化分析
- skills/design-with-existing-modules/SKILL.md - 基于现有模块的设计
- skills/protocol-compliance-check/SKILL.md - 协议合规性检查

**测试参考:**
- tests/claude-code/test-helpers.sh - 测试辅助函数
- tests/claude-code/README.md - 测试套件文档
- tests/subagent-driven-dev/ - 完整工作流示例
- docs/testing.md - 测试指南

**工作流参考:**
- commands/brainstorm.md - 头脑风暴命令
- commands/write-plan.md - 编写计划命令
- commands/execute-plan.md - 执行计划命令
- agents/code-reviewer.md - 代码审查代理

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
