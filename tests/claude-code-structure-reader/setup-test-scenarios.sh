#!/bin/bash
# setup-test-scenarios.sh - 创建测试场景
# 用途: 为code-structure-reader技能的TDD测试准备测试项目

set -e

# 配置
TEST_BASE_DIR="/tmp/test-code-structure-reader"
PROJECTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.."

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

printf "${GREEN}═══════════════════════════════════${NC}\n"
printf "${GREEN}Code Structure Reader - TDD RED阶段测试${NC}\n"
printf "${GREEN}═══════════════════════════════════${NC}\n"
printf "${NC}\n"

# 检查测试场景是否已创建
if [ ! -d "$TEST_BASE_DIR" ]; then
  printf "${RED}❌ 测试场景未创建!${NC}\n"
  printf "请先运行: bash setup-test-scenarios.sh${NC}\n"
  exit 1
fi

# 检查test-cases.md是否存在
if [ ! -f "$PROJECTS_ROOT/tests/claude-code-structure-reader/test-cases.md" ]; then
  printf "${RED}❌ 测试用例文档不存在!${NC}\n"
  exit 1
fi

printf "${YELLOW}🧪 设置测试场景...${NC}\n"
printf "${NC}\n"

# 清理旧测试数据
if [ -d "$TEST_BASE_DIR" ]; then
  printf "${YELLOW}清理旧测试数据...${NC}\n"
  rm -rf "$TEST_BASE_DIR"
fi

# 创建测试基础目录
mkdir -p "$TEST_BASE_DIR"

# ============================================================================
# Scenario 1: 新人入职 - React+Express项目
# ============================================================================

printf "${YELLOW}─────────────────────────────${NC}\n"
printf "${YELLOW}场景: Scenario 1: 新人入职${NC}\n"
printf "${YELLOW}描述: 新成员加入一个React+Express项目,需要在30分钟内理解项目结构并启动开发环境。${NC}\n"
printf "${YELLOW}─────────────────────────────${NC}\n"
printf "${NC}\n"

SCENARIO1_DIR="$TEST_BASE_DIR/scenario1-newbie"
mkdir -p "$SCENARIO1_DIR"

printf "${GREEN}创建Scenario 1: 新人入职测试项目...${NC}\n"

# 创建package.json
printf "${YELLOW}创建package.json...${NC}\n"
cat > "$SCENARIO1_DIR/package.json" << 'EOF'
{
  "name": "test-project-newbie",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18.2.0",
    "express": "^4.18.2",
    "lodash": "^4.17.21"
  }
}
EOF

printf "${GREEN}✅ Scenario 1 package.json创建完成${NC}\n"

# 创建目录结构
printf "${YELLOW}创建目录结构...${NC}\n"
mkdir -p "$SCENARIO1_DIR/src"/{frontend/{pages,components},backend/{api,domain,repository}}
mkdir -p "$SCENARIO1_DIR/tests"
mkdir -p "$SCENARIO1_DIR/docs"

printf "${GREEN}✅ Scenario 1 目录结构创建完成${NC}\n"

# 创建前端代码
printf "${YELLOW}创建前端代码...${NC}\n"
cat > "$SCENARIO1_DIR/src/frontend/pages/LoginPage.tsx" << 'EOF'
export const LoginPage = () => {
  return (
    <div>
      <h2>Login</h2>
      <form onSubmit={(credentials) => handleSubmit(credentials)}>
        <input name="username" />
        <input name="password" type="password" />
      </form>
    </div>
  );
};
EOF

printf "${GREEN}✅ Scenario 1 LoginPage.tsx创建完成${NC}\n"

cat > "$SCENARIO1_DIR/src/frontend/components/Button.tsx" << 'EOF'
export const Button = ({children, onClick}) => (
  <button onClick={onClick}>{children}</button>
);
EOF

printf "${GREEN}✅ Scenario 1 Button.tsx创建完成${NC}\n"

# 创建后端代码
printf "${YELLOW}创建后端代码...${NC}\n"
cat > "$SCENARIO1_DIR/src/backend/api/auth.ts" << 'EOF'
export const login = (req, res) => {
  res.json({token: 'fake-token'});
};
EOF

printf "${GREEN}✅ Scenario 1 auth.ts创建完成${NC}\n"

cat > "$SCENARIO1_DIR/src/backend/domain/auth/AuthService.ts" << 'EOF'
export class AuthService {
  login(username, password) {
    // Auth logic
  }
}
EOF

printf "${GREEN}✅ Scenario 1 AuthService.ts创建完成${NC}\n"

# 创建README
printf "${YELLOW}创建README...${NC}\n"
cat > "$SCENARIO1_DIR/README.md" << 'EOF'
# 测试项目 - 新人入职场景

## 项目说明
这是一个典型的React+Express项目,用于测试code-structure-reader技能的新人入职场景。

## 目录结构
\`\`\`
src/
├── frontend/
│   ├── pages/LoginPage.tsx
│   └── components/Button.tsx
└── backend/
    ├── api/auth.ts
    └── domain/auth/AuthService.ts
\`\`\`

## 测试要点
1. 项目结构是否清晰?
2. 是否容易理解?
3. 新人能否快速上手?

## 使用方法
参见 \`tests/test-cases.md\` 中的Scenario 1
EOF

printf "${GREEN}✅ Scenario 1 README.md创建完成${NC}\n"

printf "${GREEN}✅ Scenario 1 创建完成${NC}\n"

# ============================================================================
# Scenario 2: 技术方案设计 - 添加评论功能
# ============================================================================

printf "${YELLOW}─────────────────────────────${NC}\n"
printf "${YELLOW}场景: Scenario 2: 技术方案设计${NC}\n"
printf "${YELLOW}描述: 需要添加"用户评论"功能,在技术方案设计阶段需要了解项目是否已有类似功能和可复用组件。${NC}\n"
printf "${YELLOW}─────────────────────────────${NC}\n"
printf "${NC}\n"

SCENARIO2_DIR="$TEST_BASE_DIR/scenario2-tech-design"
mkdir -p "$SCENARIO2_DIR"

printf "${GREEN}创建Scenario 2: 技术方案设计测试项目...${NC}\n"

# 创建package.json
printf "${YELLOW}复制package.json...${NC}\n"
cp "$SCENARIO1_DIR/package.json" "$SCENARIO2_DIR/package.json"

printf "${GREEN}✅ Scenario 2 package.json创建完成${NC}\n"

# 复制基础结构
printf "${YELLOW}复制基础结构...${NC}\n"
cp -r "$SCENARIO1_DIR/src" "$SCENARIO2_DIR/"

printf "${GREEN}✅ Scenario 2 基础结构复制完成${NC}\n"

# 添加评论功能
printf "${YELLOW}添加评论功能代码...${NC}\n"

# 前端组件
cat > "$SCENARIO2_DIR/src/frontend/components/CommentBox.tsx" << 'EOF'
export const CommentBox = ({comment}) => (
  <div className="comment-box">{comment}</div>
);
EOF

printf "${GREEN}✅ Scenario 2 CommentBox.tsx创建完成${NC}\n"

# 后端API
cat > "$SCENARIO2_DIR/src/backend/api/comments.ts" << 'EOF'
export const getComments = (req, res) => {
  res.json([
    {id: 1, text: 'existing comment'}
  ]);
};
EOF

printf "${GREEN}✅ Scenario 2 comments.ts创建完成${NC}\n"

# 创建README
printf "${YELLOW}创建README...${NC}\n"
cat > "$SCENARIO2_DIR/README.md" << 'EOF'
# 测试场景: 技术方案设计

## 场景说明
测试"评论功能"设计时,子代理是否能发现现有能力并建议复用组件。

## 已有功能
- ✅ 评论API: \`GET /api/comments\`
- ✅ 评论组件: \`CommentBox.tsx\`

## 测试要点
子代理是否能:
1. 扫描现有API发现评论功能?
2. 提示复用CommentBox组件?
3. 分析依赖关系?

## 使用方法
参见 \`tests/test-cases.md\` 中的Scenario 2
EOF

printf "${GREEN}✅ Scenario 2 README.md创建完成${NC}\n"

printf "${GREEN}✅ Scenario 2 创建完成${NC}\n"

# ============================================================================
# Scenario 3: 代码审查 - 修改AuthService
# ============================================================================

printf "${YELLOW}─────────────────────────────${NC}\n"
printf "${YELLOW}场景: Scenario 3: 代码审查${NC}\n"
printf "${YELLOW}描述: 模拟审查修改AuthService的PR,测试子代理是否能识别影响范围。${NC}\n"
printf "${YELLOW}─────────────────────────────${NC}\n"
printf "${NC}\n"

SCENARIO3_DIR="$TEST_BASE_DIR/scenario3-code-review"
mkdir -p "$SCENARIO3_DIR"

printf "${GREEN}创建Scenario 3: 代码审查测试项目...${NC}\n"

# 创建package.json
printf "${YELLOW}复制package.json...${NC}\n"
cp "$SCENARIO1_DIR/package.json" "$SCENARIO3_DIR/package.json"

printf "${GREEN}✅ Scenario 3 package.json创建完成${NC}\n"

# 复制基础结构
printf "${YELLOW}复制基础结构...${NC}\n"
cp -r "$SCENARIO1_DIR/src" "$SCENARIO3_DIR/"

printf "${GREEN}✅ Scenario 3 基础结构复制完成${NC}\n"

# 模拟PR修改：在AuthService添加refreshToken方法
printf "${YELLOW}添加refreshToken方法...${NC}\n"

cat > "$SCENARIO3_DIR/src/backend/domain/auth/AuthService.ts" << 'EOF'
export class AuthService {
  login(username, password) {
    // Auth logic
  }

  // 新增：PR添加的功能
  refreshToken(token) {
    // Refresh token logic
  }
}
EOF

printf "${GREEN}✅ Scenario 3 AuthService.ts更新完成${NC}\n"

# 创建依赖关系说明
printf "${YELLOW}创建依赖关系说明...${NC}\n"

cat > "$SCENARIO3_DIR/DEPENDENCIES.txt" << 'EOF'
原始依赖关系:
- AuthService被以下模块依赖:
  - UserController (登录)
  - SessionManager (她话管理)
  - ApiService (第三方调用)

PR修改内容:
- 添加refreshToken方法
- 可能需要新增依赖: TokenValidator

影响范围:
- UserController可能需要调用refreshToken
- SessionManager需要存储refresh token
EOF

printf "${GREEN}✅ Scenario 3 DEPENDENCIES.txt创建完成${NC}\n"

# 创建README
printf "${YELLOW}创建README...${NC}\n"
cat > "$SCENARIO3_DIR/README.md" << 'EOF'
# 测试场景: 代码审查场景

## 场景说明
模拟审查修改AuthService的PR,测试子代理是否能识别影响范围。

## 测试要点
子代理是否能:
1. 分析模块依赖关系?
2. 识别受影响的模块?
3. 生成影响范围报告?

## 使用方法
参见 \`tests/test-cases.md\` 中的Scenario 3
EOF

printf "${GREEN}✅ Scenario 3 README.md创建完成${NC}\n"

printf "${GREEN}✅ Scenario 3 创建完成${NC}\n"

# ============================================================================
# Scenario 4: 大型项目 - 性能测试
# ============================================================================

printf "${YELLOW}─────────────────────────────${NC}\n"
printf "${YELLOW}场景: Scenario 4: 大型项目性能测试${NC}\n"
printf "${YELLOW}描述: 包含~1000个源文件的大型项目,测试分析性能。${NC}\n"
printf "${YELLOW}─────────────────────────────${NC}\n"
printf "${NC}\n"

SCENARIO4_DIR="$TEST_BASE_DIR/scenario4-large-project"
mkdir -p "$SCENARIO4_DIR"

printf "${GREEN}创建Scenario 4: 大型项目性能测试...${NC}\n"

# 创建package.json
printf "${YELLOW}复制package.json...${NC}\n"
cp "$SCENARIO1_DIR/package.json" "$SCENARIO4_DIR/package.json"

printf "${GREEN}✅ Scenario 4 package.json创建完成${NC}\n"

# 创建大量文件(模拟大型项目)
printf "${YELLOW}创建大量文件(模拟大型项目)...${NC}\n"

mkdir -p "$SCENARIO4_DIR/src"/{api,domain,utils,models}

printf "${YELLOW}生成1000个文件...${NC}\n"
for i in {1..200}; do
  printf "// File $i" > "$SCENARIO4_DIR/src/file$i.js"
done

printf "${GREEN}✅ Scenario 4 文件创建完成${NC}\n"

# 创建子目录
printf "${YELLOW}创建子目录...${NC}\n"
for dir in api domain utils models; do
  mkdir -p "$SCENARIO4_DIR/src/$dir"
  printf "  生成 $dir 文件..."
  for j in {1..50}; do
    printf "// $dir file $j" > "$SCENARIO4_DIR/src/$dir/file$j.js"
  done
done

printf "${GREEN}✅ Scenario 4 子目录创建完成${NC}\n"

# 创建README
printf "${YELLOW}创建README...${NC}\n"
cat > "$SCENARIO4_DIR/README.md" << 'EOF'
# 测试场景: 大型项目性能测试

## 场景说明
包含~1000个源文件的大型项目,测试分析性能。

## 项目规模
- 总文件数: ~1000个
- 目录数: 20+个

## 测试要点
子代理是否能:
1. 在20分钟内完成分析?
2. 内存占用 < 2GB?
3. 是否超时?

## 性能基准
- 小型项目(<50文件): < 2分钟
- 中型项目(<500文件): < 10分钟
- 大型项目(<2000文件): < 30分钟

## 使用方法
参见 \`tests/test-cases.md\` 中的Scenario 4
EOF

printf "${GREEN}✅ Scenario 4 README.md创建完成${NC}\n"

printf "${GREEN}✅ Scenario 4 创建完成${NC}\n"

# ============================================================================
# 总结
# ============================================================================

printf "${NC}\n"
printf "${GREEN}🎉 测试场景创建完成!${NC}\n"
printf "${NC}\n"
printf "${YELLOW}📁 创建的场景:${NC}\n"
printf "  1. Scenario 1: $SCENARIO1_DIR (新人入职)${NC}\n"
printf "  2. Scenario 2: $SCENARIO2_DIR (技术方案设计)${NC}\n"
printf "  3. Scenario 3: $SCENARIO3_DIR (代码审查)${NC}\n"
printf "  4. Scenario 4: $SCENARIO4_DIR (大型项目性能)${NC}\n"
printf "${NC}\n"
printf "${YELLOW}📍 下一步: 运行基线测试${NC}\n"
printf "${NC}\n"
printf "${YELLOW}运行命令:${NC}\n"
printf "  bash tests/claude-code-structure-reader/run-baseline-tests.sh${NC}\n"

printf "${GREEN}═══════════════════════════════════${NC}\n"
printf "${NC}\n"
