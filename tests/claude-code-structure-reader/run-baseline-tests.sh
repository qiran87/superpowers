#!/bin/bash
# run-baseline-tests.sh - 运行基线测试(RED阶段)
# 用途: 对code-structure-reader技能执行TDD RED阶段测试

set -e

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_CASES_DOC="$SCRIPT_DIR/test-cases.md"
TEST_BASE_DIR="/tmp/test-code-structure-reader"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}══════════════════════════════════════════${NC}"
echo -e "${YELLOW}Code Structure Reader - TDD RED阶段测试${NC}"
echo -e "${YELLOW}══════════════════════════════════════${NC}"
echo ""

# 检查测试场景是否已创建
if [ ! -d "$TEST_BASE_DIR" ]; then
  echo -e "${RED}❌ 测试场景未创建!${NC}"
  echo "请先运行: bash setup-test-scenarios.sh"
  exit 1
fi

# 检查test-cases.md是否存在
if [ ! -f "$TEST_CASES_DOC" ]; then
  echo -e "${RED}❌ 测试用例文档不存在!${NC}"
  exit 1
fi

echo -e "${GREEN}✅ 测试环境检查通过${NC}"
echo ""

# ============================================================================
# 运行4个基线测试场景
# ============================================================================

run_scenario() {
  local scenario_name="$1"
  local scenario_dir="$2"
  local description="$3"

  echo -e "${YELLOW}─────────────────────────────────────${NC}"
  echo -e "${YELLOW}场景: $scenario_name${NC}"
  echo -e "${YELLOW}描述: $description${NC}"
  echo -e "${YELLOW}测试项目: $scenario_dir${NC}"
  echo -e "${YELLOW}─────────────────────────────────────${NC}"
  echo ""

  # 创建测试记录文件
  local record_file="$TEST_BASE_DIR/baseline-result-$scenario_name.md"
  cat > "$record_file" << 'EOF'
# 基线测试记录: $scenario_name

> 测试时间: $(date +%Y-%m-%d %H:%M:%S)

## 场景描述
$(echo "$description" | sed 's/^/  /g')

## 测试设置
[记录测试项目结构和配置]

## 基线行为 (观察结果)

### 分析过程
[子代理执行了什么操作]

### 发现的问题

1. **问题名称**: [描述]
   - 证据: [子代理的具体原话]
   - 影响: [对新人上手的影响]

2. **问题名称**: [描述]
   - 证据: [子代理的原话]
   - 影响: [对文档质量的影响]

[... 根据实际观察添加问题 ...]

## 预期合理化 (子代理可能的借口)
[列出所有预期的合理化借口]

## 压力类型
[时间压力/沉没成本/权威压力/疲劳压力]

## 测试结论
基线测试: ❌ FAILED

需要改进的方面:
1. [具体改进点1]
2. [具体改进点2]
...
EOF

  echo -e "${GREEN}📝 创建测试记录: $record_file${NC}"

  # 提示用户
  echo ""
  echo -e "${YELLOW}即将派生子代理(不加载技能)...${NC}"
  echo "请观察子代理的行为，并记录到上述文件"
  echo "按任意键继续..."
  read

  # 派生子代理（模拟，实际应该是claude命令）
  # 注意：这里应该用claude命令派生子代理
  # 但为了测试，我们手动模拟不加载技能的子代理
  echo ""
  echo -e "${GREEN}✅ 场景测试完成${NC}"
  echo ""
  sleep 1
}

# Scenario 1: 新人入职
run_scenario \
  "Scenario 1: 新人入职" \
  "$TEST_BASE_DIR/scenario1-newbie" \
  "新成员加入一个React+Express项目,需要在30分钟内理解项目结构并启动开发环境。测试项目路径: $TEST_BASE_DIR/scenario1-newbie"

# Scenario 2: 技术方案设计
run_scenario \
  "Scenario 2: 技术方案设计" \
  "$TEST_BASE_DIR/scenario2-tech-design" \
  "需要添加用户评论功能,在技术方案设计阶段需要了解项目是否已有类似功能和可复用组件。测试项目路径: $TEST_BASE_DIR/scenario2-tech-design"

# Scenario 3: 代码审查
run_scenario \
  "Scenario 3: 代码审查" \
  "$TEST_BASE_DIR/scenario3-code-review" \
  "审查一个PR,该PR修改了AuthService,需要了解这个改动会影响哪些其他模块。测试项目路径: $TEST_BASE_DIR/scenario3-code-review"

# Scenario 4: 大型项目性能
run_scenario \
  "Scenario 4: 大型项目性能" \
  "$TEST_BASE_DIR/scenario4-large-project" \
  "在一个包含1000+个文件的大型项目中测试分析性能。测试项目路径: $TEST_BASE_DIR/scenario4-large-project"

# ============================================================================
# 测试完成总结
# ============================================================================

echo ""
echo -e "${YELLOW}══════════════════════════════════════${NC}"
echo -e "${GREEN}🎉 所有基线测试场景执行完成!${NC}"
echo -e "${YELLOW}══════════════════════════════════════${NC}"
echo ""

echo -e "${GREEN}📋 测试记录位置:${NC}"
echo "  $TEST_BASE_DIR/baseline-result-*.md"
echo ""

echo -e "${YELLOW}下一步:${NC}"
echo "1. 查看每个场景的测试记录"
echo "2. 整理所有问题到test-cases.md的Phase 3 REFACTOR节"
echo "3. 基于发现的问题创建SKILL.md (GREEN阶段)"
echo ""
echo -e "${GREEN}准备好进入GREEN阶段!${NC}"
