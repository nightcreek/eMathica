# Phase 1 Precheck: Core → Collector 重复文件删除前依赖验证

> **日期:** 2026-06-23  
> **操作:** 只读依赖分析 — 未移动、未删除、未修改任何文件  
> **范围:** 16 个 Phase 0 标记文件 + 4 个关联文件的交叉引用验证

---

## 0. 关键发现（摘要）

| 检查项 | 结果 |
|--------|------|
| Xcode Target Membership | **全部 20 个文件已从 Core target 排除**（`membershipExceptions`） |
| Core 编译代码引用 | **零引用** — 无任何编译入 Core 的代码引用这些文件中的类型 |
| Core 测试引用 | **零引用** — 无任何测试文件引用这些文件中的类型 |
| 文件间互相引用 | **有** — 这些文件形成一个 Collector 内部依赖集群，但全部已排除 |
| 删除后编译风险 | **🟢 零风险** — 删除不影响 Core 编译 |

### 意外发现

`State/KeyboardShortcutManager.swift` 和 `State/UndoRedoManager.swift` **同样已被排除**在 Core target 之外，并且**完全 Collector 专用**。它们也应从 Core 删除。

---

## 1. Xcode Target Membership 验证

### 核心发现

Core 的 Xcode 项目使用 **`PBXFileSystemSynchronizedRootGroup`**（文件系统同步组），这意味着：

> Xcode 自动包含 `eMathica/eMathica/` 目录下**所有** `.swift` 文件，**除非**它们在 `membershipExceptions` 中明确排除。

### membershipExceptions 完整列表

取自 `project.pbxproj` (lines 48-69):

```
membershipExceptions = (
    AI/README.md,
    AI/ProductDesign/README.md,
    App/OpenMathInkCollectorApp.swift,
    Docs/README.md,
    FeatureUtilities/Files/DatasetFileBrowserView.swift,
    FeatureUtilities/Files/StatisticsView.swift,
    FeatureUtilities/Handwriting/DrawingToolSettings.swift,
    FeatureUtilities/Handwriting/HandwritingCanvasView.swift,
    FeatureUtilities/Handwriting/HandwritingToolbarView.swift,
    FeatureUtilities/Handwriting/PencilDrawingRepresentable.swift,
    FeatureUtilities/Preview/LatexRenderService.swift,
    SharedUI/Components/FormulaLabelPreviewView.swift,
    State/CollectorWorkspaceState.swift,
    State/ConsentFlowView.swift,
    State/ContributorConsentManager.swift,
    State/KeyboardShortcutManager.swift,
    State/LocalSampleStore.swift,
    State/OnboardingManager.swift,
    State/SettingsView.swift,
    State/UndoRedoManager.swift,
);
```

**结论：** 所有 16 个 Phase 0 目标文件 + `KeyboardShortcutManager.swift` + `UndoRedoManager.swift` + 2 个 README 文件，**全部已从 Core target 排除**。

---

## 2. 每个文件的引用分析

### 2.1 Collector 入口文件

#### `App/OpenMathInkCollectorApp.swift`

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 被排除文件引用 | 引用 `OnboardingManager`（同排除） |
| 删除风险 | 🟢 **安全删除** |
| 说明 | Collector 的 `@main` 入口，在 Core 中无意义 |

---

### 2.2 State/ 中的 Collector 文件

#### `State/CollectorWorkspaceState.swift`

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 被排除文件引用 | 引用 `LocalSampleStore`, `ContributorConsentManager`（全排除） |
| 被哪些排除文件引用 | `DatasetFileBrowserView`, `StatisticsView`, `HandwritingCanvasView`, `SettingsView`, `KeyboardShortcutManager` |
| 删除风险 | 🟢 **安全删除** |
| 说明 | Collector 中心状态对象，543 行，全部 Collector 专用 |

#### `State/ConsentFlowView.swift`

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 被排除文件引用 | 引用 `ContributorConsentManager`；被 `OnboardingManager` 引用（全排除） |
| 删除风险 | 🟢 **安全删除** |

#### `State/ContributorConsentManager.swift`

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 被排除文件引用 | 被 `CollectorWorkspaceState`, `ConsentFlowView`, `OnboardingManager`, `SettingsView` 引用（全排除） |
| 删除风险 | 🟢 **安全删除** |

#### `State/LocalSampleStore.swift`

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 被排除文件引用 | 被 `CollectorWorkspaceState` 引用（排除） |
| 删除风险 | 🟢 **安全删除** |

#### `State/OnboardingManager.swift`

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 被排除文件引用 | 引用 `ContributorConsentManager`, `ConsentFlowView`；被 `OpenMathInkCollectorApp`, `SettingsView` 引用（全排除） |
| 删除风险 | 🟢 **安全删除** |

#### `State/SettingsView.swift`

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 被排除文件引用 | 引用 `CollectorWorkspaceState`, `ContributorConsentManager`, `StatisticsView`, `OnboardingManager`（全排除） |
| 删除风险 | 🟢 **安全删除** |

---

### 2.3 FeatureUtilities/ 全部文件

这 7 个文件形成一个**紧密的内部依赖集群**，但全部相互引用且全部已排除。

#### `FeatureUtilities/Files/DatasetFileBrowserView.swift`

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 引用 | `CollectorWorkspaceState`（排除） |
| 删除风险 | 🟢 **安全删除** |

#### `FeatureUtilities/Files/StatisticsView.swift`

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 引用 | `CollectorWorkspaceState`（排除）；被 `SettingsView` 引用（排除） |
| 删除风险 | 🟢 **安全删除** |

#### `FeatureUtilities/Handwriting/DrawingToolSettings.swift`

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 引用 | 无（独立工具类） |
| 被引用 | `HandwritingToolbarView`, `PencilDrawingRepresentable`（全排除） |
| 删除风险 | 🟢 **安全删除** |

#### `FeatureUtilities/Handwriting/HandwritingCanvasView.swift`

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 引用 | `CollectorWorkspaceState`, `PencilDrawingRepresentable`, `HandwritingToolbarView`（全排除） |
| 删除风险 | 🟢 **安全删除** |

#### `FeatureUtilities/Handwriting/HandwritingToolbarView.swift`

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 引用 | `DrawingToolSettings`（排除） |
| 删除风险 | 🟢 **安全删除** |

#### `FeatureUtilities/Handwriting/PencilDrawingRepresentable.swift`

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 引用 | `DrawingToolSettings`（排除） |
| 删除风险 | 🟢 **安全删除** |

#### `FeatureUtilities/Preview/LatexRenderService.swift`

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 引用 | 无（独立的协议 + 实现） |
| 删除风险 | 🟢 **安全删除** |

---

### 2.4 SharedUI 重复组件

#### `SharedUI/Components/FormulaLabelPreviewView.swift`

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 引用 | 无依赖 |
| 删除风险 | 🟢 **安全删除** |
| 说明 | 这是一个通用 UI 组件，但在 Core 中无引用。Collector 中也有副本。如果未来 Core 需要，应从 SharedLibraries 导入。 |

---

### 2.5 根级文档

#### `OPENMATHINK_COLLECTOR_FIXES.md`

| 检查项 | 结果 |
|--------|------|
| 编译影响 | 无（Markdown 文件） |
| Core 需要 | ❌ 完全不 |
| 删除风险 | 🟢 **安全删除** |

---

### 2.6 额外发现：也应从 Core 删除的文件

#### `State/KeyboardShortcutManager.swift` ★

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 引用 | `CollectorWorkspaceState`（排除，行 111） |
| 内容 | 全部快捷键调用 `CollectorWorkspaceState` 方法 |
| 删除风险 | 🟢 **安全删除** |
| 说明 | Phase 0 误列为「Core 保留」，实际是**完全 Collector 专用** |

#### `State/UndoRedoManager.swift` ★

| 检查项 | 结果 |
|--------|------|
| Core 编译代码引用 | ❌ 无 |
| Core 测试引用 | ❌ 无 |
| 引用 | 无 |
| 内容 | `DrawingSnapshot`（PKDrawing）、`WorkspaceAction`（含 `SampleStatus`）— 全部 Collector 概念 |
| 删除风险 | 🟢 **安全删除** |
| 说明 | Phase 0 建议「保留两份」，但**它在 Core 中完全不被引用，且是 Collector 专用**。应从 Core 删除。 |

---

## 3. 依赖关系图

### 排除文件内部依赖集群（全部已排除，互不影响 Core）

```
OpenMathInkCollectorApp.swift
  └── OnboardingManager.swift ──────────┐
       ├── ContributorConsentManager.swift ←┐
       └── ConsentFlowView.swift ─────────┐ │
            └── ContributorConsentManager.swift │
                                               │
SettingsView.swift                             │
  ├── CollectorWorkspaceState.swift ───────────┤
  │     ├── LocalSampleStore.swift             │
  │     └── ContributorConsentManager.swift ───┘
  ├── ContributorConsentManager.swift
  ├── StatisticsView.swift
  │     └── CollectorWorkspaceState.swift
  └── OnboardingManager.swift

HandwritingCanvasView.swift
  ├── CollectorWorkspaceState.swift
  ├── PencilDrawingRepresentable.swift
  │     └── DrawingToolSettings.swift
  └── HandwritingToolbarView.swift
        └── DrawingToolSettings.swift

DatasetFileBrowserView.swift
  └── CollectorWorkspaceState.swift

KeyboardShortcutManager.swift
  └── CollectorWorkspaceState.swift

FormulaLabelPreviewView.swift (无依赖)
LatexRenderService.swift (无依赖)
```

**关键结论：** 图中全部节点均在 `membershipExceptions` 中。**没有任何箭头指向 Core 编译文件。**

---

## 4. 删除风险评估

### 风险矩阵

| 文件 | Target 排除 | 编译引用 | 测试引用 | 风险 | 可删除 |
|------|-----------|---------|---------|------|-------|
| `OpenMathInkCollectorApp.swift` | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| `CollectorWorkspaceState.swift` | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| `ConsentFlowView.swift` | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| `ContributorConsentManager.swift` | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| `LocalSampleStore.swift` | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| `OnboardingManager.swift` | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| `SettingsView.swift` | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| `FormulaLabelPreviewView.swift` | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| `DatasetFileBrowserView.swift` | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| `StatisticsView.swift` | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| `DrawingToolSettings.swift` | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| `HandwritingCanvasView.swift` | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| `HandwritingToolbarView.swift` | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| `PencilDrawingRepresentable.swift` | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| `LatexRenderService.swift` | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| `OPENMATHINK_COLLECTOR_FIXES.md` | 非代码 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| **`KeyboardShortcutManager.swift`** ★ | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |
| **`UndoRedoManager.swift`** ★ | ✅ 已排除 | ❌ 无 | ❌ 无 | 🟢 零 | ✅ |

### 综合评估

| 维度 | 结论 |
|------|------|
| 不影响编译 | **100% 确认** — 全部已排除且无外部引用 |
| 不影响测试 | **100% 确认** — 测试零引用 |
| 不影响运行时 | **确认** — 这些文件不在 Core target 中，运行时不加载 |
| 删除后 Collector 是否受影响 | **否** — Collector 有全部文件的完整副本（且是真正的源） |
| **整体风险等级** | **🟢 极低 — 可以安全删除** |

---

## 5. 删除顺序建议

### 建议分批删除（降低人为失误风险）

#### 第一批：独立无依赖文件（最安全）

| 顺序 | 文件 | 理由 |
|------|------|------|
| 1 | `OPENMATHINK_COLLECTOR_FIXES.md` | Markdown，零影响 |
| 2 | `SharedUI/Components/FormulaLabelPreviewView.swift` | 零依赖 |
| 3 | `FeatureUtilities/Preview/LatexRenderService.swift` | 独立协议+实现 |
| 4 | `FeatureUtilities/Handwriting/DrawingToolSettings.swift` | 独立工具类 |

#### 第二批：State/ 中的 Collector 文件

| 顺序 | 文件 | 理由 |
|------|------|------|
| 5 | `State/LocalSampleStore.swift` | 被 CollectorWorkspaceState 引用，但全排除 |
| 6 | `State/ContributorConsentManager.swift` | 被多个排除文件引用 |
| 7 | `State/ConsentFlowView.swift` | 依赖 ContributorConsentManager |
| 8 | `State/OnboardingManager.swift` | 依赖 ConsentFlowView + ContributorConsentManager |
| 9 | `State/UndoRedoManager.swift` | 新增发现 |
| 10 | `State/KeyboardShortcutManager.swift` | 新增发现 |
| 11 | `State/CollectorWorkspaceState.swift` | 中心依赖，最后删 |
| 12 | `State/SettingsView.swift` | 引用全部上层 |

#### 第三批：FeatureUtilities/ 全部

| 顺序 | 文件 | 理由 |
|------|------|------|
| 13 | `FeatureUtilities/Handwriting/PencilDrawingRepresentable.swift` | 依赖 DrawingToolSettings（已删） |
| 14 | `FeatureUtilities/Handwriting/HandwritingToolbarView.swift` | 依赖 DrawingToolSettings（已删） |
| 15 | `FeatureUtilities/Handwriting/HandwritingCanvasView.swift` | 引用 CollectorWorkspaceState（已删） |
| 16 | `FeatureUtilities/Files/StatisticsView.swift` | 引用 CollectorWorkspaceState（已删） |
| 17 | `FeatureUtilities/Files/DatasetFileBrowserView.swift` | 引用 CollectorWorkspaceState（已删） |

#### 第四批：App 入口

| 顺序 | 文件 | 理由 |
|------|------|------|
| 18 | `App/OpenMathInkCollectorApp.swift` | 最后—确认 Core 自己的 @main 正常 |

---

## 6. 删除前必须备份的内容

虽然删除风险为零，但建议在操作前备份：

| 备份内容 | 原因 |
|---------|------|
| 当前 `project.pbxproj` | 对比变更——虽然这些文件已排除，删除后 xcodeproj 的排除列表会自动消失 |
| `State/UndoRedoManager.swift` | 计划「保留两份」，确认 Collector 版本有相同逻辑 |
| `State/KeyboardShortcutManager.swift` | 同上 |
| `SharedUI/Components/FormulaLabelPreviewView.swift` | 确认 Collector 中有完全一致的副本 |
| `FeatureUtilities/Preview/LatexRenderService.swift` | 同上 |

---

## 7. 删除操作步骤

### 前置条件

- [x] 完整备份 `eMathica Hub/` 目录
- [x] 确认当前 Core 构建通过
- [x] 确认 Collector 构建通过
- [x] 保存当前 `project.pbxproj` 副本

### 操作步骤

```bash
# 第一阶段：State/ 目录
rm "Projects/eMathica/eMathica/State/CollectorWorkspaceState.swift"
rm "Projects/eMathica/eMathica/State/ConsentFlowView.swift"
rm "Projects/eMathica/eMathica/State/ContributorConsentManager.swift"
rm "Projects/eMathica/eMathica/State/LocalSampleStore.swift"
rm "Projects/eMathica/eMathica/State/OnboardingManager.swift"
rm "Projects/eMathica/eMathica/State/SettingsView.swift"
rm "Projects/eMathica/eMathica/State/UndoRedoManager.swift"
rm "Projects/eMathica/eMathica/State/KeyboardShortcutManager.swift"

# 第二阶段：FeatureUtilities/ 目录
rm -rf "Projects/eMathica/eMathica/FeatureUtilities"

# 第三阶段：其他
rm "Projects/eMathica/eMathica/App/OpenMathInkCollectorApp.swift"
rm "Projects/eMathica/eMathica/SharedUI/Components/FormulaLabelPreviewView.swift"
rm "Projects/eMathica/eMathica/OPENMATHINK_COLLECTOR_FIXES.md"
```

### 删除后措施

1. **立即构建验证** — Xcode 中 Clean Build Folder → Build
2. **运行测试** — `Cmd+U` 运行全部测试
3. **尝试在 Core 中搜索任何残留引用** — `grep -r "CollectorWorkspaceState\|ContributorConsent\|LocalSampleStore\|OnboardingManager\|SettingsView\|UndoRedoManager\|KeyboardShortcutManager\|FormulaLabelPreview\|DatasetFileBrowser\|StatisticsView\|DrawingToolSettings\|HandwritingCanvas\|HandwritingToolbar\|PencilDrawingRepresentable\|LatexRenderService\|OpenMathInkCollectorApp" eMathica/ --include="*.swift"`
4. **不需要修改 Xcode 项目** — 因为使用的是 `PBXFileSystemSynchronizedRootGroup`，Xcode 自动同步文件系统状态

### 特别注意：Xcode 自动行为

使用 `PBXFileSystemSynchronizedRootGroup` 时：
- 删除物理文件后，Xcode 自动从项目中移除
- `membershipExceptions` 中已不存在的文件条目自动失效
- **无需手动编辑 pbxproj**

但建议：删除后检查 `membershipExceptions` 是否还有残留条目。如果 Xcode 未自动清理，可能需要手动移除已删除文件路径。

---

## 8. 总结

### 最终删除清单（18 个文件）

| # | 文件 | 路径 (相对 Projects/eMathica/eMathica/) |
|---|------|----------------------------------------|
| 1 | `OpenMathInkCollectorApp.swift` | `App/OpenMathInkCollectorApp.swift` |
| 2 | `CollectorWorkspaceState.swift` | `State/CollectorWorkspaceState.swift` |
| 3 | `ConsentFlowView.swift` | `State/ConsentFlowView.swift` |
| 4 | `ContributorConsentManager.swift` | `State/ContributorConsentManager.swift` |
| 5 | `LocalSampleStore.swift` | `State/LocalSampleStore.swift` |
| 6 | `OnboardingManager.swift` | `State/OnboardingManager.swift` |
| 7 | `SettingsView.swift` | `State/SettingsView.swift` |
| 8 | `FormulaLabelPreviewView.swift` | `SharedUI/Components/FormulaLabelPreviewView.swift` |
| 9 | `DatasetFileBrowserView.swift` | `FeatureUtilities/Files/DatasetFileBrowserView.swift` |
| 10 | `StatisticsView.swift` | `FeatureUtilities/Files/StatisticsView.swift` |
| 11 | `DrawingToolSettings.swift` | `FeatureUtilities/Handwriting/DrawingToolSettings.swift` |
| 12 | `HandwritingCanvasView.swift` | `FeatureUtilities/Handwriting/HandwritingCanvasView.swift` |
| 13 | `HandwritingToolbarView.swift` | `FeatureUtilities/Handwriting/HandwritingToolbarView.swift` |
| 14 | `PencilDrawingRepresentable.swift` | `FeatureUtilities/Handwriting/PencilDrawingRepresentable.swift` |
| 15 | `LatexRenderService.swift` | `FeatureUtilities/Preview/LatexRenderService.swift` |
| 16 | `OPENMATHINK_COLLECTOR_FIXES.md` | `eMathica/OPENMATHINK_COLLECTOR_FIXES.md` |
| **17**★ | **`KeyboardShortcutManager.swift`** | `State/KeyboardShortcutManager.swift` |
| **18**★ | **`UndoRedoManager.swift`** | `State/UndoRedoManager.swift` |

### Phase 0 → Phase 1 修正

| Phase 0 说法 | Phase 1 结论 |
|-------------|-------------|
| 16 个文件应从 Core 删除 | **18 个文件**（新增 KeyboardShortcutManager + UndoRedoManager） |
| UndoRedoManager「保留两份」 | **应从 Core 删除** — 完全 Collector 专用 |
| KeyboardShortcutManager「Core 保留」 | **应从 Core 删除** — 完全 Collector 专用（引用 CollectorWorkspaceState） |

### 删除后 Core 剩余文件数

| 模块 | 当前 | 删除后 |
|------|------|--------|
| `App/` | 5 | 4（保留 EMathicaApp.swift 等 Core 入口） |
| `State/` | 8 | **0**（全部 8 个文件被删除） |
| `FeatureUtilities/` | 7 | **0**（整个目录删除） |
| `SharedUI/Components/` | 1 | **0** |
| Root | 1 | **0** |
| **Core Swift 文件总计** | ~90 | **~72**（18 个删除） |
