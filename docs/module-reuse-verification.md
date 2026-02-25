# 模块复用设计功能 - 验证清单

## ✅ 实现检查

### 已创建的文件

1. **新技能**
   - ✅ `skills/design-with-existing-modules/SKILL.md`
   - 包含完整的技能定义和实施指南

2. **修改的技能**
   - ✅ `skills/brainstorming/SKILL.md`
   - 在 Part 2A 和 Part 2B 前添加了模块复用检查提示

3. **文档**
   - ✅ `docs/feature-module-reuse-design.md`
   - 包含功能说明、使用场景、格式示例

## 🧪 验证步骤

### 1. 验证技能加载

在 Claude Code 中测试：

```
你能看到 design-with-existing-modules 技能吗？
```

**预期结果:** Claude 应该能够识别并描述该技能

### 2. 验证集成

触发 brainstorming 技能：

```
帮我设计一个用户头像上传功能
```

**预期流程:**
1. brainstorming 首先询问文档健康状态
2. 完成 Part 1 (Business Requirements)
3. 在 Part 2A 前提示使用 design-with-existing-modules
4. 分析现有 UserService，发现可以改造
5. 在设计文档中标记为 🔧 MODIFY

### 3. 完整工作流测试

```bash
# Step 1: 生成项目分析文档
claude -p "使用 superpowers:code-structure-reader 分析这个项目"

# Step 2: 设计新功能
claude -p "帮我设计一个订单退款功能，使用 brainstorming 技能"
```

**预期结果:**
- 读取 docs/project-analysis/ 目录
- 检查是否有现有退款相关模块
- 决定是复用/改造/新增
- 在设计文档中标注决策
- 更新对应的项目文档

## 📋 决策矩阵

| 相似度 | 决策 | 示例 |
|--------|------|------|
| 95-100% | ✅ REUSE | 现有的登出功能完全满足需求 |
| 60-94% | 🔧 MODIFY | UserService 70% 匹配，添加头像功能 |
| 0-59% | ➕ CREATE NEW | 无退款功能，需要新建 RefundService |

## 📝 设计文档检查清单

设计文档中的"模块复用分析"章节应该包含：

- [ ] ✅ REUSED MODULES 部分（如有）
  - [ ] 模块名称和来源
  - [ ] 决策理由
  - [ ] 集成方式

- [ ] 🔧 MODIFIED MODULES 部分（如有）
  - [ ] 现有功能描述
  - [ ] 改造方案（从什么到什么）
  - [ ] 详细变更列表
  - [ ] 影响分析

- [ ] ➕ NEW MODULES 部分（如有）
  - [ ] 新增理由
  - [ ] 功能描述
  - [ ] 集成点说明

## 🔗 文档更新检查清单

对于 MODIFY 或 CREATE NEW 的模块，检查是否更新了：

- [ ] `01-frontend-components.md` - 前端组件
- [ ] `02-backend-apis.md` - 后端接口
- [ ] `03-backend-domains.md` - 领域模型
- [ ] `04-database-schemas.md` - 数据库架构
- [ ] `08-code-relations.md` - 代码关系（如适用）

## ⚠️ 常见问题

### Q1: 如果项目没有 docs/project-analysis/ 怎么办？

**A:** brainstorming 会先询问是否更新文档。如果选择"Documentation needs update"，会先运行 code-structure-reader。

### Q2: 可以跳过模块复用检查吗？

**A:** 可以。这只是 best practice，不是强制要求。但如果跳过，可能会错失复用机会。

### Q3: 如果我不确定是复用还是新建怎么办？

**A:** 选择更保守的方案。如果相似度在 60-94% 之间，优先考虑改造；< 60% 时选择新建。

### Q4: 文档更新的格式在哪里定义？

**A:** 在 `design-with-existing-modules` 技能的 "Step 4: Update Project Documentation" 部分有详细格式说明。

## 🎯 实际效果预期

使用这个功能后，您应该能够：

1. **减少重复代码**
   - 发现并复用现有模块
   - 避免重复实现相同功能

2. **提高设计质量**
   - 基于现有架构进行设计
   - 保持代码风格一致性

3. **节省开发时间**
   - 复用: 节省 80-100% 开发时间
   - 改造: 节省 30-50% 开发时间
   - 新增: 清楚知道为什么必须新建

4. **保持文档准确**
   - 文档与代码同步更新
   - 降低维护成本

## 📞 技术支持

如果遇到问题：

1. 查看技能文档：`skills/design-with-existing-modules/SKILL.md`
2. 查看功能说明：`docs/feature-module-reuse-design.md`
3. 运行测试：参考 `tests/claude-code/` 中的测试用例
