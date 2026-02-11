#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""run-baseline-tests.py - 运行基线测试(RED阶段)
用途: 对code-structure-reader技能执行TDD RED阶段测试
"""

import os
import subprocess
from datetime import datetime
from pathlib import Path

# 配置
SCRIPT_DIR = Path(__file__).parent
TEST_CASES_DOC = SCRIPT_DIR / "test-cases.md"
TEST_BASE_DIR = Path("/tmp/test-code-structure-reader")

# ANSI颜色代码
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
NC = '\033[0m'  # No Color

def print_header():
    print(f"{YELLOW}{'='*44}{NC}")
    print(f"{YELLOW}Code Structure Reader - TDD RED阶段测试{NC}")
    print(f"{YELLOW}{'='*44}{NC}")
    print(f"{NC}")

def print_section(title):
    print(f"{YELLOW}{'-'*45}{NC}")
    print(f"{YELLOW}{title}{NC}")
    print(f"{YELLOW}{'-'*45}{NC}")
    print(f"{NC}")

def create_record_file(scenario_name, scenario_dir, description):
    """创建测试记录文件"""
    # 清理scenario_name中的特殊字符，用作文件名
    safe_name = scenario_name.replace(" ", "-").replace(":", "")
    record_file = TEST_BASE_DIR / f"baseline-result-{safe_name}.md"

    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    content = f"""# 基线测试记录: {scenario_name}

> 测试时间: {timestamp}

## 场景描述
{description}

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
"""

    with open(record_file, 'w', encoding='utf-8') as f:
        f.write(content)

    return record_file

def run_scenario(scenario_name, scenario_dir, description):
    """运行单个测试场景"""
    print_section(f"场景: {scenario_name}")
    print(f"描述: {description}")
    print(f"测试项目: {scenario_dir}")
    print(f"{NC}")

    # 创建测试记录文件
    record_file = create_record_file(scenario_name, scenario_dir, description)
    print(f"{GREEN}✅ 创建测试记录: {record_file}{NC}")

    # 提示用户
    print(f"{NC}")
    print(f"{YELLOW}═══════════════════════════════════════════════════{NC}")
    print(f"{YELLOW}手动测试指南:{NC}")
    print(f"{NC}")
    print(f"1. 打开Claude Code，在项目目录: {scenario_dir}")
    print(f"2. 使用以下提示词(不要加载code-structure-reader技能):")
    print(f"   '{scenario_name}' - 请分析这个项目的结构")
    print(f"3. 观察子代理的行为，记录:")
    print(f"   - 是否进行了系统性分析?")
    print(f"   - 生成了哪些文档?")
    print(f"   - 分析耗时多久?")
    print(f"4. 将观察结果填写到: {record_file}")
    print(f"{NC}")
    print(f"{YELLOW}═══════════════════════════════════════════════════{NC}")
    print(f"{NC}")

    # 询问是否继续
    user_input = input(f"{YELLOW}按Enter继续下一个场景，或输入'skip'跳过: {NC}")
    print(f"{NC}")

    return user_input.lower() != 'skip'

# 检查测试场景是否已创建
if not TEST_BASE_DIR.exists():
    print(f"{RED}❌ 测试场景未创建!{NC}")
    print("请先运行: python3 setup-test-scenarios.py")
    exit(1)

# 检查test-cases.md是否存在
if not TEST_CASES_DOC.exists():
    print(f"{RED}❌ 测试用例文档不存在!{NC}")
    exit(1)

print_header()
print(f"{GREEN}✅ 测试环境检查通过{NC}")
print(f"{NC}")

# ============================================================================
# 运行4个基线测试场景
# ============================================================================

scenarios = [
    (
        "Scenario 1: 新人入职",
        TEST_BASE_DIR / "scenario1-newbie",
        "新成员加入一个React+Express项目,需要在30分钟内理解项目结构并启动开发环境。"
    ),
    (
        "Scenario 2: 技术方案设计",
        TEST_BASE_DIR / "scenario2-tech-design",
        "需要添加用户评论功能,在技术方案设计阶段需要了解项目是否已有类似功能和可复用组件。"
    ),
    (
        "Scenario 3: 代码审查",
        TEST_BASE_DIR / "scenario3-code-review",
        "审查一个PR,该PR修改了AuthService,需要了解这个改动会影响哪些其他模块。"
    ),
    (
        "Scenario 4: 大型项目性能",
        TEST_BASE_DIR / "scenario4-large-project",
        "在一个包含1000+个文件的大型项目中测试分析性能。"
    ),
]

for i, (scenario_name, scenario_dir, description) in enumerate(scenarios, 1):
    print(f"{GREEN}{'═'*44}{NC}")
    print(f"{GREEN}场景进度: {i}/{len(scenarios)}{NC}")

    should_continue = run_scenario(scenario_name, scenario_dir, description)

    if not should_continue:
        print(f"{YELLOW}⏭️ 跳过剩余场景{NC}")
        break

# ============================================================================
# 测试完成总结
# ============================================================================

print(f"{NC}")
print(f"{YELLOW}{'='*44}{NC}")
print(f"{GREEN}🎉 基线测试指南生成完成!{NC}")
print(f"{YELLOW}{'='*44}{NC}")
print(f"{NC}")

print(f"{GREEN}📋 测试记录位置:{NC}")
print(f"  {TEST_BASE_DIR}/baseline-result-*.md")
print(f"{NC}")

print(f"{YELLOW}下一步:{NC}")
print(f"1. 按照上述指南手动测试每个场景")
print(f"2. 查看每个场景的测试记录")
print(f"3. 整理所有问题到test-cases.md的Phase 3 REFACTOR节")
print(f"4. 基于发现的问题更新SKILL.md (GREEN阶段)")
print(f"{NC}")
print(f"{GREEN}准备好进入GREEN阶段!{NC}")
print(f"{NC}")
