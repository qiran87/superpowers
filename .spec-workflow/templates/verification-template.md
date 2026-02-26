# Verification Checklist

> **Feature:** [Feature Name]
> **Version:** 1.0
> **Implementation Plan:** [Link to tasks.md]
> **Last Verified:** 2026-02-26 15:00

---

## Overview

This verification checklist ensures that all features are complete, tested, and ready for deployment before marking the implementation as done.

**⚠️ MANDATORY:** Do NOT claim implementation is complete until ALL applicable items in this checklist are verified.

---

## Part 1: Pre-Verification Checklist

### 1.1 Task Completion Check

- [ ] **All tasks marked as Complete** in tasks.md
  - **Verification:** Review tasks.md, ensure all required tasks have [x] checkbox
  - **Expected:** No tasks with status "Not Started" or "In Progress"

- [ ] **No blocking TODOs remain**
  - **Verification:** Check TODOs & Gaps section
  - **Expected:** All P0 (Critical) and P1 (High) TODOs completed

- [ ] **No blocking issues**
  - **Verification:** Check Blocking Issues section
  - **Expected:** No items listed, or all have workarounds

### 1.2 Code Quality Verification

- [ ] **All linting passes**
  - **Command:** `npm run lint` | `eslint .` | `ruff check .`
  - **Expected:** 0 errors, 0 warnings (or only acceptable warnings)
  - **Output:** [Attach lint output]

- [ ] **Type checking passes**
  - **Command:** `npm run type-check` | `tsc --noEmit`
  - **Expected:** Exit code 0, no type errors
  - **Output:** [Attach type check output]

- [ ] **Build succeeds**
  - **Command:** `npm run build` | `cargo build` | `python -m build`
  - **Expected:** Exit code 0, successful compilation
  - **Output:** [Attach build output]

### 1.3 Testing Verification

- [ ] **All unit tests pass**
  - **Command:** `npm test` | `pytest` | `cargo test`
  - **Expected:** 0 failures
  - **Coverage:** Minimum [X]% coverage achieved
  - **Output:** [Attach test summary]

- [ ] **Integration tests pass** (if applicable)
  - **Command:** `npm run test:integration`
  - **Expected:** 0 failures
  - **Output:** [Attach test summary]

- [ ] **E2E tests pass** (if applicable)
  - **Command:** `npm run test:e2e` | `cypress run`
  - **Expected:** 0 failures
  - **Output:** [Attach test summary]

---

## Part 2: Functional Requirements Checklist

### Requirement 1: [Requirement Name]

**User Story:** As a [role], I want [feature], so that [benefit]

#### Acceptance Criteria Verification

- [ ] **AC 1.1:** [Acceptance criteria description]
  - **Verification Method:** Manual test | Automated test | Code review
  - **Test Command:** [if applicable]
  - **Test Steps:**
    1. [Step 1]
    2. [Step 2]
    3. [Expected result]
  - **Verified By:** [Agent Name]
  - **Verified At:** [Timestamp]
  - **Result:** ✅ Pass | ❌ Fail
  - **Notes:** [Any issues found]

- [ ] **AC 1.2:** [Acceptance criteria description]
  - **Verification Method:** [How verified]
  - **Verified By:** [Agent Name]
  - **Verified At:** [Timestamp]
  - **Result:** ✅ Pass | ❌ Fail
  - **Notes:** [Issues or edge cases]

#### Edge Cases

- [ ] [Edge case 1 description]
  - **Test Scenario:** [How to test]
  - **Result:** ✅ Handled | ❌ Not handled
  - **Notes:** [Any findings]

### Requirement 2: [Requirement Name]

[Same structure as above]

---

## Part 3: Documentation Checklist

- [ ] **README.md updated**
  - **Verification:** Check README.md includes:
    - [ ] Feature description
    - [ ] Usage instructions
    - [ ] Configuration requirements
    - [ ] Examples
  - **Verified By:** [Agent Name]

- [ ] **API documentation current** (if applicable)
  - **Verification:** API docs match implementation
  - **Verified By:** [Agent Name]

- [ ] **Code comments appropriate**
  - **Verification:** Code review for comment quality
  - **Verified By:** [Agent Name]

- [ ] **Changelog updated**
  - **Verification:** Changes documented in CHANGELOG.md
  - **Verified By:** [Agent Name]

---

## Part 4: Integration & Deployment Checklist

### Integration Verification

- [ ] **All components integrated**
  - **Verification:** Code review for integration points
  - **Verified By:** [Agent Name]

- [ ] **No breaking changes**
  - **Verification:** `npm run test` passes on integration branch
  - **Verified By:** [Agent Name]

### Deployment Readiness

- [ ] **Environment variables documented**
  - **Verification:** .env.example file exists and up-to-date
  - **Verified By:** [Agent Name]

- [ ] **Database migrations ready**
  - **Verification:** Migration scripts tested on staging
  - **Verified By:** [Agent Name]

- [ ] **Deployment scripts tested**
  - **Verification:** Deploy to test environment successful
  - **Verified By:** [Agent Name]

---

## Part 5: TODOs & Gaps Summary

### Discovered TODOs

| Priority | TODO Item | Status | Assigned To | ETA |
|----------|----------|--------|------------|-----|
| P0 | [Critical TODO] | 🔵 Not Started | | |
| P1 | [Important TODO] | ⏳ In Progress | | |
| P2 | [Nice to have] | ✅ Complete | | |

### Deferred Items

| Item | Reason | Planned For |
|------|--------|------------|
| [Feature/Task] | [Why deferred] | v1.1 / Future sprint |
| [Optimization] | [Why deferred] | When performance issue arises |

### Known Limitations

- [ ] [Limitation 1]: [Impact and potential future solutions]
- [ ] [Limitation 2]: [Why it exists and when it might be addressed]

---

## Part 6: Final Sign-Off

### Completion Declaration

**I have verified that:**

- [ ] All required tasks are complete
- [ ] All acceptance criteria are satisfied
- [ ] All quality gates pass (tests, linting, type check)
- [ ] All documentation is up to date
- [ ] No critical TODOs remain
- [ ] No blocking issues

**Overall Assessment:**

- **Functional Completeness:** [X]% complete
- **Quality Status:** 🟢 Excellent | 🟡 Good | 🔴 Needs Improvement
- **Ready for:** [Merge | PR | Deployment | Code Review]

**Verification Summary:**

| Category | Status | Notes |
|----------|--------|-------|
| Tasks | ✅ All complete | |
| Acceptance Criteria | ✅ All satisfied | |
| Tests | ✅ All passing | [X]% coverage |
| Documentation | ✅ Up to date | |
| TODOs | ✅ All addressed | |

**Verified By:** [Agent Name]
**Verified At:** [Timestamp]
**Next Steps:** [Merge to main | Create PR | Request review]

**Blockers (if any):**
- [ ] [Blocker 1] - [Workaround]
- [ ] [Blocker 2] - [Workaround]

**Final Notes:**
[Any additional observations, concerns, or recommendations]

---

## Verification History

| Date | Verified By | Result | Notes |
|------|------------|--------|-------|
| 2026-02-26 14:30 | Agent 1 | ✅ Pass | Initial verification |
| 2026-02-26 15:00 | Agent 1 | ❌ Fail | Missing edge case handling |
| 2026-02-26 15:30 | Agent 2 | ✅ Pass | All issues resolved |
