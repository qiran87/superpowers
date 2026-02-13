# Documentation Check Integration Feature

## 概述

此功能在 `brainstorming` 技能中添加了文档健康检查步骤,确保在开始设计讨论前项目文档是最新的。

## 实现时间

2026-02-13

## 修改内容

### 修改的文件

- `skills/brainstorming/SKILL.md` - 在 "Overview" 和 "The Process" 之间添加了新章节 "Pre-Check: Documentation Health"

### 新增功能

1. **文档健康询问**
   - 在了解项目状态之前询问用户文档是否过时
   - 使用 `AskUserQuestion` 工具提供三个选项:
     - "Documentation is current" - 文档是最新的
     - "Documentation needs update" - 文档需要更新(调用 code-structure-reader)
     - "Not sure" - 不确定(自动检查文档年龄)

2. **自动调用 code-structure-reader**
   - 如果用户选择需要更新,使用 `Skill` 工具调用 `superpowers:code-structure-reader`
   - 等待该技能完成,生成 11 个文档文件
   - 完成后继续 brainstorming 流程

3. **智能检查**
   - 如果用户选择"不确定",自动检查文档目录和 git 提交历史
   - 根据文档年龄(< 30天 或 > 60天)给出建议

## 工作流程

```
用户触发 brainstorming
         ↓
添加文档健康检查步骤
         ↓
询问用户: "文档是否需要更新?"
         ↓
    ┌────┴────┐
    │         │
  是         否   不确定
    │         │         │
调用         直接      检查文档
code-structure  继续     年龄
    │         │         │
  生成      继续      提供建议
11个文档     brainstorm   ↓
    │                   询问用户
    └────────┬───────────┘
             ↓
      继续 brainstorming
      (使用最新文档上下文)
```

## 测试场景

### 场景 1: 用户确认需要更新文档

**输入:**
- 用户触发 brainstorming 技能
- 用户选择 "Documentation needs update"

**预期输出:**
1. 系统使用 `AskUserQuestion` 工具询问
2. 用户选择需要更新
3. 系统宣布: "Using **superpowers:code-structure-reader** to systematically analyze..."
4. 调用 Skill 工具加载 `superpowers:code-structure-reader`
5. 等待文档生成完成
6. 宣布完成并继续 brainstorming

### 场景 2: 用户确认文档是当前的

**输入:**
- 用户触发 brainstorming 技能
- 用户选择 "Documentation is current"

**预期输出:**
1. 系统询问用户
2. 用户选择文档是最新的
3. 跳过文档分析,直接进入 "Understanding the idea" 阶段

### 场景 3: 用户不确定

**输入:**
- 用户触发 brainstorming 技能
- 用户选择 "Not sure"

**预期输出:**
1. 系统询问用户
2. 用户选择不确定
3. 系统检查 `docs/` 目录和 git 历史
4. 根据文档年龄给出建议
5. 再次询问用户,是否需要更新

## 好处

1. **避免重复设计**: 确保在开始设计前了解现有功能
2. **提高设计质量**: 基于最新的架构和依赖信息进行设计
3. **节省时间**: 在早期发现冲突,避免后期返工
4. **自动化**: 无需手动检查文档,系统自动处理

## 注意事项

1. **非阻塞**: 这个检查不会阻止 brainstorming 流程,用户可以跳过
2. **时间成本**: code-structure-reader 通常需要 5-10 分钟完成
3. **文档位置**: 生成的文档保存在 `docs/project-analysis/` 目录
4. **增量更新**: code-structure-reader 支持增量更新,只更新变更的文档

## 未来改进

1. **自动检测**: 可以添加自动检测机制,基于文档年龄自动提示
2. **缓存机制**: 缓存文档分析结果,避免重复分析
3. **部分更新**: 允许用户选择只更新特定类型的文档
4. **CI 集成**: 在 CI 流程中自动检查文档健康状态

## 相关技能

- **superpowers:brainstorming** - 主技能,已修改
- **superpowers:code-structure-reader** - 被调用的技能,用于生成文档

## 相关文档

- `skills/brainstorming/SKILL.md` - 修改后的 brainstorming 技能
- `skills/code-structure-reader/SKILL.md` - code-structure-reader 技能文档
