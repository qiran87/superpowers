---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
---

# Brainstorming Ideas Into Designs

## Overview

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design in three parts, presenting each part in small sections (200-300 words), checking after each section whether it looks right so far.

## Pre-Check: Documentation Health

**Before understanding the project context, check if documentation needs systematic update.**

### Why This Matters

Outdated documentation can lead to:
- Designing features that already exist
- Missing architectural constraints and patterns
- Inconsistent understanding of the system
- Wasted development effort

### The Check Process

**Step 1: Ask the user**

Use the `AskUserQuestion` tool with this configuration:

```yaml
questions:
  - question: "Before we dive into requirements, I need to check: Does the current project documentation accurately reflect the codebase, or has it become outdated as the code evolved?"
    header: "Doc Status"
    options:
      - label: "Documentation is current"
        description: "Project docs are up-to-date, proceed with brainstorming"
      - label: "Documentation needs update"
        description: "Systematically analyze codebase and generate fresh documentation (11 docs, ~5-10 min)"
      - label: "Not sure"
        description: "I'll check the docs and let you know if they seem outdated"
    multiSelect: false
```

**Step 2: Handle user response**

**If user selects "Documentation needs update":**

1. Announce: "Using **superpowers:code-structure-reader** to systematically analyze the codebase and generate comprehensive documentation."

2. Use the `Skill` tool to invoke `superpowers:code-structure-reader`

3. Wait for the skill to complete. It will generate 12 documents at `docs/project-analysis/`:
   - 00-overview.md (Project overview)
   - 01-frontend-components.md (Frontend architecture)
   - 02-backend-apis.md (API endpoints)
   - 03-backend-domains.md (Domain models)
   - 04-database-schemas.md (Database structure)
   - 05-third-party-deps.md (Dependencies)
   - 06-external-apis.md (External services)
   - 07-dev-guide.md (Development guide)
   - 08-code-relations.md (Dependencies + calls + data flows)
   - 09-architecture-patterns.md (Architecture patterns)
   - 10-testing-strategy.md (Testing approach)
   - 11-quality-reports.md (Technical debt + security)
   - 12-interaction-index.md (Navigation index)

4. After completion, announce: "✅ Documentation analysis complete! Generated 12 comprehensive documents at `docs/project-analysis/`. I'll use this fresh context to inform our design discussion."

5. Proceed to "Understanding the idea" section with updated context

**If user selects "Documentation is current":**

- Skip code analysis
- Proceed directly to "Understanding the idea" section
- Use existing documentation for context

**If user selects "Not sure":**

- Quick check: Look at `docs/` directory and recent git commits
- If docs exist and are recent (< 30 days old), proceed
- If docs are missing or old (> 60 days), recommend update
- Ask user again with recommendation

**Step 3: Continue to brainstorming**

Whether documentation was updated or not, proceed to the "Understanding the idea" section below.

**Record to Execution Log:**
```markdown
- [ ] Update EXECUTION_LOG.md with:
  - Phase: Brainstorming
  - Action: Completed brainstorming session for "{feature/concept}"
  - Details: Design decisions made, alternatives explored, stakeholder questions answered
  - Next: Proceed to writing-plans or design-with-existing-modules
```

## The Process

**Understanding the idea:**
- Check out the current project state first (files, docs, recent commits)
- Ask questions one at a time to refine the idea
- Prefer multiple choice questions when possible, but open-ended is fine too
- Only one question per message - if a topic needs more exploration, break it into multiple questions
- Focus on understanding: purpose, constraints, success criteria

**Exploring approaches:**
- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why

**Presenting the design:**
- Once you believe you understand what you're building, present the design in three parts
- Break each part into sections of 200-300 words
- Ask after each section whether it looks right so far
- Be ready to go back and clarify if something doesn't make sense

**Part 1: Business Requirements (for stakeholders)**
- Feature overview: What problem does this solve?
- User stories: Who benefits and how?
- Business rules: What are the constraints and requirements?
- User workflows: Step-by-step user interactions
- Acceptance criteria: How do we know it's done?
- Edge cases: What about unusual scenarios?

**Part 2A: Backend Technical Design (for backend team)**

> **⚠️ IMPORTANT:** Before presenting this section, use **superpowers:design-with-existing-modules** to:
> 1. Check `docs/project-analysis/` for existing modules
> 2. Identify reusable components, APIs, domain models, database schemas
> 3. Make informed decisions: REUSE → MODIFY → CREATE NEW
> 4. Update project documentation with changes
>
> This ensures the technical design leverages existing investments and avoids duplication.

- What are the architectural layers and their responsibilities?
- What are the cross-cutting concerns (logging, caching, metrics)?
- How will services communicate (sync vs async, message queue, event-driven)?

> **Technology Choices:**
> - What are the libraries, frameworks, and databases?
> - What are the testing frameworks and strategies?

> **DDD Domain Model:**
> - What are the domains, aggregates, and entities?
> - What are the repository patterns and value objects?

> **Database Design:**
> - What is the schema, indexes, and migrations?
> - How will we handle data versioning and consistency?
> - What are the transaction boundaries and isolation levels?

> **API Design:**
> - **输出格式要求:** 必须为每个新/修改的 API 提供以下格式:
>   ```markdown
>   #### METHOD /api/资源名
>   **描述:** 操作说明
>   **请求:** `{字段: 类型, ...}`
>   **响应:** `{字段: 类型, ...}`
>   **错误码:** 列表
>   ```
> - **同步要求:** 设计完成后必须将此部分内容同步到 `docs/project-analysis/02-backend-apis.md`
> - What are the endpoints and contracts?
> - What are the authentication and authorization mechanisms?
> - What are the error codes and response formats?
> - What are the rate limiting and throttling strategies?
>
> **🔍 EXTERNAL API INTEGRATION (外部接口集成):**
>
> **当设计涉及调用外部服务时，必须设计适配器层:**
>
> **1. 分析外部接口字段差异 (REQUIRED)**
>
> **检查所有外部接口并记录:**
> - 外部接口 A 返回的字段格式
> - 外部接口 B 返回的字段格式
> - 识别字段命名不一致的地方
>
> **示例场景:**
> ```typescript
> // 外部接口 A: { n: "value" }
> // 外部接口 B: { name: "value" }
> // → 字段命名不一致！
> ```
>
> **2. 设计适配器层 (Adapter Layer) - REQUIRED**
>
> **⚠️ CRITICAL: 直接使用外部接口字段是架构违规**
>
> **必须创建:**
> - **统一的内部字段命名** - 所有外部接口通过适配器后使用统一字段
> - **适配器服务** - 处理外部字段到内部字段的映射
> - **隔离层** - 防止外部接口变化影响内部系统
>
> **架构设计:**
> ```
> External API A → UserAdapter_A → Internal System (统一字段)
> External API B → UserAdapter_B → Internal System (统一字段)
> ```
>
> **3. 字段映射配置 (REQUIRED)**
>
> **必须在设计中明确记录:**
> ```markdown
> ## External API Field Mapping
>
> ### External API A
> | External Field | Internal Field | Transformation |
> |----------------|----------------|----------------|
> | `n` | `name` | Direct mapping |
> | `id` | `externalId` | Rename to avoid collision |
>
> ### External API B
> | External Field | Internal Field | Transformation |
> |----------------|----------------|----------------|
> | `name` | `name` | No transformation needed |
> ```
>
> **4. 实现示例**
>
> **❌ WRONG: 直接使用外部字段**
> ```typescript
> class UserService {
>     // 接口 A
>     async getUserFromAPI_A() {
>         const response = await fetch('https://api-a.com/user');
>         const user = await response.json();
>         return { name: user.n };  // ❌ 直接使用外部字段 n
>     }
>
>     // 接口 B
>     async getUserFromAPI_B() {
>         const response = await fetch('https://api-b.com/user');
>         const user = await response.json();
>         return { name: user.name };  // ❌ 与接口A处理方式不同
>     }
> }
> ```
>
> **✅ RIGHT: 通过适配器层统一处理**
> ```typescript
> // 适配器层 - 处理字段映射
> class UserAdapterService {
>     async getUserFromAPI_A() {
>         const externalUser = await externalAPI_A.getUser();
>         // 字段映射: n → name
>         return {
>             name: externalUser.n,
>             externalId: externalUser.id
>         };
>     }
>
>     async getUserFromAPI_B() {
>         const externalUser = await externalAPI_B.getUser();
>         // 字段映射: name → name (无需转换)
>         return {
>             name: externalUser.name,
>             externalId: externalUser.id
>         };
>     }
> }
>
> // 统一的内部接口
> class UserService {
>     constructor(private adapter: UserAdapterService) {}
>
>     async getUser(source: 'api-a' | 'api-b', externalId: string) {
>         // 统一的内部字段: name
>         return await this.adapter.getUser(source, externalId);
>     }
> }
> ```
>
> **5. 协议文档更新要求**
>
> **必须同时更新两个文档：**
>
> **1. 外部接口文档: `docs/project-analysis/06-external-apis.md`**
> ```markdown
> ## [External Service Name]
>
> **Base URL:** `https://api.example.com`
>
> **Authentication:** API Key / OAuth 2.0 / Bearer Token
>
> **Endpoints:**
> | Method | Path | Purpose | Request Fields | Response Fields |
> |--------|------|---------|----------------|-----------------|
> | GET | `/api/users/:id` | Get user | `id` | `n`, `id` |
>
> **Field Mapping (External → Internal):**
> | External Field | Internal Field | Type | Transformation |
> |----------------|----------------|------|----------------|
> | `n` | `name` | string | Direct mapping |
> | `id` | `externalId` | string | Rename to avoid collision |
> ```
>
> **2. 内部适配器接口: `docs/project-analysis/02-backend-apis.md`**
> ```markdown
> ## [ServiceName]Adapter API
>
> **Description:** 适配器层，统一外部 [Service Name] 接口字段
>
> **Internal Schema:**
> ```json
> {
>   "name": "string",      // 统一的字段
>   "externalId": "string" // 外部系统 ID
> }
> ```
>
> **Adapter Implementation:** `src/adapters/[ServiceName]AdapterService.ts`
> ```
>
> **6. 常见错误模式**
>
> ❌ **直接使用外部字段**
> ```typescript
> const user = await externalAPI.getUser();
> const name = user.n;  // 外部字段直接使用
> ```
>
> ❌ **在不同接口使用不同处理**
> ```typescript
> // 接口 A
> const nameA = user.n;
> // 接口 B
> const nameB = user.name;
> // → 内部系统字段不统一!
> ```
>
> ❌ **在多处重复映射逻辑**
> ```typescript
> // 重复的映射逻辑散落在各处
> const name1 = externalUser1.n;
> const name2 = externalUser2.n;
> ```
>
> ✅ **正确: 统一的适配器层**
> ```typescript
> // 所有外部接口都通过适配器
> const user = await adapter.getUser(source, id);
> const name = user.name;  // 统一使用内部字段
> ```
>
> **7. 询问用户 (在设计阶段)**
>
> **在设计涉及外部接口时，必须询问:**
> ```yaml
> questions:
>   - question: "这个功能是否涉及调用外部服务？"
>     options:
>       - label: "是，需要调用外部接口"
>       - label: "否，仅内部系统"
>       - label: "不确定"
> ```
>
> **如果选择"是"：**
> - 列出所有外部接口及其字段格式
> - 识别字段命名不一致的地方
> - 设计适配器层处理字段映射
> - 在协议文档中记录映射关系

> **Security & Performance:**
> - What are the data encryption and hashing algorithms?
> - What are the SQL injection and XSS prevention strategies?
> - What are the query optimization and connection pooling strategies?
> - What are the observability mechanisms (metrics, tracing, alerts)?

> **🔍 Criteria: Large Requirement Changes**
> The following items require detailed elaboration only during 【Large Requirement Changes】:
> - System Architecture (系统架构)
> - Data Modeling Strategy (数据建模策略)
> - Error Handling & Logging (错误处理和日志)
> - Caching Strategy (缓存策略)
> - Messaging & Async Processing (消息队列)
> - Service Governance & Monitoring (服务治理)
> - Database Migration & Versioning (数据库迁移和版本管理)
>
> 【Small Requirement Changes】should only cover:
> - Technical architecture (技术架构)
> - DDD domain model (领域模型)
> - Database design (数据库设计)
> - API design (接口设计)
> - Security & performance (安全和性能)
>
> **Basis for judgment:**
> - Involves multiple service/system collaboration
> - Impacts overall architecture selection
> - Requires cross-team review (frontend, backend, DevOps)
> - Or is microservices/distributed architecture
>
> **Team size > 5 people or Large projects: Must elaborate system-level design**
>
> **Small Requirement Changes handling approach:**
> - Maintain existing architecture, optimize existing implementation
> - Does not involve system-level design changes
> - Can be completed within single service
>
> **⚠️ PROTOCOL CHANGE CHECK for Small Changes:**
>
> **Before finalizing small requirement designs, check:**
>
> **1. Does this change involve protocol modifications?**
> - New fields in API request/response?
> - Modified field types or names?
> - New/modified API endpoints?
> - Database schema changes?
>
> **2. If YES → Protocol Change Required:**
>
> **Step-by-Step Update Process:**
>
> **Step 1: Read current protocol**
> ```bash
> Read docs/project-analysis/02-backend-apis.md
> ```
>
> **Step 2: Update using Edit tool**
> ```markdown
> ## [API Name]
>
> ### [field_name] [NEW/MODIFIED/YYYY-MM-DD]
> - **Type:** string | number | boolean | object | array
> - **Description:** What this field represents
> - **Required:** true | false
> - **Constraints:** Any validation rules
> - **Example:** Example value
>
> **For NEW field example:**
> ### avatar [NEW 2025-02-26]
> - **Type:** string
> - **Description:** User avatar URL
> - **Required:** false
> - **Constraints:** Must be valid URL
> - **Example:** "https://example.com/avatar.jpg"
>
> **For MODIFIED field example:**
> ### email [MODIFIED 2025-02-26]
> - **Required:** false (changed from: true)
> - **Reason:** Support social login without email
> ```
>
> **Step 3: Verify format consistency**
> - Match existing field format in the document
> - Use same indentation and style
> - Include in correct section (Request/Response)
>
> **Step 4: Frontend-Backend Alignment Verification**
>
> Create and present alignment checklist:
> ```markdown
> **Frontend-Backend Alignment:**
> - Field name: `avatar`
>   - Frontend uses: avatar ✅
>   - Backend provides: avatar ✅
>   - Protocol defines: avatar ✅
>   - All three match: YES ✅
> ```
>
> **Step 5: Document and confirm**
> - State clearly: "协议变更: 新增字段 avatar"
> - Mark in design document: `[PROTOCOL CHANGE]`
> - Ask user: "前后端字段已对齐，使用 `avatar`，是否确认继续？"
>
> **3. Summary Update Process:**
> - Use Edit tool to modify `docs/project-analysis/02-backend-apis.md`
> - Mark changes with [NEW], [MODIFIED date], or [DEPRECATED]
> - If changing existing field: document breaking change impact
> - Verify frontend and backend design sections reference same field names
> - Present alignment checklist to user for confirmation
>
> **4. Communication:**
> - Explicitly state: "协议变更: 字段 X 是 [NEW/MODIFIED]"
> - Present alignment checklist with field names
> - Ask: "前后端已对齐，都使用 `field_name`，是否确认？"
>
> **5. If NO protocol change:**
> - Proceed with standard small change process
>
> **Common mistakes to avoid:**
> - ❌ Adding field in backend but not updating protocol
> - ❌ Frontend uses `avatar_url` while backend provides `avatar`
> - ❌ Changing field type without marking [MODIFIED]
> - ❌ Forgetting to update 02-backend-apis.md after design

**Part 2B: Frontend Technical Design (for frontend team)**

> **⚠️ IMPORTANT:** Before presenting this section, use **superpowers:design-with-existing-modules** to:
> 1. Check `docs/project-analysis/01-frontend-components.md` for existing components
> 2. Identify reusable UI components, layouts, hooks, contexts
> 3. Make informed decisions: REUSE → MODIFY → CREATE NEW
> 4. Update project documentation with changes
>
> This ensures the frontend design maintains consistency and leverages existing patterns.

- How will we structure the application routing and layouts?
- What are the code organization patterns (feature-based, layer-based)?

> **Technology Choices:**
> - What are the frameworks and UI libraries?
> - What are the state management solutions and build tools?
> - What are the testing frameworks and mocking strategies?

> **Component Design:**
> - What are the main components and their hierarchy?
> - What are the presentational vs container components?
> - What are the composition patterns and prop drilling strategies?

> **State Management:**
> - How will we manage global state (server, client, static)?
> - How will we handle async state and side effects?
> - What are the state persistence and rehydration strategies?

> **API Integration:**
> - How will we call backend services and handle loading/error states?
> - What are the request/response interceptors and retry strategies?
> - What are the real-time data synchronization mechanisms (WebSockets, SSE)?

> **UI/UX Design:**
> - What are the design system and component libraries?
> - What are the responsive design breakpoints and strategies?
> - What are the accessibility standards (WCAG, ARIA) and keyboard navigation?

> **Performance & Optimization:**
> - What are the code splitting and lazy loading strategies?
> - What are the asset optimization and bundling strategies?
> - What are the rendering optimization techniques (memo, virtualization, React.memo)?

**Part 3: Cross-Cutting Concerns**

- How will frontend and backend integrate and synchronize data?
- What are the API versioning and backward compatibility strategies?

> **Testing Strategy:**
> - What are the unit testing frameworks and coverage targets?
> - What are the integration and E2E testing approaches?
> - What are the contract testing and consumer-driven testing strategies?

> **Deployment & DevOps:**
> - What are the deployment environments and promotion strategies?
> - What are the infrastructure as code and configuration management approaches?
> - What are the monitoring, alerting, and incident response procedures?

> **🔍 Criteria: Large Requirement Changes**
> The following items require detailed elaboration only during 【Large Requirement Changes】:
> - System Architecture (系统架构)
> - Data Modeling Strategy (数据建模策略)
> - Error Handling & Logging (错误处理和日志)
> - Caching Strategy (缓存策略)
> - Messaging & Async Processing (消息队列)
> - Service Governance & Monitoring (服务治理)
> - Database Migration & Versioning (数据库迁移和版本管理)
>
> 【Small Requirement Changes】should only cover:
> - Technical architecture (技术架构)
> - DDD domain model (领域模型)
> - Database design (数据库设计)
> - API design (接口设计)
> - Security & performance (安全和性能)
>
> **Basis for judgment:**
> - Involves multiple service/system collaboration
> - Impacts overall architecture selection
> - Requires cross-team review (frontend, backend, DevOps)
> - Or is microservices/distributed architecture
>
> **Team size > 5 people or Large projects: Must elaborate system-level design**

## After Design

**Documentation:**
- Write the validated design to `docs/plans/YYYY-MM-DD-<topic>-design.md`
- Use elements-of-style:writing-clearly-and-concisely skill if available
- Commit the design document to git

**Implementation (if continuing):**
- Ask: "Ready to set up for implementation?"
- Use superpowers:using-git-worktrees to create isolated workspace
- Use superpowers:writing-plans to create detailed implementation plan

## Key Principles

- **One question at a time** - Don't overwhelm with multiple questions
- **Multiple choice preferred** - Easier to answer than open-ended when possible
- **YAGNI ruthlessly** - Remove unnecessary features from all designs
- **Explore alternatives** - Always propose 2-3 approaches before settling
- **Incremental validation** - Present design in sections, validate each
- **Be flexible** - Go back and clarify when something doesn't make sense
