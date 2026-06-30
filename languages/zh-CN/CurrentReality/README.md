# Current Reality

> 本文档描述 eMathica 生态系统中**当前真实存在**的项目和结构。

它不是未来规划，也不是临时审计报告。

## 当前 workspace 结构

| 目录 | 角色 | 当前说明 |
|------|------|----------|
| `eMathica/` | 主应用 | eMathica 主 app，App shell + Plane + HomeFeature consumption |
| `SharedLibraries/` | 共享包根目录 | 当前真实物理 package root，包含 6 个 SwiftPM 包 |
| `OpenMathInkCollector/` | 采集工具 | 手写数据采集与标注应用 |
| `OpenMathInkDataset/` | 数据集 | 开源数学手写数据集（规划中） |
| `eMathica-Hub/` | 入口门户 | 项目导航、哲学、当前状态、仓库索引 |

## eMathica Core

**Status:** In Development

**Current Focus:**

| Area | Description |
|------|-------------|
| Plane | 平面几何与函数绘图，仍是主开发模块 |
| Space | 3D 几何骨架与后续扩展 |
| Home | 已迁入 `SharedLibraries/EMathicaHomeFeature` |
| PluginSystem | 插件协议定义层 |

**Shared packages:**

- `EMathicaMathCore`
- `EMathicaDocumentKit`
- `EMathicaThemeKit`
- `EMathicaMathInputKit`
- `EMathicaWorkspaceKit`
- `EMathicaHomeFeature`

**Current boundary:**

- `SharedLibraries/` 是当前真实物理 package root
- `Packages/shared/`、`Packages/emathica-only/`、`Packages/openmathink-only/` 只是 future target
- `ProjectPreviewRenderer` 和 `LocalProjectStore` 仍属于 app-private 边界

## OpenMathInk Collector

**Status:** In Development

**Current Focus:**

| Area | Description |
|------|-------------|
| Handwriting | PencilKit 采集与笔触管理 |
| Keyboard Input | 数学公式输入 |
| File Management | 样本与导出文件管理 |
| Preview | LaTeX 预览 |
| State | 工作区状态、设置、撤销/重做 |

**Domain Models:**

- `MathInkSample`
- `SampleStatus`
- `DatasetManifest`
- `ContributorConsent`
