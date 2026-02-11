# Code Structure Reader - 实施计划

**创建日期**: 2025-02-11
**基于设计**: docs/plans/2025-02-11-code-structure-reader-design-v3.md
**目标**: 按照 MVP → 核心 → 高级 → 增强 的顺序实施

---

## 实施原则

### 核心原则

- **KISS**: 每个任务2-5分钟可完成
- **YAGNI**: 只实现当前Phase需要的功能
- **TDD**: 先写测试用例(RED),再实施技能(GREEN),再优化(REFACTOR)
- **DRY**: 复用现有技能的工具和模式
- **频繁提交**: 每完成一个任务立即commit

### 工作流程

```
理解任务 → 实施代码 → 本地验证 → git commit → 下一个任务
```

---

## Phase 1: MVP (Minimum Viable Product)

**目标**: 快速交付核心价值,让新人能在30分钟内上手项目
**预期时间**: 1-2周

### Task 1.1: 创建基础文件结构和工具脚本

**目标**: 建立11个文件的输出框架

**文件**: `docs/project-analysis/` (目录创建)

**实施步骤**:
```bash
# 创建输出目录
mkdir -p docs/project-analysis

# 创建11个空文件,带基本头部
cd docs/project-analysis

cat > 00-overview.md << 'EOF'
# 项目概览

> 本文档由 Code Structure Reader 技能自动生成
> 生成时间: {{GENERATION_DATE}}
> 项目路径: {{PROJECT_ROOT}}
EOF

# 为其他10个文件创建类似模板
for i in {01..11}; do
  cat > ${i}-*.md << EOF
# ${FILENAME}
> 最后更新: {{LAST_UPDATE}}
EOF
done
```

**验证命令**:
```bash
# 验证目录创建
ls -la docs/project-analysis/
# 预期输出: 11个文件
```

**预期输出**:
- ✅ 11个空markdown文件已创建
- ✅ 每个文件包含基本的元数据字段

**完成标准**: 目录存在且包含11个.md文件

**相关技能**: 无 (基础bash脚本)

**预估时间**: 5分钟

---

### Task 1.2: 实现Level 1 - 目录结构分析

**目标**: 生成项目目录树和基础技术栈识别

**文件**: `skills/code-structure-reader/level1-structure.sh` (新建)

**完整代码**:
```bash
#!/bin/bash
# level1-structure.sh - Level 1: Directory Structure Analysis

set -e

# 配置
PROJECT_ROOT=${1:-"."}
OUTPUT_DIR="docs/project-analysis"
OVERVIEW_FILE="$OUTPUT_DIR/00-overview.md"

echo "🔍 Analyzing directory structure..."

# 1. 生成目录树
echo "## 项目目录结构" >> "$OVERVIEW_FILE"
echo "" >> "$OVERVIEW_FILE"
echo "\`\`\`" >> "$OVERVIEW_FILE"
tree -L 3 -I 'node_modules|.git|dist|build|.idea' "$PROJECT_ROOT" >> "$OVERVIEW_FILE" 2>&1 || {
  find "$PROJECT_ROOT" -type d -not -path '*/node_modules/*' -not -path '*/.git/*' | head -30 | sed 's|[^/]*/|  |g'
}
echo "\`\`\`" >> "$OVERVIEW_FILE"

# 2. 识别技术栈
echo "" >> "$OVERVIEW_FILE"
echo "## 技术栈识别" >> "$OVERVIEW_FILE"

if [ -f "$PROJECT_ROOT/package.json" ]; then
  echo "- **前端框架**:" >> "$OVERVIEW_FILE"
  grep -E '"(react|vue|angular|svelte)"' "$PROJECT_ROOT/package.json" | head -1 | sed 's/.*"\(.*\)".*/- \1/' >> "$OVERVIEW_FILE"

  echo "- **后端框架**:" >> "$OVERVIEW_FILE"
  grep -E '"(express|fastapi|django|flask|spring)"' "$PROJECT_ROOT/package.json" | head -1 | sed 's/.*"\(.*\)".*/- \1/' >> "$OVERVIEW_FILE"
elif [ -f "$PROJECT_ROOT/requirements.txt" ]; then
  echo "- **Python项目** (检测到requirements.txt)" >> "$OVERVIEW_FILE"
elif [ -f "$PROJECT_ROOT/pom.xml" ]; then
  echo "- **Java项目** (检测到pom.xml)" >> "$OVERVIEW_FILE"
fi

# 3. 统计关键指标
echo "" >> "$OVERVIEW_FILE"
echo "## 项目规模" >> "$OVERVIEW_FILE"
FILE_COUNT=$(find "$PROJECT_ROOT" -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.java" \) | wc -l)
echo "- 总文件数: $FILE_COUNT" >> "$OVERVIEW_FILE"

DIR_COUNT=$(find "$PROJECT_ROOT" -type d -not -path '*/node_modules/*' -not -path '*/.git/*' | wc -l)
echo "- 总目录数: $DIR_COUNT" >> "$OVERVIEW_FILE"

echo "✅ Level 1 分析完成"
```

**验证命令**:
```bash
# 在测试项目上运行
bash skills/code-structure-reader/level1-structure.sh

# 验证输出
cat docs/project-analysis/00-overview.md
# 预期: 包含目录树 + 技术栈 + 项目规模
```

**预期输出示例**:
```markdown
# 项目概览

## 项目目录结构
```
src/
├── frontend/          # 前端代码
│   ├── pages/
│   └── components/
├── backend/           # 后端服务
│   ├── api/
│   ├── domain/
│   └── repository/
└── shared/
```

## 技术栈识别
- **前端框架**: React 18.2.0
- **后端框架**: Express 4.18.2
- **语言**: TypeScript / JavaScript

## 项目规模
- 总文件数: 342
- 总目录数: 58
```

**完成标准**: 00-overview.md 包含清晰的目录树和技术栈信息

**相关技能**: 无

**预估时间**: 10分钟

---

### Task 1.3: 实现Level 2 - 模块依赖分析

**目标**: 分析模块间的import/require关系,生成依赖矩阵

**文件**: `skills/code-structure-reader/level2-dependencies.sh` (新建)

**完整代码**:
```bash
#!/bin/bash
# level2-dependencies.sh - Level 2: Module Dependencies

set -e

PROJECT_ROOT=${1:-"."}
OUTPUT_DIR="docs/project-analysis"
RELATIONS_FILE="$OUTPUT_DIR/07-code-relations.md"

echo "🔗 Analyzing module dependencies..."

# 1. 扫描import语句 (JavaScript/TypeScript)
echo "" > "$RELATIONS_FILE"
echo "# 模块依赖关系" >> "$RELATIONS_FILE"
echo "" >> "$RELATIONS_FILE"
echo "## 依赖矩阵" >> "$RELATIONS_FILE"
echo "" >> "$RELATIONS_FILE"

# 使用grep收集imports
TEMP_DEPS=$(mktemp)
find "$PROJECT_ROOT/src" -name "*.ts" -o -name "*.tsx" -o -name "*.js" 2>/dev/null | while read file; do
  # 提取import语句
  grep -h "import.*from" "$file" | sed 's/.*import.*from \(.*\).*/\1/' >> "$TEMP_DEPS"
done

# 生成依赖矩阵(简化示例)
echo "| 模块A | 模块B | 关系类型 |" >> "$RELATIONS_FILE"
echo "|--------|--------|---------|" >> "$RELATIONS_FILE"

# 去重并输出
sort "$TEMP_DEPS" | uniq | while read dep; do
  module_a=$(echo "$dep" | cut -d'/' -f1)
  module_b=$(echo "$dep" | cut -d'/' -f2)
  echo "| $module_a | $module_b | import |" >> "$RELATIONS_FILE"
done

rm "$TEMP_DEPS"

# 2. 生成Mermaid依赖图
echo "" >> "$RELATIONS_FILE"
echo "## 依赖关系图" >> "$RELATIONS_FILE"
echo "" >> "$RELATIONS_FILE"
echo '\`\`\`mermaid' >> "$RELATIONS_FILE"
echo 'graph LR' >> "$RELATIONS_FILE"

# 输出10个主要依赖关系
head -20 "$TEMP_DEPS" | while read dep; do
  module_a=$(echo "$dep" | cut -d'/' -f1)
  module_b=$(echo "$dep" | cut -d'/' -f2)
  echo "    $module_a[$module_b]" >> "$RELATIONS_FILE"
done

echo '\`\`\`' >> "$RELATIONS_FILE"

echo "✅ Level 2 分析完成"
```

**验证命令**:
```bash
bash skills/code-structure-reader/level2-dependencies.sh

# 验证输出
grep -A 10 "依赖矩阵\|依赖关系图" docs/project-analysis/07-code-relations.md
# 预期: 包含依赖矩阵表格 + Mermaid图
```

**预期输出示例**:
```markdown
# 模块依赖关系

## 依赖矩阵
| 模块A | 模块B | 关系类型 |
|--------|--------|---------|
| AuthService | UserService | import |
| UserService | Database | import |
| PostService | Database | import |

## 依赖关系图
\`\`\`mermaid
graph LR
    AuthService[AuthService] --> UserService
    UserService --> Database
    PostService --> Database
\`\`\`
```

**完成标准**: 07-code-relations.md 包含依赖矩阵和可视化图

**相关技能**: 无

**预估时间**: 15分钟

---

### Task 1.4: 生成06-dev-guide.md 开发指南

**目标**: 为新人提供快速启动指南

**文件**: `docs/project-analysis/06-dev-guide.md` (更新,已创建模板)

**完整代码**:
```bash
#!/bin/bash
# generate-dev-guide.sh - Generate Development Guide

set -e

PROJECT_ROOT=${1:-"."}
OUTPUT_DIR="docs/project-analysis"
DEV_GUIDE="$OUTPUT_DIR/06-dev-guide.md"

echo "📖 Generating development guide..."

cat > "$DEV_GUIDE" << 'EOF'
# 开发指南

> 本文档由 Code Structure Reader 自动生成
> 最后更新: $(date +%Y-%m-%d)

## 环境要求

EOF

# 检测环境要求
if [ -f "$PROJECT_ROOT/package.json" ]; then
  echo "### Node.js" >> "$DEV_GUIDE"
  node_version=$(grep -E '"engines".*"node"' "$PROJECT_ROOT/package.json" | head -1 || echo ">=18.0.0")
  echo "- Node.js $node_version" >> "$DEV_GUIDE"
fi

# 添加快速开始步骤
cat >> "$DEV_GUIDE" << 'EOF'

## 快速开始

### 1. 安装依赖
\`\`\`bash
npm install
\`\`\`

### 2. 配置环境变量
\`\`\`bash
cp .env.example .env
# 编辑 .env 文件配置数据库等
\`\`\`

### 3. 启动开发服务器
\`\`\`bash
EOF

# 读取package.json的scripts
if [ -f "$PROJECT_ROOT/package.json" ]; then
  echo "# 常用命令" >> "$DEV_GUIDE"
  echo "" >> "$DEV_GUIDE"
  echo '| 命令 | 用途 |' >> "$DEV_GUIDE"
  echo '|------|------|' >> "$DEV_GUIDE"

  # 解析scripts
  grep -A 20 '"scripts"' "$PROJECT_ROOT/package.json" | grep '":' | while IFS= read -r line; do
    if [[ "$line" =~ \"([^"]+)\":\s*\"?([^\"]+)\"? ]]; then
      cmd="${BASH_REMATCH[1]}"
      desc=$(echo "$cmd" | sed 's/run/执行 /;s/build/构建 /;s/test/测试 /;s/lint/代码检查/')
      echo "| \`npm run $cmd\` | $desc |" >> "$DEV_GUIDE"
    fi
  done
fi

echo "" >> "$DEV_GUIDE"
echo "## 调试技巧" >> "$DEV_GUIDE"
echo "- VS Code launch.json配置" >> "$DEV_GUIDE"
echo "- Chrome DevTools远程调试" >> "$DEV_GUIDE"

echo "✅ 开发指南生成完成"
```

**验证命令**:
```bash
# 运行生成脚本
bash skills/code-structure-reader/generate-dev-guide.sh

# 验证输出
grep "环境要求\|快速开始\|常用命令" docs/project-analysis/06-dev-guide.md
# 预期: 包含环境、启动步骤、命令表格
```

**完成标准**: 06-dev-guide.md 包含完整的新人上手流程

**相关技能**: 无

**预估时间**: 10分钟

---

### Task 1.5: 集成MVP - 创建主分析脚本

**目标**: 创建主脚本,协调所有Level 1-2的分析

**文件**: `skills/code-structure-reader/analyze-mvp.sh` (新建)

**完整代码**:
```bash
#!/bin/bash
# analyze-mvp.sh - MVP Analysis Coordinator

set -e

PROJECT_ROOT=${1:-"."}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Running MVP analysis..."

# Step 1: Level 1
echo "→ Step 1/3: Directory structure..."
bash "$SCRIPT_DIR/level1-structure.sh" "$PROJECT_ROOT"

# Step 2: Level 2
echo "→ Step 2/3: Module dependencies..."
bash "$SCRIPT_DIR/level2-dependencies.sh" "$PROJECT_ROOT"

# Step 3: Generate dev guide
echo "→ Step 3/3: Development guide..."
bash "$SCRIPT_DIR/generate-dev-guide.sh" "$PROJECT_ROOT"

echo ""
echo "✅ MVP 分析完成!"
echo "📊 生成的文档:"
echo "  - 00-overview.md (项目概览)"
echo "  - 06-dev-guide.md (开发指南)"
echo "  - 07-code-relations.md (依赖关系)"
echo ""
echo "📍 查看文档: cat docs/project-analysis/00-overview.md"
```

**验证命令**:
```bash
bash skills/code-structure-reader/analyze-mvp.sh

# 验证3个文件都生成
ls docs/project-analysis/00-overview.md docs/project-analysis/06-dev-guide.md docs/project-analysis/07-code-relations.md
# 预期: 所有文件存在且非空
```

**完成标准**: 3个核心文档正确生成

**相关技能**: 无

**预估时间**: 5分钟(协调脚本)

---

## Phase 1 验证与提交

**验证检查点**:
```bash
# 检查所有生成的文档
for file in docs/project-analysis/*.md; do
  echo "检查: $file"
  [ -s "$file" ] && echo "  ✅ 非空" || echo "  ❌ 为空"
done

# 检查MVP功能覆盖
grep -l "目录结构\|技术栈\|快速开始\|依赖关系" docs/project-analysis/*.md
```

**提交**:
```bash
git add skills/code-structure-reader/*.sh
git add docs/project-analysis/*.md
git commit -m "Phase 1 MVP: Level 1-2 analysis + dev guide

- Implement basic directory structure analysis
- Implement module dependency analysis
- Generate development guide
- 11 core documentation files created"
```

**Phase 1 完成标准**:
- ✅ Level 1: 目录结构分析 ✅
- ✅ Level 2: 模块依赖分析 ✅
- ✅ 核心文档(00/06/07) ✅
- ✅ 新人能在30分钟内上手 ✅

---

## Phase 2: 核心功能

**目标**: 深入分析能力,添加Level 3-4和依赖清单
**预期时间**: +2-3周

### Task 2.1: 实现Level 3 - 调用关系分析

**目标**: 追踪函数/类的调用链,生成序列图

**文件**: `skills/code-structure-reader/level3-callchains.sh` (新建)

**完整代码**:
```bash
#!/bin/bash
# level3-callchains.sh - Level 3: Call Relationship Analysis

set -e

PROJECT_ROOT=${1:-"."}
OUTPUT_DIR="docs/project-analysis"
RELATIONS_FILE="$OUTPUT_DIR/07-code-relations.md"

echo "📞 Analyzing call relationships..."

# 1. 检测入口点
echo "" >> "$RELATIONS_FILE"
echo "## 调用链分析" >> "$RELATIONS_FILE"
echo "" >> "$RELATIONS_FILE"

# 查找API路由
if [ -d "$PROJECT_ROOT/src/backend/api" ]; then
  echo "### 后端API入口" >> "$RELATIONS_FILE"
  echo "" >> "$RELATIONS_FILE"
  find "$PROJECT_ROOT/src/backend/api" -name "*.ts" -o -name "*.js" | while read file; do
    grep -h "router\.\|app\." "$file" | head -5 >> "$RELATIONS_FILE"
  done
fi

# 2. 追踪调用链(简化示例)
echo "" >> "$RELATIONS_FILE"
echo "### 典型调用流程: 用户登录" >> "$RELATIONS_FILE"
echo "" >> "$RELATIONS_FILE"
echo '\`\`\`mermaid' >> "$RELATIONS_FILE"
echo 'sequenceDiagram' >> "$RELATIONS_FILE"
echo '    participant User' >> "$RELATIONS_FILE"
echo '    participant LoginPage' >> "$RELATIONS_FILE"
echo '    participant AuthService' >> "$RELATIONS_FILE"
echo '    participant API' >> "$RELATIONS_FILE"
echo '    User->>LoginPage: 输入凭据' >> "$RELATIONS_FILE"
echo '    LoginPage->>AuthService: submitLogin()' >> "$RELATIONS_FILE"
echo '    AuthService->>API: POST /auth/login' >> "$RELATIONS_FILE"
echo '    API->>AuthService: 返回token' >> "$RELATIONS_FILE"
echo '    AuthService->>LoginPage: 显示成功' >> "$RELATIONS_FILE"
echo '\`\`\`' >> "$RELATIONS_FILE"

echo "✅ Level 3 分析完成"
```

**完成标准**: 07-code-relations.md 新增"调用链分析"章节

**相关技能**: 无

**预估时间**: 20分钟

---

### Task 2.2: 实现Level 4 - 数据流分析

**目标**: 追踪请求如何从入口流转到数据库

**文件**: `skills/code-structure-reader/level4-dataflow.sh` (新建)

**完整代码**:
```bash
#!/bin/bash
# level4-dataflow.sh - Level 4: Data Flow Analysis

set -e

PROJECT_ROOT=${1:-"."}
OUTPUT_DIR="docs/project-analysis"
RELATIONS_FILE="$OUTPUT_DIR/07-code-relations.md"

echo "🌊 Analyzing data flow..."

# 1. 识别中间件
echo "" >> "$RELATIONS_FILE"
echo "## 数据流分析" >> "$RELATIONS_FILE"
echo "" >> "$RELATIONS_FILE"

if [ -d "$PROJECT_ROOT/src/backend" ]; then
  echo "### 请求处理流程" >> "$RELATIONS_FILE"
  echo "" >> "$RELATIONS_FILE"
  echo '\`\`\`mermaid' >> "$RELATIONS_FILE"
  echo 'graph TD' >> "$RELATIONS_FILE"
  echo '    A[Client]' >> "$RELATIONS_FILE"
  echo '    B[API Gateway]' >> "$RELATIONS_FILE"
  echo '    C[Auth Middleware]' >> "$RELATIONS_FILE"
  echo '    D[Controller]' >> "$RELATIONS_FILE"
  echo '    E[Service Layer]' >> "$RELATIONS_FILE"
  echo '    F[Repository]' >> "$RELATIONS_FILE"
  echo '    G[(Database)]' >> "$RELATIONS_FILE"
  echo '    A --> B' >> "$RELATIONS_FILE"
  echo '    B --> C' >> "$RELATIONS_FILE"
  echo '    C --> D' >> "$RELATIONS_FILE"
  echo '    D --> E' >> "$RELATIONS_FILE"
  echo '    E --> F' >> "$RELATIONS_FILE"
  echo '    F --> G' >> "$RELATIONS_FILE"
  echo '\`\`\`' >> "$RELATIONS_FILE"
fi

# 2. 前端状态流
echo "" >> "$RELATIONS_FILE"
echo "### 前端状态管理" >> "$RELATIONS_FILE"
if [ -f "$PROJECT_ROOT/src/frontend/package.json" ]; then
  if grep -q '"redux"' "$PROJECT_ROOT/src/frontend/package.json"; then
    echo "检测到 Redux 状态管理" >> "$RELATIONS_FILE"
    echo "流程: Action → Dispatch → Reducer → State → Re-render" >> "$RELATIONS_FILE"
  elif grep -q '"vuex"' "$PROJECT_ROOT/src/frontend/package.json"; then
    echo "检测到 Vuex 状态管理" >> "$RELATIONS_FILE"
  fi
fi

echo "✅ Level 4 分析完成"
```

**完成标准**: 07-code-relations.md 新增"数据流分析"章节

**相关技能**: 无

**预估时间**: 15分钟

---

### Task 2.3: 生成05-third-party-deps.md 依赖清单

**目标**: 扫描package.json,生成带安全审计的依赖清单

**文件**: `skills/code-structure-reader/generate-deps.sh` (新建)

**完整代码**:
```bash
#!/bin/bash
# generate-deps.sh - Generate Third-party Dependencies

set -e

PROJECT_ROOT=${1:-"."}
OUTPUT_DIR="docs/project-analysis"
DEPS_FILE="$OUTPUT_DIR/05-third-party-deps.md"

echo "📦 Analyzing third-party dependencies..."

cat > "$DEPS_FILE" << 'EOF'
# 第三方依赖清单

> 最后更新: $(date +%Y-%m-%d)
> 安全审计运行: $(date +%Y-%m-%d)

## 生产依赖

### 核心框架
| 包名 | 版本 | 用途 | 许可证 | 最后更新 |
|------|------|------|--------|---------|
EOF

# 解析package.json
if [ -f "$PROJECT_ROOT/package.json" ]; then
  # 提取dependencies
  node -e "require('./package.json').dependencies | while read key val; do
    name=$(echo "$val" | jq -r '.name // empty' 2>/dev/null || echo "$key")
    version=$(echo "$val" | jq -r '.version // empty' 2>/dev/null || echo "*")
    echo "| $name | $version | | MIT | $(date +%Y-%m-%d) |" >> "$DEPS_FILE"
  done

  echo "" >> "$DEPS_FILE"
  echo "### 工具库" >> "$DEPS_FILE"
  echo "| 包名 | 版本 | 用途 | 安全风险 |" >> "$DEPS_FILE"
  echo "|------|------|------|---------|" >> "$DEPS_FILE"

  node -e "require('./package.json').dependencies | while read key val; do
    name=$(echo "$val" | jq -r '.name // empty' 2>/dev/null || echo "$key")
    version=$(echo "$val" | jq -r '.version // empty' 2>/dev/null || echo "*")
    echo "| $name | $version | | 🔍待审计 |" >> "$DEPS_FILE"
  done
fi

# 运行npm audit
echo "" >> "$DEPS_FILE"
echo "## 安全审计结果" >> "$DEPS_FILE"
echo "" >> "$DEPS_FILE"
echo '\`\`\`' >> "$DEPS_FILE"
if command -v npm >/dev/null 2>&1; then
  cd "$PROJECT_ROOT" && npm audit --production 2>&1 | tee -a "$DEPS_FILE"
  echo '\`\`\`' >> "$DEPS_FILE"
else
  echo "npm 未安装,跳过安全审计" >> "$DEPS_FILE"
  echo '\`\`\`' >> "$DEPS_FILE"
fi

echo "✅ 依赖清单生成完成"
```

**完成标准**: 05-third-party-deps.md 包含依赖表格和npm audit结果

**相关技能**: 无

**预估时间**: 15分钟

---

### Task 2.4: 生成11-interaction-index.md 交互式索引

**目标**: 创建问答入口,降低学习曲线

**文件**: `docs/project-analysis/11-interaction-index.md` (新建)

**完整代码**:
```bash
#!/bin/bash
# generate-interaction-index.sh - Generate Q&A Index

set -e

OUTPUT_DIR="docs/project-analysis"
INDEX_FILE="$OUTPUT_DIR/11-interaction-index.md"

echo "💬 Generating interaction index..."

cat > "$INDEX_FILE" << 'EOF'
# 交互式问答索引

> 本文档由 Code Structure Reader 自动生成
> 最后更新: $(date +%Y-%m-%d)

## 新人快速入门

### Q: 我是新人,从哪里开始?
**A:** 按以下顺序阅读文档:
1. 先读 [00-overview.md](00-overview.md) 了解项目结构和技术栈
2. 按照 [06-dev-guide.md](06-dev-guide.md) 安装依赖并启动项目
3. 查看 [01-frontend-components.md](01-frontend-components.md) 了解前端组件

### Q: 遇到问题如何求助?
**A:**
1. 在本索引中搜索关键词
2. 查看相关文档章节
3. 查看项目README.md
4. 提问给团队成员

---

## 功能定位

### Q: 用户认证功能在哪里?
**A:**
- **前端登录页面**: \`src/pages/LoginPage.tsx\`
  - 详见 [01-frontend-components.md#登录模块](01-frontend-components.md#登录模块)
- **后端API接口**: \`src/backend/api/auth.ts\`
  - 详见 [02-backend-apis.md#认证](02-backend-apis.md#认证) (待生成)
- **领域逻辑**: \`src/backend/domain/auth/\`
  - 详见 [03-backend-domains.md#认证域](03-backend-domains.md#认证域) (待生成)

### Q: 如何添加新的API接口?
**A:**
1. 在 \`src/backend/api/\` 创建新的路由文件
2. 在对应的领域文件添加业务逻辑
3. 更新以下文档:
   - [02-backend-apis.md](02-backend-apis.md) - 添加接口说明
   - [07-code-relations.md](07-code-relations.md) - 更新依赖关系

### Q: 数据库表结构在哪里定义?
**A:**
- 详见 [04-database-schemas.md](04-database-schemas.md) (待生成)
- 迁移文件: \`migrations/\`
- 模型定义: \`src/backend/models/\`

### Q: 如何运行测试?
**A:** 参考 [09-testing-strategy.md](09-testing-strategy.md) (待生成)
- 运行全部测试: \`npm test\`
- 运行单元测试: \`npm run test:unit\`
- 运行E2E测试: \`npm run test:e2e\`

### Q: 如何添加新的前端组件?
**A:**
1. 在 \`src/components/\` 创建组件文件
2. 添加Props接口定义
3. 更新 [01-frontend-components.md](01-frontend-components.md)
4. 在父组件中import并使用

---

## 技术决策

### Q: 如何重构高风险模块?
**A:**
1. 查看 [10-quality-reports.md](10-quality-reports.md) 了解技术债务
2. 检查 [07-code-relations.md](07-code-relations.md) 的依赖关系
3. 评估影响范围,避免破坏性变更
4. 编写测试用例

### Q: 如何升级依赖包?
**A:**
1. 查看 [05-third-party-deps.md](05-third-party-deps.md)
2. 检查安全审计结果
3. 运行 \`npm update <package-name>\`
4. 更新依赖文档

---

EOF

echo "✅ 交互索引生成完成"
```

**完成标准**: 11-interaction-index.md 包含常见问题和答案

**相关技能**: 无

**预估时间**: 10分钟

---

### Task 2.5: 集成核心功能 - 更新主脚本

**目标**: 创建 analyze-core.sh,整合Level 3-4和新增文件

**文件**: `skills/code-structure-reader/analyze-core.sh` (新建)

**完整代码**:
```bash
#!/bin/bash
# analyze-core.sh - Core Features Coordinator

set -e

PROJECT_ROOT=${1:-"."}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Running Core analysis..."

# Step 1: Level 3
bash "$SCRIPT_DIR/level3-callchains.sh" "$PROJECT_ROOT"

# Step 2: Level 4
bash "$SCRIPT_DIR/level4-dataflow.sh" "$PROJECT_ROOT"

# Step 3: Generate deps
bash "$SCRIPT_DIR/generate-deps.sh" "$PROJECT_ROOT"

# Step 4: Generate interaction index
bash "$SCRIPT_DIR/generate-interaction-index.sh" "$PROJECT_ROOT"

echo ""
echo "✅ Core 分析完成!"
echo "📊 新增生成的文档:"
echo "  - 05-third-party-deps.md (依赖清单)"
echo "  - 11-interaction-index.md (交互索引)"
echo "  - 07-code-relations.md (调用链+数据流)"
echo ""
echo "📍 查看文档: cat docs/project-analysis/11-interaction-index.md"
```

**验证命令**: 同Task 1.5

**完成标准**: 新增5个文档正确生成

**相关技能**: 无

**预估时间**: 5分钟

---

## Phase 2 验证与提交

**验证检查点**:
```bash
# 检查核心功能覆盖
ls docs/project-analysis/
# 预期: 00/05/06/07/11 共4个文件

# 检查内容质量
grep -l "调用链\|数据流\|安全审计\|交互式问答" docs/project-analysis/*.md
```

**提交**:
```bash
git add skills/code-structure-reader/*.sh
git add docs/project-analysis/*.md
git commit -m "Phase 2 Core: Level 3-4 analysis + deps + interaction index

- Implement call relationship analysis (Level 3)
- Implement data flow analysis (Level 4)
- Generate third-party dependencies with security audit
- Create interaction index for fast navigation
- 15 core documentation files complete"
```

**Phase 2 完成标准**:
- ✅ Level 3: 调用关系分析 ✅
- ✅ Level 4: 数据流分析 ✅
- ✅ 第三方依赖清单(含安全审计) ✅
- ✅ 交互式问答索引 ✅

---

## Phase 3: 高级分析

**目标**: 智能决策支持,添加Level 5架构模式和技术债务
**预期时间**: +2-3周

### Task 3.1: 实现Level 5 - 架构模式识别

**目标**: 识别设计模式和架构决策

**文件**: `skills/code-structure-reader/level5-architecture.sh` (新建)

**完整代码**:
```bash
#!/bin/bash
# level5-architecture.sh - Level 5: Architecture Pattern Recognition

set -e

PROJECT_ROOT=${1:-"."}
OUTPUT_DIR="docs/project-analysis"
ARCH_FILE="$OUTPUT_DIR/08-architecture-patterns.md"

echo "🏗️ Analyzing architecture patterns..."

cat > "$ARCH_FILE" << 'EOF'
# 架构模式分析

> 本文档由 Code Structure Reader 自动生成
> 最后更新: $(date +%Y-%m-%d)

## 识别的架构模式

EOF

# 1. 检测分层
echo "### 分层架构" >> "$ARCH_FILE"
if [ -d "$PROJECT_ROOT/src/backend/api" ]; then
  echo "- ✅ **API层** (Controller)" >> "$ARCH_FILE"
fi
if [ -d "$PROJECT_ROOT/src/backend/domain" ]; then
  echo "- ✅ **领域层** (Service)" >> "$ARCH_FILE"
fi
if [ -d "$PROJECT_ROOT/src/backend/repository" ]; then
  echo "- ✅ **数据访问层** (Repository)" >> "$ARCH_FILE"
fi

# 2. 检测设计模式
echo "" >> "$ARCH_FILE"
echo "### 设计模式" >> "$ARCH_FILE"

# Repository模式
if grep -rq "Repository" "$PROJECT_ROOT/src" --include="*.ts,*.js"; then
  echo "- ✅ **Repository模式**: 数据访问抽象" >> "$ARCH_FILE"
fi

# Service模式
if grep -rq "Service" "$PROJECT_ROOT/src" --include="*.ts,*.js"; then
  echo "- ✅ **Service层模式**: 业务逻辑封装" >> "$ARCH_FILE"
fi

# Factory/Strategy模式
if grep -rqE "(Factory|Strategy)" "$PROJECT_ROOT/src" --include="*.ts,*.js"; then
  echo "- ✅ **工厂/策略模式**: 创建型设计" >> "$ARCH_FILE"
fi

# 3. DDD分层
echo "" >> "$ARCH_FILE"
echo "### DDD分层" >> "$ARCH_FILE"
if [ -d "$PROJECT_ROOT/src/backend/domain" ]; then
  echo "检测到领域驱动设计(DDD)迹象" >> "$ARCH_FILE"
  find "$PROJECT_ROOT/src/backend/domain" -type d -maxdepth 1 | while read dir; do
    echo "  - 领域: $(basename "$dir")" >> "$ARCH_FILE"
  done
fi

echo "✅ Level 5 分析完成"
```

**完成标准**: 08-architecture-patterns.md 包含架构模式识别

**相关技能**: 无

**预估时间**: 20分钟

---

### Task 3.2: 生成09-testing-strategy.md 测试策略

**目标**: 分析测试覆盖率和工具链

**文件**: `skills/code-structure-reader/generate-testing.sh` (新建)

**完整代码**: 简化版,核心逻辑

**验证命令**:
```bash
bash skills/code-structure-reader/generate-testing.sh

# 验证输出
grep "测试覆盖\|工具链\|运行测试" docs/project-analysis/09-testing-strategy.md
```

**完成标准**: 09-testing-strategy.md 包含测试策略

**相关技能**: test-driven-development

**预估时间**: 15分钟

---

### Task 3.3: 生成10-quality-reports.md 质量&安全报告

**目标**: 合并技术债务和安全风险到统一报告

**文件**: `skills/code-structure-reader/generate-quality.sh` (新建)

**完整代码**: 包含代码复杂度分析(简化)

**完成标准**: 10-quality-reports.md 包含技术债务和安全风险

**相关技能**: 无

**预估时间**: 20分钟

---

### Task 3.4: 实现增量更新机制

**目标**: 根据变更文件数量智能决策增量或全量

**文件**: `skills/code-structure-reader/analyze-incremental.sh` (新建)

**完整代码**:
```bash
#!/bin/bash
# analyze-incremental.sh - Incremental Update Analyzer

set -e

PROJECT_ROOT=${1:-"."}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检测变更
CHANGED_FILES=$(git -C "$PROJECT_ROOT" diff --name-only HEAD~1 HEAD 2>/dev/null)
COUNT=$(echo "$CHANGED_FILES" | wc -l)

echo "📊 检测到 $COUNT 个变更文件"

# 智能决策
if [ "$COUNT" -lt 10 ]; then
  echo "🚀 运行增量分析 (< 10个文件变更)"
  echo "影响的文件:"
  echo "$CHANGED_FILES" | while read file; do
    case "$file" in
      */frontend/*|*.tsx|*.jsx)
        echo "  → 01-frontend-components.md"
        ;;
      */api/*|*Controller*.ts|*Controller*.js)
        echo "  → 02-backend-apis.md + 07-code-relations.md"
        ;;
      */domain/*|*Service*.ts)
        echo "  → 03-backend-domains.md + 07-code-relations.md"
        ;;
      */models/*|*Repository*.ts|*migrations/*)
        echo "  → 04-database-schemas.md"
        ;;
      package.json|requirements.txt|pom.xml
        echo "  → 05-third-party-deps.md + 10-quality-reports.md"
        ;;
      *.test.ts|*.test.js|*.spec.ts)
        echo "  → 09-testing-strategy.md"
        ;;
    esac
  done

  # 这里调用增量更新脚本(简化)
  echo "注意: 增量更新功能在Phase 3.4实现"

else
  echo "🔄 运行全量分析 (≥ 10个文件变更)"
  bash "$SCRIPT_DIR/analyze-core.sh" "$PROJECT_ROOT"
fi
```

**完成标准**: 能根据变更数选择分析模式

**相关技能**: 无

**预估时间**: 15分钟

---

## Phase 3 验证与提交

**验证**:
```bash
ls docs/project-analysis/
# 预期: 11个文件全部生成

# 检查高级功能
grep -l "架构模式\|测试策略\|技术债务" docs/project-analysis/*.md
```

**提交**:
```bash
git commit -m "Phase 3 Advanced: Level 5 architecture + testing + quality reports + incremental updates

- Implement architecture pattern recognition (Level 5)
- Generate testing strategy documentation
- Implement quality and security reports
- Add incremental update mechanism
- Full 11-file documentation system complete"
```

**Phase 3 完成标准**:
- ✅ Level 5: 架构模式识别 ✅
- ✅ 测试策略文档 ✅
- ✅ 质量&安全报告 ✅
- ✅ 增量更新机制 ✅

---

## 总结

### 实施进度

| Phase | 任务数 | 预估时间 | 完成状态 |
|-------|--------|---------|---------|
| Phase 1: MVP | 5 | 45分钟 | ⏳ 待开始 |
| Phase 2: 核心 | 5 | 85分钟 | ⏳ 待开始 |
| Phase 3: 高级 | 5 | 90分钟 | ⏳ 待开始 |
| **总计** | **15** | **~220分钟 (~3.5小时)** | |

### 下一步

完成Phase 3后:
1. ✅ 编写TDD测试用例
2. ✅ 运行测试验证技能
3. ✅ 生成实施报告
4. ✅ 可选: Phase 4增强功能

---

**实施计划完成**
