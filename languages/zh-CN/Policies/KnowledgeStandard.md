# eMathica Knowledge Standard v1.1

> 知识管理标准，适用于人类开发者和 AI 辅助开发。

⸻

## 概述

本文档定义了 eMathica 生态系统的知识管理策略。

目标是降低维护成本、消除重复信息，并让项目对长期 AI 辅助开发（Vibe Coding）友好。

⸻

## 核心原则

### 1. 知识优先（Knowledge First）

仓库应该管理**知识**，而不是管理**文档**。

Markdown 文件只是知识的一种表现形式。

真正的目标是确保每一条重要的知识都有一个清晰且权威的归属地。

### 2. 文档预算（Documentation Budget）

每个仓库应当有意识限制永久文档的数量。

文档的增长速度应当远慢于源码的增长速度。

创建新的 Markdown 文件之前，首先要确定信息是否可以整合到现有文档中。

长期目标参考：

| 仓库 | 建议规模 |
|------|----------|
| Hub | 最小化门户文档 |
| Core | 仓库概述 + 模块文档 |
| Collector | 仓库概述 + 模块文档 |
| SharedLibraries | 每个包一个 README |
| Dataset | 仅数据使用者需要的文档 |

### 3. 仓库描述现在（Repositories Describe the Present）

文档应该描述项目**当前**的状态。

不要记录开发过程的历史。

GitHub 已经保存了历史（PR、Issue、Commit）。

### 4. 每个知识有唯一归属（One Canonical Location）

同一条信息不应该在多个仓库中维护。

示例：

| 知识 | 归属 |
|------|------|
| Plane 设计 | eMathica Core |
| Collector 架构 | OpenMathInk Collector |
| 共享包文档 | SharedLibraries |
| 数据集规范 | OpenMathInk Dataset |
| 生态系统哲学 | eMathica Hub |

Hub 可以介绍这些项目，但不应该重复它们的文档。

### 5. 文档为下一个开发者存在（Documentation for the Next Developer）

文档是为了帮助下一个开发者理解项目，而不是记录昨天发生了什么。

⸻

## 文档层级（Documentation Layers）

文档体系分为四层：

**Layer 1 — Hub**

生态系统门户。回答：
- 什么是 eMathica？
- 为什么存在？
- 包含哪些仓库？
- 如何参与？

**Layer 2 — Repository**

每个仓库只保留描述自身状态的文档。

推荐永久文件：`README.md`、`STATUS.md`、`ROADMAP.md`

**Layer 3 — Module**

每个重要模块应包含一个 `README.md`，解释：
- 目的
- 职责
- 公开接口
- 依赖
- 设计约束

**Layer 4 — GitHub**

GitHub 负责保存开发历史（PR、Issue、Discussion、Commit）。

⸻

## 文档分类（Documentation Classification）

### 永久文档（Permanent）

长期保留。包括：

- README
- STATUS
- ROADMAP
- Module README
- 长期有效的技术规范

### 临时文档（Temporary）

工作完成后不应保留。包括：

- 阶段报告
- 审计报告
- 清理报告
- 迁移报告
- 临时规划文档
- AI 中间报告

这些文档在开发过程中有价值，但完成后应移除。

GitHub 已经通过 PR、Issue 和 Commit 保存了这些历史。

⸻

## 文档生命周期（Documentation Lifecycle）

知识会随着时间变化。

每个文档应有清晰的生命周期：

```
想法
  ↓
讨论
  ↓
提案
  ↓
实现
  ↓
稳定知识（永久文档）
  ↓
归档（Git 历史 / Archive 目录）
```

临时规划文档不应成为永久的仓库文件。

⸻

## 创建新文件的检查清单

在添加任何新文档之前，回答以下问题：

1. **这是长期知识吗？**
   - 如果不是 → 使用 GitHub（PR、Issue、Discussion）

2. **现有文档是否已经描述了此主题？**
   - 如果是 → 更新现有文档

3. **这个内容属于其他仓库吗？**
   - 文档应跟随代码归属

4. **真的需要新文件吗？**
   - 创建新 Markdown 文件始终是最后选项

> **创建新 Markdown 文件的成本总是高于改进现有文档。**
> 在决定新建之前，请先考虑：能否合并到现有 README？能否添加到 STATUS？能否用代码注释替代？

⸻

## AI 辅助知识管理原则

文档系统同时为人类和 AI 设计。

AI 开发时应遵循：

1. **先读 README，再读源码。**
2. **优先更新现有文档，而不是创建新文件。**
3. **仅在描述项目当前状态时生成永久文档。**
4. **绝不将历史报告作为永久仓库文件。**

⸻

## 文档所有权

每个文档应跟随代码的归属。

| 主题 | 归属仓库 |
|------|----------|
| Plane 几何模块 | eMathica Core |
| Space 空间模块 | eMathica Core |
| WorkspaceKit 工作区 | SharedLibraries |
| MathCore 数学引擎 | SharedLibraries |
| Collector 采集管线 | OpenMathInk Collector |
| 数据集格式 | OpenMathInk Dataset |
| 项目哲学与愿景 | eMathica Hub |

Hub 介绍仓库。仓库拥有自己的知识。

⸻

## 长期目标

文档体系应保持多年稳定。

新的贡献者——或新的 AI 会话——应通过阅读少量精心维护的文档就能理解整个项目。

- 仓库描述当前项目
- GitHub 保存历史
- 每条知识有唯一归属
- 创建新文档的成本总是高于改进现有文档

⸻

> eMathica Knowledge Standard v1.1 · 适用于整个 eMathica 生态系统
