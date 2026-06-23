# Current Reality

> 本文档描述 eMathica 生态系统中**当前真实存在**的项目和状态。
>
> 不是未来规划，不是未来梦想，不是可能性。

---

## eMathica Core

**Status:** In Development

**Source:** `Projects/eMathica/`

**Current Focus:**

| Module | Source Files | Description |
|--------|-------------|-------------|
| Plane | 39 | 平面几何 — 交互式几何画板、函数绘图、依赖图形 |
| Space | 9 | 空间解析 — 3D 几何体、空间坐标系 |
| Modeling | 1 | 数学建模（占位阶段） |
| Music | 1 | 音乐模块（占位阶段） |
| Notes | 1 | 公式笔记（占位阶段） |
| CoreHome | 30 | 主屏幕 UI — 项目画廊、最近项目、背景主题 |
| PluginSystem | 5 | 插件协议定义 |

**Packages (local references):**
- EMathicaMathCore — 数学引擎
- EMathicaDocumentKit — 文档模型
- EMathicaMathInputKit — 数学键盘输入
- EMathicaThemeKit — 主题系统
- EMathicaWorkspaceKit — 工作区基础设施

**Architecture:** SwiftUI app with SwiftPM packages. Uses `PBXFileSystemSynchronizedRootGroup` for Xcode project.

**Recent cleanup:** Phase 1 removed 18 duplicate files that belonged to OpenMathInk Collector.

---

## OpenMathInk Collector

**Status:** In Development

**Source:** `Projects/OpenMathInkCollector/`

**Current Focus:**

| Module | Source Files | Description |
|--------|-------------|-------------|
| Handwriting | 4 | PencilKit 手写采集 — 画布、工具、笔触 |
| Keyboard Input | 4 | 数学公式键盘输入 |
| File Management | 6 | 样本文件浏览、数据包构建、导出 |
| Preview | 2 | LaTeX 渲染预览 |
| State | 6 | 工作区状态、引导、设置、撤销/重做 |

**Domain Models:**
- MathInkSample — 数学手写样本
- SampleStatus — 样本状态机（draft / confirmed / exported）
- DatasetManifest — 数据集清单
- ContributorConsent — 贡献者同意书

---

## Shared Libraries

**Status:** Active

**Source:** `Projects/Packages/`

**Packages:**

| Package | Source Files | Dependencies | Description |
|---------|-------------|-------------|-------------|
| EMathicaMathCore | 76 | None | 数学引擎：代数、CAS、求值、图形、采样、坐标变换 |
| EMathicaDocumentKit | 11 | MathCore | 文档模型、项目元数据、文件I/O |
| EMathicaMathInputKit | 9 | None | 数学键盘输入 — 解析、引擎、序列化 |
| EMathicaThemeKit | 10 | None | 主题系统：颜色令牌、玻璃态组件、工作区主题 |
| EMathicaWorkspaceKit | 61 | MathCore, DocumentKit, ThemeKit, MathInputKit | 工作区：命令、工具、输入、检查器、对象面板 |

*All packages are currently hosted in a single directory. Future splitting is a separate discussion.*

---

## Ecosystem Structure

```
eMathica Hub/
├── Philosophy/          ← 项目理念（5 篇文档）
├── CurrentReality/      ← 本文档
├── CurrentDevelopment/  ← 正在开发
├── FuturePossibilities/ ← 未来方向
├── RepositoryIndex/     ← 仓库索引
├── CommunityVoting/     ← 社区投票
├── Assets/              ← 共享设计资源
├── Documentation/       ← 架构方案、审计报告
└── Projects/
    ├── eMathica/              ← Core 主应用
    ├── OpenMathInkCollector/  ← 采集应用
    └── Packages/              ← Shared Libraries
```

> 注意：当前 Core、Collector、Shared Libraries 都位于 `Projects/` 下，尚未扁平化为独立的一级目录。这是计划中的下一步工作。
