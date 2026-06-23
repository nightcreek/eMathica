# eMathica 生态系统本地工作区重组方案

> **状态:** 只读方案 — 未移动任何文件，未执行任何 git 命令。  
> **日期:** 2026-06-23  
> **范围:** 完整架构审计 → 本地目录重组 → Git 仓库初始化 → 迁移计划

---

## 目录

0. [当前目录审计](#0-当前目录审计)
1. [推荐本地目录结构](#1-推荐本地目录结构)
2. [推荐 GitHub 仓库结构](#2-推荐-github-仓库结构)
3. [eMathica Hub 内容结构](#3-emathica-hub-内容结构)
4. [eMathica Core 内部结构](#4-emathica-core-内部结构)
5. [OpenMathInk Collector 内部结构](#5-openmathink-collector-内部结构)
6. [Shared Libraries 分析](#6-shared-libraries-分析)
7. [仓库迁移计划](#7-仓库迁移计划)
8. [风险分析](#8-风险分析)

---

## 0. 当前目录审计

### 当前完整布局

```
/Users/night_creek/开发/eMathica Hub/
│
├── Assets/                          ← 设计资源
│   └── icon design/                 → eMathica + OpenMathInk 图标源文件
│
├── Data/                            ← 数据文件
│   ├── Ink Data/                    → 原始手写数据（空目录）
│   └── ML models/                   → CoreML .mlproj 项目
│
├── Documentation/                   ← 跨项目文档
│   ├── ADR/                        → 架构决策记录
│   ├── ARCHITECTURE/               → 架构方案（本文件所在目录）
│   ├── ARCHIVE/                    → 存档
│   ├── Automation/                 → 自动化报告
│   ├── POLICIES/                   → 政策文件
│   ├── Working/                    → 进行中的工作文档
│   └── temp/                       → 临时文件
│
├── Projects/                        ← 所有项目源码
│   │
│   ├── eMathica/                    ★ [Core] 主应用（已有 Git 仓库）
│   │   ├── .git/                    → 当前唯一的 Git 仓库
│   │   ├── eMathica/               → 应用源码 tree
│   │   │   ├── App/                → 应用入口（含 Collector 重复文件 ❌）
│   │   │   ├── CalculatorModules/  → 模块（Plane, Space, Modeling...）
│   │   │   ├── CoreHome/           → 主屏幕 UI
│   │   │   ├── Docs/               → 应用文档
│   │   │   ├── FeatureUtilities/   → 与 Collector 重复的文件 ❌
│   │   │   ├── PluginSystem/       → 插件协议
│   │   │   ├── Resources/          → Assets.xcassets
│   │   │   ├── Services/           → 业务逻辑
│   │   │   ├── SharedUI/           → 共享 UI 组件
│   │   │   ├── State/              → 混合：状态 + 视图 + 服务
│   │   │   └── AI/                 → AI 开发记录
│   │   ├── eMathica.xcodeproj/
│   │   ├── eMathicaTests/          → 50+ 单元测试
│   │   ├── eMathicaUITests/
│   │   ├── Scripts/
│   │   └── Packages/               → （空 — MathCore 已移走）
│   │
│   ├── OpenMathInkCollector/        ★ [Collector] 手写采集应用（无 Git）
│   │   └── OpenMathInkCollector/
│   │       ├── OpenMathInkCollector.xcodeproj/
│   │       ├── OpenMathInkCollector/
│   │       │   ├── App/
│   │       │   ├── Models/
│   │       │   ├── Modules/
│   │       │   ├── Shared/
│   │       │   ├── State/
│   │       │   └── Resources/
│   │       └── README.md
│   │
│   └── Packages/                    ★ [Shared Libraries] 共享 Swift 包（无 Git）
│       ├── EMathicaMathCore/
│       ├── EMathicaDocumentKit/
│       ├── EMathicaMathInputKit/
│       ├── EMathicaThemeKit/
│       └── EMathicaWorkspaceKit/
│
├── .claude/                         ← 本地 agent 配置
├── .reasonix/                       ← 本地 agent 配置
└── reasonix.toml                    ← 本地 agent 配置
```

### 目录 → 仓库映射

| 当前路径 | 归属 | 状态 | 备注 |
|---------|------|------|------|
| `Documentation/`（跨项目文档） | **Hub** | ✅ 基本就绪 | 需要筛选：Hub 仅保留跨项目文档 |
| `Assets/icon design/` | **Hub** | ✅ 就绪 | 共享设计资源 |
| `Data/Ink Data/` | 暂放 **Hub** | ⚠️ 占位 | 空目录，可删 |
| `Data/ML models/` | **Hub** 或 **Collector** | 🤔 待定 | mlproj 很小，可随 Collector |
| `Projects/eMathica/`（源码） | **Core** | ⚠️ 需清理 | 必须先移除 Collector 重复文件 |
| `Projects/OpenMathInkCollector/` | **Collector** | ⚠️ 需改名 + 重构 | 去掉空格，内部结构重组 |
| `Projects/Packages/`（5 个包） | **Shared Libraries** | ✅ 就绪 | 一个仓库，不拆分 |
| `.claude/`, `.reasonix/`, `reasonix.toml` | 本地配置 | ❌ 不入库 | 只在开发者本地 |

### 关键问题：一个目录 ≠ 一个仓库

**当前违反原则的地方：**

```
eMathica Hub/           ← 这将来是 Hub 仓库
├── Projects/
│   ├── eMathica/       ← 但 Core 的源码嵌套在 Hub 内部！
│   ├── OpenMathInk...
│   └── Packages/       ← Shared Libraries 也嵌套在内！
├── Assets/
└── Documentation/
```

**问题：** 如果当前 `eMathica Hub/` 作为 Hub 仓库初始化 git，那么 Core、Collector、Shared Libraries 的源码全都在 **同一个 git 仓库** 内—无法分别上传到不同的 GitHub 仓库。

**解决方案：** 将每个独立仓库提升为**同级目录**（扁平结构）。

---

## 1. 推荐本地目录结构

### 原则：一个目录 = 一个 Git 仓库 = 一个 GitHub 仓库

```
/Users/night_creek/开发/
│
├── eMathica-Hub/               ★ GitHub: nightcreek/eMathica
│   ├── README.md
│   ├── Philosophy/
│   ├── CurrentReality/
│   ├── CurrentDevelopment/
│   ├── FuturePossibilities/
│   ├── RepositoryIndex/
│   └── CommunityVoting/
│
├── eMathica/                    ★ GitHub: nightcreek/eMathica-Core
│   ├── eMathica.xcodeproj
│   ├── eMathica/
│   │   ├── AppShell/
│   │   ├── Features/
│   │   ├── Services/
│   │   ├── AppState/
│   │   ├── SharedUI/
│   │   ├── Resources/
│   │   └── Docs/
│   ├── Tests/
│   └── Scripts/
│
├── OpenMathInkCollector/        ★ GitHub: nightcreek/OpenMathInk-Collector
│   ├── OpenMathInkCollector.xcodeproj
│   ├── OpenMathInkCollector/
│   │   ├── AppShell/
│   │   ├── Features/
│   │   ├── DomainModels/
│   │   ├── AppState/
│   │   ├── Services/
│   │   ├── SharedUI/
│   │   └── Resources/
│   └── Tests/
│
├── OpenMathInkDataset/          ★ GitHub: nightcreek/OpenMathInk-Dataset
│   └── README.md               → 占位，仅说明
│
└── SharedLibraries/             ★ GitHub: nightcreek/SharedLibraries
    ├── EMathicaMathCore/
    ├── EMathicaDocumentKit/
    ├── EMathicaMathInputKit/
    ├── EMathicaThemeKit/
    └── EMathicaWorkspaceKit/
```

### 关键变更点

| 当前 | 目标 | 原因 |
|------|------|------|
| `Projects/eMathica/` | `eMathica/` | 扁平化，不再嵌套在 Hub 下 |
| `Projects/OpenMathInkCollector/` | `OpenMathInkCollector/` | 扁平化，去掉空格 |
| `Projects/Packages/` | `SharedLibraries/` | 独立的包仓库 |
| — | `eMathica-Hub/` | 与 Core 同级，不含业务代码 |
| — | `OpenMathInkDataset/` | 未来数据集占位 |
| `Assets/` | → `eMathica-Hub/Assets/` | 设计资源跟随 Hub |
| `Documentation/` | → `eMathica-Hub/CurrentReality/docs/` | 跨项目文档归 Hub 管 |
| `Data/` | 按内容分发 | ML models → Collector 或 Hub |

---

## 2. 推荐 GitHub 仓库结构

### GitHub 组织：`github.com/nightcreek/`

```
nightcreek/
│
├── eMathica                     ★ Hub — 门户仓库
│   ├── README.md
│   ├── Philosophy/
│   ├── CurrentReality/
│   ├── CurrentDevelopment/
│   ├── FuturePossibilities/
│   ├── RepositoryIndex/
│   └── CommunityVoting/
│
├── eMathica-Core                ★ 主应用
│   ├── eMathica.xcodeproj
│   ├── eMathica/
│   ├── Tests/
│   └── Scripts/
│
├── OpenMathInk-Collector        ★ 手写数据采集
│   ├── OpenMathInkCollector.xcodeproj
│   ├── OpenMathInkCollector/
│   └── Tests/
│
├── OpenMathInk-Dataset          ★ 未来：公开数据集
│   └── README.md
│
└── SharedLibraries              ★ 所有共享 Swift 包（暂不拆分）
    ├── EMathicaMathCore/
    │   └── Package.swift
    ├── EMathicaDocumentKit/
    │   └── Package.swift
    ├── EMathicaMathInputKit/
    │   └── Package.swift
    ├── EMathicaThemeKit/
    │   └── Package.swift
    └── EMathicaWorkspaceKit/
        └── Package.swift
```

### Hub README 示例

```markdown
# eMathica

数学创作，不止于计算。

## 仓库索引

| 仓库 | 描述 | 链接 |
|------|------|------|
| eMathica Core | 主应用 — 平⾯几何、空间解析、计算器 | https://github.com/nightcreek/eMathica-Core |
| OpenMathInk Collector | 手写数学数据采集 | https://github.com/nightcreek/OpenMathInk-Collector |
| OpenMathInk Dataset | 开源手写数据集 | https://github.com/nightcreek/OpenMathInk-Dataset |
| Shared Libraries | 共享 Swift 包 | https://github.com/nightcreek/SharedLibraries |
```

---

## 3. eMathica Hub 内容结构

### 完整目录树

```
eMathica-Hub/
│
├── README.md                       ← 项目介绍 + 仓库索引 + 快速导航
│
├── Philosophy/                     ←「为什么存在」
│   ├── WhyEMathica.md             → 为什么有 eMathica
│   ├── MathematicsAsArt.md        → 数学即艺术
│   ├── StudentCreatorsInAIEra.md  → AI 时代的学生创作者
│   └── VibeCodingReflection.md    → AI 开发反思（架构/模块边界/代码审查/技术债务）
│
├── CurrentReality/                 ← 已经存在
│   ├── README.md                  → 当前状态概述
│   ├── Architecture/
│   │   ├── Overview.md            → 系统架构概览
│   │   ├── PackageArchitecture.md → 包架构
│   │   └── RepositoryLayout.md    → 仓库布局
│   ├── docs/
│   │   ├── ADR/                   → 架构决策记录
│   │   └── POLICIES/              → 政策文件
│   └── assets/
│       └── icons/                 → 共享图标
│
├── CurrentDevelopment/             ← 正在开发
│   ├── STATUS.md                  → 开发状态
│   ├── ROADMAP.md                 → 路线图
│   └── CONTRIBUTING.md            → 贡献指南
│
├── FuturePossibilities/            ← 未来可能发展
│   ├── VISION.md                  → 长期愿景
│   ├── Community.md               → 社区发展思路（当前不开发）
│   ├── AI.md                      → AI 方向说明（当前不计划接入）
│   ├── Dataset.md                 → 数据集规划
│   └── proposals/                 → RFC / 提案
│
├── RepositoryIndex/                ← 仓库索引
│   └── README.md                  → 所有仓库列表 + URL + 描述
│
└── CommunityVoting/                ← 社区投票
    └── README.md                  → 投票机制说明（占位）
```

### README 内容顺序

```
1. What is eMathica          → 一句话定义 + 核心价值
2. Philosophy                → 为什么存在（链接到 Philosophy/）
3. Current Reality           → 当前状态（链接到 CurrentReality/）
4. Current Development       → 正在发生的（链接到 CurrentDevelopment/）
5. Future Possibilities      → 未来方向（链接到 FuturePossibilities/）
6. Repository Index          → 所有仓库列表
7. Community Voting          → 社区参与方式
```

### Philosophy 文件说明

| 文件 | 核心内容 |
|------|---------|
| `WhyEMathica.md` | GeoGebra 的启发、数学艺术、创作经历、从用户到开发者的故事 |
| `MathematicsAsArt.md` | 数学不仅是学科，也是艺术与创作媒介；eMathica 让每个人都能用数学表达 |
| `StudentCreatorsInAIEra.md` | AI 时代学生创作者的机会；eMathica 降低数学创作门槛 |
| `VibeCodingReflection.md` | AI 辅助开发的反思：架构设计决策、模块边界原则、代码审查流程、技术债务控制策略 |

---

## 4. eMathica Core 内部结构

### 最终目标

```
eMathica/                          ★ GitHub: nightcreek/eMathica-Core
│
├── README.md                     ← 应用说明 + 构建指南 + 指向 Hub 的超链接
├── .gitignore
│
├── eMathica.xcodeproj/
│
├── eMathica/                     ← 应用源码根目录
│   │
│   ├── AppShell/                 ← 应用生命周期、路由、DI
│   │   ├── EMathicaApp.swift
│   │   ├── AppRootView.swift
│   │   ├── AppNavigationState.swift
│   │   ├── AppRoute.swift
│   │   └── Infrastructure/
│   │       └── PersistenceController.swift
│   │
│   ├── Features/                 ★ 替代 CalculatorModules/
│   │   ├── CoreHome/             ← 主屏幕（来自 CoreHome/）
│   │   ├── PlaneCalculator/      ← 平面几何（来自 CalculatorModules/Plane/）
│   │   │   ├── PlaneModule.swift
│   │   │   ├── Commands/
│   │   │   ├── Interaction/
│   │   │   ├── Rendering/
│   │   │   ├── Services/
│   │   │   ├── Tools/
│   │   │   └── Views/
│   │   ├── SpaceCalculator/      ← 空间解析（来自 CalculatorModules/Space/）
│   │   ├── Modeling/             ← 建模（来自 CalculatorModules/Modeling/）
│   │   ├── Music/                ← 音乐模块（来自 CalculatorModules/Music/）
│   │   ├── NotesFormula/         ← 公式笔记（来自 CalculatorModules/Notes/）
│   │   ├── PluginSystem/         ← 插件系统（来自 PluginSystem/）
│   │   ├── CalculatorModuleRegistry.swift
│   │   └── DefaultWorkspaceModuleProvider.swift
│   │
│   ├── Services/                 ← 业务逻辑、数据访问、非 UI 服务
│   │   ├── KeyboardShortcutManager.swift
│   │   ├── LocalProjectStore.swift
│   │   └── ...
│   │
│   ├── AppState/                 ★ 全局状态管理（从 State/ 拆分）
│   │   ├── UndoRedoManager.swift
│   │   ├── CoreHomeState.swift
│   │   ├── CoreHomeUIState.swift
│   │   └── ...
│   │
│   ├── SharedUI/                 ← 共享 UI 组件
│   │   └── Components/
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   └── eMathica.xcdatamodeld/
│   │
│   ├── Docs/                     ← 应用专有文档
│   │   ├── Architecture/
│   │   ├── Plane/
│   │   ├── Testing/
│   │   └── archive/
│   │
│   └── AI/                       ← AI 开发记录（非产品功能）
│       ├── Core/
│       ├── Data/
│       ├── ProductDesign/
│       └── archive/
│
├── Tests/
│   ├── eMathicaTests/            ← 来自 eMathicaTests/
│   └── eMathicaUITests/          ← 来自 eMathicaUITests/
│
├── Scripts/                      ← 构建验证脚本
│
└── Packages/                     ← SwiftPM 本地 checkout（自动生成）
```

### 需要从 Core 删除的文件（Collector 重复）

| 文件 | 路径 | 原因 |
|------|------|------|
| `OpenMathInkCollectorApp.swift` | `eMathica/App/` | Collector 的 @main 入口 |
| `CollectorWorkspaceState.swift` | `eMathica/State/` | Collector 专有状态 |
| `ConsentFlowView.swift` | `eMathica/State/` | Collector 专有视图 |
| `ContributorConsentManager.swift` | `eMathica/State/` | Collector 专有逻辑 |
| `LocalSampleStore.swift` | `eMathica/State/` | Collector 专有数据层 |
| `OnboardingManager.swift` | `eMathica/State/` | Collector 专有管理 |
| `SettingsView.swift` | `eMathica/State/` | Collector 专有设置 |
| `FormulaLabelPreviewView.swift` | `eMathica/SharedUI/Components/` | 与 Collector 重复 |
| 整个 `FeatureUtilities/` 目录 | — | 7 个文件全部与 Collector 重复 |

**特别说明：** `UndoRedoManager.swift` 在 Core 和 Collector 中各有一份。**保留两份** — 它很小且可能各自演进。

---

## 5. OpenMathInk Collector 内部结构

### 最终目标

```
OpenMathInkCollector/              ★ GitHub: nightcreek/OpenMathInk-Collector
│
├── README.md                     ← 应用说明 + 指向 Hub 的超链接
├── .gitignore
│
├── OpenMathInkCollector.xcodeproj/
│
├── OpenMathInkCollector/         ← 应用源码
│   │
│   ├── AppShell/
│   │   ├── OpenMathInkCollectorApp.swift
│   │   └── AppRootView.swift
│   │
│   ├── Features/                 ★ 替代 Modules/
│   │   ├── HandwritingInput/     ← 手写采集
│   │   │   ├── HandwritingCanvasView.swift
│   │   │   ├── HandwritingToolbarView.swift
│   │   │   ├── DrawingToolSettings.swift
│   │   │   └── PencilDrawingRepresentable.swift
│   │   ├── KeyboardInput/        ← 数学键盘
│   │   │   ├── MathKeyboardView.swift
│   │   │   ├── MathKeyboardKey.swift
│   │   │   ├── LatexKeyboardInputView.swift
│   │   │   └── CollectorMathInputState.swift
│   │   ├── FileManagement/       ← 文件浏览、数据导出
│   │   │   ├── DatasetFileBrowserView.swift
│   │   │   ├── SampleDetailView.swift
│   │   │   ├── PrivacyNoticeView.swift
│   │   │   ├── DatasetPackageBuilder.swift
│   │   │   └── ConsentFlowView.swift   ← 从 State/ 移入
│   │   └── Preview/              ← LaTeX 预览
│   │       ├── LatexPreviewView.swift
│   │       └── LatexRenderService.swift
│   │
│   ├── DomainModels/             ★ 替代 Models/
│   │   ├── MathInkSample.swift
│   │   ├── SampleStatus.swift
│   │   ├── DatasetManifest.swift
│   │   └── ContributorConsent.swift
│   │
│   ├── AppState/
│   │   ├── CollectorWorkspaceState.swift
│   │   ├── OnboardingManager.swift
│   │   └── UndoRedoManager.swift
│   │
│   ├── Services/
│   │   ├── ContributorConsentManager.swift
│   │   ├── LocalSampleStore.swift
│   │   └── DatasetPackageBuilder.swift   ← 业务逻辑分离
│   │
│   ├── SharedUI/
│   │   ├── Components/
│   │   │   └── FormulaLabelPreviewView.swift
│   │   ├── Theme/
│   │   │   └── CollectorCardStyle.swift
│   │   └── Utilities/
│   │       └── PlatformImageLoader.swift
│   │
│   └── Resources/
│       └── Assets.xcassets/
│
├── Tests/
│   └── OpenMathInkCollectorTests/
│
└── StatisticsView.swift          ← 当前在 Core FeatureUtilities/，归 Collector
```

### Collector 内部变更总结

| 当前 | 目标 | 说明 |
|------|------|------|
| `Modules/` | `Features/` | 统一命名约定 |
| `Models/` | `DomainModels/` | 避免与 ML 模型混淆 |
| `Shared/` | `SharedUI/` | 与 Core 统一 |
| `State/`（视图类文件） | `Features/` 或 `AppState/` | 视图回归 Feature |
| `State/`（服务类文件） | `Services/` | 逻辑回归 Services |

---

## 6. Shared Libraries 分析

### 当前包状态

| 包名 | 源码数 | 依赖 | 阶段 | 未来独立？ |
|------|--------|------|------|-----------|
| **EMathicaMathCore** | ~43 个文件 | 无 | ✅ 当前 | ⭐ **首要候选** |
| **EMathicaDocumentKit** | 11 个文件 | MathCore | ✅ 当前 | ✅ 可独立 |
| **EMathicaMathInputKit** | 9 个文件 | 无 | ✅ 当前 | ✅ 可独立 |
| **EMathicaThemeKit** | 10 个文件 | 无 | ✅ 当前 | ✅ 可独立 |
| **EMathicaWorkspaceKit** | 50+ 个文件 | MathCore, DocumentKit, ThemeKit, MathInputKit | ✅ 当前 | ⚠️ 依赖多，暂缓 |

### 未来可能独立的 Package

这些属于 **Future Possibilities** — 现在不拆分，但值得提前规划接口：

| 未来包名 | 来源 | 依赖 | 说明 |
|---------|------|------|------|
| **EMathicaMathInputKit** | 已存在 | 无 | **最适合首批独立。** 无外部依赖，可被任何 iOS/macOS 数学应用复用。 |
| **EMathicaSymbolKit** | 新提取 | MathCore | 符号/记法系统。将符号渲染从 Core 中独立出来。 |
| **EMathicaCASKit** | 新提取 | MathCore | CAS 引擎的轻量封装层。如果其他项目需要 CAS 但不想要整个 MathCore。 |
| **EMathicaNotebookKit** | 新提取 | MathCore, DocumentKit | 笔记本/文档模型。可作为独立笔记应用的基础。 |
| **EMathicaAnimationKit** | 新提取 | MathCore, ThemeKit | Animation 是 Plane 和 Space 的**共享能力**，不是独立 App。提取后可避免重复。 |
| **EMathicaCollectorSharedKit** | 新提取 | MathCore, ThemeKit | 从 FeatureUtilities 提取的手写/预览/文件共享代码。 |

### 依赖关系图

```
EMathicaMathCore ────────────────────────────────────── (无依赖)
    │
    ├── EMathicaDocumentKit ─────── 依赖 MathCore
    ├── EMathicaMathInputKit ────── (无依赖)
    ├── EMathicaThemeKit ────────── (无依赖)
    │
    └── EMathicaWorkspaceKit ───── 依赖 MathCore + DocumentKit + ThemeKit + MathInputKit

(未来) EMathicaAnimationKit ────── 依赖 MathCore + ThemeKit
(未来) EMathicaNotebookKit ─────── 依赖 MathCore + DocumentKit
```

### 推荐策略

1. **当前：** 所有 5 个包放在 `SharedLibraries/` 一个仓库
2. **未来：** 当某个包（如 `EMathicaMathInputKit`）被外部项目独立使用，或需要不同发布节奏时，拆分为独立仓库
3. **接口设计原则：** 现在就在包的公共 API 上标记 `@available` / `public` 边界，为未来拆分做准备

---

## 7. 仓库迁移计划

### 总览

```
Phase 0: 准备与快照
Phase 1: 清理 Core 中的 Collector 重复文件
Phase 2: 重构 Core 内部结构
Phase 3: 重构 Collector 内部结构
Phase 4: 建立 Hub 结构
Phase 5: 扁平化目录 + 初始化 Git 仓库
Phase 6: GitHub 上传
```

---

### Phase 0: 准备与快照

**目标：** 确保在动手之前有完整备份，所有当前状态可回退。

| 步骤 | 操作 | 风险 | 验证方式 |
|------|------|------|---------|
| 0.1 | 对整个 `eMathica Hub/` 目录做快照备份 | 无 | `cp -R` 到安全位置 |
| 0.2 | 确认当前 Git 仓库状态 | 无 | `cd Projects/eMathica && git status` 无未提交变更 |
| 0.3 | 记录所有 Xcode 项目设置 | 无 | 截图或保存 pbxproj 副本 |
| 0.4 | 记录所有 Package.swift 的依赖路径 | 无 | 存档当前 5 个 Package.swift |

---

### Phase 1: 清理 Core 中的 Collector 重复文件

**目标：** Core 仓库不应包含任何 Collector 专属代码。  
**风险：** 🔴 **高** — 删除文件可能破坏 Xcode 目标引用。

| 步骤 | 操作 | 文件路径 |
|------|------|---------|
| 1.1 | 从 Xcode 项目中移除目标成员身份 | 先解除所有待删文件的 target membership |
| 1.2 | 删除 `App/OpenMathInkCollectorApp.swift` | `Projects/eMathica/eMathica/App/OpenMathInkCollectorApp.swift` |
| 1.3 | 删除 `State/` 中的 Collector 文件（6 个） | `CollectorWorkspaceState.swift`, `ConsentFlowView.swift`, `ContributorConsentManager.swift`, `LocalSampleStore.swift`, `OnboardingManager.swift`, `SettingsView.swift` |
| 1.4 | 删除整个 `FeatureUtilities/` 目录 | `Projects/eMathica/eMathica/FeatureUtilities/`（7 个文件） |
| 1.5 | 删除 `SharedUI/Components/FormulaLabelPreviewView.swift` | 与 Collector 重复 |
| 1.6 | 删除 `OPENMATHINK_COLLECTOR_FIXES.md` | Core 根目录的 Collector 文档 |
| 1.7 | 更新 Xcode pbxproj 移除所有已删文件引用 | — |
| 1.8 | ✅ **构建验证** | `xcodebuild` Core 通过 |

**注意：** `UndoRedoManager.swift` 在 Core 和 Collector 中各保留一份，不删除。

---

### Phase 2: 重构 Core 内部结构

**目标：** 将 Core 从当前布局转换为目标布局。  
**风险：** 🟡 中 — 目录重命名需要同步更新 Xcode 引用。

| 步骤 | 操作 | 说明 |
|------|------|------|
| 2.1 | `App/` → `AppShell/` | 目录重命名，更新 Xcode 文件夹引用 |
| 2.2 | `CalculatorModules/` → `Features/` | 目录重命名 |
| 2.3 | `CalculatorModules/Plane/` → `Features/PlaneCalculator/` | 子目录重命名 |
| 2.4 | `CalculatorModules/Space/` → `Features/SpaceCalculator/` | 子目录重命名 |
| 2.5 | `CalculatorModules/Notes/` → `Features/NotesFormula/` | 子目录重命名 |
| 2.6 | 创建 `AppState/` + `Services/` | 从 `State/` 拆分：`KeyboardShortcutManager.swift` → `Services/`，`UndoRedoManager.swift` → `AppState/` |
| 2.7 | 搬移测试目录 | `eMathicaTests/` → `Tests/eMathicaTests/`，`eMathicaUITests/` → `Tests/eMathicaUITests/` |
| 2.8 | ✅ **构建测试验证** | Core 编译通过，所有测试通过 |

---

### Phase 3: 重构 Collector 内部结构

**目标：** 将 Collector 从当前布局转换为目标布局。  
**风险：** 🟢 低 — Collector 无外部依赖。

| 步骤 | 操作 | 说明 |
|------|------|------|
| 3.1 | `Models/` → `DomainModels/` | 目录重命名 |
| 3.2 | `Modules/` → `Features/` | 目录重命名 |
| 3.3 | `Modules/Handwriting/` → `Features/HandwritingInput/` | 子目录重命名 |
| 3.4 | `Modules/Files/` → `Features/FileManagement/` | 子目录重命名 |
| 3.5 | `Shared/` → `SharedUI/` | 目录重命名 |
| 3.6 | 拆分 `State/`：`OnboardingManager` → `AppState/`，`ContributorConsentManager` → `Services/`，`ConsentFlowView` → `Features/FileManagement/` | 状态与视图分离 |
| 3.7 | ✅ **构建验证** | Collector 独立编译通过 |

---

### Phase 4: 建立 Hub 结构

**目标：** 创建 eMathica-Hub 仓库，包含 Philosophy、仓库索引等全部内容。  
**风险：** 🟢 低 — 只有 Markdown 文件。

| 步骤 | 操作 | 说明 |
|------|------|------|
| 4.1 | 从当前 Hub 根复制所需文档到 `CurrentReality/` | 筛选跨项目文档 |
| 4.2 | 创建 `Philosophy/` 目录 | 写入 4 个 Philosophy 文件 |
| 4.3 | 创建 `CurrentReality/` 目录 | 架构文档、ADR、政策 |
| 4.4 | 创建 `CurrentDevelopment/` 目录 | 状态、路线图、贡献指南 |
| 4.5 | 创建 `FuturePossibilities/` 目录 | 愿景、AI 说明、社区规划 |
| 4.6 | 创建 `RepositoryIndex/` 目录 | 所有仓库列表 + URL |
| 4.7 | 创建 `CommunityVoting/` 目录 | 占位 |
| 4.8 | 写入 `README.md` | 按指定顺序组织内容 |
| 4.9 | 移动 `Assets/icon design/` 到 `eMathica-Hub/Assets/` | 共享设计资源 |

---

### Phase 5: 扁平化目录 + 初始化 Git 仓库

**核心操作：** 这是改变目录结构的关键阶段。需要将嵌套在 `Projects/` 下的仓库移到顶级。

**风险：** 🔴 **高** — 需要更新 Xcode 项目中的文件引用路径、Package.swift 中的相对路径。

| 步骤 | 操作 | 详细说明 |
|------|------|----------|
| 5.1 | 创建 `eMathica-Hub/`（顶级） | 将 Hub 内容从当前根目录移入 |
| 5.2 | 移动 `Projects/eMathica/` → `eMathica/`（顶级） | ⚠️ 更新 Xcode 项目设置中的 Source Root 路径 |
| 5.3 | 移动 `Projects/OpenMathInkCollector/` → `OpenMathInkCollector/`（顶级） | 去除中间嵌套层级 |
| 5.4 | 移动 `Projects/Packages/` → `SharedLibraries/`（顶级） | 重命名 |
| 5.5 | 创建 `OpenMathInkDataset/` | 仅 README.md |
| 5.6 | 更新 Package.swift 依赖路径 | 所有相对路径指向新的 `../SharedLibraries/` |
| 5.7 | 更新 Xcode pbxproj 引用路径 | — |
| 5.8 | ✅ **两个应用构建验证** | Core 和 Collector 都编译通过 |

**Git 初始化：**

| 步骤 | 操作 | .gitignore |
|------|------|-----------|
| 5.9 | `cd eMathica-Hub && git init` | `.DS_Store`, `.reasonix/`, `.claude/` |
| 5.10 | `cd eMathica && git init` | `.build/`, `xcuserdata/`, `DerivedData/`, `.DS_Store` |
| 5.11 | `cd OpenMathInkCollector && git init` | `.build/`, `xcuserdata/`, `.DS_Store` |
| 5.12 | `cd SharedLibraries && git init` | `.build/`, `.swiftpm/`, `.DS_Store` |
| 5.13 | `cd OpenMathInkDataset && git init` | `.DS_Store` |

**关于历史迁移：** 现有 Git 仓库在 `Projects/eMathica/` 中。推荐 **Core 保留历史**（使用 `git filter-branch` 或 `git subtree`），其他仓库**全新开始**。

---

### Phase 6: GitHub 上传

| 步骤 | 操作 | URL |
|------|------|-----|
| 6.1 | GitHub 创建仓库 `nightcreek/eMathica` | Hub |
| 6.2 | GitHub 创建仓库 `nightcreek/eMathica-Core` | Core |
| 6.3 | GitHub 创建仓库 `nightcreek/OpenMathInk-Collector` | Collector |
| 6.4 | GitHub 创建仓库 `nightcreek/SharedLibraries` | 共享包 |
| 6.5 | GitHub 创建仓库 `nightcreek/OpenMathInk-Dataset` | 数据集占位 |
| 6.6 | 各仓库添加 remote + push | `git remote add origin <url>` |
| 6.7 | 更新 Hub `RepositoryIndex/README.md` | 填入实际 GitHub URL |
| 6.8 | Hub 整体 `git add && git commit && git push` | 最终提交 |

---

## 8. 风险分析

### 8.1 Git 风险

| 风险 | 等级 | 描述 | 缓解措施 |
|------|------|------|---------|
| **历史丢失** | 🔴 高 | 现有 Git 仓库（`Projects/eMathica/`）有完整提交历史。扁平化后如果直接删除 `.git/`，所有历史丢失。 | Phase 5 中用 `git filter-branch` 提取 Core 历史，或使用 `git subtree split`。 |
| **多仓库冲突** | 🟡 中 | 5 个仓库在同一父目录下。如果在 `开发/` 整体做 git 操作可能误操作。 | 每个仓库独立 `.gitignore`，开发者在哪个目录就用哪个仓库的 git。 |
| **GitHub URL 变更** | 🟢 低 | 未来 GitHub 用户名或仓库名改变需要更新 Hub 中的 URL 索引。 | Hub README 中的 URL 是唯一需要更新的地方。集中管理。 |

### 8.2 文件移动风险

| 风险 | 等级 | 描述 | 缓解措施 |
|------|------|------|---------|
| **Xcode 引用断裂** | 🔴 高 | 移动/重命名目录后，`.pbxproj` 中的文件引用路径失效，Xcode 无法找到文件。 | ✅ **逐步操作：** 每次重命名后立即在 Xcode 中更新文件夹引用。不要批量移动。 |
| **删除文件破坏构建** | 🔴 高 | Phase 1 删除 Collector 文件时，如果 Xcode 目标仍有引用，构建失败。 | ✅ **先解除 target membership，再删除文件。** |
| **多应用共享文件缺失** | 🟡 中 | `FormulaLabelPreviewView.swift` 在两个应用中都有。删除 Core 中的副本后如果 Collector 的引用路径变了会出问题。 | 在 Collector 中确认文件存在且被引用，再删除 Core 中的副本。 |
| **Resources 引用断裂** | 🟡 中 | xcodeproj 引用 `Assets.xcassets` 的方式是相对路径。移动后失效。 | 在 Xcode 中重新指定 Resources 路径。 |

### 8.3 Package 依赖风险

| 风险 | 等级 | 描述 | 缓解措施 |
|------|------|------|---------|
| **相对路径断裂** | 🔴 高 | 当前 Package.swift 使用 `../../eMathica/eMathica/Packages/EMathicaMathCore` 这样的相对路径。目录扁平化后所有路径都失效。 | ✅ **必须原子化更新：** 在一次操作中更新所有 5 个 Package.swift 和 2 个 xcodeproj 的依赖路径。构建验证后再提交。 |
| **EMathicaMathCore 位置变更** | 🔴 高 | MathCore 从 `Projects/eMathica/eMathica/Packages/` 移到了 `SharedLibraries/`。3 个包依赖它，2 个 xcodeproj 引用它。 | 依赖图：`MathCore ← DocumentKit, WorkspaceKit ← WorkspaceKit 依赖所有`。必须在一次原子操作中全部更新。 |
| **SwiftPM 缓存问题** | 🟡 中 | Xcode 缓存了旧的 package 解析路径。路径更改后可能仍解析旧位置。 | `rm -rf ~/Library/Caches/org.swift.swiftpm/` 或使用 `File > Packages > Reset Package Caches`。 |
| **跨仓库依赖管理** | 🟡 中 | Core 和 Collector 都依赖 SharedLibraries 中的包。两个独立仓库如何引用同一组包？ | **方案一（推荐）：** 开发时使用本地相对路径 `.package(path: "../SharedLibraries/EMathicaMathCore")`，发布前切换到 Git URL。 |
| **版本号冲突** | 🟢 低 | 当使用 Git URL 引用时，如果包版本不兼容。 | **初期建议：** 保持所有包在同一个 SharedLibraries 仓库中，统一版本。拆分后每个包有自己的版本。 |

### 风险优先级矩阵

```
                可能性
              低      中      高
    高 │ 版本冲突  │ 多仓库操作 │ Xcode 引用断裂
  影    │          │ 删除文件   │ 相对路径断裂
  响 中 │ GitHub   │ 资源引用   │ MathCore 位置变更
        │ URL 变更 │ 共享文件   │ 历史丢失
    低 │ —        │ 缓存问题   │ —
```

**最高优先级（需特别注意）：**

1. 🔴 **相对路径断裂** — 必须在一次原子操作中更新所有 Package.swift
2. 🔴 **Xcode 引用断裂** — 每个重命名/移动后必须立即在 Xcode 中更新
3. 🔴 **历史丢失** — Core 仓库应保留 Git 历史
4. 🔴 **文件删除破坏构建** — 先解除 target membership，再删文件

---

## 附录 A: 目录变更汇总表

| 当前路径 | 目标路径 | 操作类型 | 风险 | 影响 |
|---------|---------|---------|------|------|
| `Projects/eMathica/` | `eMathica/`（顶级） | 移动 | 🔴 高 | Xcode 路径 + 相对依赖路径 |
| `Projects/OpenMathInkCollector/` | `OpenMathInkCollector/`（顶级） | 移动 | 🟡 中 | Xcode 路径 |
| `Projects/Packages/` | `SharedLibraries/`（顶级） | 移动+重命名 | 🟡 中 | Package 依赖路径 |
| — | `eMathica-Hub/`（新建） | 新建 | 🟢 低 | 纯 Markdown |
| — | `OpenMathInkDataset/`（新建） | 新建 | 🟢 低 | 占位 |
| `App/` → `AppShell/` | 重命名 | 🟢 低 | Xcode 文件夹引用 |
| `CalculatorModules/` → `Features/` | 重命名 | 🟢 低 | Xcode 文件夹引用 |
| `State/` → `AppState/`+`Services/` | 拆分 | 🟡 中 | import 路径变更 |
| `eMathicaTests/` → `Tests/eMathicaTests/` | 移动 | 🟢 低 | Xcode 目标设置 |
| Collector `Models/` → `DomainModels/` | 重命名 | 🟢 低 | Xcode 文件夹引用 |
| Collector `Modules/` → `Features/` | 重命名 | 🟢 低 | Xcode 文件夹引用 |
| Collector `Shared/` → `SharedUI/` | 重命名 | 🟢 低 | Xcode 文件夹引用 |
| Collector `State/` 拆分 | 拆分 | 🟢 低 | import 路径变更 |

## 附录 B: 保留 vs 删除核对清单

### Core 要保留的（确认后删除 Collector 重复）

- [x] `App/EMathicaApp.swift` — Core 入口
- [x] `App/AppRootView.swift` — Core 根视图
- [x] `App/AppNavigationState.swift` — Core 导航
- [x] `App/AppRoute.swift` — Core 路由
- [x] `App/Infrastructure/PersistenceController.swift` — Core 持久化
- [x] 全部 `CalculatorModules/`（5 个模块）
- [x] 全部 `CoreHome/`（22 个文件）
- [x] 全部 `PluginSystem/`（5 个文件）
- [x] `Services/LocalProjectStore.swift` — Core 专有
- [x] `State/KeyboardShortcutManager.swift` → 移至 `Services/`
- [x] `State/UndoRedoManager.swift` → 移至 `AppState/`
- [ ] ❌ `State/CollectorWorkspaceState.swift` — 删除
- [ ] ❌ `State/ConsentFlowView.swift` — 删除
- [ ] ❌ `State/ContributorConsentManager.swift` — 删除
- [ ] ❌ `State/LocalSampleStore.swift` — 删除
- [ ] ❌ `State/OnboardingManager.swift` — 删除
- [ ] ❌ `State/SettingsView.swift` — 删除
- [ ] ❌ `App/OpenMathInkCollectorApp.swift` — 删除
- [ ] ❌ `SharedUI/Components/FormulaLabelPreviewView.swift` — 删除
- [ ] ❌ 全部 `FeatureUtilities/`（7 个文件） — 删除
- [ ] ❌ `OPENMATHINK_COLLECTOR_FIXES.md` — 删除

### Animation 处理

Animation **不是独立 App**，它是 Plane 和 Space 的共享能力。保留在各自 Feature 中：
- `Features/PlaneCalculator/Rendering/` 包含 Plane 动画逻辑
- `Features/SpaceCalculator/` 包含 Space 动画逻辑

未来提取到 `EMathicaAnimationKit` 再讨论。
