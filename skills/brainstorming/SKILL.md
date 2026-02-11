---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
---

# Brainstorming Ideas Into Designs

## Overview

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design in three parts, presenting each part in small sections (200-300 words), checking after each section whether it looks right so far.

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
> - What are the endpoints and contracts?
> - What are the authentication and authorization mechanisms?
> - What are the error codes and response formats?
> - What are the rate limiting and throttling strategies?

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

**Part 2B: Frontend Technical Design (for frontend team)**

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
