---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

## Overview

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting agent success reports
- Relying on partial verification
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ compiler |
| "Agent said success" | Verify independently |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## Verification Methods

### HTTP/API Testing

**Simple curl verification:**
```bash
# Verify API endpoint returns expected response
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","name":"Test User"}' \
  -w "\nHTTP Status: %{http_code}\n"

# Expected: HTTP Status: 201
# Verify: Response contains user data
```

**Complex API verification:**
```bash
# Test multiple endpoints in sequence
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}' \
  | jq -r '.token')

curl -s -X GET http://localhost:3000/api/users/me \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.email == "test@example.com"'

# Expected: true
```

### Python Verification Scripts

**Simple verification:**
```python
# verify_fix.py
import requests

response = requests.post('http://localhost:3000/api/users', json={
    'email': 'test@example.com',
    'name': 'Test User'
})

assert response.status_code == 201, f"Expected 201, got {response.status_code}"
data = response.json()
assert 'id' in data, "Response missing user ID"
assert data['email'] == 'test@example.com', f"Email mismatch: {data['email']}"

print("✅ Fix verified: User created successfully")
```

**Database verification:**
```python
# verify_db_fix.py
import psycopg2

conn = psycopg2.connect("dbname=test user=postgres")
cur = conn.cursor()

cur.execute("SELECT COUNT(*) FROM users WHERE email = %s", ('test@example.com',))
count = cur.fetchone()[0]

assert count > 0, "User not found in database"
print(f"✅ Fix verified: {count} user(s) found")

cur.close()
conn.close()
```

### Shell Command Verification

**Service health check:**
```bash
# Verify service is running and healthy
curl -f http://localhost:3000/health || exit 1
echo "✅ Service is healthy"

# Check with timeout
timeout 5 curl -f http://localhost:3000/health || {
  echo "❌ Service health check failed"
  exit 1
}
```

**File content verification:**
```bash
# Verify log file contains expected output
grep "expected_string" output.log || {
  echo "❌ Expected string not found in output"
  exit 1
}
echo "✅ Output verified"

# Count occurrences
COUNT=$(grep -c "success" output.log)
if [ "$COUNT" -lt 5 ]; then
  echo "❌ Expected at least 5 success messages, got $COUNT"
  exit 1
fi
echo "✅ Found $COUNT success messages"
```

**Process verification:**
```bash
# Verify background process is running
if ! pgrep -f "my_service"; then
  echo "❌ Service process not running"
  exit 1
fi
echo "✅ Service process is running"

# Verify port is listening
if ! netstat -an | grep 3000 | grep LISTEN; then
  echo "❌ Port 3000 not listening"
  exit 1
fi
echo "✅ Port 3000 is listening"
```

### Integration Test Verification

**Multi-step verification:**
```bash
# Full integration test
echo "Step 1: Create user..."
USER_ID=$(curl -s -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}' | jq -r '.id')

echo "Step 2: Verify user exists..."
curl -s -X GET "http://localhost:3000/api/users/$USER_ID" \
  | jq '.email == "test@example.com"' || {
  echo "❌ User verification failed"
  exit 1
}

echo "Step 3: Update user..."
curl -s -X PUT "http://localhost:3000/api/users/$USER_ID" \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Name"}' > /dev/null

echo "Step 4: Verify update..."
curl -s -X GET "http://localhost:3000/api/users/$USER_ID" \
  | jq '.name == "Updated Name"' || {
  echo "❌ Update verification failed"
  exit 1
}

echo "✅ All integration tests passed"
```

### Error Detection Verification

**Verify error is fixed:**
```bash
# Before fix: This would return 500
# After fix: Should return proper validation error
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"email":""}' \
  -w "\nHTTP Status: %{http_code}\n"

# Expected: HTTP Status: 400 (not 500)
# Expected response: {"error": "Email required"}
```

## Why This Matters

From 24 failure memories:
- your human partner said "I don't believe you" - trust broken
- Undefined functions shipped - would crash
- Missing requirements shipped - incomplete features
- Time wasted on false completion → redirect → rework
- Violates: "Honesty is a core value. If you lie, you'll be replaced."

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness

## The Bottom Line

**No shortcuts for verification.**

Run the command. Read the output. THEN claim the result.

This is non-negotiable.
