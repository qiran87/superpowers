  🔍 精确触发语句链路

  #️⃣ 步骤 1：自动注入 using-superpowers

  触发源： SessionStart 钩子（不可见，系统级）

  注入内容： skills/using-superpowers/SKILL.md:7

  <EXTREMELY-IMPORTANT>
  If you think there is even a 1% chance a skill might apply to what you are doing,
  you ABSOLUTELY MUST invoke the skill.

  IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.
  </EXTREMELY-IMPORTANT>

  建立规则：
  # using-superpowers/SKILL.md:24
  **Invoke relevant or requested skills BEFORE any response or action.**
  Even a 1% chance a skill might apply means that you should invoke skill to check.

  ---
  #️⃣ 步骤 2：匹配触发 brainstorming

  用户输入示例： "我想添加用户认证功能"

  触发点： description 字段匹配

  # brainstorming/SKILL.md:3
  description: "You MUST use this before any creative work - creating features, 
               building components, adding functionality, or modifying behavior. 
               Explores user intent, requirements and design before implementation."

  匹配逻辑：
  用户消息中的关键词：
  ├─ "添加" → 匹配 "creating features"
  ├─ "认证功能" → 匹配 "adding functionality"
  └─ AI 判断：这是"创造性工作"（creative work）

  → 触发 Skill 工具调用 brainstorming

  ---
  #️⃣ 步骤 3：brainstorming → using-git-worktrees

  精确触发语句： brainstorming/SKILL.md:187

  ## After Design

  **Documentation:**
  - Write validated design to `docs/plans/YYYY-MM-DD-<topic>-design.md`
  - Use elements-of-style:writing-clearly-and-concisely skill if available
  - Commit design document to git

  **Implementation (if continuing):**
  - Ask: "Ready to set up for implementation?"
  - Use superpowers:using-git-worktrees to create isolated workspace
  - Use superpowers:writing-plans to create detailed implementation plan

  执行时机：
  - ✅ 设计文档已保存到 docs/plans/
  - ✅ 已提交到 git
  - ✅ 用户确认继续实施

  ---
  #️⃣ 步骤 4：using-git-worktrees 创建隔离空间

  触发源： 上一步的明确指令

  # using-git-worktrees/SKILL.md:3
  description: Use when starting feature work that needs isolation from current
               workspace or before executing implementation plans - creates isolated
               git worktrees with smart directory selection and safety verification

  执行内容：
  1. 目录选择（.worktrees > worktrees > 全局目录）
  2. 安全验证（检查 .gitignore）
  3. 创建 worktree：git worktree add "$path" -b "$BRANCH_NAME"

  ---
  #️⃣ 步骤 5：brainstorming → writing-plans

  精确触发语句： brainstorming/SKILL.md:188

  **Implementation (if continuing):**
  - Ask: "Ready to set up for implementation?"
  - Use superpowers:using-git-worktrees to create isolated workspace
  - Use superpowers:writing-plans to create detailed implementation plan

  执行时机：
  - ✅ worktree 已创建
  - ✅ 在隔离工作空间中

  ---
  #️⃣ 步骤 6：writing-plans → 选择执行路径

  精确触发语句： writing-plans/SKILL.md:99-107

  ## Execution Handoff

  After saving the plan, offer execution choice:

  **"Plan complete and saved to `docs/plans/<filename>.md`. Two execution options:**

  **1. Subagent-Driven (this session)** - I dispatch fresh subagent per task,
     review between tasks, fast iteration

  **2. Parallel Session (separate)** - Open new session with executing-plans,
     batch execution with checkpoints

  **Which approach?**

  ---
  #️⃣ 步骤 7A：writing-plans → subagent-driven-development

  精确触发语句： writing-plans/SKILL.md:110

  **If Subagent-Driven chosen:**
  - **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
  - Stay in this session
  - Fresh subagent per task + code review

  技能描述：
  # subagent-driven-development/SKILL.md:3
  description: Use when executing implementation plans with independent tasks in current session

  ---
  #️⃣ 步骤 7B：writing-plans → executing-plans

  精确触发语句： writing-plans/SKILL.md:116

  **If Parallel Session chosen:**
  - Guide them to open new session in worktree
  - **REQUIRED SUB-SKILL:** New session uses superpowers:executing-plans

  技能描述：
  # executing-plans/SKILL.md:3
  description: Use when you have a written implementation plan to execute
               in a separate session with review checkpoints

  ---
  #️⃣ 步骤 8：嵌入 test-driven-development

  触发点： 自动嵌入（不在主流程中显式调用）

  嵌入位置： 子代理执行每个任务时

  # test-driven-development/SKILL.md:3
  description: Use when implementing any feature or bugfix,
               before writing implementation code

  集成说明： subagent-driven-development/SKILL.md:239

  ## Integration

  **Subagents should use:**
  - **superpowers:test-driven-development** - Subagents follow TDD for each task

  执行时机：
  - ✅ 每个子代理实施任务时
  - ✅ 自动检查是否需要 TDD

  ---
  #️⃣ 步骤 9：subagent-driven-development → code-reviewer

  触发点： 子代理任务完成后

  精确触发语句： subagent-driven-development/SKILL.md:46-47

  "Dispatch spec reviewer subagent (./spec-reviewer-prompt.md)" [shape=box];
  "Dispatch code quality reviewer subagent (./code-quality-reviewer-prompt.md)" [shape=box];

  模板文件： agents/code-reviewer.md

  name: code-reviewer
  description: Use this agent when a major project step has been completed
               and needs to be reviewed against original plan...

  ---
  #️⃣ 步骤 10：executing-plans / subagent-driven-development → finishing-a-development-branch

  精确触发语句：
  - executing-plans/SKILL.md:49
  - subagent-driven-development/SKILL.md:62

  # executing-plans/SKILL.md
  ### Step 5: Complete Development
  After all tasks complete and verified:
  - Announce: "I'm using finishing-a-development-branch skill..."
  - **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch

  # finishing-a-development-branch/SKILL.md:3
  description: Use when implementation is complete, all tests pass,
               and you need to decide how to integrate work

  ---
  📊 完整触发链路图

  用户: "我想添加用户认证功能"
         ↓
  【#1】SessionStart 钩子
         ↓
  注入: using-superpowers/SKILL.md:7
         ↓
  "IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT."
         ↓
  【#2】AI 匹配 description
         ↓
  brainstorming/SKILL.md:3
  description: "You MUST use this before any creative work..."
         ↓
  【#3】brainstorming 完成后
         ↓
  brainstorming/SKILL.md:187-188
  "Use superpowers:using-git-worktrees..."
  "Use superpowers:writing-plans..."
         ↓
  【#4】using-git-worktrees 执行
         ↓
  创建隔离工作空间 (.worktrees/project-name/)
         ↓
  【#5】writing-plans 执行
         ↓
  分解为 2-5 分钟的小任务
         ↓
  【#6】writing-plans/SKILL.md:101-107
  "Which approach?" → 用户选择
         ↓
         ├─ 【#7A】选择 Subagent-Driven
         │         ↓
         │         subagent-driven-development/SKILL.md:3
         │         description: "...in current session"
         │         ↓
         │         为每个任务派发子代理
         │         ↓
         │         【#8】自动嵌入 test-driven-development
         │         ↓
         │         RED → GREEN → REFACTOR
         │         ↓
         │         【#9】双重代码审查
         │         ↓
         │         agents/code-reviewer.md
         │         ↓
         │         Spec Reviewer → Code Quality Reviewer
         │
         └─ 【#7B】选择 Parallel Session
                   ↓
                   executing-plans/SKILL.md:3
                   description: "...in a separate session"
                   ↓
                   批量执行，检查点审查
                   ↓
                   【#8】自动嵌入 test-driven-development
         ↓
  【#10】所有任务完成
         ↓
  finishing-a-development-branch/SKILL.md:3
  description: "...when implementation is complete"
         ↓
  验证测试，呈现选项（合并/PR/保留/放弃）

  ---
  🎯 关键设计模式

  1. Description-First Triggering（描述优先触发）

  description: "You MUST use this before [触发条件]..."
  - 触发条件 = AI 匹配关键词 + 语义理解
  - 1% 原则 = "even a 1% chance a skill might apply"

  2. Explicit Instruction Chaining（显式指令链）

  - Use superpowers:using-git-worktrees to create isolated workspace
  - Use superpowers:writing-plans to create detailed implementation plan
  - 硬编码调用 = 技能文档中的明确语句
  - 顺序保证 = 按文档定义的顺序执行

  3. REQUIRED SUB-SKILL Marker（必需子技能标记）

  - **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
  - 强制调用 = 不建议，而是要求
  - 可验证性 = AI 检查是否调用了子技能

  4. Auto-Injection（自动嵌入）

  **Subagents should use:**
  - **superpowers:test-driven-development**
  - 隐性调用 = 不在主流程中显式调用
  - 条件嵌入 = 特定场景自动启用

  ---
  💡 触发机制总结

  | 机制                 | 位置                        | 触发方式    | 示例                              |
  |--------------------|---------------------------|---------|---------------------------------|
  | SessionStart 钩子    | .claude-plugin/hooks.json | 系统自动    | 注入 using-superpowers            |
  | Description 匹配     | SKILL.md:3                | AI 语义匹配 | "creative work" → brainstorming |
  | 显式指令               | SKILL.md 正文               | 逐字执行    | Use superpowers:xxx             |
  | REQUIRED SUB-SKILL | 技能集成部分                    | 强制调用    | **REQUIRED SUB-SKILL:**         |
  | Auto-Injection     | 子技能说明                     | 隐性嵌入    | "Subagents should use:"         |

  这就是 Superpowers 的精确触发链路！每一步都有明确的触发点，形成了完整的自动化流程。🎯