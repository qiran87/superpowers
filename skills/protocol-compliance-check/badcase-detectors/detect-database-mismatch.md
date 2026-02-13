# Bad Case 3: Database Schema Violation Detection

**检测目标:** 发现数据库操作与架构文档定义的不一致

## 检测原理

```
提取数据库架构定义
    ↓
提取代码中的数据库操作
    ↓
对比: 表名、列名、列类型、约束
    ↓
发现不匹配 → 报告违规
```

## 检测规则

### 类型 1: 表不存在或未定义

**问题:** 代码操作了架构文档中未定义的表

**检测模式:**

**Pattern 1: SELECT 不存在的表**
```sql
-- ❌ 代码操作
SELECT * FROM user_logs;  -- user_logs 表不存在

-- ✅ Schema 定义 (04-database-schemas.md)
CREATE TABLE users (...);
CREATE TABLE orders (...);
CREATE TABLE products (...);

-- 🔧 修复选项:
-- 1. 使用正确的表名: SELECT * FROM users;
-- 2. 添加表到架构文档
```

**Pattern 2: ORM 查询不存在的模型**
```typescript
// ❌ 代码操作
await UserLog.findAll();  // UserLog 模型不存在

// ✅ Schema 定义
// 只有 User, Order, Product 模型

// 🔧 修复: 使用正确的模型
await User.findAll();
```

### 类型 2: 列不存在或未定义

**问题:** 代码查询/插入了架构文档中未定义的列

**检测模式:**

**Pattern 1: SELECT 未定义的列**
```sql
-- ❌ 代码查询
SELECT id, name, phone FROM users;  -- phone 列不存在

-- ✅ Schema 定义 (04-database-schemas.md)
CREATE TABLE users (
  id UUID PRIMARY KEY,
  name VARCHAR NOT NULL,
  email VARCHAR NOT NULL  -- ✅ 有 email，没有 phone
);

-- 🔧 修复选项:
-- 1. 移除 phone 列: SELECT id, name FROM users;
-- 2. 添加 phone 列到 schema
```

**Pattern 2: INSERT 未定义的列**
```sql
-- ❌ 代码插入
INSERT INTO users (id, name, status) VALUES (?, ?, ?);
-- status 列不存在

-- ✅ Schema 定义
CREATE TABLE users (
  id UUID PRIMARY KEY,
  name VARCHAR NOT NULL,
  email VARCHAR NOT NULL
);

-- 🔧 修复: 移除 status 列
INSERT INTO users (id, name, email) VALUES (?, ?, ?);
```

**Pattern 3: UPDATE 未定义的列**
```typescript
// ❌ 代码更新
await User.update(
  { id: userId },
  { lastLogin: new Date() }  // lastLogin 列不存在
);

// ✅ Schema 定义
// User 表只有 id, name, email, created_at, updated_at

// 🔧 修复: 使用 updated_at
await User.update(
  { id: userId },
  { updated_at: new Date() }
);
```

### 类型 3: 列类型不匹配

**问题:** 代码使用的类型与架构定义的类型不一致

**检测模式:**

**Pattern 1: 插入错误类型**
```typescript
// ❌ 代码插入
await User.create({
  id: generateId(),
  age: '25',  // ❌ 字符串类型
  name: 'Alice'
});

// ✅ Schema 定义 (04-database-schemas.md)
CREATE TABLE users (
  id UUID PRIMARY KEY,
  name VARCHAR NOT NULL,
  age INTEGER NOT NULL  -- ✅ 期望整数类型
);

-- 🔧 修复
await User.create({
  id: generateId(),
  age: 25,  // ✅ 使用整数
  name: 'Alice'
});
```

**Pattern 2: 查询假设错误类型**
```typescript
// ❌ 代码假设
const count = await User.count();
console.log(count + 1);  // ❌ 假设是数字

// ✅ Schema 定义
count: VARCHAR  -- ❌ 实际是字符串类型

-- 🔧 修复
const count = parseInt(await User.count());
console.log(count + 1);
```

### 类型 4: 必填字段缺失

**问题:** INSERT 或 UPDATE 缺少必填字段

**检测模式:**

**Pattern 1: INSERT 缺少必填列**
```sql
-- ❌ 代码插入
INSERT INTO users (id, name) VALUES (?, ?);
-- 缺少必填字段 email

-- ✅ Schema 定义
CREATE TABLE users (
  id UUID PRIMARY KEY,
  name VARCHAR NOT NULL,
  email VARCHAR NOT NULL,  -- ✅ 必填
  age INTEGER
);

-- 🔧 修复
INSERT INTO users (id, name, email) VALUES (?, ?, ?);
```

**Pattern 2: ORM 创建缺少必填字段**
```typescript
// ❌ 代码创建
await User.create({
  name: 'Bob'  // ❌ 缺少必填的 email
});

// ✅ Schema 定义
// User.name NOT NULL
// User.email NOT NULL

-- 🔧 修复
await User.create({
  name: 'Bob',
  email: 'bob@example.com'
});
```

### 类型 5: 约束违反

**问题:** 代码操作违反了数据库约束

**检测模式:**

**Pattern 1: 违反 UNIQUE 约束**
```typescript
// ❌ 代码假设可以插入重复
await User.create({
  email: 'alice@example.com'
});
await User.create({
  email: 'alice@example.com'  // ❌ 违反 UNIQUE 约束
});

// ✅ Schema 定义
CREATE TABLE users (
  ...
  email VARCHAR UNIQUE NOT NULL  -- ✅ UNIQUE 约束
);

-- 🔧 修复: 检查重复
const exists = await User.findOne({ email });
if (!exists) {
  await User.create({ email });
}
```

**Pattern 2: 违反 NOT NULL 约束**
```sql
-- ❌ 代码插入 NULL
INSERT INTO users (id, name, email) VALUES (?, ?, NULL);
-- email 不能为 NULL

-- ✅ Schema 定义
CREATE TABLE users (
  ...
  email VARCHAR NOT NULL  -- ✅ NOT NULL 约束
);

-- 🔧 修复: 提供有效值
INSERT INTO users (id, name, email) VALUES (?, ?, 'valid@email.com');
```

## 检测算法

### 步骤 1: 提取数据库架构定义

```python
# 伪代码
def extract_database_schema():
    schema = {
        'tables': {},
        'relationships': {}
    }

    # 从文档读取 schema
    schema_doc = read_file('docs/project-analysis/04-database-schemas.md')

    # 解析表定义
    tables = parse_create_table_statements(schema_doc)

    for table in tables:
        schema['tables'][table['name']] = {
            'columns': table['columns'],
            'constraints': table['constraints'],
            'indexes': table['indexes']
        }

    # 解析关系
    relationships = parse_relationships(schema_doc)
    schema['relationships'] = relationships

    return schema
```

**提取的 Schema 信息:**
```python
{
    'users': {
        'columns': {
            'id': {'type': 'UUID', 'nullable': False, 'primary_key': True},
            'name': {'type': 'VARCHAR', 'nullable': False},
            'email': {'type': 'VARCHAR', 'nullable': False, 'unique': True},
            'age': {'type': 'INTEGER', 'nullable': True}
        },
        'constraints': {
            'users_email_key': {'type': 'UNIQUE', 'columns': ['email']},
            'users_pkey': {'type': 'PRIMARY_KEY', 'columns': ['id']}
        }
    }
}
```

### 步骤 2: 提取代码中的数据库操作

```python
# 伪代码
def extract_database_operations(code_files):
    operations = []

    for file in code_files:
        if file.endswith('.sql'):
            # 解析 SQL 语句
            sql_ops = parse_sql_file(file)
            operations.extend(sql_ops)

        elif file.endswith(('.ts', '.js')):
            # 解析 ORM 操作
            orm_ops = parse_orm_operations(file)
            operations.extend(orm_ops)

    return operations
```

**提取的操作信息:**
```python
{
    'type': 'SELECT',
    'table': 'users',
    'columns': ['id', 'name', 'phone'],  # ❌ phone 不存在
    'where': 'id = ?',
    'location': {'file': 'src/repositories/UserRepository.ts', 'line': 45}
}
```

### 步骤 3: 对比检测违规

```python
# 伪代码
def detect_schema_violations(operations, schema):
    violations = []

    for op in operations:
        table = op['table']

        # 检查表是否存在
        if table not in schema['tables']:
            violations.append({
                'type': 'table_not_found',
                'operation': op,
                'severity': 'CRITICAL',
                'message': f"Table '{table}' not defined in schema"
            })
            continue  # 无法进一步检查此操作

        table_schema = schema['tables'][table]

        # 检查列是否存在
        if op['type'] in ['SELECT', 'INSERT', 'UPDATE']:
            for column in op.get('columns', []):
                if column not in table_schema['columns']:
                    violations.append({
                        'type': 'column_not_found',
                        'column': column,
                        'table': table,
                        'operation': op,
                        'severity': 'CRITICAL',
                        'message': f"Column '{column}' not found in table '{table}'"
                    })

        # 检查列类型是否匹配
        if op['type'] == 'INSERT':
            for column, value in op.get('values', {}).items():
                column_def = table_schema['columns'].get(column)
                if column_def:
                    expected_type = column_def['type']
                    actual_type = infer_type(value)
                    if not is_type_compatible(actual_type, expected_type):
                        violations.append({
                            'type': 'column_type_mismatch',
                            'column': column,
                            'table': table,
                            'expected_type': expected_type,
                            'actual_type': actual_type,
                            'operation': op,
                            'severity': 'HIGH',
                            'message': f"Type mismatch for '{table}.{column}': expected {expected_type}, got {actual_type}"
                        })

        # 检查必填字段
        if op['type'] == 'INSERT':
            required_columns = [
                col for col, col_def in table_schema['columns'].items()
                if not col_def['nullable']
            ]
            provided_columns = op.get('columns', [])

            missing_columns = set(required_columns) - set(provided_columns)
            if missing_columns:
                violations.append({
                    'type': 'missing_required_columns',
                    'columns': list(missing_columns),
                    'table': table,
                    'operation': op,
                    'severity': 'CRITICAL',
                    'message': f"Missing required columns in INSERT to '{table}': {missing_columns}"
                })

    return violations
```

## 报告格式

### 单个违规报告

```markdown
### ❌ Issue #[N]: Database Schema Violation

- **Type:** Column Not Found
- **Severity:** CRITICAL

**Code Operation:**
- **Location:** `src/repositories/UserRepository.ts:45`
- **Operation:** SELECT
- **Code:**
  ```typescript
  const user = await db.query(
    'SELECT id, name, phone FROM users WHERE id = ?'
  );
  ```

**Schema Definition:**
- **Document:** `docs/project-analysis/04-database-schemas.md`
- **Table:** `users`
- **Defined Columns:**
  ```sql
  CREATE TABLE users (
    id UUID PRIMARY KEY,
    name VARCHAR NOT NULL,
    email VARCHAR NOT NULL,
    created_at TIMESTAMP
  );
  ```

**Problem:**
- Column `phone` used in query but not defined in schema
- Query will fail with: "column phone does not exist"

**Impact:**
- Runtime error when query executes
- Application crashes if not caught
- Data integrity compromised (missing email but querying phone)

**Fix Options:**

**Option 1: Remove Column (Recommended)**
```typescript
// src/repositories/UserRepository.ts
const user = await db.query(
  'SELECT id, name, email FROM users WHERE id = ?'  // ✅ 移除 phone
);
```

**Option 2: Add Column to Schema**
```sql
-- Update schema (04-database-schemas.md)
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
```

**Recommendation:**
- If `phone` is needed → Update schema and run migration
- If `phone` was a mistake → Remove from query
- Verify all related code uses consistent fields
```

## 特殊情况处理

### 框架自动管理的字段

**不报告为违规的字段:**
- `id` (auto-increment primary key)
- `created_at`, `updated_at` (ORM managed timestamps)
- `version` (optimistic locking)

**报告格式:**
```markdown
### ℹ️ Info: ORM-managed field

- **Field:** `updated_at`
- **Location:** `src/models/User.ts:12`
- **Note:** Automatically managed by ORM, not explicitly in schema
- **Recommendation:** Document in schema if referenced in business logic
```

### 视图和子查询

**场景:** 代码查询视图或使用子查询，不直接访问表

**处理方式:**
```markdown
### ℹ️ Info: Query using subquery

- **Query:** `SELECT * FROM user_summary WHERE ...`
- **Note:** `user_summary` is a view, not a base table
- **Verification:** Check if view is defined in schema
- **Recommendation:** Document views in schema if used in code
```

### 动态列名

**场景:** 代码使用动态列名（如 `data_json->>'key'`）

**处理方式:**
```markdown
### ⚠️ Warning: Dynamic column access

- **Code:** `SELECT data->>'customField' FROM users`
- **Note:** Accessing JSON field, not validated at schema level
- **Recommendation:** Document JSON schema in protocol docs
- **Impact:** Cannot validate at static analysis time
```

### 数据库函数和计算列

**场景:** 查询使用数据库函数或计算列

**处理方式:**
```markdown
### ✅ Acceptable: Computed column

- **Query:** `SELECT COUNT(*) as user_count FROM users`
- **Note:** `user_count` is a computed alias, not a table column
- **Recommendation:** Acceptable, but ensure consistent naming
```

## 修复建议

### 修复策略 1: 更新代码适配 Schema（推荐）

**适用场景:** Schema 是标准的，代码需要适配

**步骤:**
1. 更新 SQL 查询或 ORM 操作
2. 移除不存在的列
3. 添加缺失的必填列
4. 修正列类型
5. 更新相关测试

**示例:**
```typescript
// Before
const users = await db.query(
  'SELECT id, name, phone FROM users'
);

// After
const users = await db.query(
  'SELECT id, name, email FROM users'  // ✅ 使用正确的列
);
```

### 修复策略 2: 更新 Schema 适配代码

**适用场景:** 代码是正确的，Schema 遗漏了字段

**步骤:**
1. 更新 `docs/project-analysis/04-database-schemas.md`
2. 创建数据库迁移脚本
3. 执行迁移
4. 验证相关代码
5. 更新测试

**示例:**
```sql
-- 更新 schema (04-database-schemas.md)
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- 迁移脚本
-- migrations/001_add_phone_column.sql
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
```

### 修复策略 3: 同步更新

**适用场景:** 双方都需要修改

**步骤:**
1. 分析根本原因（设计演进？遗留代码？）
2. 确定正确的数据模型
3. 同时更新代码和 Schema
4. 运行迁移
5. 全面测试

## 检测优先级

| 违规类型 | 优先级 | 理由 |
|---------|--------|------|
| 表不存在 | CRITICAL | 查询直接失败 |
| 列不存在 | CRITICAL | 查询执行失败 |
| 必填字段缺失 | CRITICAL | 违反约束，插入失败 |
| 类型不匹配 | HIGH | 可能插入失败或数据损坏 |
| 约束违反 | HIGH | 违反约束，操作失败 |
| 可选字段未使用 | LOW | 可能是设计优化 |

## 自动修复建议

### 可以自动修复的场景

**简单的列名修正:**
```sql
-- Before
SELECT id, name, phone FROM users;

-- Auto-fix
SELECT id, name, email FROM users;
```

**添加缺失的必填字段:**
```sql
-- Before
INSERT INTO users (id, name) VALUES (?, ?);

-- Auto-fix
INSERT INTO users (id, name, email) VALUES (?, ?, 'default@email.com');
```

### 需要人工判断的场景

**复杂的类型转换:**
```sql
-- 需要确认业务逻辑
-- age 是整数还是字符串？
SELECT * FROM users WHERE age > '25';  -- 错误类型
```

**影响范围大的 Schema 变更:**
```sql
-- 需要评估影响
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
-- 需要考虑: 索引、约束、默认值、迁移策略
```

## 相关资源

- 主技能: `../SKILL.md`
- Bad Case 1: `detect-extra-fields.md`
- Bad Case 2: `detect-frontend-backend-mismatch.md`
- 报告模板: `../compliance-report-template.md`
