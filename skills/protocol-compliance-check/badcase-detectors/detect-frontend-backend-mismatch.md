# Bad Case 2: Frontend-Backend Mismatch Detection

**检测目标:** 发现前端 API 调用与后端接口定义的不一致

## 检测原理

```
提取前端 API 调用签名
    ↓
提取后端 API 接口定义
    ↓
对比: endpoint URL, HTTP 方法, 请求字段, 响应字段
    ↓
发现不匹配 → 报告违规
```

## 检测规则

### 类型 1: Endpoint 不匹配

**问题:** 前端调用的端点 URL 与后端定义不一致

**检测模式:**

**Pattern 1: 路径不匹配**
```typescript
// ❌ 前端调用
fetch('/api/user/profile')  // 错误路径

// ✅ 后端定义 (02-backend-apis.md)
GET /api/users/:id/profile

// 🔧 修复
fetch(`/api/users/${userId}/profile`)
```

**Pattern 2: HTTP 方法不匹配**
```typescript
// ❌ 前端调用
axios.post('/api/users/:id')  // 错误方法

// ✅ 后端定义 (02-backend-apis.md)
GET /api/users/:id

// 🔧 修复
axios.get(`/api/users/${userId}`)
```

**Pattern 3: 查询参数不匹配**
```typescript
// ❌ 前端调用
axios.get('/api/users?page=1&limit=10')

// ✅ 后端定义 (02-backend-apis.md)
GET /api/users
Query: { offset, limit }  // 使用 offset 而不是 page

// 🔧 修复
axios.get('/api/users', { params: { offset: 0, limit: 10 } })
```

### 类型 2: Request Body 不匹配

**问题:** 前端发送的请求体字段与后端期望不一致

**检测模式:**

**Pattern 1: 字段名不匹配**
```typescript
// ❌ 前端发送
api.login({
  username: 'alice',  // ❌ 字段名错误
  password: 'secret'
})

// ✅ 后端期望 (02-backend-apis.md)
POST /api/auth/login
Body: {
  email: string,     // ✅ 期望 email
  password: string
}

// 🔧 修复
api.login({
  email: 'alice',    // ✅ 使用正确的字段名
  password: 'secret'
})
```

**Pattern 2: 字段类型不匹配**
```typescript
// ❌ 前端发送
api.updateUser({
  age: '25',  // ❌ 字符串类型
  name: 'Alice'
})

// ✅ 后端期望 (02-backend-apis.md)
PUT /api/users/:id
Body: {
  age: number,  // ✅ 期望数字类型
  name: string
}

// 🔧 修复
api.updateUser({
  age: 25,  // ✅ 使用正确的类型
  name: 'Alice'
})
```

**Pattern 3: 必填字段缺失**
```typescript
// ❌ 前端发送
api.createUser({
  name: 'Bob'
  // ❌ 缺少必填字段 email
})

// ✅ 后端期望 (02-backend-apis.md)
POST /api/users
Body: {
  name: string,
  email: string,  // ✅ 必填
  age?: number   // 可选
}

// 🔧 修复
api.createUser({
  name: 'Bob',
  email: 'bob@example.com'  // ✅ 添加必填字段
})
```

### 类型 3: Response Body 不匹配

**问题:** 前端期望的响应字段与后端返回不一致

**检测模式:**

**Pattern 1: 响应字段名不匹配**
```typescript
// ❌ 前端期望
const { data } = await api.getUser();
console.log(data.user.fullName);  // ❌ 字段名错误

// ✅ 后端返回 (02-backend-apis.md)
GET /api/users/:id
Response: {
  user: {
    id,
    firstName,  // ✅ 后端返回 firstName
    lastName
  }
}

// 🔧 修复选项 1: 修改前端
const { firstName, lastName } = data.user;
const fullName = `${firstName} ${lastName}`;

// 🔧 修复选项 2: 修改后端
Response: {
  user: {
    id,
    fullName: `${firstName} ${lastName}`  // 添加计算字段
  }
}
```

**Pattern 2: 嵌套结构不匹配**
```typescript
// ❌ 前端期望
const { data } = await api.getOrders();
console.log(data.orders);  // ❌ 期望 data.orders

// ✅ 后端返回 (02-backend-apis.md)
GET /api/orders
Response: {
  orders: [],  // ✅ 直接返回 orders 数组
  pagination: {}
}

// 🔧 修复
const { data: { orders, pagination } } = await api.getOrders();
```

**Pattern 3: 字段类型不匹配**
```typescript
// ❌ 前端期望
const { count } = await api.getUserCount();
console.log(count + 1);  // ❌ 假设 count 是数字

// ✅ 后端返回 (02-backend-apis.md)
GET /api/users/count
Response: {
  count: string  // ❌ 返回字符串
}

// 🔧 修复
const { count } = await api.getUserCount();
console.log(parseInt(count) + 1);  // ✅ 转换类型
```

## 检测算法

### 步骤 1: 提取前端 API 调用

```python
# 伪代码
def extract_frontend_api_calls():
    api_calls = []

    # 扫描前端代码文件
    for file in glob('src/**/*.{ts,tsx,js,jsx}'):
        content = read_file(file)

        # 检测 fetch 调用
        fetch_calls = extract_fetch_calls(content, file)

        # 检测 axios 调用
        axios_calls = extract_axios_calls(content, file)

        # 检测自定义 API 函数
        custom_calls = extract_custom_api_calls(content, file)

        api_calls.extend(fetch_calls + axios_calls + custom_calls)

    return api_calls
```

**提取的 API 调用信息:**
```python
{
    'file': 'src/features/auth/login.tsx',
    'line': 23,
    'method': 'POST',
    'endpoint': '/api/auth/login',
    'request_fields': ['username', 'password'],  # ❌ 错误字段
    'response_usage': ['user.id', 'user.token']   # 如何使用响应
}
```

### 步骤 2: 提取后端 API 定义

```python
# 伪代码
def extract_backend_api_definitions():
    api_definitions = {}

    # 从文档读取 API 定义
    api_docs = read_file('docs/project-analysis/02-backend-apis.md')

    # 解析 API 端点
    endpoints = parse_api_endpoints(api_docs)

    for endpoint in endpoints:
        api_definitions[endpoint['path']] = {
            'method': endpoint['method'],
            'request_fields': endpoint['request_fields'],
            'response_fields': endpoint['response_fields']
        }

    return api_definitions
```

**提取的 API 定义信息:**
```python
{
    '/api/auth/login': {
        'method': 'POST',
        'request_fields': ['email', 'password'],  # ✅ 正确字段
        'response_fields': {
            'user': ['id', 'email', 'createdAt'],
            'token': 'string'
        }
    }
}
```

### 步骤 3: 对比检测不匹配

```python
# 伪代码
def detect_api_mismatches(frontend_calls, backend_definitions):
    mismatches = []

    for call in frontend_calls:
        endpoint = call['endpoint']

        if endpoint not in backend_definitions:
            mismatches.append({
                'type': 'endpoint_not_found',
                'frontend': call,
                'expected': None,
                'severity': 'CRITICAL'
            })
            continue

        backend_def = backend_definitions[endpoint]

        # 检查 HTTP 方法
        if call['method'] != backend_def['method']:
            mismatches.append({
                'type': 'http_method_mismatch',
                'frontend': call['method'],
                'expected': backend_def['method'],
                'severity': 'CRITICAL'
            })

        # 检查请求字段
        request_mismatch = compare_fields(
            call['request_fields'],
            backend_def['request_fields']
        )

        if request_mismatch:
            mismatches.append({
                'type': 'request_field_mismatch',
                'frontend_fields': call['request_fields'],
                'expected_fields': backend_def['request_fields'],
                'differences': request_mismatch,
                'severity': 'CRITICAL'
            })

        # 检查响应字段使用
        response_usage = call['response_usage']
        response_def = backend_def['response_fields']

        response_mismatch = validate_response_usage(
            response_usage,
            response_def
        )

        if response_mismatch:
            mismatches.append({
                'type': 'response_field_mismatch',
                'frontend_usage': response_usage,
                'available_fields': response_def,
                'missing_fields': response_mismatch,
                'severity': 'CRITICAL'
            })

    return mismatches
```

## 报告格式

### 单个违规报告

```markdown
### ❌ Issue #[N]: Frontend-Backend API Mismatch

- **Type:** Request Field Mismatch
- **Severity:** CRITICAL

**Frontend Call:**
- **Location:** `src/features/auth/login.tsx:23`
- **Code:**
  ```typescript
  api.login({
    username: 'alice',  // ❌ 字段名错误
    password: 'secret'
  })
  ```

**Backend Definition:**
- **Endpoint:** `POST /api/auth/login`
- **Document:** `docs/project-analysis/02-backend-apis.md`
- **Expected:**
  ```json
  {
    "email": "string",     // ✅ 期望 email
    "password": "string"
  }
  ```

**Problem:**
- Frontend sends `username`, backend expects `email`
- Field names don't match, will cause 400 Bad Request

**Impact:**
- User cannot log in
- Frontend needs to send correct field name
- Or backend needs to accept both field names

**Fix Options:**

**Option 1: Fix Frontend (Recommended)**
```typescript
// src/features/auth/login.tsx
api.login({
  email: username,  // ✅ 使用 email 字段
  password: password
})
```

**Option 2: Fix Backend**
```typescript
// Update backend to accept both fields
if (req.body.username) {
  req.body.email = req.body.username;
}
```

**Option 3: Update Protocol**
Add both `username` and `email` to protocol documentation if both should be supported.

**Recommendation:** Use Option 1 (Fix Frontend) unless business logic requires both field names.
```

## 特殊情况处理

### 向后兼容的字段

**场景:** 后端接受多种字段名，用于向后兼容

**处理方式:**
```markdown
### ℹ️ Info: Legacy field support

- **Frontend uses:** `username`
- **Backend accepts:** `email`, `username` (legacy)
- **Note:** `username` is deprecated but still supported
- **Recommendation:** Update frontend to use `email` before removing legacy support
```

### 可选字段

**场景:** 协议中定义为可选的字段，前端未发送

**不报告为违规，但给出提示:**
```markdown
### ⚠️ Warning: Optional field not sent

- **Field:** `profile.avatarUrl`
- **Location:** `src/components/UserSettings.tsx:56`
- **Note:** Field is optional in protocol, not sent by frontend
- **Impact:** May be intentional, verify if field should be sent
```

### 版本化的 API

**场景:** API 有多个版本 (v1, v2)，前端使用旧版本

**检测逻辑:**
```python
# 检查 API 版本
if call['endpoint'].startswith('/api/v1/'):
    # 允许 v1 和 v2 之间的差异
    check_compatibility(call, v1_definition, v2_definition)
```

## 修复建议

### 修复策略 1: 前端适配后端（推荐）

**适用场景:** 后端定义是标准的，前端需要适配

**优点:**
- 保持 API 一致性
- 前端修改影响范围小

**步骤:**
1. 更新前端 API 调用
2. 更新类型定义
3. 更新相关测试
4. 验证功能正常

### 修复策略 2: 后端适配前端

**适用场景:** 前端使用更合理，或多个前端依赖现有接口

**优点:**
- 不影响现有前端
- 可能改进 API 设计

**步骤:**
1. 更新后端接口定义
2. 添加字段别名或转换逻辑
3. 更新 API 文档
4. 更新相关测试
5. 确保向后兼容

### 修复策略 3: 更新协议文档

**适用场景:** 双方都有合理需求，需要统一标准

**步骤:**
1. 分析不匹配的根本原因
2. 确定最佳实践
3. 更新技术方案设计文档
4. 更新 `docs/project-analysis/02-backend-apis.md`
5. 协调前后端同步修改

## 检测优先级

| 不匹配类型 | 优先级 | 理由 |
|-----------|--------|------|
| Endpoint 404 | CRITICAL | 功能完全不可用 |
| Request field mismatch | CRITICAL | 请求失败或数据错误 |
| Response field mismatch | HIGH | 数据不显示或错误 |
| HTTP method mismatch | CRITICAL | 方法不被允许 |
| Optional field not sent | LOW | 可能是有意设计 |

## 自动修复建议

### 可以自动修复的场景

**简单字段重命名:**
```typescript
// Before
api.login({ username, password })

// Auto-fix suggestion
api.login({ email: username, password })
```

**路径参数修正:**
```typescript
// Before
axios.get('/api/user/profile')

// Auto-fix suggestion
axios.get('/api/users/:userId/profile')
```

### 需要人工判断的场景

**字段语义不明确:**
```typescript
// username vs email - 语义不同，需要人工确认哪个正确
// 不能自动修复
```

## 相关资源

- 主技能: `../SKILL.md`
- Bad Case 1: `detect-extra-fields.md`
- Bad Case 3: `detect-database-mismatch.md`
- 报告模板: `../compliance-report-template.md`
