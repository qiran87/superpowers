# Global TODOs

> **Last Updated:** 2026-02-26 15:30
> **Total TODOs:** 0
> **P0 (Critical):** 0 | **P1 (High):** 0 | **P2 (Medium):** 0 | **P3 (Low):** 0

---

## Purpose

此文件用于跟踪跨多个功能的待办事项和全局性问题。每个功能的特定 TODO 应记录在其对应的 `tasks.md` 文件中。

---

## P0 (Critical) - Blockers

> 阻塞开发进度或影响系统稳定性的关键问题

- [ ] **[P0-001]** - [Feature Name] - [Task/Component] - [Description]
  - **Discovered At:** 2026-02-26 14:00
  - **ETA:** 2026-02-26 18:00
  - **Assigned To:** [Agent Name]
  - **Impact:** [What is blocked]
  - **Workaround:** [Temporary solution if any]

---

## P1 (High) - Important

> 重要但不阻塞当前开发的功能改进

- [ ] **[P1-001]** - [Feature Name] - [Task/Component] - [Description]
  - **Discovered At:** 2026-02-26 14:00
  - **ETA:** TBD
  - **Assigned To:** [Agent Name]
  - **Impact:** [Why it's important]

---

## P2 (Medium) - Medium Priority

> 中等优先级的改进和优化

- [ ] **[P2-001]** - [Feature Name] - [Task/Component] - [Description]
  - **Discovered At:** 2026-02-26 14:00
  - **ETA:** TBD
  - **Assigned To:** [Agent Name]

---

## P3 (Low) - Low Priority

> 低优先级的改进或技术债

- [ ] **[P3-001]** - [Feature Name] - [Task/Component] - [Description]
  - **Discovered At:** 2026-02-26 14:00
  - **ETA:** TBD
  - **Assigned To:** [Agent Name]

---

## Deferred Items

> 已推迟到未来版本的功能或改进

| Item | Reason | Planned For | Reference |
|------|--------|-------------|-----------|
| [Feature/Optimization] | [Why deferred] | v1.1 / Future sprint | [Link to tasks.md] |

---

## Completed TODOs

> 最近完成的待办事项（保留最近 30 天的记录）

| ID | Description | Completed At | Completed By |
|----|-------------|--------------|--------------|
| P0-001 | [Description] | 2026-02-26 14:30 | [Agent Name] |
| P1-001 | [Description] | 2026-02-26 15:00 | [Agent Name] |

---

## Usage Guidelines

### 何时添加全局 TODO

**应该在 global-todos.md 中记录：**
- 影响多个功能的问题
- 架构级别的改进
- 跨功能的依赖项
- 全局配置问题
- 技术债和重构需求

**应该在功能的 tasks.md 中记录：**
- 功能特定的待办事项
- 任务级别的 TODO
- 功能相关的改进建议

### TODO ID 格式

使用格式 `[P<priority>-<number>]` 确保唯一性：
- P0-001, P0-002, ... (Critical)
- P1-001, P1-002, ... (High)
- P2-001, P2-002, ... (Medium)
- P3-001, P3-002, ... (Low)

### 状态更新流程

1. **发现 TODO：** 添加到相应优先级部分
2. **分配工作：** 更新 Assigned To 和 ETA
3. **完成 TODO：** 移动到 Completed TODOs 部分
4. **推迟 TODO：** 移动到 Deferred Items 表格
5. **定期清理：** 删除超过 30 天的已完成记录

---

## Integration with Active Work

全局 TODO 会自动同步到 `.spec-workflow/active/status.md` 的 "Global TODOs" 部分。

当更新此文件时，也应更新 `active/status.md` 以保持一致性。
