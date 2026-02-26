---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute tasks in batches, report for review between batches.

**Core principle:** Batch execution with checkpoints for architect review.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## The Process

### Step 1: Load and Review Plan

1. **Read plan file** from `docs/plans/YYYY-MM-DD-<feature-name>.md`
2. **Read tasks.md** from `.spec-workflow/specs/<feature-name>/tasks.md` (if exists)
3. **Read verification.md** from `.spec-workflow/specs/<feature-name>/verification.md` (if exists)
4. Review critically - identify any questions or concerns about the plan
5. If concerns: Raise them with your human partner before starting
6. If no concerns: Create TodoWrite and proceed

> **⚠️ CRITICAL (v4.2.0):** If `.spec-workflow/specs/<feature-name>/tasks.md` exists:
> - **MANDATORY:** Use it as the source of truth for task status
> - **MANDATORY:** Update task status in tasks.md when executing
> - **MANDATORY:** Run verification checklist after batch completion

### Step 2: Execute Batch
**Default: First 3 tasks**

For each task:
1. **Mark as in_progress in tasks.md** (if using enhanced format):
   ```markdown
   - [ ] **Status:** 🔵 Not Started → ⏳ In Progress
   ```
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. **Mark as completed in tasks.md**:
   ```markdown
   - [x] **Status:** ✅ Complete
   - **Actual:** [Time spent]
   ```
5. **Document any discovered TODOs** in the task's TODO Items section

> **⚠️ CRITICAL (v4.2.0):** If a task has TODO Items discovered:
> - Add to task's TODO Items section with priority
> - If P0/P1 and cross-feature, also add to `.spec-workflow/global-todos.md`

### Step 3: Verification Checkpoint ⭐ MANDATORY (v4.2.0)

**After each batch complete, run verification checkpoint:**

**3.1 Check tasks.md Status:**
- [ ] All completed tasks marked as ✅ Complete
- [ ] All in-progress tasks marked correctly
- [ ] Actual time recorded for completed tasks
- [ ] Discovered TODOs documented

**3.2 Run Verification Commands:**
For each completed task, run its verification commands:
```bash
# Example verification commands from task
npm run type-check      # Type checking
npm test -- test.file   # Unit tests
npm run lint           # Linting
```

**3.3 Check verification.md (if exists):**
- [ ] Mark completed verification items
- [ ] Record verification results with evidence

**3.4 Report Verification Status:**
```
✅ Batch Complete: Tasks [N-M]
📊 Status: [X/Y tasks verified]
✅ Verifications: [All pass | X failures]
📋 TODOs: [X new TODOs discovered]
Ready for feedback.
```

### Step 4: Handle Verification Results

**If all verifications pass:**
- Proceed to Step 5 (Continue)

**If any verification fails:** ⭐ REPAIR LOOP
1. **Document failure:**
   ```markdown
   ### Task N: [Task Name]
   **Verification Status:** ❌ Failed
   **Failure:** [Description]
   **Failed Command:** [Command that failed]
   **Output:** [Error output]
   ```
2. **Fix the issue:**
   - Update task status to ⏳ In Progress (or ⚠️ Blocked if truly blocked)
   - Apply fix
   - Re-run verification
3. **Re-verify:**
   - If pass: Update status to ✅ Complete
   - If fail again: Return to fix step
4. **Only then proceed** to next batch

> **⚠️ CRITICAL:** Do NOT proceed to next batch while verifications are failing.
> Evidence of passing verification is required before marking tasks complete.

### Step 5: Report and Request Feedback

When batch complete AND verifications pass:
- Show what was implemented
- Show verification output with evidence
- Show any discovered TODOs
- **Update `.spec-workflow/active/status.md`** (if exists)
- Say: "Ready for feedback."

### Step 6: Continue to Next Batch

Based on feedback:
- Apply changes if needed
- Execute next batch (repeat Steps 2-5)
- Continue until all tasks complete

### Step 7: Complete Development ⭐ FINAL VERIFICATION (v4.2.0)

**After all tasks complete and verified:**

**7.1 Final Status Check:**
- [ ] All tasks in tasks.md marked as ✅ Complete
- [ ] All verification commands pass
- [ ] No blocking TODOs (P0/P1) remain unaddressed
- [ ] verification.md checklist complete (if exists)

**7.2 Update Final Status:**
Update `.spec-workflow/specs/<feature-name>/tasks.md`:
```markdown
## Sign-Off
**Implementation Complete:** ✅
**All Tasks Verified:** ✅
**Verified By:** [Agent Name]
**Verified At:** [Timestamp]
**Notes:** All [N] tasks completed, verification passed
```

**7.3 Handoff to Finishing Skill:**
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

> **⚠️ CRITICAL:** Do NOT skip to finishing skill until:
> - ✅ All tasks verified passing
> - ✅ No blocking issues remain
> - ✅ Final status documented in tasks.md

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker mid-batch (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Between batches: just report and wait
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - REQUIRED: Set up isolated workspace before starting
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:finishing-a-development-branch** - Complete development after all tasks
