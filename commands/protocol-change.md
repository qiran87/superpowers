---
name: protocol-change
description: 处理接口协议变更，确保前后端对齐并更新文档
---

# 协议变更命令

使用 `/protocol-change` 来处理需要修改接口协议的变更。

## 适用场景

当您遇到以下情况时使用此命令：

- **新增字段** - 添加新的 API 字段或数据库列
- **修改字段** - 改变字段类型、名称或属性
- **删除字段** - 移除现有字段（需考虑向后兼容）
- **新增/修改 API** - 创建新端点或修改现有端点
- **前后端对齐** - 确保前后端使用相同的字段定义

## 协议变更检查清单

在实施任何代码变更之前：

```
□ 识别变更类型
  □ 新增字段
  □ 修改字段
  □ 删除字段
  □ 新增/修改 API

□ 更新协议文档
  □ docs/project-analysis/02-backend-apis.md
  □ docs/project-analysis/03-backend-domains.md
  □ docs/project-analysis/04-database-schemas.md

□ 前后端对齐
  □ 前端使用: field_name
  □ 后端提供: field_name
  □ 协议定义: field_name
  □ 三者完全一致
```

## 处理流程

### Step 1: 识别变更类型

**问自己：**
- 这个变更是否涉及 API 字段？
- 这个变更是否影响前后端接口？
- 这个变更是否需要数据库 schema 变更？

### Step 2: 更新协议文档

**更新格式：**

```markdown
## [API/Entity 名称]

### [字段名称] [NEW] / [MODIFIED YYYY-MM-DD] / [DEPRECATED]

**类型:** string | number | boolean | etc.

**描述:** 字段说明

**是否必需:** true | false

**示例:**
```json
{
  "field_name": "example value"
}
```

**变更说明:**
- [NEW]: 新增字段，用途是...
- [MODIFIED]: 从 old_type 改为 new_type，原因是...
- [DEPRECATED]: 计划于 YYYY-MM-DD 移除，请使用 new_field 替代
```

### Step 3: 前后端对齐验证

**检查表：**

| 检查项 | 前端 | 后端 | 协议 | 状态 |
|--------|------|------|------|------|
| 字段名 | `avatar` | `avatar` | `avatar` | ✅ |
| 字段类型 | string | string | string | ✅ |
| 必需性 | required | true | true | ✅ |

### Step 4: 实施代码变更

**顺序：**
1. 先更新协议文档
2. 后端实现
3. 前端实现
4. 验证对齐

## 常见场景

### 场景 1: 新增字段

**需求：** 给用户对象添加头像字段

**正确流程：**

```bash
# 1. 更新协议文档
# docs/project-analysis/02-backend-apis.md
## User API
### avatar [NEW 2025-02-26]
- **类型:** string
- **描述:** 用户头像 URL
- **是否必需:** false

# 2. 后端实现
# 添加 avatar 字段到响应

# 3. 前端实现
# 使用 avatar 字段（不是 avatar_url）

# 4. 验证
# 前端: user.avatar
# 后端: { avatar: "url" }
# 协议: avatar: string
```

### 场景 2: 修改字段

**需求：** email 字段从必需改为可选

**正确流程：**

```bash
# 1. 更新协议文档
# docs/project-analysis/02-backend-apis.md
### email [MODIFIED 2025-02-26]
- **是否必需:** false (原: true)
- **变更原因:** 支持社交登录，用户可能没有邮箱

# 2. 后端实现
# 修改验证逻辑

# 3. 前端实现
# 调整表单验证

# 4. 验证
# 确保前后端都支持 email 为空
```

### 场景 3: 字段重命名

**需求：** `username` 改为 `email`

**正确流程：**

```bash
# 1. 更新协议文档
# docs/project-analysis/02-backend-apis.md
### email [MODIFIED 2025-02-26, was: username]
- **类型:** string
- **描述:** 用户邮箱（原 username 字段）
- **迁移说明:** 现有数据需要迁移

# 2. 数据库迁移
# username → email

# 3. 后端实现
# 使用 email 替代 username

# 4. 前端实现
# 全局替换 username 为 email

# 5. 验证
# 确保没有残留的 username 引用
```

## 错误示例

### ❌ 错误 1: 只改后端，不更新协议

```
后端添加了 avatar 字段
前端使用了 avatar_url 字段
协议文档没更新

结果：前后端不对齐
```

### ❌ 错误 2: 字段名不一致

```
后端提供: avatar
前端使用: avatar_url
协议定义: avatar（但前端不知道）

结果：运行时错误
```

### ❌ 错误 3: 类型不一致

```
协议定义: count: number
后端返回: count: string
前端期望: count: number

结果：类型错误
```

## 相关技能

- **superpowers:protocol-compliance-check** - 验证代码与协议一致
- **superpowers:test-driven-development** - TDD 中包含协议变更检测
- **superpowers:brainstorming** - 设计阶段处理协议变更

## 快捷方式

**使用方式：**
```
/protocol-change
```

**带描述：**
```
/protocol-change 给 User 对象添加 avatar 字段
```

**输出：**
自动引导您完成协议变更的完整流程。
