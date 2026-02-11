#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""setup-test-scenarios.py - 创建测试场景
用途: 为code-structure-reader技能的TDD测试准备测试项目
"""

import os
import shutil
from pathlib import Path

# 配置
TEST_BASE_DIR = "/tmp/test-code-structure-reader"
SCRIPT_DIR = Path(__file__).parent
PROJECTS_ROOT = SCRIPT_DIR.parent

# ANSI颜色代码
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
NC = '\033[0m'  # No Color

def print_header():
    print(f"{GREEN}{'═'*33}{NC}")
    print(f"{GREEN}Code Structure Reader - TDD RED阶段测试{NC}")
    print(f"{GREEN}{'═'*33}{NC}")
    print(f"{NC}")

def print_section(title):
    print(f"{YELLOW}{'─'*37}{NC}")
    print(f"{YELLOW}{title}{NC}")
    print(f"{YELLOW}{'─'*37}{NC}")
    print(f"{NC}")

def create_file(path, content):
    """创建文件"""
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

# 检查test-cases.md是否存在
test_cases_doc = SCRIPT_DIR / "test-cases.md"
if not test_cases_doc.exists():
    print(f"{RED}❌ 测试用例文档不存在!{NC}")
    exit(1)

print_header()

# 清理旧测试数据
if os.path.exists(TEST_BASE_DIR):
    print(f"{YELLOW}清理旧测试数据...{NC}")
    shutil.rmtree(TEST_BASE_DIR)

# 创建测试基础目录
os.makedirs(TEST_BASE_DIR, exist_ok=True)

# ============================================================================
# Scenario 1: 新人入职 - React+Express项目
# ============================================================================

print_section("场景: Scenario 1: 新人入职")
print("描述: 新成员加入一个React+Express项目,需要在30分钟内理解项目结构并启动开发环境。")

scenario1_dir = Path(TEST_BASE_DIR) / "scenario1-newbie"
scenario1_dir.mkdir(parents=True, exist_ok=True)

print(f"{GREEN}创建Scenario 1: 新人入职测试项目...{NC}")

# 创建package.json
print(f"{YELLOW}创建package.json...{NC}")
package_json = '''{
  "name": "test-project-newbie",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18.2.0",
    "express": "^4.18.2",
    "lodash": "^4.17.21"
  }
}
'''
create_file(scenario1_dir / "package.json", package_json)
print(f"{GREEN}✅ Scenario 1 package.json创建完成{NC}")

# 创建目录结构
print(f"{YELLOW}创建目录结构...{NC}")
(scenario1_dir / "src" / "frontend" / "pages").mkdir(parents=True, exist_ok=True)
(scenario1_dir / "src" / "frontend" / "components").mkdir(parents=True, exist_ok=True)
(scenario1_dir / "src" / "backend" / "api").mkdir(parents=True, exist_ok=True)
(scenario1_dir / "src" / "backend" / "domain" / "auth").mkdir(parents=True, exist_ok=True)
(scenario1_dir / "src" / "backend" / "repository").mkdir(parents=True, exist_ok=True)
(scenario1_dir / "tests").mkdir(parents=True, exist_ok=True)
(scenario1_dir / "docs").mkdir(parents=True, exist_ok=True)
print(f"{GREEN}✅ Scenario 1 目录结构创建完成{NC}")

# 创建前端代码
print(f"{YELLOW}创建前端代码...{NC}")
login_page = '''export const LoginPage = () => {
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
'''
create_file(scenario1_dir / "src" / "frontend" / "pages" / "LoginPage.tsx", login_page)
print(f"{GREEN}✅ Scenario 1 LoginPage.tsx创建完成{NC}")

button_tsx = '''export const Button = ({children, onClick}) => (
  <button onClick={onClick}>{children}</button>
);
'''
create_file(scenario1_dir / "src" / "frontend" / "components" / "Button.tsx", button_tsx)
print(f"{GREEN}✅ Scenario 1 Button.tsx创建完成{NC}")

# 创建后端代码
print(f"{YELLOW}创建后端代码...{NC}")
auth_ts = '''export const login = (req, res) => {
  res.json({token: 'fake-token'});
};
'''
create_file(scenario1_dir / "src" / "backend" / "api" / "auth.ts", auth_ts)
print(f"{GREEN}✅ Scenario 1 auth.ts创建完成{NC}")

auth_service = '''export class AuthService {
  login(username, password) {
    // Auth logic
  }
}
'''
create_file(scenario1_dir / "src" / "backend" / "domain" / "auth" / "AuthService.ts", auth_service)
print(f"{GREEN}✅ Scenario 1 AuthService.ts创建完成{NC}")

# 创建README
print(f"{YELLOW}创建README...{NC}")
readme1 = '''# 测试项目 - 新人入职场景

## 项目说明
这是一个典型的React+Express项目,用于测试code-structure-reader技能的新人入职场景。

## 目录结构
```
src/
├── frontend/
│   ├── pages/LoginPage.tsx
│   └── components/Button.tsx
└── backend/
    ├── api/auth.ts
    └── domain/auth/AuthService.ts
```

## 测试要点
1. 项目结构是否清晰?
2. 是否容易理解?
3. 新人能否快速上手?

## 使用方法
参见 `tests/test-cases.md` 中的Scenario 1
'''
create_file(scenario1_dir / "README.md", readme1)
print(f"{GREEN}✅ Scenario 1 README.md创建完成{NC}")

print(f"{GREEN}✅ Scenario 1 创建完成{NC}")

# ============================================================================
# Scenario 2: 技术方案设计 - 添加评论功能
# ============================================================================

print_section("场景: Scenario 2: 技术方案设计")
print("描述: 需要添加\"用户评论\"功能,在技术方案设计阶段需要了解项目是否已有类似功能和可复用组件。")

scenario2_dir = Path(TEST_BASE_DIR) / "scenario2-tech-design"
scenario2_dir.mkdir(parents=True, exist_ok=True)

print(f"{GREEN}创建Scenario 2: 技术方案设计测试项目...{NC}")

# 复制package.json
print(f"{YELLOW}复制package.json...{NC}")
shutil.copy(scenario1_dir / "package.json", scenario2_dir / "package.json")
print(f"{GREEN}✅ Scenario 2 package.json创建完成{NC}")

# 复制基础结构
print(f"{YELLOW}复制基础结构...{NC}")
shutil.copytree(scenario1_dir / "src", scenario2_dir / "src", dirs_exist_ok=True)
print(f"{GREEN}✅ Scenario 2 基础结构复制完成{NC}")

# 添加评论功能
print(f"{YELLOW}添加评论功能代码...{NC}")

# 前端组件
comment_box = '''export const CommentBox = ({comment}) => (
  <div className="comment-box">{comment}</div>
);
'''
create_file(scenario2_dir / "src" / "frontend" / "components" / "CommentBox.tsx", comment_box)
print(f"{GREEN}✅ Scenario 2 CommentBox.tsx创建完成{NC}")

# 后端API
comments_ts = '''export const getComments = (req, res) => {
  res.json([
    {id: 1, text: 'existing comment'}
  ]);
};
'''
create_file(scenario2_dir / "src" / "backend" / "api" / "comments.ts", comments_ts)
print(f"{GREEN}✅ Scenario 2 comments.ts创建完成{NC}")

# 创建README
print(f"{YELLOW}创建README...{NC}")
readme2 = '''# 测试场景: 技术方案设计

## 场景说明
测试"评论功能"设计时,子代理是否能发现现有能力并建议复用组件。

## 已有功能
- ✅ 评论API: `GET /api/comments`
- ✅ 评论组件: `CommentBox.tsx`

## 测试要点
子代理是否能:
1. 扫描现有API发现评论功能?
2. 提示复用CommentBox组件?
3. 分析依赖关系?

## 使用方法
参见 `tests/test-cases.md` 中的Scenario 2
'''
create_file(scenario2_dir / "README.md", readme2)
print(f"{GREEN}✅ Scenario 2 README.md创建完成{NC}")

print(f"{GREEN}✅ Scenario 2 创建完成{NC}")

# ============================================================================
# Scenario 3: 代码审查 - 修改AuthService
# ============================================================================

print_section("场景: Scenario 3: 代码审查")
print("描述: 模拟审查修改AuthService的PR,测试子代理是否能识别影响范围。")

scenario3_dir = Path(TEST_BASE_DIR) / "scenario3-code-review"
scenario3_dir.mkdir(parents=True, exist_ok=True)

print(f"{GREEN}创建Scenario 3: 代码审查测试项目...{NC}")

# 复制package.json
print(f"{YELLOW}复制package.json...{NC}")
shutil.copy(scenario1_dir / "package.json", scenario3_dir / "package.json")
print(f"{GREEN}✅ Scenario 3 package.json创建完成{NC}")

# 复制基础结构
print(f"{YELLOW}复制基础结构...{NC}")
shutil.copytree(scenario1_dir / "src", scenario3_dir / "src", dirs_exist_ok=True)
print(f"{GREEN}✅ Scenario 3 基础结构复制完成{NC}")

# 模拟PR修改：在AuthService添加refreshToken方法
print(f"{YELLOW}添加refreshToken方法...{NC}")

auth_service_v3 = '''export class AuthService {
  login(username, password) {
    // Auth logic
  }

  // 新增：PR添加的功能
  refreshToken(token) {
    // Refresh token logic
  }
}
'''
create_file(scenario3_dir / "src" / "backend" / "domain" / "auth" / "AuthService.ts", auth_service_v3)
print(f"{GREEN}✅ Scenario 3 AuthService.ts更新完成{NC}")

# 创建依赖关系说明
print(f"{YELLOW}创建依赖关系说明...{NC}")
dependencies_txt = '''原始依赖关系:
- AuthService被以下模块依赖:
  - UserController (登录)
  - SessionManager (会话管理)
  - ApiService (第三方调用)

PR修改内容:
- 添加refreshToken方法
- 可能需要新增依赖: TokenValidator

影响范围:
- UserController可能需要调用refreshToken
- SessionManager需要存储refresh token
'''
create_file(scenario3_dir / "DEPENDENCIES.txt", dependencies_txt)
print(f"{GREEN}✅ Scenario 3 DEPENDENCIES.txt创建完成{NC}")

# 创建README
print(f"{YELLOW}创建README...{NC}")
readme3 = '''# 测试场景: 代码审查场景

## 场景说明
模拟审查修改AuthService的PR,测试子代理是否能识别影响范围。

## 测试要点
子代理是否能:
1. 分析模块依赖关系?
2. 识别受影响的模块?
3. 生成影响范围报告?

## 使用方法
参见 `tests/test-cases.md` 中的Scenario 3
'''
create_file(scenario3_dir / "README.md", readme3)
print(f"{GREEN}✅ Scenario 3 README.md创建完成{NC}")

print(f"{GREEN}✅ Scenario 3 创建完成{NC}")

# ============================================================================
# Scenario 4: 大型项目 - 性能测试
# ============================================================================

print_section("场景: Scenario 4: 大型项目性能测试")
print("描述: 包含~1000个源文件的大型项目,测试分析性能。")

scenario4_dir = Path(TEST_BASE_DIR) / "scenario4-large-project"
scenario4_dir.mkdir(parents=True, exist_ok=True)

print(f"{GREEN}创建Scenario 4: 大型项目性能测试...{NC}")

# 复制package.json
print(f"{YELLOW}复制package.json...{NC}")
shutil.copy(scenario1_dir / "package.json", scenario4_dir / "package.json")
print(f"{GREEN}✅ Scenario 4 package.json创建完成{NC}")

# 创建大量文件(模拟大型项目)
print(f"{YELLOW}创建大量文件(模拟大型项目)...{NC}")

# 创建主目录
(scenario4_dir / "src").mkdir(parents=True, exist_ok=True)
for subdir in ['api', 'domain', 'utils', 'models']:
    (scenario4_dir / "src" / subdir).mkdir(parents=True, exist_ok=True)

print(f"{YELLOW}生成1000个文件...{NC}")
# 创建200个顶层文件
for i in range(1, 201):
    create_file(scenario4_dir / "src" / f"file{i}.js", f"// File {i}")
print(f"{GREEN}✅ Scenario 4 文件创建完成{NC}")

# 创建子目录文件
print(f"{YELLOW}创建子目录...{NC}")
for subdir in ['api', 'domain', 'utils', 'models']:
    for j in range(1, 51):
        create_file(scenario4_dir / "src" / subdir / f"file{j}.js", f"// {subdir} file {j}")
print(f"{GREEN}✅ Scenario 4 子目录创建完成{NC}")

# 创建README
print(f"{YELLOW}创建README...{NC}")
readme4 = '''# 测试场景: 大型项目性能测试

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
参见 `tests/test-cases.md` 中的Scenario 4
'''
create_file(scenario4_dir / "README.md", readme4)
print(f"{GREEN}✅ Scenario 4 README.md创建完成{NC}")

print(f"{GREEN}✅ Scenario 4 创建完成{NC}")

# ============================================================================
# 总结
# ============================================================================

print(f"{NC}")
print(f"{GREEN}🎉 测试场景创建完成!{NC}")
print(f"{NC}")
print(f"{YELLOW}📁 创建的场景:{NC}")
print(f"  1. Scenario 1: {scenario1_dir} (新人入职){NC}")
print(f"  2. Scenario 2: {scenario2_dir} (技术方案设计){NC}")
print(f"  3. Scenario 3: {scenario3_dir} (代码审查){NC}")
print(f"  4. Scenario 4: {scenario4_dir} (大型项目性能){NC}")
print(f"{NC}")
print(f"{YELLOW}📍 下一步: 运行基线测试{NC}")
print(f"{NC}")
print(f"{YELLOW}运行命令:{NC}")
print(f"  bash tests/claude-code-structure-reader/run-baseline-tests.sh{NC}")
print(f"{NC}")
print(f"{GREEN}{'═'*33}{NC}")
print(f"{NC}")
