# 模块复用设计功能说明

## 概述

在技术方案设计环节增加模块复用检查功能，确保新功能能够充分利用现有代码库，避免重复开发，保持架构一致性。

## 实现时间

2026-02-13

## 核心功能

### 1. 自动检查现有模块

在技术方案设计前，系统会自动：
- 读取 `docs/project-analysis/` 目录中的项目文档
- 分析新需求的各个维度（前端/后端/领域/数据库）
- 对比现有模块，查找可复用/可改造的内容

### 2. 三种决策模式

根据分析结果，自动推荐三种方案之一：

#### ✅ REUSE (直接复用)
- **条件:** 现有模块 100% 满足需求
- **行动:** 直接使用，无需修改
- **示例:** 现有的 AuthComponent 完全满足认证需求

#### 🔧 MODIFY (改造升级)
- **条件:** 现有模块满足 60-90% 的需求，且改造成本 < 从头开发
- **行动:** 在设计文档中详细描述改造方案
- **格式:** **从** [现有状态] **改造成** [目标状态]
- **示例:** UserService 改造增加 2FA 功能

#### ➕ CREATE NEW (新增模块)
- **条件:** 无相似模块，或现有模块差异过大 (< 60% 相似度)
- **行动:** 论证新增必要性，说明为什么不能复用/改造
- **示例:** 需要全新的 NotificationService

### 3. 文档同步更新

所有改造或新增的模块，必须同步更新到 `docs/project-analysis/` 对应文件中：
- ✅ REUSE: 无需更新文档
- 🔧 MODIFY: 更新现有模块说明，标注变更
- ➕ CREATE NEW: 添加新模块说明，遵循已有格式

## 工作流程

```
用户触发技术方案设计
         ↓
使用 design-with-existing-modules 技能
         ↓
读取 docs/project-analysis/ 文档
         ↓
分析需求 vs 现有模块
    ┌────┴────┐
    │         │
  相似      不相似
    │         │
评估相似度   新增
    │         │
┌───┴───┐     ↓
│       │  论证必要性
100%  部分  说明新模块
 │     (60-90%)
 │       │
 │    改造方案
 │       │
 │    更新文档
 │       │
 └───┬───┘
     ↓
更新设计文档
标注决策
     ↓
完成技术设计
```

## 设计文档格式

在技术设计文档中，需要添加"模块复用分析"章节：

### 示例：后端技术设计

```markdown
## Part 2A: Backend Technical Design

### Module Reuse Analysis

#### ✅ REUSED MODULES

**AuthComponent** (from `01-frontend-components.md`)
- **Existing:** LoginForm, RegisterForm, PasswordReset
- **Decision:** REUSE 100%
- **Reasoning:** 现有认证组件完全满足需求
- **Integration:** 无需修改，直接配置

#### 🔧 MODIFIED MODULES

**UserService** (from `03-backend-domains.md`)
- **Existing:** 用户 CRUD、个人资料管理
- **Decision:** 改造增加 2FA 功能
- **改造方案:**
  - **从:** 基于密码的单因素认证
  - **到:** 支持TOTP的多因素认证
  - **所需变更:**
    - 在领域模型中添加 `TwoFactorAuth` 实体
    - UserService 添加 `verifyTotp(token)` 方法
    - 数据库架构更新，存储TOTP密钥
  - **影响分析:**
    - 破坏性变更: 无（向后兼容）
    - 现有消费者: 不受影响
    - 需要迁移: 是（添加TOTP密钥列）

#### ➕ NEW MODULES

**NotificationService** (新增)
- **Decision:** 创建新模块
- **理由:**
  - 未找到现有的通知功能
  - 需要实时提醒能力
  - 无法轻易添加到现有服务
- **功能:**
  - 多渠道通知（邮件、短信、推送）
  - 模板管理
  - 投递追踪
- **集成点:**
  - 调用方: OrderService, UserService
  - 依赖: MessageQueue (RabbitMQ)
  - 存储: notification_log 表
```

## 文档更新格式

### MODIFY 示例

在 `docs/project-analysis/03-backend-domains.md` 中：

```markdown
## UserService

**描述:** 管理用户生命周期和认证

**最后修改:** 2026-02-13 (添加2FA支持)

### 核心方法

- `createUser(data)`: 创建新用户账户
- `updateUser(id, data)`: 更新用户资料
- `authenticate(credentials)`: 认证用户（密码 + TOTP）
- `verifyTotp(token)`: **[新增]** 验证基于时间的一次性密码
- `enableTotp(userId)`: **[新增]** 启用双因素认证
- `disableTotp(userId)`: **[新增]** 禁用双因素认证

### 实体

#### User (现有)
- id: UUID
- email: String
- password_hash: String
- profile: JSONB
- totp_secret: String **[新增]**
- totp_enabled: Boolean **[新增]**
- created_at: Timestamp
- updated_at: Timestamp

#### TwoFactorAuth **[新增]**
- id: UUID
- user_id: UUID (外键)
- secret: String
- backup_codes: String[]
- enabled_at: Timestamp
```

### CREATE NEW 示例

在 `docs/project-analysis/02-backend-apis.md` 中：

```markdown
## NotificationService API

**描述:** 多渠道通知投递服务

**添加时间:** 2026-02-13

### 接口端点

#### POST /api/notifications/send
通过指定渠道发送通知

**请求体:**
```json
{
  "userId": "uuid",
  "channels": ["email", "sms", "push"],
  "template": "order_confirmation",
  "data": {
    "orderId": "uuid",
    "amount": 99.99
  }
}
```

**响应:** 202 Accepted
```json
{
  "notificationId": "uuid",
  "status": "queued",
  "estimatedDelivery": "2026-02-13T10:30:00Z"
}
```
```

## 使用场景

### 场景 1: 完全新功能，无现有模块

**需求:** 添加订单退款功能

**检查结果:**
- ❌ 未找到现有 RefundService
- ❌ 未找到退款相关的领域模型
- ❌ 未找到退款相关的数据库表

**决策:** ➕ CREATE NEW

**设计文档内容:**
```markdown
#### ➕ NEW MODULES

**RefundService** (新增)
- **Decision:** 创建新模块
- **理由:**
  - 项目中完全没有退款功能
  - 需要全新的业务逻辑
  - 涉及支付系统集成，复杂度高
- **功能:** 退款申请、审核、执行、状态追踪
```

**文档更新:** 添加到 `03-backend-domains.md` 和 `04-database-schemas.md`

### 场景 2: 部分匹配，可以改造

**需求:** 为用户资料添加头像上传功能

**检查结果:**
- ✅ 找到 UserService，负责用户管理
- ✅ 找到 User 实体
- ❌ 未找到文件上传相关功能
- ✅ 相似度约 70%（已有用户管理，缺文件上传）

**决策:** 🔧 MODIFY

**设计文档内容:**
```markdown
#### 🔧 MODIFIED MODULES

**UserService** (from `03-backend-domains.md`)
- **Existing:** 用户 CRUD、个人资料管理
- **Decision:** 改造增加头像上传功能
- **改造方案:**
  - **从:** 仅支持文本资料更新
  - **到:** 支持头像图片上传和管理
  - **所需变更:**
    - UserService 添加 `uploadAvatar(userId, file)` 方法
    - UserService 添加 `deleteAvatar(userId)` 方法
    - User 实体添加 avatar_url 字段
    - 集成文件存储服务（如 S3）
  - **影响分析:**
    - 破坏性变更: 无
    - 现有消费者: 不受影响
    - 需要迁移: 是（添加 avatar_url 列）
```

**文档更新:** 更新 `03-backend-domains.md` 中的 UserService 部分

### 场景 3: 完全匹配，直接复用

**需求:** 添加用户登出功能

**检查结果:**
- ✅ 找到 AuthService
- ✅ 已有 `logout(token)` 方法
- ✅ 相似度 100%

**决策:** ✅ REUSE

**设计文档内容:**
```markdown
#### ✅ REUSED MODULES

**AuthService** (from `03-backend-domains.md`)
- **Existing:** 登录、登出、令牌刷新
- **Decision:** 直接复用 100%
- **Reasoning:** 现有登出功能完全满足需求
- **Integration:** 无需修改，直接调用现有 `logout(token)` 方法
```

**文档更新:** 无需更新

## 技术优势

1. **避免重复开发**
   - 在设计阶段发现可复用模块
   - 节省 30-50% 开发时间

2. **保持架构一致性**
   - 复用现有设计模式和最佳实践
   - 减少技术债务

3. **降低维护成本**
   - 复用经过测试的代码
   - 减少潜在 bug

4. **文档与代码同步**
   - 强制更新项目文档
   - 确保文档始终准确

5. **更好的决策记录**
   - 明确记录为什么选择复用/改造/新增
   - 便于后续审查和演进

## 文件结构

```
skills/
  design-with-existing-modules/
    SKILL.md  # 新技能定义

skills/
  brainstorming/
    SKILL.md  # 已修改，集成新技能

docs/
  feature-module-reuse-design.md  # 本文档
```

## 相关技能

- **design-with-existing-modules** - 核心技能（新建）
- **brainstorming** - 主技能（已修改）
- **code-structure-reader** - 前置依赖（生成项目分析文档）

## 使用步骤

1. **运行 code-structure-reader**
   ```bash
   # 生成项目分析文档
   /superpowers:code-structure-reader
   ```

2. **触发 brainstorming**
   ```
   "帮我设计一个订单退款功能"
   ```

3. **自动检查模块**
   - brainstorming 会自动调用 design-with-existing-modules
   - 分析现有代码库
   - 提供复用/改造/新增建议

4. **审查设计文档**
   - 查看"模块复用分析"章节
   - 确认决策合理性
   - 验证文档更新

## 未来改进

1. **自动相似度计算**
   - 使用语义分析自动计算模块相似度
   - 提供量化的复用建议

2. **改造影响分析**
   - 自动分析改造对现有代码的影响
   - 识别潜在的破坏性变更

3. **测试用例推荐**
   - 为复用的模块推荐相关测试用例
   - 为改造的模块生成回归测试清单

4. **成本估算**
   - 估算复用 vs 改造 vs 新增的开发成本
   - 提供数据驱动的决策支持
