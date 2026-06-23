# Phase 1.5: Core → Collector 重复文件副本一致性验证

> **日期:** 2026-06-23  
> **操作:** 只读比对 — 未移动、未删除、未修改任何文件  
> **目标:** 确认 Collector 是否存在完整对应副本、内容是否一致、删除条件是否成立

---

## 1. Core → Collector 对应表

### 1.1 全部 18 个文件逐项验证

| # | Core 文件 (相对 `eMathica/eMathica/`) | Collector 对应路径 | 存在? | 相同? | 大小 (Core / Collector) | 建议 |
|---|----------------------------------------|-------------------|-------|-------|------------------------|------|
| 1 | `App/OpenMathInkCollectorApp.swift` | `App/OpenMathInkCollectorApp.swift` | ✅ | ❌ 不同 | 505 / 696 B | **Collector 更新** → 可直接删除 Core 副本 |
| 2 | `State/CollectorWorkspaceState.swift` | `State/CollectorWorkspaceState.swift` | ✅ | ❌ **差异大** | 19087 / 18111 B | **Collector 更新** → 可直接删除 Core 副本 |
| 3 | `State/ConsentFlowView.swift` | `State/ConsentFlowView.swift` | ✅ | ✅ **相同** | 6885 / 6885 B | ✅ 可直接删除 |
| 4 | `State/ContributorConsentManager.swift` | `State/ContributorConsentManager.swift` | ✅ | ❌ 不同 | 2245 / 2831 B | **Collector 更新** (有缓存) → 可直接删除 |
| 5 | `State/LocalSampleStore.swift` | `Modules/Files/LocalSampleStore.swift` | ✅ | ❌ **差异大** | 11309 / 7950 B | **实现不同** (Core 有正式错误类型, Collector 有 cleanup) → 可直接删除 |
| 6 | `State/OnboardingManager.swift` | `State/OnboardingManager.swift` | ✅ | ❌ 微差 | 5185 / 5183 B | **Collector 更新** (@EnvironmentObject) → 可直接删除 |
| 7 | `State/SettingsView.swift` | `State/SettingsView.swift` | ✅ | ❌ 不同 | 7764 / 10617 B | **Collector 更新** (有隐私说明+许可证) → 可直接删除 |
| 8 | `State/KeyboardShortcutManager.swift` | — | ❌ **不存在!** | — | 5980 / N/A | ⚠️ **需先同步到 Collector** 再删除 |
| 9 | `State/UndoRedoManager.swift` | `State/UndoRedoManager.swift` | ✅ | ✅ **相同** | 3726 / 3726 B | ✅ 可直接删除 |
| 10 | `SharedUI/Components/FormulaLabelPreviewView.swift` | `Shared/Components/FormulaLabelPreviewView.swift` | ✅ | ❌ 不同 | 3498 / 3524 B | **Collector 更新** (latexSymbolReplacements 常量化) → 可直接删除 |
| 11 | `FeatureUtilities/Files/DatasetFileBrowserView.swift` | `Modules/Files/DatasetFileBrowserView.swift` | ✅ | ✅ **相同** | 16590 / 16590 B | ✅ 可直接删除 |
| 12 | `FeatureUtilities/Files/StatisticsView.swift` | `Modules/Files/StatisticsView.swift` | ✅ | ❌ 不同 | 6609 / 7161 B | **Collector 更新** (async getStorageUsage) → 可直接删除 |
| 13 | `FeatureUtilities/Handwriting/DrawingToolSettings.swift` | `Modules/Handwriting/DrawingToolSettings.swift` | ✅ | ❌ 不同 | 4456 / 4968 B | **Collector 更新** (bounds check + 错误处理) → 可直接删除 |
| 14 | `FeatureUtilities/Handwriting/HandwritingCanvasView.swift` | `Modules/Handwriting/HandwritingCanvasView.swift` | ✅ | ❌ 不同 | 4110 / 3996 B | **Collector 更新** (使用 status.icon) → 可直接删除 |
| 15 | `FeatureUtilities/Handwriting/HandwritingToolbarView.swift` | `Modules/Handwriting/HandwritingToolbarView.swift` | ✅ | ❌ 微差 | 4391 / 4394 B | **Collector 更新** (@ObservedObject) → 可直接删除 |
| 16 | `FeatureUtilities/Handwriting/PencilDrawingRepresentable.swift` | `Modules/Handwriting/PencilDrawingRepresentable.swift` | ✅ | ✅ **相同** | 4390 / 4390 B | ✅ 可直接删除 |
| 17 | `FeatureUtilities/Preview/LatexRenderService.swift` | `Modules/Preview/LatexRenderService.swift` | ✅ | ❌ **差异大** | 6903 / 8679 B | **Collector 更新** (normalizeAndFormat, 更好渲染) → 可直接删除 |
| 18 | `OPENMATHINK_COLLECTOR_FIXES.md` | — | — | — | 2927 / N/A | Core-only 文档, 无 Collector 对应 → 可直接删除 |

### 1.2 一致性统计

| 类别 | 数量 | 文件 |
|------|------|------|
| ✅ 完全一致 (可直接删除) | 4 | ConsentFlowView, UndoRedoManager, DatasetFileBrowserView, PencilDrawingRepresentable |
| 🟢 Collector 版本更新 (可直接删除) | 12 | OpenMathInkCollectorApp, CollectorWorkspaceState, ContributorConsentManager, LocalSampleStore, OnboardingManager, SettingsView, FormulaLabelPreviewView, StatisticsView, DrawingToolSettings, HandwritingCanvasView, HandwritingToolbarView, LatexRenderService |
| ⚠️ Core 有但 Collector 无 (需先同步) | 1 | **KeyboardShortcutManager** |
| 🟢 Core 特有文档 (可直接删除) | 1 | OPENMATHINK_COLLECTOR_FIXES.md |

---

## 2. 内容差异摘要

### 2.1 完全一致的文件（4 个）

这些文件在 Core 和 Collector 中 **字节级一致**，可以直接删除 Core 副本：

| 文件 | Core 字节 | Collector 字节 | 确认方式 |
|------|----------|--------------|---------|
| `ConsentFlowView.swift` | 6,885 | 6,885 | `diff` 零输出 |
| `UndoRedoManager.swift` | 3,726 | 3,726 | `diff` 零输出 |
| `DatasetFileBrowserView.swift` | 16,590 | 16,590 | `diff` 零输出 |
| `PencilDrawingRepresentable.swift` | 4,390 | 4,390 | `diff` 零输出 |

### 2.2 Collector 版本更新的文件（12 个）

这些文件在 Collector 中已有**更完善的版本**，Core 副本是旧版或中间态：

| 文件 | Collector 改进 | 程度 |
|------|---------------|------|
| `OpenMathInkCollectorApp.swift` | 新增 `consentManager` as `@ObservedObject` + `.environmentObject(consentManager)` | 小改进 |
| `CollectorWorkspaceState.swift` | async Task 延迟加载、undo/redo 抽取为私有方法、export 改用 async/await、getStorageUsage 改为 async、新增 ExportError 枚举 | **大重构** |
| `ContributorConsentManager.swift` | 新增 `cachedConsent` / `cachedConsentKey` 缓存机制、do/catch 错误处理 | 中等 |
| `LocalSampleStore.swift` | init 改为 non-throwing（降级到 tmp）、cleanupOrphanedFiles 更安全（空列表跳过）、storageUsage 方法 | **大重构** |
| `OnboardingManager.swift` | `@EnvironmentObject` 替代 `@StateObject` | 小改进 |
| `SettingsView.swift` | 新增 `PrivacyNoticeView` + `LicenseInfoView` sheet 显示、deleteAllSamples 改用 map+forEach | **功能增强** |
| `FormulaLabelPreviewView.swift` | `latexSymbolReplacements` 提取为模块级常量、`RenderServiceManager.shared` 替代 `= RenderServiceManager()` | 中等重构 |
| `StatisticsView.swift` | `getStorageUsage()` 改为 `async`、Task 异步加载统计数据 | 中等 |
| `DrawingToolSettings.swift` | `color(at:)` / `thickness(at:)` 新增 bounds check、`do/catch` 错误处理、macOS UIColor 兼容 | 中等 |
| `HandwritingCanvasView.swift` | 使用 `status.icon` + `status.color` 替代 `statusColor` 计算属性 | 小改进 |
| `HandwritingToolbarView.swift` | `@ObservedObject` 替代 `@StateObject` | 小改进 |
| `LatexRenderService.swift` | `normalizeAndFormat()` 函数、fallback 渲染带 padding + 背景、frac 改用空格替代 | **大重构** |

### 2.3 ⚠️ Core 有但 Collector 没有的文件（1 个）

#### `State/KeyboardShortcutManager.swift`（5,980 字节）

**Collector 中完全不存在此文件！**

分析：
- 定义 `KeyboardShortcut` struct、`KeyboardShortcutManager` class、`ShortcutDisplayItem` struct、`View.keyboardShortcuts()` extension、`KeyboardShortcutsHelpView`
- 所有快捷键方法调用 `CollectorWorkspaceState`（undo, redo, saveCurrentDraft, createNewSample, confirmCurrentSample, exportConfirmedSamples, requestDeleteSample, clearCurrentDrawing, clearFormulaInput）
- 行 111: `private func appWorkspace() -> CollectorWorkspaceState?` — 完全 Collector 依赖

**结论：** 这是 Collector 应该拥有但缺失的文件。在删除 Core 副本之前，**必须先复制到 Collector**。

### 2.4 Core 特有文档（1 个）

`OPENMATHINK_COLLECTOR_FIXES.md`（2,927 字节）— 记录 Collector 代码修复步骤的历史文档。对 Core 无意义，可以直接删除。

---

## 3. 唯一源确认

### 3.1 删除后以 Collector 版本为唯一源的文件

| 文件 | 删除后唯一源 |
|------|-------------|
| `OpenMathInkCollectorApp.swift` | Collector `App/` |
| `CollectorWorkspaceState.swift` | Collector `State/` |
| `ConsentFlowView.swift` | Collector `State/` |
| `ContributorConsentManager.swift` | Collector `State/` |
| `LocalSampleStore.swift` | Collector `Modules/Files/` |
| `OnboardingManager.swift` | Collector `State/` |
| `SettingsView.swift` | Collector `State/` |
| `UndoRedoManager.swift` | Collector `State/` |
| `FormulaLabelPreviewView.swift` | Collector `Shared/Components/` |
| `DatasetFileBrowserView.swift` | Collector `Modules/Files/` |
| `StatisticsView.swift` | Collector `Modules/Files/` |
| `DrawingToolSettings.swift` | Collector `Modules/Handwriting/` |
| `HandwritingCanvasView.swift` | Collector `Modules/Handwriting/` |
| `HandwritingToolbarView.swift` | Collector `Modules/Handwriting/` |
| `PencilDrawingRepresentable.swift` | Collector `Modules/Handwriting/` |
| `LatexRenderService.swift` | Collector `Modules/Preview/` |

### 3.2 删除后需要额外操作的文件

| 文件 | 操作 |
|------|------|
| `KeyboardShortcutManager.swift` | **先复制到 Collector `State/`**，再从 Core 删除 |
| `OPENMATHINK_COLLECTOR_FIXES.md` | 直接删除（Core 特有文档） |

### 3.3 未来可能提取到 SharedLibraries 的候选

以下文件在两个 app 中都存在（删除 Core 副本后 Collector 仍持有），且**不包含 Collector 特定业务逻辑**，未来可能提取到 SharedLibraries：

| 文件 | 分析 | 可行性 |
|------|------|--------|
| `FormulaLabelPreviewView.swift` | 纯 UI 组件，不依赖 Collector 特有类型 | ⭐ **高** — 适合提取 |
| `LatexRenderService.swift` | 协议 + 实现，不依赖 Collector 特有类型 | ⭐ **高** — 适合提取 |
| `PencilDrawingRepresentable.swift` | UIViewRepresentable 桥接，纯技术组件 | 🟡 中 — 但依赖 PencilKit |
| `DrawingToolSettings.swift` | 工具设置，纯数据模型 | 🟡 中 — 但依赖 UserDefaults |
| `UndoRedoManager.swift` | 通用撤销/重做管理器 | ⭐ **高** — 但当前写死了 Collector 类型 |

### 3.4 历史遗留文件（可完全删除）

| 文件 | 说明 |
|------|------|
| `OPENMATHINK_COLLECTOR_FIXES.md` | 2026-06-16 的修复记录，已过时 |

---

## 4. 删除后 Core 空目录分析

### 4.1 `State/` 目录

| 当前文件 (8) | 操作 | 删除后 |
|-------------|------|--------|
| CollectorWorkspaceState.swift | 删除 | — |
| ConsentFlowView.swift | 删除 | — |
| ContributorConsentManager.swift | 删除 | — |
| LocalSampleStore.swift | 删除 | — |
| OnboardingManager.swift | 删除 | — |
| SettingsView.swift | 删除 | — |
| KeyboardShortcutManager.swift | 删除 | — |
| UndoRedoManager.swift | 删除 | — |

**结论：`State/` 目录将完全变空。建议：**
- ✅ **删除 `State/` 空目录**
- Core 未来不使用 `State/` 命名（改用 `AppState/` + `Services/`）
- 空目录留在 Git 中会产生无意义跟踪

### 4.2 `FeatureUtilities/` 目录

| 当前子目录 | 文件 | 操作 | 删除后 |
|-----------|------|------|--------|
| `Files/` | DatasetFileBrowserView.swift, StatisticsView.swift | 删除 | 空 |
| `Handwriting/` | DrawingToolSettings.swift, HandwritingCanvasView.swift, HandwritingToolbarView.swift, PencilDrawingRepresentable.swift | 删除 | 空 |
| `Preview/` | LatexRenderService.swift | 删除 | 空 |

**结论：整个 `FeatureUtilities/` 树变空。建议：**
- ✅ **删除整个 `FeatureUtilities/` 目录树**（`rm -rf`）
- 这是历史遗留的"共享工具"目录，删除后不再重建

### 4.3 `SharedUI/Components/` 目录

| 当前文件 | 操作 | 删除后 |
|---------|------|--------|
| FormulaLabelPreviewView.swift | 删除 | 空 |

**结论：`SharedUI/Components/` 变空，但 `SharedUI/` 目录本身在 Core 架构中仍需要。建议：**
- ✅ **删除 `SharedUI/Components/FormulaLabelPreviewView.swift`**
- ✅ **删除空的 `SharedUI/Components/` 子目录**
- ⚠️ **保留 `SharedUI/` 目录** — Core 未来可能在此放置真正共享组件
- 如需保留空目录结构占位，可添加 `.gitkeep`

### 4.4 `App/` 目录

| 当前文件 (5) | 操作 | 删除后 |
|-------------|------|--------|
| EMathicaApp.swift | 保留 | ✅ 保留 |
| AppRootView.swift | 保留 | ✅ 保留 |
| AppNavigationState.swift | 保留 | ✅ 保留 |
| AppRoute.swift | 保留 | ✅ 保留 |
| Infrastructure/PersistenceController.swift | 保留 | ✅ 保留 |
| OpenMathInkCollectorApp.swift | 删除 | — |

**结论：`App/` 保留 4 个 Core 文件，删除 1 个 Collector 文件。目录正常使用中。**

### 空目录汇总

| 目录 | 删除后状态 | 建议 |
|------|----------|------|
| `State/` | 全空 | ✅ 删除整个目录 |
| `FeatureUtilities/` | 全空（含 3 个子目录） | ✅ 删除整个目录树 |
| `SharedUI/Components/` | 空（不含 `SharedUI/` 上级） | ✅ 删除 Components/ 子目录, 保留 SharedUI/ |
| `App/` | 正常（4 文件保留） | ✅ 无操作 |

---

## 5. Phase 1 正式执行建议

### 5.1 是否可以进入正式删除

| 条件 | 满足? | 说明 |
|------|-------|------|
| 删除不影响 Core 编译 | ✅ | Phase 1 Precheck 已确认零引用、已排除 target |
| Collector 有完整替代 | ⚠️ **部分满足** | 17/18 文件有 Collector 对应; **KeyboardShortcutManager 需先同步** |
| 删除顺序合理 | ✅ | 已有分批方案 |
| 删除后无副作用 | ✅ | 空目录清理方案已制定 |

**结论：✅ 可以进入正式删除，但需先处理 KeyboardShortcutManager。**

### 5.2 正式执行前置条件

- [x] Phase 0 审计确认 18 个文件
- [x] Phase 1 Precheck 确认零编译引用
- [x] Phase 1.5 确认 17/18 文件有 Collector 对应版本
- [ ] **同步 KeyboardShortcutManager.swift 到 Collector**（见下文）
- [ ] **对整个 eMathica Hub/ 目录做快照备份**
- [ ] **确认当前 Core 和 Collector 都构建通过**

### 5.3 正式删除批次

#### 预备批：先同步 KeyboardShortcutManager

```bash
cp "Projects/eMathica/eMathica/State/KeyboardShortcutManager.swift" \
   "Projects/OpenMathInkCollector/OpenMathInkCollector/OpenMathInkCollector/State/KeyboardShortcutManager.swift"
```

⚠️ **重要：复制后需要检查 Collector 的 xcodeproj 是否会自动包含此文件。** Collector 也使用 `PBXFileSystemSynchronizedRootGroup` 吗？需要核实。如果不自动包含，需在 Xcode 中手动添加。

#### 第一批：4 个完全相同的文件（最安全）

```bash
rm "Projects/eMathica/eMathica/State/ConsentFlowView.swift"
rm "Projects/eMathica/eMathica/State/UndoRedoManager.swift"
rm "Projects/eMathica/eMathica/FeatureUtilities/Files/DatasetFileBrowserView.swift"
rm "Projects/eMathica/eMathica/FeatureUtilities/Handwriting/PencilDrawingRepresentable.swift"
```

#### 第二批：轻微差异的文件（Collector 版本更新）

```bash
rm "Projects/eMathica/eMathica/App/OpenMathInkCollectorApp.swift"
rm "Projects/eMathica/eMathica/State/OnboardingManager.swift"
rm "Projects/eMathica/eMathica/SharedUI/Components/FormulaLabelPreviewView.swift"
rm "Projects/eMathica/eMathica/FeatureUtilities/Handwriting/HandwritingToolbarView.swift"
rm "Projects/eMathica/eMathica/FeatureUtilities/Handwriting/HandwritingCanvasView.swift"
```

#### 第三批：有差异但 Collector 版本更完善的文件

```bash
rm "Projects/eMathica/eMathica/State/ContributorConsentManager.swift"
rm "Projects/eMathica/eMathica/State/SettingsView.swift"
rm "Projects/eMathica/eMathica/FeatureUtilities/Files/StatisticsView.swift"
rm "Projects/eMathica/eMathica/FeatureUtilities/Handwriting/DrawingToolSettings.swift"
```

#### 第四批：大差异且 Collector 版本更优的文件

```bash
rm "Projects/eMathica/eMathica/State/CollectorWorkspaceState.swift"
rm "Projects/eMathica/eMathica/State/LocalSampleStore.swift"
rm "Projects/eMathica/eMathica/FeatureUtilities/Preview/LatexRenderService.swift"
rm "Projects/eMathica/eMathica/State/KeyboardShortcutManager.swift"  # 只在复制到 Collector 后
```

#### 第五批：文档 + 空目录清理

```bash
rm "Projects/eMathica/eMathica/OPENMATHINK_COLLECTOR_FIXES.md"
rm -rf "Projects/eMathica/eMathica/State"        # 整个目录空
rm -rf "Projects/eMathica/eMathica/FeatureUtilities"  # 整个目录树空
rm -rf "Projects/eMathica/eMathica/SharedUI/Components"  # 子目录空
```

#### 第六批：保留 SharedUI/ 目录结构

```bash
# SharedUI/ 保留，后续可能放新组件
touch "Projects/eMathica/eMathica/SharedUI/.gitkeep"
```

### 5.4 删除后验证步骤

| 步骤 | 操作 | 预期 |
|------|------|------|
| 1 | Core: Xcode Clean Build Folder + Build | ✅ 编译通过 |
| 2 | Core: 运行全部单元测试 (`Cmd+U`) | ✅ 全部通过 |
| 3 | Collector: Xcode Clean Build Folder + Build | ✅ 编译通过（含新增的 KeyboardShortcutManager） |
| 4 | Core: 搜索残留引用 | `grep -r` 无匹配 |
| 5 | 确认空目录已清理 | `State/`, `FeatureUtilities/`, `SharedUI/Components/` 不存在 |
| 6 | 确认 SharedUI/ 保留 | `SharedUI/` 存在（含 `.gitkeep`） |

### 5.5 关于 Xcode 项目的说明

Core 使用 `PBXFileSystemSynchronizedRootGroup`：
- 删除物理文件后，Xcode 自动从项目中移除
- `membershipExceptions` 中已删除文件的引用会自然失效
- **无需手动编辑 pbxproj**

Collector 如果也使用 `PBXFileSystemSynchronizedRootGroup`：
- 复制 `KeyboardShortcutManager.swift` 到 Collector `State/` 后，Xcode 自动包含
- **同样无需手动编辑 pbxproj**

---

## 6. 总结

### 总体结论

| 维度 | 结论 |
|------|------|
| 可直接删除的文件数 | **17/18**（有 Collector 对应版本） |
| 需先同步后删除的文件数 | **1/18**（KeyboardShortcutManager） |
| 删除后 Core 编译风险 | 🟢 零风险 |
| 删除后 Collector 功能影响 | 无影响（所有 Collector 功能完整） |
| 删除后空目录 | 3 个：State/, FeatureUtilities/, SharedUI/Components/ |
| **状态** | **✅ 可以进入正式删除（先同步 KeyboardShortcutManager）** |

### 重要行动项

| 优先级 | 行动 | 理由 |
|--------|------|------|
| 🔴 **P0** | 复制 `KeyboardShortcutManager.swift` 到 Collector | Collector 缺失此文件但需要它 |
| 🟡 P1 | 备份当前工作目录 | 防止意外 |
| 🟡 P1 | 确认 Core + Collector 当前能构建 | 删除前的基线验证 |
| 🟢 P2 | 按 6 批顺序执行删除 | 从最安全到最复杂 |
| 🟢 P2 | 删除后空目录清理 | 保持目录整洁 |
| 🟢 P2 | 构建 + 测试验证 | 确认删除无副作用 |
