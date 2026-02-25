# Protocol Compliance Report Template

**使用说明:** 此模板用于生成协议一致性检查报告，在检测到代码实现与协议文档不一致时使用。

---

## 报告头部

```markdown
# Protocol Compliance Report

**Generated:** {timestamp}
**Design Document:** {path-to-design-doc}
**Code Location:** {code-directory}
**Reviewer:** AI Agent (superpowers:protocol-compliance-check)
**Review Scope:** {frontend/backend/both}

## Executive Summary

- ✅ **Passed Checks:** {number} protocol compliance checks passed
- ❌ **Failed Checks:** {number} protocol violations detected
- ⚠️ **Warnings:** {number} items need attention
- **Overall Status:** {PASS/FAIL}

---

## Summary by Bad Case Type

| Bad Case Type | Critical | High | Medium | Low | Total |
|---------------|----------|------|--------|-----|-------|
| Bad Case 1: Extra Fields | {n1} | {n2} | {n3} | {n4} | {total1} |
| Bad Case 2: Frontend-Backend Mismatch | {n5} | {n6} | {n7} | {n8} | {total2} |
| Bad Case 3: Database Schema Violation | {n9} | {n10} | {n11} | {n12} | {total3} |
| **Total** | **{crit}** | **{high}** | **{med}** | **{low}** | **{overall}** |

---

## Bad Case 1: Extra Fields (越界使用)

{如果发现违规}

### Severity Breakdown

- **CRITICAL:** {number} violations
- **HIGH:** {number} violations
- **MEDIUM:** {number} violations
- **LOW:** {number} violations

### Violations Found

#### ❌ #{N}: Extra field used in frontend component

- **Location:** `{file}:{line}`
- **Severity:** CRITICAL

**Code Snippet:**
```typescript
{code_with_extra_field}
```

**Problem:**
Field `{field_name}` used but not defined in:
- `docs/project-analysis/03-backend-domains.md` ({entity} entity)
- `docs/project-analysis/02-backend-apis.md` (API endpoint)

**Impact:**
- Code depends on undefined field
- May cause runtime error: "Cannot read property '{field_name}' of undefined"
- Frontend displays broken or missing data

**Fix Required:**
- [ ] Remove field usage OR
- [ ] Add field to protocol documentation
- [ ] Update type definitions
- [ ] Verify with backend if field is available

**Recommended Action:**
{recommendation_based_on_context}

---

#### ❌ #{N}: Extra field in backend response

- **Location:** `{file}:{line}`
- **Severity:** CRITICAL

**Code Snippet:**
```typescript
{code_with_extra_field}
```

**Problem:**
Backend returns field `{field_name}` not documented in:
- `docs/project-analysis/02-backend-apis.md` (endpoint response)
- `docs/project-analysis/03-backend-domains.md` (entity definition)

**Impact:**
- Frontend cannot consume field
- Contract violation between backend and documentation
- May indicate incomplete implementation

**Fix Required:**
- [ ] Remove field from response OR
- [ ] Add field to protocol documentation
- [ ] Update API documentation
- [ ] Inform frontend team about new field

**Recommended Action:**
{recommendation}

---

{如果没有发现违规}

### ✅ No Extra Fields Detected

All fields used in code are defined in protocol documentation:
- ✅ Frontend components use only documented fields
- ✅ Backend API responses match protocol definitions
- ✅ No undefined field access detected

---

## Bad Case 2: Frontend-Backend Mismatch (前后端不一致)

{如果发现违规}

### Severity Breakdown

- **CRITICAL:** {number} mismatches
- **HIGH:** {number} mismatches
- **MEDIUM:** {number} mismatches
- **LOW:** {number} mismatches

### Mismatches Found

#### ❌ #{N}: API endpoint mismatch

- **Type:** Endpoint Not Found / Method Mismatch
- **Severity:** CRITICAL

**Frontend Call:**
- **Location:** `{file}:{line}`
```typescript
{frontend_api_call}
```

**Backend Definition:**
- **Document:** `docs/project-analysis/02-backend-apis.md`
```
{backend_api_definition}
```

**Problem:**
{mismatch_description}

**Impact:**
- API call will fail with 404 Not Found / 405 Method Not Allowed
- Feature completely broken
- User experience degraded

**Fix Required:**
- [ ] Fix frontend endpoint OR
- [ ] Fix backend endpoint OR
- [ ] Update protocol documentation
- [ ] Coordinate frontend and backend changes

**Recommended Action:**
{specific_fix_suggestion}

---

#### ❌ #{N}: Request body field mismatch

- **Type:** Request Field Mismatch
- **Severity:** CRITICAL

**Frontend Request:**
- **Location:** `{file}:{line}`
```typescript
{frontend_request}
```

**Backend Expects:**
- **Document:** `docs/project-analysis/02-backend-apis.md`
```
{backend_request_spec}
```

**Problem:**
{field_mismatch_details}

**Field-by-Field Comparison:**
| Field | Frontend Sends | Backend Expects | Status |
|-------|----------------|------------------|--------|
| {field1} | {type1} | {type2} | ❌ Mismatch |
| {field2} | {type3} | {type3} | ✅ Match |

**Impact:**
- Request may be rejected with 400 Bad Request
- Data validation errors
- Feature partially broken

**Fix Required:**
- [ ] Align field names in frontend request OR
- [ ] Update backend to accept field name OR
- [ ] Add field mapping layer
- [ ] Update type definitions

**Recommended Action:**
{fix_recommendation}

---

#### ❌ #{N}: Response field mismatch

- **Type:** Response Field Mismatch
- **Severity:** HIGH

**Frontend Expects:**
- **Location:** `{file}:{line}`
```typescript
{frontend_response_expectation}
```

**Backend Returns:**
- **Document:** `docs/project-analysis/02-backend-apis.md`
```
{backend_response_spec}
```

**Problem:**
{response_mismatch_details}

**Impact:**
- Frontend cannot access required data
- Displays undefined or incorrect values
- May cause runtime errors

**Fix Required:**
- [ ] Fix frontend field access OR
- [ ] Update backend response OR
- [ ] Add data transformation layer
- [ ] Update protocol documentation

**Recommended Action:**
{recommendation}

---

{如果没有发现违规}

### ✅ No Frontend-Backend Mismatches Detected

All API calls are properly aligned:
- ✅ Frontend endpoints match backend definitions
- ✅ Request fields match backend expectations
- ✅ Response fields match frontend usage
- ✅ HTTP methods are correct

---

## Bad Case 3: Database Schema Violation (数据库不一致)

{如果发现违规}

### Severity Breakdown

- **CRITICAL:** {number} violations
- **HIGH:** {number} violations
- **MEDIUM:** {number} violations
- **LOW:** {number} violations

### Violations Found

#### ❌ #{N}: Table not found in schema

- **Location:** `{file}:{line}`
- **Severity:** CRITICAL

**Code Operation:**
```sql
{sql_operation}
```

**Schema Definition:**
- **Document:** `docs/project-analysis/04-database-schemas.md`
- **Available Tables:** {list_of_tables}

**Problem:**
Table `{table_name}` used in code but not defined in schema

**Impact:**
- Query will fail with "table '{table_name}' doesn't exist"
- Runtime error, application crash
- Data operation completely broken

**Fix Required:**
- [ ] Use correct table name OR
- [ ] Add table to schema (requires migration)
- [ ] Update all references

**Recommended Action:**
{recommendation}

---

#### ❌ #{N}: Column not found in table

- **Location:** `{file}:{line}`
- **Severity:** CRITICAL

**Code Operation:**
```sql
{sql_operation}
```

**Schema Definition:**
- **Document:** `docs/project-analysis/04-database-schemas.md`
- **Table:** `{table_name}`
- **Available Columns:** {list_of_columns}

**Problem:**
Column `{column_name}` used but not defined in table schema

**Impact:**
- Query will fail with "column '{column_name}' does not exist"
- Data retrieval or insertion fails
- Application error

**Fix Required:**
- [ ] Remove column from query OR
- [ ] Add column to table (requires migration)
- [ ] Update query logic

**Recommended Action:**
{recommendation}

---

#### ❌ #{N}: Column type mismatch

- **Location:** `{file}:{line}`
- **Severity:** HIGH

**Code Operation:**
```sql
{sql_operation}
```

**Schema Definition:**
- **Expected Type:** `{expected_type}`
- **Actual Type:** `{actual_type}`

**Problem:**
Type mismatch for column `{column_name}` in table `{table_name}`

**Impact:**
- Data insertion may fail
- Implicit conversion may lose precision
- Query may return incorrect results

**Fix Required:**
- [ ] Fix data type in code OR
- [ ] Update schema type definition (requires migration)
- [ ] Add explicit type casting

**Recommended Action:**
{recommendation}

---

#### ❌ #{N}: Missing required column

- **Location:** `{file}:{line}`
- **Severity:** CRITICAL

**Code Operation:**
```sql
{sql_operation}
```

**Schema Definition:**
- **Required Columns:** {list_of_required_columns}
- **Provided Columns:** {list_of_provided_columns}

**Problem:**
Required columns not provided: {missing_columns}

**Impact:**
- Database constraint violation
- Insert/Update operation fails
- Data integrity compromised

**Fix Required:**
- [ ] Add missing columns to operation OR
- [ ] Make columns nullable in schema (requires migration)
- [ ] Provide default values

**Recommended Action:**
{recommendation}

---

{如果没有发现违规}

### ✅ No Database Schema Violations Detected

All database operations comply with schema definition:
- ✅ Tables used in code exist in schema
- ✅ Columns used exist in tables
- ✅ Column types match schema definition
- ✅ Required constraints respected

---

## Recommendations

### Critical Actions Required (Block PR Merge)

{如果有 CRITICAL 级别的问题}

1. **Fix Protocol Violations First**
   - Address all CRITICAL issues before merging
   - Do not proceed to code quality review until compliance verified
   - Estimated fix time: {time_estimate}

2. **Specific Actions by Priority:**

   **Priority 1: Blocker Issues**
   - [ ] Fix {critical_issue_1}
   - [ ] Fix {critical_issue_2}
   - [ ] Verify fixes resolve violations

   **Priority 2: High Impact Issues**
   - [ ] Address {high_issue_1}
   - [ ] Consider {high_issue_2}

3. **Process Improvements**
   - [ ] Run protocol-compliance-check in CI pipeline
   - [ ] Add pre-commit hooks for protocol validation
   - [ ] Document any legitimate protocol exceptions

### Process Recommendations

{即使没有违规，也可以提供建议}

1. **Pre-Merge Checklist**
   - [ ] All fields used are documented
   - [ ] Frontend-backend APIs aligned
   - [ ] Database operations match schema
   - [ ] No critical violations detected

2. **Documentation Updates**
   {如果文档需要更新}
   - [ ] Update `docs/project-analysis/02-backend-apis.md`
   - [ ] Update `docs/project-analysis/03-backend-domains.md`
   - [ ] Update `docs/project-analysis/04-database-schemas.md`
   - [ ] Update `docs/project-analysis/06-external-apis.md` (if external APIs changed)

3. **Testing Recommendations**
   - [ ] Add integration tests to catch mismatches
   - [ ] Add contract tests for API compliance
   - [ ] Add database schema validation tests

---

## Detailed Violation Analysis

{提供更深入的分析}

### Root Cause Analysis

**Common Patterns:**
- {pattern_1}: {description} ({count} occurrences)
- {pattern_2}: {description} ({count} occurrences)

**Potential Causes:**
- {cause_1}: Design evolved, documentation not updated
- {cause_2}: Multiple developers, miscommunication
- {cause_3}: Copy-paste errors, not adapted properly

### Impact Assessment

**Affected Components:**
- Frontend: {components_affected}
- Backend: {services_affected}
- Database: {tables_affected}

**Risk Level:** {HIGH/MEDIUM/LOW}

**Business Impact:**
{business_impact_description}

---

## Appendix

### Protocol Documents Referenced

1. **Design Document:** `{path-to-design-doc}`
2. **Backend APIs:** `docs/project-analysis/02-backend-apis.md`
3. **Domain Models:** `docs/project-analysis/03-backend-domains.md`
4. **Database Schema:** `docs/project-analysis/04-database-schemas.md`
5. **External APIs:** `docs/project-analysis/06-external-apis.md`
6. **Code Relations:** `docs/project-analysis/08-code-relations.md`

### Code Files Analyzed

**Frontend Files:** {count} files
- {list_of_frontend_files}

**Backend Files:** {count} files
- {list_of_backend_files}

**Database Files:** {count} files
- {list_of_database_files}

---

**Report End**

*Generated by superpowers:protocol-compliance-check*
*Review Date: {timestamp}*
