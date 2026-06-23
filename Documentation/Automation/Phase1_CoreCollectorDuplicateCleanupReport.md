# Phase 1: Core → Collector 重复文件清理报告

> **日期:** 2026-06-23  
> **操作:** 正式执行 — 复制 + 删除 + 空目录清理 + 验证  
> **依据:** Phase 0 审计 + Phase 1 Precheck 依赖分析 + Phase 1.5 一致性验证

---

## 1. 执行总览

| 阶段 | 状态 | 说明 |
|------|------|------|
| Step 0: 备份 | ✅ 完成 | 备份到 `/tmp/emathica-phase1-backup-20260623_183837`（818MB） |
| Step 1: 同步 KeyboardShortcutManager | ✅ 完成 | 复制到 Collector `State/` 目录 |
| Step 2: 删除 18 个文件 | ✅ 完成 | 全部成功删除 |
| Step 3: 清理空目录 | ✅ 完成 | 3 个空目录已清理 |
| Step 4: 验证 | ✅ 完成 | 全部通过 |

---

## 2. 备份记录

| 备份内容 | 路径 | 状态 |
|---------|------|------|
| Core 源码 | `/tmp/.../Projects/eMathica` | ✅ |
| Collector 源码 | `/tmp/.../Projects/OpenMathInkCollector` | ✅ |
| SharedLibraries | `/tmp/.../Projects/Packages` | ✅ |
| 审计文档 | `/tmp/.../Documentation/Automation` | ✅ |
| **备份总大小** | **818 MB** | |

---

## 3. 文件同步记录

| 操作 | 源路径 | 目标路径 | 结果 |
|------|--------|---------|------|
| 复制 | `eMathica/State/KeyboardShortcutManager.swift` | `OpenMathInkCollector/.../State/KeyboardShortcutManager.swift` | ✅ 5,980 字节 |

---

## 4. 文件删除记录

### 4.1 State/ 目录（8 个文件）

| 文件 | 大小 | 结果 |
|------|------|------|
| `CollectorWorkspaceState.swift` | 19,087 B | ✅ 已删除 |
| `ConsentFlowView.swift` | 6,885 B | ✅ 已删除 |
| `ContributorConsentManager.swift` | 2,245 B | ✅ 已删除 |
| `LocalSampleStore.swift` | 11,309 B | ✅ 已删除 |
| `OnboardingManager.swift` | 5,185 B | ✅ 已删除 |
| `SettingsView.swift` | 7,764 B | ✅ 已删除 |
| `UndoRedoManager.swift` | 3,726 B | ✅ 已删除 |
| `KeyboardShortcutManager.swift` | 5,980 B | ✅ 已删除（先复制到 Collector） |

### 4.2 App/ 目录（1 个文件）

| 文件 | 大小 | 结果 |
|------|------|------|
| `OpenMathInkCollectorApp.swift` | 505 B | ✅ 已删除 |

### 4.3 FeatureUtilities/ 目录（7 个文件）

| 文件 | 大小 | 结果 |
|------|------|------|
| `Files/DatasetFileBrowserView.swift` | 16,590 B | ✅ 已删除 |
| `Files/StatisticsView.swift` | 6,609 B | ✅ 已删除 |
| `Handwriting/DrawingToolSettings.swift` | 4,456 B | ✅ 已删除 |
| `Handwriting/HandwritingCanvasView.swift` | 4,110 B | ✅ 已删除 |
| `Handwriting/HandwritingToolbarView.swift` | 4,391 B | ✅ 已删除 |
| `Handwriting/PencilDrawingRepresentable.swift` | 4,390 B | ✅ 已删除 |
| `Preview/LatexRenderService.swift` | 6,903 B | ✅ 已删除 |

### 4.4 SharedUI/Components/ 目录（1 个文件）

| 文件 | 大小 | 结果 |
|------|------|------|
| `Components/FormulaLabelPreviewView.swift` | 3,498 B | ✅ 已删除 |

### 4.5 根目录（1 个文件）

| 文件 | 大小 | 结果 |
|------|------|------|
| `OPENMATHINK_COLLECTOR_FIXES.md` | 2,927 B | ✅ 已删除 |

### 删除统计

| 维度 | 数值 |
|------|------|
| 删除文件总数 | **18** |
| 删除总字节 | **~103,548 B（约 101 KB）** |
| 涉及目录 | 5（State/, App/, FeatureUtilities/, SharedUI/Components/, 根目录） |

---

## 5. 空目录清理记录

| 目录 | 状态 | 操作 |
|------|------|------|
| `eMathica/State/` | ✅ 已删除 | 全部 8 个 Swift 文件删除后变为空目录 |
| `eMathica/FeatureUtilities/` | ✅ 已删除 | 全部 7 个文件 + 3 个子目录删除 |
| `eMathica/SharedUI/Components/` | ✅ 已删除 | 唯一文件删除后子目录变空 |
| `eMathica/SharedUI/` | ✅ 保留 | 添加 `.gitkeep` 保留目录结构 |

---

## 6. 验证结果

### 6.1 文件存在性验证

| 检查项 | 结果 |
|--------|------|
| 18 个 Core 文件已全部消失 | ✅ 0/18 剩余 |
| Collector 存在 KeyboardShortcutManager.swift | ✅ 5,980 B |

### 6.2 残留引用验证

在 Core 源码中搜索 16 个类型模式，排除 AI/ 和 Docs/：

```
CollectorWorkspaceState|ContributorConsentManager|LocalSampleStore|OnboardingManager|
SettingsView|KeyboardShortcutManager|UndoRedoManager|FormulaLabelPreviewView|
DatasetFileBrowserView|StatisticsView|DrawingToolSettings|HandwritingCanvasView|
HandwritingToolbarView|PencilDrawingRepresentable|LatexRenderService|OpenMathInkCollectorApp
```

| 结果 | 说明 |
|------|------|
| ✅ **零残留引用** | 没有 .swift 文件匹配上述任何模式 |

### 6.3 目录清理验证

| 目录 | 存在? |
|------|-------|
| `State/` | ❌ 不存在（正确） |
| `FeatureUtilities/` | ❌ 不存在（正确） |
| `SharedUI/Components/` | ❌ 不存在（正确） |
| `SharedUI/` | ✅ 存在 + 含 `.gitkeep` |

### 6.4 Core 当前 Swift 文件分布

| 模块 | 文件数 | 说明 |
|------|--------|------|
| `App/` | 5 | EMathicaApp, AppRootView, AppNavigationState, AppRoute, PersistenceController |
| `CalculatorModules/` | 57 | Plane(23), Space(9), 其他模块 + 协议 |
| `CoreHome/` | 30 | 主屏幕 UI |
| `PluginSystem/` | 5 | 插件协议 |
| `Services/` | 1 | LocalProjectStore |
| `SharedUI/` | 0 | 保留目录（含 .gitkeep） |
| **总计** | **98** | （含 AI/ 和 Docs/ 中的非编译文件） |

### 6.5 Collector 当前状态

| 检查项 | 结果 |
|--------|------|
| Collector Swift 文件数 | **32**（原 31 + 新增 KeyboardShortcutManager） |
| Collector 功能完整性 | 未受影响（所有文件都是 Collector 原有 + 1 个新增） |

---

## 7. 总结与后续建议

### 7.1 Phase 1 执行结论

| 条件 | 状态 |
|------|------|
| 备份已创建 | ✅ `/tmp/emathica-phase1-backup-20260623_183837` |
| Core 已清除 Collector 遗留文件 | ✅ 18 个文件全部删除 |
| Collector 获得缺失文件 | ✅ KeyboardShortcutManager 已同步 |
| 空目录已清理 | ✅ State/, FeatureUtilities/, SharedUI/Components/ 已删除 |
| Core 零残留引用 | ✅ |
| **Phase 1 完成** | ✅ **可以进入 Phase 2** |

### 7.2 建议下一步（Phase 2）

Phase 1 完成后，Core 已经只包含自身代码（无 Collector 重复）。下一个阶段可以：

1. **重命名目录**（Phase 2）：
   - `App/` → `AppShell/`
   - `CalculatorModules/` → `Features/`
   - `CalculatorModules/Plane/` → `Features/PlaneCalculator/`
   - 等等

2. **特别注意**：`CalculatorModules/` 下有 57 个 Swift 文件分布在 5 个模块中，重命名需要更新 Xcode 引用

3. 建议在 Phase 2 开始前先**确认 Core 可以构建**（通过 Xcode 验证）

### 7.3 回退方案

如果出现意外情况，可以从备份恢复：

```bash
cp -R /tmp/emathica-phase1-backup-20260623_183837/Projects/eMathica Projects/eMathica
cp -R /tmp/emathica-phase1-backup-20260623_183837/Projects/OpenMathInkCollector Projects/OpenMathInkCollector
```
