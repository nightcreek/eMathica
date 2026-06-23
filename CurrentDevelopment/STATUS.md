# Current Development — 开发状态

> 当前正在开发的内容。

---

## eMathica Core

### 活跃开发模块

| Module | Priority | Notes |
|--------|----------|-------|
| Plane | **Active** | 平面几何交互的核心模块。39 个源文件，包含交互、服务、工具、视图层。当前开发重点：几何依赖系统、语义预览、采样质量策略。 |
| Space | Active | 3D 空间解析。9 个源文件。当前开发重点：几何解析器、命中测试、线框渲染。 |
| Input System | Active | 基于 EMathicaMathInputKit 的键盘输入系统。包含公式解析引擎、状态管理、序列化。 |
| Object Panel | Active | 通过 EMathicaWorkspaceKit 实现的对象面板、检查器、工具管理。 |
| Preview System | Active | LaTeX 预览渲染、图形预览。LatexRenderService 协议 + EMathicaMathRenderService / TextSubstitutionRenderService 实现。 |
| CoreHome | Stable | 主屏幕 UI 基本稳定。项目画廊、背景动画、响应式布局。 |
| PluginSystem | Stable | 插件协议定义。当前仅定义接口，无插件加载运行时。 |
| Modeling | Placeholder | 建模模块处于占位阶段，基本 UI 框架就绪。 |
| Music | Placeholder | 音乐模块处于占位阶段。 |
| Notes | Placeholder | 公式笔记处于占位阶段。 |

### 代码库清理（Phase 1 — 已完成）

从 Core 中移除了 18 个属于 OpenMathInk Collector 的重复文件：
- 8 个 State/ 文件（含 KeyboardShortcutManager、UndoRedoManager）
- 7 个 FeatureUtilities/ 文件（Handwriting、Files、Preview）
- 1 个 App/ 入口文件
- 1 个 SharedUI/ 组件
- 1 个根目录文档

**结果：** Core 不再包含 Collector 代码。

---

## OpenMathInk Collector

### 活跃开发模块

| Module | Priority | Notes |
|--------|----------|-------|
| Handwriting Collection | **Active** | PencilKit 画布集成。支持 Apple Pencil 手写输入、笔触管理。 |
| Formula Labeling | Active | 公式标注流程。支持 LaTeX 输入、样本标注、状态管理。 |
| Data Export | Active | 数据集打包导出。DatasetPackageBuilder 构建标准格式的数据包。 |
| Consent Flow | Active | 贡献者同意书管理、隐私声明、合规流程。 |
| Undo/Redo | Active | 基于 UndoRedoManager 的撤销/重做系统。 |

### 代码库对齐（Phase 1 — 已完成）

- 从 Core 接收 `KeyboardShortcutManager.swift`（Collector 先前缺失的文件）
- 确认所有 31 个 Collector 源文件完整

---

## Shared Libraries

### 包状态

| Package | Status | Notes |
|---------|--------|-------|
| EMathicaMathCore | Active | 76 个源文件。代数、CAS、求值、图形、采样引擎。跨平台（iOS + macOS）。 |
| EMathicaDocumentKit | Active | 11 个源文件。文档模型、项目元数据、文件 I/O 层。 |
| EMathicaMathInputKit | Active | 9 个源文件。公式键盘输入。InputCore 无 UI 依赖，InputUI 含 SwiftUI 键盘视图。 |
| EMathicaThemeKit | Active | 10 个源文件。颜色令牌、玻璃态组件。跨平台。 |
| EMathicaWorkspaceKit | Active | 61 个源文件。工作区基础设施。Commands、Tools、Input、Inspector、ObjectPanel、Toolbar、History。 |

---

## 基础设施

| Item | Status | Notes |
|------|--------|-------|
| Xcode 项目 | 已修复 | Package 相对路径从 `../../Packages/` 更正为 `../Packages/` |
| 包依赖关系 | 已验证 | 所有 5 个包引用指向正确的本地路径 |
| Core 源码引用 | 零残留 | Phase 1 后无 Collector 类型残留 |
