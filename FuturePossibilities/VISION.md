# Future Possibilities — 未来可能性

> **This document describes possibilities, not commitments.**
>
> 本文档描述未来可能发展的方向，不代表开发承诺或时间计划。
>
> 所有内容均由社区讨论和项目发展决定。

---

## Community

eMathica 的社区生态是一个长期愿景。当前项目处于早期阶段，社区功能尚未启动。

**可能的方向：**
- 用户社区 — 数学创作分享、交流
- 贡献者指南 — 让外部开发者参与
- 插件生态 — 基于 PluginSystem 的第三方扩展

**当前状态：** 未开发。保留为未来可能性。

---

## Dataset

OpenMathInk Dataset 是计划中的开源数学手写数据集。

**可能的方向：**
- 基于 OpenMathInk Collector 采集的手写数据
- 标准化格式
- 学术研究用途
- 公开许可

**当前状态：** 规划中。仓库占位已创建。

---

## eMathica Music

Music 模块当前处于占位阶段。

**可能的未来方向：**
- MIDI 编辑
- 音乐理论计算
- 数学与音乐的联系（频率、和声、节奏）
- 可视化音频

**当前状态：** 占位 UI 存在，功能未开发。

---

## eMathica for Modeling

Modeling 模块当前处于占位阶段。

**可能的未来方向：**
- 数学建模环境
- 统计分析
- 数据可视化
- 参数化建模

**当前状态：** 占位 UI 存在，功能未开发。

---

## Professional Branches

可能发展为更专业的数学分支工具。

**可能的领域：**
- 高等教育数学
- 工程计算
- 科研可视化
- 数学教育

**当前状态：** 尚未评估。

---

## Shared Libraries Independence

当前 5 个包在单一 `SharedLibraries` 目录中。

**未来可能独立分拆的包：**
| Package | Independence Potential | Reason |
|---------|----------------------|--------|
| EMathicaMathInputKit | **Highest** | 无外部依赖。可被任何 iOS/macOS 数学应用独立使用。 |
| EMathicaMathCore | High | 数学引擎核心，无依赖。但当前与 Core 深度集成。 |
| EMathicaThemeKit | High | 独立主题系统。需要抽象化以消除对 eMathica 的隐含依赖。 |
| EMathicaDocumentKit | Medium | 依赖 MathCore。需创建独立版本。 |
| EMathicaWorkspaceKit | Medium | 依赖多个包。拆分需要更多工作。 |

---

## AI

当前不计划接入在线 AI 服务。AI 目录仅用于开发记录。

**可能的未来方向（非当前计划）：**
- 本地数学识别
- 手写识别模型优化
- 公式自动补全

**当前状态：** 不开发。仅在 AI/ 目录中保留开发记录。
