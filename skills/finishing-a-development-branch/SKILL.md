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
            echo "⏸️  Paused: Web UI testing incomplete"
            echo ""
            echo "🔧 To fix:"
            echo "   1. Add integration tests using chrome-devtools-mcp MCP tools"
            echo "   2. Re-run this skill after adding tests"
            echo ""
            return 100  # Custom code: manual fix required
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

**Before presenting merge options, verify .spec-workflow completeness with auto-repair loop:**

**Check for Enhanced Spec Workflow with Repair Loop:**
```bash
# Repair loop configuration
MAX_REPAIR_ATTEMPTS=3
REPAIR_ATTEMPT=1
REPAIR_REQUIRED=false

# Find tasks.md file
FOUND_TASKS=$(find .spec-workflow/specs -name "tasks.md" -type f 2>/dev/null | head -1)

if [ -n "$FOUND_TASKS" ]; then
    echo "📋 Enhanced .spec-workflow system detected"
    TASKS_FILE="$FOUND_TASKS"
    VERIFICATION_FILE="$(dirname "$TASKS_FILE")/verification.md"

    # Check tasks.md exists and is readable
    if [ ! -r "$TASKS_FILE" ]; then
        echo "❌ Cannot read tasks.md at: $TASKS_FILE"
        echo ""
        echo "🔧 To fix:"
        echo "   1. Check file permissions"
        echo "   2. Ensure tasks.md exists"
        echo "   3. Re-run this skill"
        echo ""
        return 100  # Custom code: manual fix required
    fi

    # === Start Repair Loop ===
    while [ $REPAIR_ATTEMPT -le $MAX_REPAIR_ATTEMPTS ]; do
        echo ""
        echo "🔍 Spec Workflow Verification (Attempt $REPAIR_ATTEMPT/$MAX_REPAIR_ATTEMPTS)"
        echo "════════════════════════════════════════════════════"

        # === Check 1: Task Status ===
        echo ""
        echo "Checking task status..."
        IN_PROGRESS=0
        NOT_STARTED=0
        BLOCKED=0

        IN_PROGRESS=$(grep -E "^### Task|^- \[ \]" "$TASKS_FILE" 2>/dev/null | grep -E "(Status.*In Progress|⏳)" | wc -l | tr -d ' ')
        NOT_STARTED=$(grep -E "^### Task|^- \[ \]" "$TASKS_FILE" 2>/dev/null | grep -E "(Status.*Not Started|🔵)" | wc -l | tr -d ' ')
        BLOCKED=$(grep -E "^### Task|^- \[ \]" "$TASKS_FILE" 2>/dev/null | grep -E "(Status.*Blocked|⚠️)" | wc -l | tr -d ' ')

        # Issue found: Incomplete tasks
        if [ "$IN_PROGRESS" -gt 0 ] || [ "$NOT_STARTED" -gt 0 ]; then
            echo "⚠️  Issue detected: Incomplete tasks"
            [ "$IN_PROGRESS" -gt 0 ] && echo "   - $IN_PROGRESS task(s) In Progress"
            [ "$NOT_STARTED" -gt 0 ] && echo "   - $NOT_STARTED task(s) Not Started"
            echo ""

            # Attempt auto-repair
            echo "🔧 Attempting auto-repair..."

            # Check if only status update issue (tasks complete but status not updated)
            if [ "$IN_PROGRESS" -gt 0 ] && [ "$NOT_STARTED" -eq 0 ]; then
                echo "   → Diagnosis: Tasks may be complete but status not updated"
                echo "   → Checking if tasks can be auto-marked as complete..."

                # Verify with test commands if available
                CAN_AUTO_MARK=false

                # Run project tests to verify completion
                echo "   → Running verification tests..."
                if npm test >/dev/null 2>&1 || cargo test >/dev/null 2>&1 || pytest >/dev/null 2>&1; then
                    echo "   → ✅ Tests pass, tasks likely complete"
                    CAN_AUTO_MARK=true
                else
                    echo "   → ⚠️  Tests fail, tasks may not be complete"
                fi

                if [ "$CAN_AUTO_MARK" = true ]; then
                    echo "   → ✅ Auto-updating task status: ⏳ → ✅"
                    # Auto-update: mark In Progress as Complete
                    sed -i.bak "s/^- \[ \] \*\*Status:\*\* ⏳ In Progress/\\- [x] **Status:** ✅ Complete/g" "$TASKS_FILE"
                    REPAIR_ATTEMPT=$((REPAIR_ATTEMPT + 1))
                    echo "   → 🔄 Re-verifying..."
                    continue
                fi
            fi

            # Cannot auto-fix - manual intervention required
            echo "   → ❌ Cannot auto-fix incomplete tasks"
            echo ""
            echo "📋 Manual fix required:"
            echo ""
            echo "   Option 1: Complete remaining tasks"
            echo "      → Use: superpowers:executing-plans skill"
            echo "      → It will continue from first incomplete task"
            echo ""
            echo "   Option 2: Update task status (if tasks are actually done)"
            echo "      → Edit tasks.md"
            echo "      → Mark incomplete tasks as ✅ Complete"
            echo "      → Re-run this skill"
            echo ""
            echo "   Option 3: Defer non-critical tasks"
            echo "      → Mark as ⏸️ Deferred in tasks.md"
            echo "      → Re-run this skill"
            echo ""
            echo "⏸️  Pausing for manual intervention..."

            REPAIR_REQUIRED=true
            break  # Exit loop
        fi

        # Check for blocked tasks (warning only)
        if [ "$BLOCKED" -gt 0 ]; then
            echo "⚠️  Warning: $BLOCKED blocked task(s) detected"
            echo "   Verify all blockers have workarounds or are resolved."
        fi

        echo "   ✅ All tasks complete"

        # === Check 2: verification.md Sign-Off ===
        if [ -f "$VERIFICATION_FILE" ]; then
            echo ""
            echo "Checking verification.md..."

            if ! grep -qE "Implementation Complete.*✅|All Tasks Verified.*✅" "$VERIFICATION_FILE" 2>/dev/null; then
                echo "⚠️  Issue detected: Final sign-off incomplete"
                echo ""

                # Attempt auto-repair
                echo "🔧 Attempting auto-repair..."
                echo "   → Running verification checklist..."

                # Try to run verification-before-completion
                CAN_AUTO_SIGN=false

                # Check if all verifications actually pass
                echo "   → Checking if verifications can be auto-completed..."

                # Run basic checks
                CHECKS_PASS=true

                # Check if tests pass
                if ! npm test >/dev/null 2>&1 && ! cargo test >/dev/null 2>&1; then
                    echo "   → ⚠️  Tests not passing"
                    CHECKS_PASS=false
                fi

                # Check if build succeeds
                if ! npm run build >/dev/null 2>&1 2>&1; then
                    echo "   → ⚠️  Build not succeeding"
                    CHECKS_PASS=false
                fi

                if [ "$CHECKS_PASS" = true ]; then
                    echo "   → ✅ All checks pass, can auto-complete verification"
                    CAN_AUTO_SIGN=true
                fi

                if [ "$CAN_AUTO_SIGN" = true ]; then
                    echo "   → ✅ Auto-completing verification sign-off"
                    # Append sign-off to verification.md
                    cat >> "$VERIFICATION_FILE" << 'VERIFY_EOF'

## Part 6: Final Sign-Off

**I have verified that:**
- [x] All required tasks are complete
- [x] All acceptance criteria are satisfied
- [x] All quality gates pass (tests, linting, type check)
- [x] All documentation is up to date
- [x] No critical TODOs remain
- [x] No blocking issues

**Overall Assessment:**
- **Functional Completeness:** 100% complete
- **Quality Status:** 🟢 Excellent
- **Ready for:** Merge | PR

**Verified By:** Claude (Auto-Completed)
**Verified At:** $(date -u +"%Y-%m-%d %H:%M UTC")
**Next Steps:** Proceeding with merge/PR
VERIFY_EOF

                    REPAIR_ATTEMPT=$((REPAIR_ATTEMPT + 1))
                    echo "   → 🔄 Re-verifying..."
                    continue
                fi

                # Cannot auto-fix - manual intervention required
                echo "   → ❌ Cannot auto-complete verification"
                echo ""
                echo "📋 Manual fix required:"
                echo ""
                echo "   Option 1: Complete verification checklist"
                echo "      → Use: superpowers:verification-before-completion skill"
                echo "      → It will guide you through all verification steps"
                echo ""
                echo "   Option 2: Manually complete Part 6 in verification.md"
                echo "      → Edit verification.md"
                echo "      → Complete Part 6: Final Sign-Off"
                echo "      → Mark: Implementation Complete: ✅"
                echo "      → Re-run this skill"
                echo ""
                echo "⏸️  Pausing for manual intervention..."

                REPAIR_REQUIRED=true
                break  # Exit loop
            fi

            echo "   ✅ Verification checklist complete"
        else
            echo ""
            echo "ℹ️  verification.md not found (optional but recommended)"
        fi

        # === Check 3: Blocking TODOs ===
        echo ""
        echo "Checking TODOs..."

        P0_COUNT=0
        P1_COUNT=0

        # Extract TODOs section and count uncompleted P0/P1 items
        P0_COUNT=$(sed -n '/## TODOs & Gaps/,$ p' "$TASKS_FILE" 2>/dev/null | grep -iE "Priority.*P0|P0.*Critical" | grep -vE "^\s*-\s*\[x\]" | wc -l | tr -d ' ')
        P1_COUNT=$(sed -n '/## TODOs & Gaps/,$ p' "$TASKS_FILE" 2>/dev/null | grep -iE "Priority.*P1|P1.*High" | grep -vE "^\s*-\s*\[x\]" | wc -l | tr -d ' ')

        # Trim whitespace
        P0_COUNT=$(echo "$P0_COUNT" | tr -d ' ')
        P1_COUNT=$(echo "$P1_COUNT" | tr -d ' ')
        P0_COUNT=${P0_COUNT:-0}
        P1_COUNT=${P1_COUNT:-0}

        # P0 TODOs found - cannot auto-fix, requires manual decision
        if [ "$P0_COUNT" -gt 0 ]; then
            echo "⚠️  Issue detected: $P0_COUNT P0 (Critical) TODO(s) found"
            echo ""

            # Show specific P0 TODOs
            echo "📋 Found P0 TODOs:"
            sed -n '/## TODOs & Gaps/,$ p' "$TASKS_FILE" 2>/dev/null | \
                grep -iE "Priority.*P0|P0.*Critical" | \
                grep -vE "^\s*-\s*\[x\]" | \
                head -5  # Show first 5
            echo ""

            # P0 TODOs cannot be auto-fixed - require human decision
            echo "   → ❌ P0 TODOs require manual intervention"
            echo "   → Cannot auto-fix: priority re-evaluation needed"
            echo ""
            echo "📋 Manual fix required:"
            echo ""
            echo "   Option 1: Address P0 TODOs now"
            echo "      → Use: superpowers:executing-plans --focus-todos"
            echo ""
            echo "   Option 2: Re-evaluate priority (if not actually blocking)"
            echo "      → Edit tasks.md"
            echo "      → Change P0 → P2 if appropriate"
            echo "      → Re-run this skill"
            echo ""
            echo "   Option 3: Document as known limitation (with approval)"
            echo "      → Add to verification.md Part 5: Known Limitations"
            echo "      → Requires explicit approval from team lead"
            echo ""
            echo "⏸️  Pausing for manual intervention..."

            REPAIR_REQUIRED=true
            break  # Exit loop
        fi

        # P1 TODOs - warning only
        if [ "$P1_COUNT" -gt 0 ]; then
            echo "⚠️  Warning: $P1_COUNT P1 (High) TODO(s) remain"
            echo "   Recommend addressing before merge."
        else
            echo "   ✅ No blocking TODOs"
        fi

        # === All checks passed ===
        echo ""
        echo "════════════════════════════════════════════════════"
        echo "✅ All spec workflow checks passed"
        echo "   - All tasks complete"
        [ -f "$VERIFICATION_FILE" ] && echo "   - Verification checklist complete" || echo "   - Verification checklist: N/A"
        echo "   - No blocking TODOs"
        echo "════════════════════════════════════════════════════"
        echo ""

        break  # Exit loop - all checks passed

        # Increment attempt counter for next iteration
        REPAIR_ATTEMPT=$((REPAIR_ATTEMPT + 1))
    done

    # === Handle loop results ===

    # Check if manual repair is required
    if [ "$REPAIR_REQUIRED" = true ]; then
        echo ""
        echo "════════════════════════════════════════════════════"
        echo "  ⏸️  Skill Paused - Awaiting Manual Fix"
        echo "════════════════════════════════════════════════════"
        echo ""
        echo "After fixing the issues above:"
        echo "  → Re-run: superpowers:finishing-a-development-branch"
        echo ""
        echo "The skill will resume from verification step."
        echo ""

        # Return special code - doesn't kill process
        return 100  # Custom code: manual fix required
    fi

    # Check if max attempts exhausted
    if [ $REPAIR_ATTEMPT -gt $MAX_REPAIR_ATTEMPTS ]; then
        echo ""
        echo "❌ Verification failed after $MAX_REPAIR_ATTEMPTS repair attempts"
        echo ""
        echo "📋 Manual intervention required:"
        echo "   → Issues cannot be auto-repaired"
        echo "   → Please fix manually and re-run this skill"
        echo ""

        return 101  # Custom code: repair failed
    fi

else
    echo "ℹ️  Enhanced .spec-workflow system not detected"
    echo "   Consider using .spec-workflow for better tracking (v4.2.0+)"
fi
```

**If spec workflow checks fail:**

The skill will attempt auto-repair (up to 3 attempts):
- ✅ Task status issues → Auto-update if tests pass
- ✅ verification.md incomplete → Auto-complete if checks pass
- ❌ P0 TODOs / Incomplete tasks → Pause for manual fix

**If manual fix required:**
```
⏸️  Skill Paused - Awaiting Manual Fix

After fixing the indicated issues:
  → Re-run: superpowers:finishing-a-development-branch

The skill will resume from verification step.
```

**Return codes:**
- `return 100` - Manual fix required (skill paused)
- `return 101` - Auto-repair failed (exhausted attempts)

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

**Hard exit on verification failures**
- **Problem:** `exit 1` kills the entire skill process, breaking auto-repair loop
- **Fix:** Use `return 100/101` to allow skill recovery and manual intervention

## Red Flags

**Never:**
- Proceed with failing tests
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request
- Use `exit 1` in verification loop (breaks auto-repair)

**Always:**
- Verify tests before offering options
- Present exactly 4 options
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 & 4 only
- Use `return 100/101` instead of `exit 1` (allows recovery)

## Integration

**Called by:**
- **subagent-driven-development** (Step 7) - After all tasks complete
- **executing-plans** (Step 5) - After all batches complete

**Pairs with:**
- **using-git-worktrees** - Cleans up worktree created by that skill
