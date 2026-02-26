---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Verify tests → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## The Process

### Step 1: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**🌐 For Web UI Projects: Verify chrome-devtools-mcp Integration**

If this project contains web UI components, verify browser automation testing:

```bash
# Detect if this is a web UI project
if [ -d "public/" ] || [ -d "src/" ] && grep -rq "package.json\|index.html" public/ src/ 2>/dev/null; then
    echo "🌐 Web UI project detected"

    # Check for integration tests using chrome-devtools-mcp
    if [ -d "tests/requirements" ]; then
        mcp_tests=$(find tests/requirements -type f -name "*.test.ts" -o -name "*.test.js" | xargs grep -l "chrome-devtools" 2>/dev/null | wc -l)

        if [ "$mcp_tests" -eq 0 ]; then
            echo "⚠️  No chrome-devtools-mcp integration tests found"
            echo ""
            echo "Recommendation: Add integration tests using chrome-devtools-mcp MCP tools for:"
            echo "  • Browser automation (navigate_page, fill_form, click)"
            echo "  • Console verification (list_console_messages)"
            echo "  • Network verification (list_network_requests)"
            echo "  • Performance tracing (performance_start_trace/stop_trace)"
            echo ""
            echo "Cannot proceed with merge/PR until Web UI testing is complete."
            exit 1
        else
            echo "✓ chrome-devtools-mcp integration tests verified ($mcp_tests test files)"
        fi
    fi
fi
```

**If tests fail:**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Spec Workflow Final Acceptance (Step 1.5).

### Step 1.5: Spec Workflow Final Acceptance ⭐ MANDATORY (v4.2.0)

**Before presenting merge options, verify .spec-workflow completeness:**

**Check for Enhanced Spec Workflow:**
```bash
# Check if using enhanced .spec-workflow system
SPEC_WORKFLOW_CHECK=""
TASKS_FILE=""
VERIFICATION_FILE=""
FEATURE=""

# Find tasks.md file
FOUND_TASKS=$(find .spec-workflow/specs -name "tasks.md" -type f 2>/dev/null | head -1)

if [ -n "$FOUND_TASKS" ]; then
    echo "📋 Enhanced .spec-workflow system detected"
    TASKS_FILE="$FOUND_TASKS"
    FEATURE=$(basename $(dirname "$TASKS_FILE"))
    VERIFICATION_FILE="$(dirname "$TASKS_FILE")/verification.md"

    # Check tasks.md exists and is readable
    if [ ! -r "$TASKS_FILE" ]; then
        echo "❌ Cannot read tasks.md at: $TASKS_FILE"
        exit 1
    fi

    echo ""
    echo "Checking $TASKS_FILE..."

    # Check for incomplete tasks - ONLY match task lines (### Task or - [ ])
    IN_PROGRESS=0
    NOT_STARTED=0
    BLOCKED=0

    # Count using task-line-specific patterns - use wc -l to avoid exit code issues
    IN_PROGRESS=$(grep -E "^### Task|^- \[ \]" "$TASKS_FILE" 2>/dev/null | grep -E "(Status.*In Progress|⏳)" | wc -l | tr -d ' ')
    NOT_STARTED=$(grep -E "^### Task|^- \[ \]" "$TASKS_FILE" 2>/dev/null | grep -E "(Status.*Not Started|🔵)" | wc -l | tr -d ' ')
    BLOCKED=$(grep -E "^### Task|^- \[ \]" "$TASKS_FILE" 2>/dev/null | grep -E "(Status.*Blocked|⚠️)" | wc -l | tr -d ' ')

    if [ "$IN_PROGRESS" -gt 0 ] || [ "$NOT_STARTED" -gt 0 ]; then
        echo "❌ Incomplete tasks detected:"
        [ "$IN_PROGRESS" -gt 0 ] && echo "   - In Progress: $IN_PROGRESS"
        [ "$NOT_STARTED" -gt 0 ] && echo "   - Not Started: $NOT_STARTED"
        echo ""
        echo "Cannot proceed with merge/PR until all tasks are complete."
        echo "Please complete remaining tasks or update tasks.md status."
        exit 1
    fi

    if [ "$BLOCKED" -gt 0 ]; then
        echo "⚠️  Warning: $BLOCKED blocked task(s) detected"
        echo "   Verify all blockers have workarounds or are resolved."
    fi

    # Check verification.md if exists
    if [ -f "$VERIFICATION_FILE" ]; then
        echo ""
        echo "Checking $VERIFICATION_FILE..."

        # Check for final sign-off - multiple patterns
        if ! grep -qE "Implementation Complete.*✅|All Tasks Verified.*✅" "$VERIFICATION_FILE" 2>/dev/null; then
            echo "❌ Final sign-off not completed in verification.md"
            echo ""
            echo "Please complete the verification checklist:"
            echo "   1. Run all verification commands"
            echo "   2. Complete Part 6: Final Sign-Off"
            echo "   3. Mark Implementation Complete: ✅"
            exit 1
        fi

        echo "✅ Verification checklist complete"
    else
        echo "ℹ️  verification.md not found (optional but recommended)"
    fi

    # Check for blocking TODOs - ONLY in TODOs & Gaps section
    P0_COUNT=0
    P1_COUNT=0

    # Extract TODOs section and count uncompleted P0/P1 items
    P0_COUNT=$(sed -n '/## TODOs & Gaps/,$ p' "$TASKS_FILE" 2>/dev/null | grep -iE "Priority.*P0|P0.*Critical" | grep -vE "^\s*-\s*\[x\]" | wc -l | tr -d ' ')
    P1_COUNT=$(sed -n '/## TODOs & Gaps/,$ p' "$TASKS_FILE" 2>/dev/null | grep -iE "Priority.*P1|P1.*High" | grep -vE "^\s*-\s*\[x\]" | wc -l | tr -d ' ')

    # Trim any whitespace and ensure we have numbers
    P0_COUNT=$(echo "$P0_COUNT" | tr -d ' ')
    P1_COUNT=$(echo "$P1_COUNT" | tr -d ' ')
    P0_COUNT=${P0_COUNT:-0}
    P1_COUNT=${P1_COUNT:-0}

    if [ "$P0_COUNT" -gt 0 ]; then
        echo "❌ $P0_COUNT P0 (Critical) TODO(s) remain unaddressed"
        echo ""
        echo "Cannot proceed with merge/PR until P0 TODOs are resolved."
        exit 1
    fi

    if [ "$P1_COUNT" -gt 0 ]; then
        echo "⚠️  Warning: $P1_COUNT P1 (High) TODO(s) remain"
        echo "   Recommend addressing before merge."
    fi

    echo ""
    echo "✅ Spec workflow verification passed"
    echo "   - All tasks complete"
    [ -f "$VERIFICATION_FILE" ] && echo "   - Verification checklist complete" || echo "   - Verification checklist: N/A"
    echo "   - No blocking TODOs"
else
    echo "ℹ️  Enhanced .spec-workflow system not detected"
    echo "   Consider using .spec-workflow for better tracking (v4.2.0+)"
fi
```

**If spec workflow checks fail:**
```
Spec workflow incomplete. Cannot proceed:

[Show failures]

Please address above issues before merge/PR.
```

Stop. Don't proceed to Step 2.

**If spec workflow checks pass (or not using enhanced system):** Continue to Step 2.

### Step 2: Determine Base Branch

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Or ask: "This branch split from main - is that correct?"

### Step 3: Present Options

Present exactly these 4 options:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Don't add explanation** - keep options concise.

### Step 4: Execute Choice

#### Option 1: Merge Locally

```bash
# Switch to base branch
git checkout <base-branch>

# Pull latest
git pull

# Merge feature branch
git merge <feature-branch>

# Verify tests on merged result
<test command>

# If tests pass
git branch -d <feature-branch>
```

**Record to Execution Log:**
```markdown
- [ ] Update EXECUTION_LOG.md with:
  - Phase: Finishing a Development Branch
  - Action: Completed "{option-selected}" (Merge/PR/Keep/Discard)
  - Details: Branch completion summary, tests status, cleanup actions
  - Next: Start next feature or return to main branch
```

Then: Cleanup worktree (Step 5)

#### Option 2: Push and Create PR

```bash
# Push branch
git push -u origin <feature-branch>

# Create PR
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

## Test Plan
- [ ] <verification steps>
EOF
)"
```

**Record to Execution Log:**
```markdown
- [ ] Update EXECUTION_LOG.md with:
  - Phase: Finishing a Development Branch
  - Action: Completed "{option-selected}" (Merge/PR/Keep/Discard)
  - Details: Branch completion summary, tests status, cleanup actions
  - Next: Start next feature or return to main branch
```

Then: Cleanup worktree (Step 5)

#### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

**Don't cleanup worktree.**

#### Option 4: Discard

**Confirm first:**
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for exact confirmation.

If confirmed:
```bash
git checkout <base-branch>
git branch -D <feature-branch>
```

**Record to Execution Log:**
```markdown
- [ ] Update EXECUTION_LOG.md with:
  - Phase: Finishing a Development Branch
  - Action: Completed "{option-selected}" (Merge/PR/Keep/Discard)
  - Details: Branch completion summary, tests status, cleanup actions
  - Next: Start next feature or return to main branch
```

Then: Cleanup worktree (Step 5)

### Step 5: Cleanup Worktree

**For Options 1, 2, 4:**

Check if in worktree:
```bash
git worktree list | grep $(git branch --show-current)
```

If yes:
```bash
git worktree remove <worktree-path>
```

**For Option 3:** Keep worktree.

## Quick Reference

| Option | Merge | Push | Keep Worktree | Cleanup Branch |
|--------|-------|------|---------------|----------------|
| 1. Merge locally | ✓ | - | - | ✓ |
| 2. Create PR | - | ✓ | ✓ | - |
| 3. Keep as-is | - | - | ✓ | - |
| 4. Discard | - | - | - | ✓ (force) |

## Common Mistakes

**Skipping test verification**
- **Problem:** Merge broken code, create failing PR
- **Fix:** Always verify tests before offering options

**Open-ended questions**
- **Problem:** "What should I do next?" → ambiguous
- **Fix:** Present exactly 4 structured options

**Automatic worktree cleanup**
- **Problem:** Remove worktree when might need it (Option 2, 3)
- **Fix:** Only cleanup for Options 1 and 4

**No confirmation for discard**
- **Problem:** Accidentally delete work
- **Fix:** Require typed "discard" confirmation

## Red Flags

**Never:**
- Proceed with failing tests
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request

**Always:**
- Verify tests before offering options
- Present exactly 4 options
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 & 4 only

## Integration

**Called by:**
- **subagent-driven-development** (Step 7) - After all tasks complete
- **executing-plans** (Step 5) - After all batches complete

**Pairs with:**
- **using-git-worktrees** - Cleans up worktree created by that skill
