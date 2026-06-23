# Phase 0: 本地工作区只读审计报告

> **日期:** 2026-06-23  
> **操作:** 只读审计 — 未移动、未删除、未修改任何文件  
> **参考方案:** `Documentation/ARCHITECTURE/LocalWorkspaceRestructurePlan.md`  
> **目标:** 确认当前结构 → 标记归属 → 列出待迁移/待删除候选 → 风险识别

---

## 1. 当前目录树

```
/Users/night_creek/开发/eMathica Hub/
│
├── Assets/                              ← 设计资源
│   └── icon design/
│       ├── eMathica.icon/               ← eMathica 图标源
│       ├── eMathica Exports/           ← eMathica PNG 导出 (6+1 watch)
│       ├── openmathink.icon/           ← OpenMathInk 图标源
│       └── openmathink Exports/       ← OpenMathInk PNG 导出 (6)
│
├── Data/
│   ├── Ink Data/                       ← 空目录
│   └── ML models/
│       └── Writing to Character.mlproj/ ← CoreML 项目 (6 files)
│
├── Documentation/
│   ├── ADR/                            ← 空
│   ├── ARCHITECTURE/                   ← 架构方案 (4 files)
│   │   ├── EMathicaCollectorSharedKitArchitecturePlan.md
│   │   ├── LocalWorkspaceRestructurePlan.md       ← 刚生成的方案
│   │   ├── ModularDirectoryArchitecturePlan.md
│   │   └── RepositorySplitFinalPlan.md
│   ├── ARCHIVE/                        ← 空
│   ├── Automation/                     ← 空
│   ├── POLICIES/                       ← 空
│   ├── Working/                        ← 进行中的工作文档 (9 files)
│   │   ├── DocumentSystemDeduplicationPreparation.md
│   │   ├── DocumentSystemOwnershipAudit.md
│   │   ├── DocumentSystemRemovalReport.md
│   │   ├── DocumentationClassificationAudit.md
│   │   ├── DocumentationStructureConsolidationReport.md
│   │   ├── FeatureUtilitiesOwnershipAudit.md
│   │   ├── Phase1_1_XcodePackageReferenceFix.md
│   │   ├── Phase1_PackageExtractionReport.md
│   │   ├── RepositoryReadinessAudit.md
│   │   ├── RepositorySplitPreparationAudit.md
│   │   └── RepositoryStructureMigrationReport.md
│   └── temp/                           ← 空
│
├── Projects/
│   │
│   ├── eMathica/                       ← ★ Core 主应用
│   │   ├── .gitignore
│   │   ├── .reasonix/                  ← 本地 agent 配置
│   │   ├── reasonix.toml               ← 本地 agent 配置
│   │   ├── eMathica.xcodeproj/
│   │   │   └── project.pbxproj         ← Xcode 项目
│   │   ├── eMathica/                   ← 应用源码 (90 .swift files)
│   │   │   ├── AI/                     ← AI 开发记录 (22 files)
│   │   │   ├── App/                    ← 应用入口 (5 swift)
│   │   │   ├── CalculatorModules/      ← 5 个模块 (48 swift)
│   │   │   ├── CoreHome/               ← 主屏幕 (22 swift)
│   │   │   ├── Docs/                   ← 开发文档 (70+ files)
│   │   │   ├── FeatureUtilities/       ← ★ 与 Collector 重复 (7 swift)
│   │   │   ├── PluginSystem/           ← 插件协议 (5 swift)
│   │   │   ├── Resources/              ← Assets.xcassets (22 files)
│   │   │   ├── Services/               ← 业务逻辑 (1 swift)
│   │   │   ├── SharedUI/               ← 共享 UI (1 swift + 1 重复)
│   │   │   ├── State/                  ← 混合状态 (8 swift)
│   │   │   └── OPENMATHINK_COLLECTOR_FIXES.md ← Collector 文档
│   │   ├── eMathicaTests/              ← 单元测试 (43 swift)
│   │   ├── eMathicaUITests/            ← UI 测试 (2 swift)
│   │   ├── Scripts/                    ← 构建脚本 (2 sh)
│   │   └── Tests/                      ← Golden Fixtures (6 files)
│   │
│   ├── OpenMathInkCollector/           ← ★ Collector 采集应用
│   │   └── OpenMathInkCollector/
│   │       ├── .gitignore
│   │       ├── README.md
│   │       ├── OpenMathInkCollector.xcodeproj/
│   │       │   └── project.pbxproj
│   │       └── OpenMathInkCollector/   ← 应用源码
│   │           ├── App/                ← 应用入口 (2 swift)
│   │           ├── Models/             ← 数据模型 (4 swift)
│   │           ├── Modules/            ← 功能模块 (15 swift)
│   │           ├── Shared/             ← 共享 UI (3 swift)
│   │           ├── State/              ← 状态管理 (6 swift)
│   │           └── Resources/          ← Assets.xcassets (6 files)
│   │
│   └── Packages/                       ← ★ Shared Libraries
│       ├── EMathicaMathCore/           ← 数学引擎 (Package.swift + 43 swift)
│       ├── EMathicaDocumentKit/        ← 文档模型 (Package.swift + 11 swift)
│       ├── EMathicaMathInputKit/        ← 数学键盘 (Package.swift + 9 swift)
│       ├── EMathicaThemeKit/           ← 主题系统 (Package.swift + 10 swift)
│       └── EMathicaWorkspaceKit/       ← 工作区 (Package.swift + 50+ swift)
│
├── .claude/                            ← 本地 agent 配置, 不入库
├── .reasonix/                          ← 本地 agent 配置, 不入库
└── reasonix.toml                       ← 本地 agent 配置, 不入库
```

### 统计

| 类别 | 数量 |
|------|------|
| 顶层目录 | 5 (Assets, Data, Documentation, Projects, .claude, .reasonix) |
| 顶层文件 | 1 (reasonix.toml) |
| Projects 子目录 | 3 (eMathica, OpenMathInkCollector, Packages) |
| Core Swift 文件 | 90 (.swift) |
| Core 测试文件 | 45 (43 unit + 2 UI) |
| Collector Swift 文件 | 31 (.swift) |
| Shared Packages | 5 |
| Hub 级别文档 | 15 (Documentation/ 下) |
| Core 级别文档 | 70+ (eMathica/Docs/ + AI/ + temp + archive) |

---

## 2. 未来仓库归属表

### 2.1 顶层目录归属

| 当前路径 | 目标仓库 | 类型 | 说明 |
|---------|---------|------|------|
| `Assets/icon design/` | **eMathica-Hub** | 设计资源 | 共享图标源文件，应随 Hub |
| `Data/Ink Data/` | **eMathica-Hub** 或删除 | 占位 | 空目录，无实际数据 |
| `Data/ML models/` | **eMathica-Hub** 或 **Collector** | ML 项目 | 手写识别模型，适合随 Collector |
| `Documentation/` (交叉部分) | **eMathica-Hub** | 文档 | 跨项目架构文档、ADR、政策 |
| `Projects/eMathica/` | **eMathica-Core** | 源码 | 主应用全部源码 |
| `Projects/OpenMathInkCollector/` | **OpenMathInk-Collector** | 源码 | 手写采集全部源码 |
| `Projects/Packages/` | **SharedLibraries** | 源码 | 5 个共享 SwiftPM 包 |
| — (新建) | **OpenMathInk-Dataset** | 占位 | 未来数据集，目前仅 README |
| `.claude/` | ❌ 不入库 | 本地配置 | AI agent 配置 |
| `.reasonix/` | ❌ 不入库 | 本地配置 | AI agent 配置 |
| `reasonix.toml` | ❌ 不入库 (或 Hub) | 本地配置 | 主配置已在 Hub 根 |

### 2.2 Core 内部目录归属

| Core 内部路径 | 归属 | 说明 |
|---------------|------|------|
| `App/` | **Core** 保留 | 应用入口 (但需删除 `OpenMathInkCollectorApp.swift`) |
| `CalculatorModules/` | **Core** 保留 | 全部 5 个模块 |
| `CoreHome/` | **Core** 保留 | 主屏幕全部 22 个文件 |
| `PluginSystem/` | **Core** 保留 | 全部 5 个文件 |
| `Services/LocalProjectStore.swift` | **Core** 保留 | Core 专有服务 |
| `State/KeyboardShortcutManager.swift` | **Core** 保留 | Core 专有状态 |
| `State/UndoRedoManager.swift` | **Core** 保留 | 可保留（Collector 也有副本） |
| `Resources/` | **Core** 保留 | 全部 22 个资源文件 |
| `SharedUI/Components/FormulaLabelPreviewView.swift` | **❌ 应从 Core 删除** | 与 Collector 重复 |
| `FeatureUtilities/` (全部 7 文件) | **❌ 应从 Core 删除** | 全部与 Collector 重复 |
| `App/OpenMathInkCollectorApp.swift` | **❌ 应从 Core 删除** | Collector 入口 |
| `State/CollectorWorkspaceState.swift` | **❌ 应从 Core 删除** | Collector 状态 |
| `State/ConsentFlowView.swift` | **❌ 应从 Core 删除** | Collector 视图 |
| `State/ContributorConsentManager.swift` | **❌ 应从 Core 删除** | Collector 逻辑 |
| `State/LocalSampleStore.swift` | **❌ 应从 Core 删除** | Collector 数据 |
| `State/OnboardingManager.swift` | **❌ 应从 Core 删除** | Collector 管理 |
| `State/SettingsView.swift` | **❌ 应从 Core 删除** | Collector 设置 |
| `OPENMATHINK_COLLECTOR_FIXES.md` | **❌ 应从 Core 删除** | Collector 文档 |
| `AI/` | **Core** 保留 | AI 开发记录 |
| `Docs/` | **Core** 保留 | 应用专有文档（部分适合移至 Hub） |
| `eMathicaTests/` | **Core** 保留 | 45 个测试文件 |
| `eMathicaUITests/` | **Core** 保留 | 2 个 UI 测试 |
| `Scripts/` | **Core** 保留 | 构建脚本 |

### 2.3 Collector 内部目录归属

| Collector 内部路径 | 归属 | 说明 |
|-------------------|------|------|
| `App/` | **Collector** 保留 | 2 个入口文件 |
| `Models/` | **Collector** 保留 (建议改名 DomainModels/) | 4 个模型 |
| `Modules/` | **Collector** 保留 (建议改名 Features/) | 15 个功能文件 |
| `Shared/` | **Collector** 保留 (建议改名 SharedUI/) | 3 个共享文件 |
| `State/` | **Collector** 保留 (建议拆分) | 6 个状态/视图文件 |
| `Resources/` | **Collector** 保留 | 6 个资源文件 |

### 2.4 Package 归属

| Package | 归属 | 说明 |
|---------|------|------|
| `EMathicaMathCore` | **SharedLibraries** | 无外部依赖，最独立的包 |
| `EMathicaDocumentKit` | **SharedLibraries** | 依赖 MathCore |
| `EMathicaMathInputKit` | **SharedLibraries** | 无外部依赖 |
| `EMathicaThemeKit` | **SharedLibraries** | 无外部依赖 |
| `EMathicaWorkspaceKit` | **SharedLibraries** | 依赖全部 4 个包 |

---

## 3. Core 中疑似 Collector 重复文件清单

通过对比两个应用的源码树，以下文件在 Core 和 Collector 中同时存在。这些文件应该在从 Core 仓库迁移前删除。

### 3.1 文件级重复（核心嫌疑）

| # | 文件名 | Core 路径 | Collector 路径 | 建议 |
|---|--------|-----------|---------------|------|
| 1 | `OpenMathInkCollectorApp.swift` | `eMathica/App/` | `Collector/App/` | **从 Core 删除** |
| 2 | `CollectorWorkspaceState.swift` | `eMathica/State/` | `Collector/State/` | **从 Core 删除** |
| 3 | `ConsentFlowView.swift` | `eMathica/State/` | `Collector/State/` | **从 Core 删除** |
| 4 | `ContributorConsentManager.swift` | `eMathica/State/` | `Collector/State/` | **从 Core 删除** |
| 5 | `LocalSampleStore.swift` | `eMathica/State/` | `Collector/Modules/Files/` | **从 Core 删除** |
| 6 | `OnboardingManager.swift` | `eMathica/State/` | `Collector/State/` | **从 Core 删除** |
| 7 | `SettingsView.swift` | `eMathica/State/` | `Collector/State/` | **从 Core 删除** |
| 8 | `FormulaLabelPreviewView.swift` | `eMathica/SharedUI/Components/` | `Collector/Shared/Components/` | **从 Core 删除** |
| 9 | `UndoRedoManager.swift` | `eMathica/State/` | `Collector/State/` | **保留两份**（各自演进） |

### 3.2 目录级重复（整个 FeatureUtilities/）

| # | Core 文件 | 对应 Collector 文件 | 建议 |
|---|----------|-------------------|------|
| 1 | `FeatureUtilities/Files/DatasetFileBrowserView.swift` | `Modules/Files/DatasetFileBrowserView.swift` | **从 Core 删除** |
| 2 | `FeatureUtilities/Files/StatisticsView.swift` | `Modules/Files/StatisticsView.swift` | **从 Core 删除** |
| 3 | `FeatureUtilities/Handwriting/DrawingToolSettings.swift` | `Modules/Handwriting/DrawingToolSettings.swift` | **从 Core 删除** |
| 4 | `FeatureUtilities/Handwriting/HandwritingCanvasView.swift` | `Modules/Handwriting/HandwritingCanvasView.swift` | **从 Core 删除** |
| 5 | `FeatureUtilities/Handwriting/HandwritingToolbarView.swift` | `Modules/Handwriting/HandwritingToolbarView.swift` | **从 Core 删除** |
| 6 | `FeatureUtilities/Handwriting/PencilDrawingRepresentable.swift` | `Modules/Handwriting/PencilDrawingRepresentable.swift` | **从 Core 删除** |
| 7 | `FeatureUtilities/Preview/LatexRenderService.swift` | `Modules/Preview/LatexRenderService.swift` | **从 Core 删除** |

### 3.3 Root 级别

| # | Core 文件 | 建议 |
|---|----------|------|
| 1 | `eMathica/OPENMATHINK_COLLECTOR_FIXES.md` | **从 Core 删除**（属于 Collector） |

### 重复统计

| 类别 | 文件数 |
|------|--------|
| State/ 中 Collector 文件 | 7 (含 UndoRedoManager，保留) |
| FeatureUtilities/ 全部 | 7 |
| App/ 入口 | 1 |
| SharedUI/ 组件 | 1 |
| Root 文档 | 1 |
| **应从 Core 删除合计** | **16 个文件** |
| **保留在 Collector 的合计** | **31 个文件**（全部保留） |

---

## 4. Hub 应保留的文档清单

以下 `Documentation/` 中的文档适合在 Hub 仓库的 `CurrentReality/docs/` 中保留：

### 4.1 确认为跨项目级文档（应保留在 Hub）

| 文件 | 理由 |
|------|------|
| `ARCHITECTURE/ModularDirectoryArchitecturePlan.md` | 跨项目的目录架构方案 |
| `ARCHITECTURE/RepositorySplitFinalPlan.md` | 跨项目的仓库拆分方案 |
| `ARCHITECTURE/LocalWorkspaceRestructurePlan.md` | 本地工作区重组方案（本阶段参考） |
| `ARCHITECTURE/EMathicaCollectorSharedKitArchitecturePlan.md` | 跨 Collector 和 Core 的共享架构 |
| `Working/RepositorySplitPreparationAudit.md` | 仓库拆分准备审计 |
| `Working/RepositoryStructureMigrationReport.md` | 已执行的迁移报告 |
| `Working/RepositoryReadinessAudit.md` | 仓库就绪审计 |
| `Working/FeatureUtilitiesOwnershipAudit.md` | 跨应用功能归属审计 |

### 4.2 应移至 Core (Docs/) 的应用级文档

| 文件 | 理由 |
|------|------|
| `Working/DocumentSystemDeduplicationPreparation.md` | DocumentSystem 是 Core 的包 |
| `Working/DocumentSystemOwnershipAudit.md` | 同上 |
| `Working/DocumentSystemRemovalReport.md` | 同上 |
| `Working/DocumentationClassificationAudit.md` | 文档分类，部分 Hub 部分 Core |
| `Working/DocumentationStructureConsolidationReport.md` | 文档整合，Hub 级别 |
| `Working/Phase1_1_XcodePackageReferenceFix.md` | XCode 配置，属于 Core |
| `Working/Phase1_PackageExtractionReport.md` | 包提取，属于 SharedLibraries |

### 4.3 建议新增的 Hub 内容（需新建）

| 文件 | 说明 |
|------|------|
| `README.md` | 项目介绍 + 仓库索引 |
| `Philosophy/WhyEMathica.md` | 为什么存在 |
| `Philosophy/MathematicsAsArt.md` | 数学即艺术 |
| `Philosophy/StudentCreatorsInAIEra.md` | AI 时代学生创作者 |
| `Philosophy/VibeCodingReflection.md` | AI 开发反思 |
| `CurrentDevelopment/STATUS.md` | 当前开发状态 |
| `CurrentDevelopment/ROADMAP.md` | 路线图 |
| `FuturePossibilities/VISION.md` | 长期愿景 |
| `FuturePossibilities/Community.md` | 社区规划 |
| `FuturePossibilities/AI.md` | AI 方向说明（不计划） |
| `RepositoryIndex/README.md` | 仓库索引 + URL |

---

## 5. 不应入库的本地配置文件

以下文件/目录是本地开发环境配置，**不应被 Git 跟踪**：

| 路径 | 说明 | 处理方式 |
|------|------|---------|
| `eMathica Hub/.claude/` | Claude Desktop 配置 | 每仓库 .gitignore 排除 |
| `eMathica Hub/.reasonix/` | Reasonix 工作目录 | 每仓库 .gitignore 排除 |
| `eMathica Hub/reasonix.toml` | Reasonix 配置 | 可选入库（Hub 级），Core 级应排除 |
| `Projects/eMathica/.reasonix/` | Core 的 Reasonix 配置 | .gitignore 排除 |
| `Projects/eMathica/reasonix.toml` | Core 的 Reasonix 配置 | .gitignore 排除 |
| `**/xcuserdata/` | Xcode 个人设置 | 已有 .gitignore 覆盖 |
| `**/UserInterfaceState.xcuserstate` | Xcode UI 状态 | 已有 .gitignore 覆盖 |
| `**/.DS_Store` | macOS 目录元数据 | 已有 .gitignore 覆盖 |
| `**/.build/` | SwiftPM 构建产物 | 已有 .gitignore 覆盖 |

### 重点：Core 需要新增的 .gitignore 内容

在迁移后，`eMathica/`（Core 仓库）的 `.gitignore` 应添加：

```
# Local agent config
.reasonix/
reasonix.toml
```

---

## 6. 当前关键发现

### 6.1 Git 仓库状态

**当前没有任何 Git 仓库存在。**  
之前报告中提到的 `Projects/eMathica/eMathica/.git/` 已不存在。这意味着：

- ✅ 不需要担心历史迁移
- ✅ 所有仓库将从零开始
- ✅ 扁平化目录操作不受版本控制约束
- ⚠️ 但建议在开始文件操作前先做快照备份

### 6.2 目录嵌套深度（当前问题）

```
开发/eMathica Hub/
  └── Projects/
        ├── eMathica/
        │     └── eMathica/          ← 源码在这里
        ├── OpenMathInkCollector/
        │     └── OpenMathInkCollector/
        │           └── OpenMathInkCollector/  ← 源码在这里
        └── Packages/                ← 包在这里
```

当前嵌套层级过深：
- Core app 源码在 `Projects/eMathica/eMathica/`（3 级）
- Collector 源码在 `Projects/OpenMathInkCollector/OpenMathInkCollector/OpenMathInkCollector/`（4 级）

目标扁平化：
- Core → `eMathica/`（1 级）
- Collector → `OpenMathInkCollector/`（1 级）
- SharedLibraries → `SharedLibraries/`（1 级）

### 6.3 Package 依赖的相对路径

当前 SharedLibraries 中，部分 Package.swift 引用其他包的相对路径。由于目录将重新组织，这些路径需要在 Phase 5 中统一更新：

| 文件 | 当前路径类型 | 目标路径 |
|------|-------------|---------|
| `EMathicaDocumentKit/Package.swift` | `../EMathicaMathCore` | 同级别，不需要改 |
| `EMathicaWorkspaceKit/Package.swift` | `../EMathicaMathCore`, `../EMathicaDocumentKit`, `../EMathicaThemeKit`, `../EMathicaMathInputKit` | 同级别，不需要改 |

**注意：** 之前方案中提到的 `../../eMathica/eMathica/Packages/EMathicaMathCore` 格式，在当前的工作副本中已经修复为 `../EMathicaMathCore`。这是之前迁移工作的成果。✅

### 6.4 数据目录归属待定

| 目录 | 建议去向 | 说明 |
|------|---------|------|
| `Data/ML models/Writing to Character.mlproj/` | **OpenMathInk-Collector** | 手写识别模型，与采集应用高度相关 |
| `Data/Ink Data/` | **删除** 或保留在 Hub | 空目录，无实际内容 |

---

## 7. 风险点与注意事项

### 7.1 高风险

| # | 风险 | 说明 |
|---|------|------|
| R1 | **Collector 目录名包含空格** | 当前 `OpenMathInkCollector` 在 Projects 下已无空格，但 Collector 源码的目录名是 `OpenMathInkCollector/OpenMathInkCollector/OpenMathInkCollector/`（三级同名）。扁平化时要明确哪个是目标。 |
| R2 | **Xcode pbxproj 引用路径** | Core 和 Collector 的 `.pbxproj` 使用相对路径引用文件。移动目录后，所有引用路径失效。 |
| R3 | **Package依赖路径** | 虽然当前相对路径是 `../EMathicaMathCore` 格式，但在目录从 `Projects/Packages/` 移到 `SharedLibraries/` 后可能需要验证。 |

### 7.2 中等风险

| # | 风险 | 说明 |
|---|------|------|
| R4 | **Core 中删除 Collector 文件时构建破裂** | 必须先将文件从 Xcode target membership 移除，再删除物理文件 |
| R5 | **SharedUI/FormulaLabelPreviewView.swift 双向依赖** | 两个 app 都有这个文件，删除 Core 中的副本前需确认 Collector 版本已就绪 |
| R6 | **Scripts/ 路径引用** | Core 的 `Scripts/` 中有构建脚本，可能硬编码了目录路径 |

### 7.3 低风险

| # | 风险 | 说明 |
|---|------|------|
| R7 | `.reasonix/` 目录消失 | 当前 `eMathica Hub/` 和 `Projects/eMathica/` 下都有 `.reasonix/`。扁平化后需要决定保留路径。 |
| R8 | 空目录被 Git 忽略 | `Data/Ink Data/` 空目录、`Documentation/ADR/` 空目录等。Git 不跟踪空目录，需要 `.gitkeep`。 |

---

## 8. 下一阶段建议

### Phase 1 执行准备

在开始 Phase 1（清理 Core 中的 Collector 重复文件）之前，建议：

1. **备份当前整个 `eMathica Hub/` 目录** — 确保可以回退
2. **确认构建当前可通** — 在 Xcode 中打开 Core 确认能编译通过
3. **记录 Xcode pbxproj 状态** — 保存一份当前 project.pbxproj 副本以便对比变更

### 推荐执行顺序

```
Phase 0 ✅ ← 你在这里
    ↓
Phase 1: 清理 Core 中的 Collector 重复文件
    ├── 解除 Xcode target membership
    ├── 删除物理文件
    └── 构建验证
    ↓
Phase 2: 重构 Core 内部结构
    ├── App/ → AppShell/
    ├── CalculatorModules/ → Features/
    ├── State/ 拆分
    └── 构建验证
    ↓
Phase 3: 重构 Collector 内部结构
    ├── Modules/ → Features/
    ├── Models/ → DomainModels/
    └── 构建验证
    ↓
Phase 4: 建立 Hub 内容
    ├── Philosophy/
    ├── RepositoryIndex/
    └── README.md
    ↓
Phase 5: 扁平化目录 + Git 初始化
    ├── 移动目录到同级
    └── git init
    ↓
Phase 6: GitHub 上传（未来任务）
```

---

## 附录 A: 文件统计明细

### A.1 Core Swift 文件按模块分组

| 模块 | 文件数 | 备注 |
|------|--------|------|
| `App/` | 5 | 含 1 个 Collector 重复 |
| `CalculatorModules/Plane/` | 23 | 最大模块 |
| `CalculatorModules/Space/` | 9 | |
| `CalculatorModules/Modeling/` | 1 | 占位 |
| `CalculatorModules/Music/` | 1 | 占位 |
| `CalculatorModules/Notes/` | 1 | 占位 |
| `CalculatorModules/` (root) | 4 | 注册表、协议 |
| `CalculatorModules/Commands/` | 2 | |
| `CalculatorModules/Data/` | 1 | 占位 |
| `CoreHome/` | 22 | 含 Background/ Layout/ 等 |
| `FeatureUtilities/` | 7 | ❌ 全部重复 |
| `PluginSystem/` | 5 | |
| `Services/` | 1 | |
| `SharedUI/` | 1 | ❌ 1 个重复 |
| `State/` | 8 | ❌ 7 个 Collector 相关 (1 保留) |
| `AI/` | 22 | 不入库？开发记录 |
| `Docs/` | 70+ | 含 archive |
| **Core Swift 合计** | **~90** | **删除 ≈16 个后 ~74 个** |

### A.2 Collector Swift 文件按模块分组

| 模块 | 文件数 | 备注 |
|------|--------|------|
| `App/` | 2 | 入口 |
| `Models/` | 4 | 数据模型 |
| `Modules/Files/` | 6 | 文件管理 |
| `Modules/Handwriting/` | 4 | 手写采集 |
| `Modules/KeyboardInput/` | 4 | 数学键盘 |
| `Modules/Preview/` | 2 | 预览 |
| `Shared/` | 3 | 主题/组件/工具 |
| `State/` | 6 | 状态管理 |
| **Collector Swift 合计** | **31** | 全部保留 |

### A.3 各 Packages 源文件数

| Package | 源码目录 | 文件数 |
|---------|---------|--------|
| EMathicaMathCore | `Sources/EMathicaMathCore/` | ~43 |
| EMathicaDocumentKit | `Sources/EMathicaDocumentKit/` | 11 |
| EMathicaMathInputKit | `Sources/EMathicaMathInputCore/` + `Sources/EMathicaMathInputUI/` | 9 |
| EMathicaThemeKit | `Sources/EMathicaThemeKit/` | 10 |
| EMathicaWorkspaceKit | `Sources/EMathicaWorkspaceKit/` | 50+ |
| **Packages 合计** | | **~123+** |

---

## 附录 B: 项目总览

| 维度 | 数值 |
|------|------|
| 顶层目录 | 4 个业务目录 + 2 个本地配置 |
| 源码仓库 | 3 个 (Core, Collector, SharedLibraries) |
| Swift 源文件总数 | ~244 |
| 测试文件 | 45 (Core) + 0 (Collector) |
| 共享包 | 5 |
| Xcode 项目 | 2 |
| Git 仓库 | 0 |
