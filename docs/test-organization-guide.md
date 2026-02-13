# Requirement-Based Test Organization Guide

**Version:** 1.0.0
**Created:** 2025-01-15
**Status:** ✅ Ready for Use

## Overview

This guide describes how to organize tests by requirement in the Superpowers project, providing complete traceability from requirements to test files.

## Directory Structure

```
tests/requirements/
└── YYYY-MM-DD-requirement-name/
    ├── README.md                    # Requirement metadata and overview
    ├── tasks.md                     # Task list with test file mappings
    ├── test.sh                      # Execute all tests for this requirement
    ├── unit/                        # Unit tests (one file per task or logical group)
    │   ├── feature-a.test.ts
    │   └── feature-b.test.ts
    └── integration/                 # Integration tests (cross-task)
        └── flow-x.test.ts
```

## Key Features

### 1. Complete Traceability

Every test file is tagged with metadata linking it to:
- **Requirement ID**: Which requirement it belongs to
- **Task ID**: Which task it validates
- **Creation Date**: When it was created
- **Author**: AI Agent or human who created it

**Example test file header:**
```typescript
/**
 * Login Service Tests
 *
 * @requirement 2025-01-15-user-authentication
 * @task task-1-user-login-service
 * @created 2025-01-15
 * @author AI Agent (subagent-driven-development)
 */
```

### 2. Batch Test Execution

Run all tests for a requirement with a single command:

```bash
cd tests/requirements/2025-01-15-user-authentication
./test.sh              # Run all tests
./test.sh unit         # Only unit tests
./test.sh integration  # Only integration tests
./test.sh verbose      # With detailed output
```

**Output includes:**
- Total test count
- Passed/Failed breakdown
- Failed test details with error messages
- Execution time

### 3. Task-Test Mapping

The `tasks.md` file provides:
- Task descriptions
- Test file locations
- Test case checklist
- Status tracking
- Verification commands

**Example:**
```markdown
## Task 1: User Login Service
**Status:** ✅ Completed
**Test File:** `unit/login.test.ts`

### Test Cases
| Test ID | Description | Status |
|---------|-------------|--------|
| T1.1 | Login with valid credentials | ✅ Pass |
| T1.2 | Login with invalid email | ✅ Pass |
```

## Integration with Superpowers Workflow

### Step 1: Planning Phase

When creating a requirement plan in `writing-plans`, specify test structure:

```markdown
## Testing Strategy

**Requirement ID:** 2025-01-15-user-authentication
**Test Directory:** tests/requirements/2025-01-15-user-authentication/

**Unit Tests:**
- Task 1: `unit/login.test.ts` (5 tests)
- Task 2: `unit/jwt.test.ts` (6 tests)

**Integration Tests:**
- `integration/auth-flow.test.ts` (6 tests)

**Verification:**
```bash
cd tests/requirements/2025-01-15-user-authentication
./test.sh
```
```

### Step 2: Implementation Phase

**Implementer Subagent** creates test files with proper metadata:

1. **Create test file** in appropriate directory
2. **Add metadata header** with JSDoc comments
3. **Follow TDD**: Write test → Watch fail → Implement → Watch pass
4. **Update tasks.md** with test case list and status

**Example implementer workflow:**
```
Implementer: Creating login service test file...

[Writes unit/login.test.ts with metadata header]
[Runs npm test unit/login.test.ts]
[Observes tests fail (RED)]
[Implements login.ts]
[Runs npm test unit/login.test.ts]
[Observes tests pass (GREEN)]

[Updates tasks.md: Task 1 status = ✅ Completed]
[Commits: "feat: implement login service with tests (Task 1 of Req #2025-01-15)"]
```

### Step 3: Code Review Phase

**Code Reviewer** verifies:
1. Test files have proper metadata
2. Tests follow TDD principles
3. `tasks.md` is updated
4. All tests pass

**Review checklist:**
```markdown
## Test Compliance

- [ ] Test files have @requirement and @task metadata
- [ ] Test cases documented in tasks.md
- [ ] All tests pass (run ./test.sh)
- [ ] Test coverage adequate
- [ ] Tests follow RED-GREEN-REFACTOR
```

### Step 4: Final Verification

After all tasks complete:

```bash
# Run final test suite
cd tests/requirements/2025-01-15-user-authentication
./test.sh

# Expected output:
✓ All tests passed!
Total Tests:  27
Passed:       27
Failed:       0
Time taken:   15s
```

## Template Files

### 1. README.md Template

```markdown
# [Requirement Name] - Test Suite

**Requirement ID:** YYYY-MM-DD-requirement-name
**Title:** [Brief description]
**Created:** YYYY-MM-DD
**Status:** 🚧 In Progress / ✅ Completed

## Overview
[Description of what this requirement implements]

## Test Structure
[Directory structure diagram]

## Task Breakdown
[Table of tasks and test files]

## Test Coverage
[Unit/Integration test coverage statistics]

## Related Documentation
- Design: [link]
- Plan: [link]
- APIs: [link]
```

### 2. tasks.md Template

```markdown
# Task List - [Requirement Name]

**Requirement ID:** YYYY-MM-DD-requirement-name

## Task 1: [Task Name]
**Status:** ⏳ Pending / 🚧 In Progress / ✅ Completed
**Test File:** `unit/feature.test.ts`

### Test Cases
| Test ID | Description | Status |
|---------|-------------|--------|
| T1.1 | [Test description] | ✅ Pass |

### Verification
```bash
npm test unit/feature.test.ts
```
```

### 3. test.sh Script

**Key features:**
- Auto-detects test framework (Jest, Vitest, Go, Pytest, Cargo)
- Supports unit/integration/verbose modes
- Color-coded output
- Failed test details
- Execution time tracking
- Exit code for CI/CD

**Usage:**
```bash
./test.sh [unit|integration|verbose|help]
```

## Best Practices

### 1. Metadata Consistency

**Always include in test files:**
```typescript
/**
 * [Test Suite Name]
 *
 * @requirement YYYY-MM-DD-requirement-name
 * @task task-id-task-name
 * @created YYYY-MM-DD
 * @author AI Agent (subagent-driven-development) / [Human Name]
 */
```

### 2. Task-Test Mapping

**Guidelines:**
- One task → One or more test files (logical grouping)
- Test file name should reflect task name
- If task has multiple components, create multiple test files
- Integration tests go in `integration/` directory

**Example:**
```
Task 1: Login Service
├── unit/login.test.ts           # Core login logic
└── unit/login-validation.test.ts # Input validation

Task 2: JWT Management
├── unit/jwt-generation.test.ts   # Token generation
└── unit/jwt-validation.test.ts   # Token validation
```

### 3. Test File Organization

**Unit Tests:**
- Test individual functions/classes
- Mock external dependencies
- Fast execution (ms scale)

**Integration Tests:**
- Test across multiple components
- Real dependencies (or high-fidelity mocks)
- Slower execution (s scale)

### 4. Commit Message Convention

**When committing test files:**
```bash
# Structure:
<type>(<scope>): <description> (Task #N of Req #YYYY-MM-DD-name)

# Examples:
feat(auth): implement login service with tests (Task 1 of Req #2025-01-15-auth)
test(jwt): add token validation tests (Task 2 of Req #2025-01-15-auth)
fix(crypto): fix password hashing bug (Task 3 of Req #2025-01-15-auth)
```

## Query and Reporting

### Find all tests for a requirement:

```bash
# Using grep
grep -r "@requirement 2025-01-15-user-authentication" tests/requirements/2025-01-15-user-authentication/

# Or run the test suite
cd tests/requirements/2025-01-15-user-authentication
./test.sh
```

### Generate test report:

```bash
cd tests/requirements/2025-01-15-user-authentication
./test.sh verbose > test-report-$(date +%Y%m%d).log
```

### Update README after task completion:

```markdown
## Execution History

| Date | Runner | Result | Notes |
|------|--------|--------|-------|
| 2025-01-15 | AI Agent | ✅ 27/27 passed | All tasks completed |
```

## Migration Guide

### For existing requirements:

**1. Create requirement directory:**
```bash
mkdir -p tests/requirements/YYYY-MM-DD-name/{unit,integration}
```

**2. Create README.md:**
Copy template and fill in requirement details

**3. Move/create test files:**
- Add metadata headers
- Organize into unit/integration
- Update tasks.md

**4. Create test.sh:**
Copy from template or generate

**5. Run tests:**
```bash
./test.sh
```

## Benefits

### 1. Complete Traceability

✅ **Requirement → Test Files**: Easy to find all tests for a requirement
✅ **Test File → Requirement**: Know which requirement a test validates
✅ **Task → Test Cases**: Clear mapping between tasks and tests
✅ **Historical Context**: Know when and why tests were created

### 2. Improved Maintenance

✅ **Easy to delete**: Remove entire requirement folder when deprecating
✅ **Easy to update**: All related tests in one place
✅ **Easy to verify**: Run all tests for a requirement with one command

### 3. Better Collaboration

✅ **Clear ownership**: Know who created which tests
✅ **Status tracking**: See which tests are complete/pending
✅ **Documentation**: Tasks.md provides complete overview

### 4. CI/CD Integration

```yaml
# Example GitHub Actions workflow
- name: Run requirement tests
  run: |
    cd tests/requirements/2025-01-15-user-authentication
    ./test.sh

# Run all requirements
- name: Run all requirement tests
  run: |
    for req in tests/requirements/*/; do
      cd "$req"
      ./test.sh || exit 1
      cd -
    done
```

## Example: Complete Workflow

### 1. Create Requirement Plan

**File:** `docs/plans/2025-01-15-user-authentication-plan.md`

```markdown
## Requirement: User Authentication

**Test Directory:** tests/requirements/2025-01-15-user-authentication

### Task 1: Implement Login Service

**Test File:** `unit/login.test.ts`
**Test Cases:**
- Valid credentials
- Invalid email format
- Wrong password
- Non-existent user
- JWT token generation
```

### 2. Implement with TDD

**Implementer creates files:**
```
tests/requirements/2025-01-15-user-authentication/
├── unit/
│   └── login.test.ts        ← Created first (RED)
├── tasks.md                 ← Updated with test list
└── README.md                ← Updated with metadata
```

### 3. Verify and Review

**Code Reviewer checks:**
- Test file has proper metadata
- Tasks.md is updated
- Tests pass

### 4. Final Validation

```bash
cd tests/requirements/2025-01-15-user-authentication
./test.sh

# Output:
✓ All tests passed!
Total: 27 tests
```

## FAQ

**Q: What if a task has 20+ test cases? Should I split them?**
A: Yes, if logical grouping exists. Example: `unit/login.test.ts` and `unit/login-validation.test.ts`

**Q: Should I commit test files separately from implementation?**
A: No, commit together: `feat: implement feature with tests (Task #N of Req #ID)`

**Q: Can I run tests from project root?**
A: Yes, but requirement-specific scripts are in `tests/requirements/YYYY-MM-DD-name/test.sh`

**Q: What about shared utility tests?**
A: Put them in the requirement folder they belong to. If truly shared, create a separate requirement.

**Q: How do I handle updates to requirements?**
A: Update README.md status, add new entries to Execution History table, keep old tasks.md as archive

## See Also

- **Superpowers Workflow:** `skills/subagent-driven-development/SKILL.md`
- **TDD Guidelines:** `skills/test-driven-development/SKILL.md`
- **Code Review:** `agents/code-reviewer.md`
- **Example Implementation:** `tests/requirements/2025-01-15-user-authentication/`

---

**Last Updated:** 2025-01-15
**Version:** 1.0.0
