# FeatureUtilities Ownership Audit

> Date: 2026-06-22
> Scope: Read-only comparison of FeatureUtilities (eMathica app) vs corresponding files in OpenMathInkCollector
> Paired files: 7 direct filename matches + additional related duplicates found

---

## 1. Executive Summary

The eMathica app's `FeatureUtilities/` and the Collector app share **7 directly
paired files** that are functionally the same code. None are byte-identical; all
have diverged to varying degrees — some trivially (property wrapper choice),
others significantly (async API adoption, robustness improvements, layout polish).

| Category | Count | Files |
|---|---|---|
| **Shared candidates** (extract to package) | 7 | All paired files listed below |
| **IDENTICAL** | 1 | `DatasetFileBrowserView.swift`, `PencilDrawingRepresentable.swift` |
| **NEAR_IDENTICAL** (minor) | 3 | `HandwritingToolbarView.swift`, `DrawingToolSettings.swift`, `HandwritingCanvasView.swift` |
| **NEAR_IDENTICAL** (diverged) | 2 | `StatisticsView.swift`, `LatexRenderService.swift` |
| **eMathica only** (FeatureUtilities, no Collector match) | 0 | — |
| **Collector only** (no FeatureUtilities match) | 4 | `DatasetPackageBuilder.swift`, `PrivacyNoticeView.swift`, `SampleDetailView.swift`, `LatexPreviewView.swift` |

**Additional related duplicates found outside FeatureUtilities scope:**

| Location | Duplicate Status |
|---|---|
| `eMathica/SharedUI/Components/FormulaLabelPreviewView.swift` ↔ `Collector/Shared/Components/FormulaLabelPreviewView.swift` | Near-identical (~26 byte diff) |
| `eMathica/State/` (8 files) ↔ `Collector/State/` (6 files) | 6 files shared, 2 eMathica-only |

**Verdict:** All 7 FeatureUtilities files should be extracted into
`EMathicaCollectorSharedKit`. For 3 of the 7 files the **Collector version**
should be the Source of Truth (it is the more actively developed copy). For 3 files
both versions are equally valid. For 2 files (`PencilDrawingRepresentable.swift`,
`DatasetFileBrowserView.swift`) either version is identical.

---

## 2. Shared Candidates

### 2.1 File Comparison Table

| # | Filename | App Lines | Col Lines | Status | Key Difference(s) |
|---|---|---|---|---|---|
| 1 | `DatasetFileBrowserView.swift` | 457 | 457 | **IDENTICAL** | No differences |
| 2 | `StatisticsView.swift` | 208 | 220 | **NEAR_IDENTICAL** | App syncs `getStorageUsage()`; Collector uses `async/await` |
| 3 | `DrawingToolSettings.swift` | 151 | 163 | **NEAR_IDENTICAL** | Collector adds safety guards + macOS AppKit + error handling |
| 4 | `HandwritingCanvasView.swift` | 110 | 104 | **NEAR_IDENTICAL** | App: text-only badge; Collector: `status.icon` + `status.color` |
| 5 | `HandwritingToolbarView.swift` | 143 | 143 | **NEAR_IDENTICAL** | App: `@StateObject`; Collector: `@ObservedObject` |
| 6 | `PencilDrawingRepresentable.swift` | 135 | 135 | **IDENTICAL** | No differences |
| 7 | `LatexRenderService.swift` | 213 | 253 | **NEAR_IDENTICAL** | Collector has richer `renderToUIImage`/`renderToNSImage` with padding, font, background, symbol replacements |

### 2.2 Detailed Diffs

#### DatasetFileBrowserView.swift — IDENTICAL ✅
Both files are 457 lines with byte-identical content. This is a pure copy.
**Extraction: trivial.**

#### StatisticsView.swift — Async divergence
**App version** (line 117-128):
```swift
private func refreshStats() {
    let storageUsage = workspace.getStorageUsage()
    stats = StorageStats(...)
}
```
**Collector version** (line 117-140):
```swift
private func refreshStats() {
    stats = StorageStats(...) // initial with 0s
    Task {
        let storageUsage = await workspace.getStorageUsage()
        await MainActor.run { stats = StorageStats(...) }
    }
}
```
The Collector version has migrated to `async/await` while the App version uses
a synchronous API. **The Collector version is the source of truth.** After
extraction, the App must be updated to use the async API.

#### DrawingToolSettings.swift — Safety & platform improvements
The Collector version adds:
1. **Safety guards** on `currentColor` (line 54-58) and `currentThickness` (line 62-66):
   ```swift
   guard colorIndex >= 0 && colorIndex < colors.count else { return colors[0] }
   ```
2. **macOS support** in `uiColor()` (line 108):
   ```swift
   #elseif canImport(AppKit)
   return UIColor(cgColor: NSColor(color).cgColor) ?? .label
   ```
3. **Error handling** in `saveSettings()` and `loadSettings()`:
   ```swift
   // App: silent
   if let data = try? encoder.encode(self)
   // Collector: prints error
   do { ... } catch { print("[DrawingToolSettings] 设置保存失败: \(error)") }
   ```

**The Collector version is the source of truth** (more robust, cross-platform).

#### HandwritingCanvasView.swift — Status badge refinement
**App** (line 90-98):
```swift
private var statusBadge: some View {
    Text(workspace.selectedSample?.status.displayName ?? "草稿")
        ...
}
```
**Collector** (line 90-103):
```swift
private var statusBadge: some View {
    let status = workspace.selectedSample?.status ?? .draft
    return HStack(spacing: 4) {
        Image(systemName: status.icon)
            .font(.caption2)
        Text(status.displayName)
            ...
    }
}
```
The Collector adds an icon to the status badge and uses `status.color` instead
of hardcoded logic. **Either version is acceptable**; recommend the Collector
version as it is more visually informative.

#### HandwritingToolbarView.swift — Property wrapper difference
**App:** `@StateObject private var toolSettings = DrawingToolSettings.shared`
**Collector:** `@ObservedObject private var toolSettings = DrawingToolSettings.shared`

`DrawingToolSettings.shared` is a singleton. `@StateObject` keeps the reference
alive across view recreation; `@ObservedObject` doesn't. Since it's a singleton,
`@ObservedObject` is technically correct and `@StateObject` is unnecessary but
harmless. **Recommend `@ObservedObject`** (Collector version).

#### PencilDrawingRepresentable.swift — IDENTICAL ✅
Both files are 135 lines across iOS (`UIViewRepresentable`) and macOS
(`NSViewRepresentable`) with byte-identical content. **Extraction: trivial.**

#### LatexRenderService.swift — Significant rendering improvement
The Collector version has a much richer rendering pipeline:
- App: simple `NSAttributedString(string:)` → draw in rect
- Collector: `normalizeAndFormat()` with `latexSymbolReplacements`, `UIFont.monospacedSystemFont`, padding, background, `NSColor.controlBackgroundColor`, `NSFont.monospacedSystemFont`

Additionally, the Collector's `TextSubstitutionRenderService` uses `" "` instead
of `"⁄"` for `\frac` substitution, aligning with the main preview.

**The Collector version is the source of truth** — it renders more accurately
with proper formatting.

### 2.3 Recommended Source of Truth Per File

| File | Source of Truth | Reason |
|---|---|---|
| `DatasetFileBrowserView.swift` | Either (identical) | Byte-identical |
| `StatisticsView.swift` | **Collector** | Async API, more correct |
| `DrawingToolSettings.swift` | **Collector** | Safety guards + macOS + error handling |
| `HandwritingCanvasView.swift` | **Collector** (recommended) | Icon + color, more informational |
| `HandwritingToolbarView.swift` | **Collector** | `@ObservedObject` is semantically correct |
| `PencilDrawingRepresentable.swift` | Either (identical) | Byte-identical |
| `LatexRenderService.swift` | **Collector** | Richer rendering pipeline |

**Overall: 5 files from Collector, 2 files either-side.**

---

## 3. eMathica Only

These files exist in `FeatureUtilities/` and have **no counterpart in the Collector's
source**:

*(None — all 7 files in FeatureUtilities are duplicated in the Collector)*

However, eMathica has **additional duplicated state files** outside FeatureUtilities
that share logic with the Collector:

| eMathica Path | Collector Path | Notes |
|---|---|---|
| `eMathica/State/CollectorWorkspaceState.swift` | `Collector/State/CollectorWorkspaceState.swift` | Both apps have this |
| `eMathica/State/ConsentFlowView.swift` | `Collector/State/ConsentFlowView.swift` | Both apps have this |
| `eMathica/State/ContributorConsentManager.swift` | `Collector/State/ContributorConsentManager.swift` | Both apps have this |
| `eMathica/State/OnboardingManager.swift` | `Collector/State/OnboardingManager.swift` | Both apps have this |
| `eMathica/State/SettingsView.swift` | `Collector/State/SettingsView.swift` | Both apps have this |
| `eMathica/State/UndoRedoManager.swift` | `Collector/State/UndoRedoManager.swift` | Both apps have this |
| `eMathica/State/LocalSampleStore.swift` | `Collector/Modules/Files/LocalSampleStore.swift` | Both apps have this, different sizes |
| `eMathica/State/KeyboardShortcutManager.swift` | *(none)* | eMathica-only |
| `eMathica/SharedUI/Components/FormulaLabelPreviewView.swift` | `Collector/Shared/Components/FormulaLabelPreviewView.swift` | Near-identical |

These are **out of scope** for the `EMathicaCollectorSharedKit` extraction but
should be noted for Phase 2 planning.

---

## 4. Collector Only

These files exist in the Collector's `Modules/` and `Shared/` directories but have
**no counterpart in FeatureUtilities**:

| File | Path in Collector | Purpose |
|---|---|---|
| `DatasetPackageBuilder.swift` | `Modules/Files/DatasetPackageBuilder.swift` | Builds export data packages |
| `PrivacyNoticeView.swift` | `Modules/Files/PrivacyNoticeView.swift` | Privacy notice sheet view |
| `SampleDetailView.swift` | `Modules/Files/SampleDetailView.swift` | Sample detail panel |
| `LatexPreviewView.swift` | `Modules/Preview/LatexPreviewView.swift` | LaTeX preview view |
| `CollectorMathInputState.swift` | `Modules/KeyboardInput/CollectorMathInputState.swift` | Math input state management |
| `LatexKeyboardInputView.swift` | `Modules/KeyboardInput/LatexKeyboardInputView.swift` | LaTeX keyboard input |
| `MathKeyboardKey.swift` | `Modules/KeyboardInput/MathKeyboardKey.swift` | Keyboard key component |
| `MathKeyboardView.swift` | `Modules/KeyboardInput/MathKeyboardView.swift` | Keyboard layout view |
| `CollectorCardStyle.swift` | `Shared/Theme/CollectorCardStyle.swift` | Card style modifier |
| `PlatformImageLoader.swift` | `Shared/Utilities/PlatformImageLoader.swift` | Cross-platform image loading |

These files represent Collector-specific functionality. Most are candidates for
the `EMathicaCollectorSharedKit` only if the eMathica app also needs them.
`CollectorCardStyle.swift` is used by both apps (via `HandwritingCanvasView.swift`
line 87: `.collectorCardStyle()`) but is defined in the Collector's Shared/Theme.

---

## 5. Proposed CollectorSharedKit Structure

```
Projects/Packages/EMathicaCollectorSharedKit/
├── Package.swift
├── Sources/
│   └── EMathicaCollectorSharedKit/
│       ├── Handwriting/
│       │   ├── DrawingToolSettings.swift       ← Collector version (SoT)
│       │   ├── HandwritingCanvasView.swift      ← Collector version (SoT)
│       │   ├── HandwritingToolbarView.swift     ← Collector version (SoT)
│       │   └── PencilDrawingRepresentable.swift ← either (identical)
│       ├── Preview/
│       │   ├── LatexRenderService.swift         ← Collector version (SoT)
│       │   └── LatexPreviewView.swift           ← Collector-only, optional
│       ├── Files/
│       │   ├── DatasetFileBrowserView.swift     ← either (identical)
│       │   ├── DatasetPackageBuilder.swift      ← Collector-only, optional
│       │   ├── PrivacyNoticeView.swift          ← Collector-only, optional
│       │   ├── SampleDetailView.swift           ← Collector-only, optional
│       │   └── StatisticsView.swift             ← Collector version (SoT)
│       └── Theme/
│           └── CollectorCardStyle.swift         ← needed by both apps
└── Tests/
    └── EMathicaCollectorSharedKitTests/
```

### Shared code (required by both apps)

| Source | Target in Package | SoT |
|---|---|---|
| `FeatureUtilities/Handwriting/DrawingToolSettings.swift` | `Handwriting/DrawingToolSettings.swift` | Collector |
| `FeatureUtilities/Handwriting/HandwritingCanvasView.swift` | `Handwriting/HandwritingCanvasView.swift` | Collector |
| `FeatureUtilities/Handwriting/HandwritingToolbarView.swift` | `Handwriting/HandwritingToolbarView.swift` | Collector |
| `FeatureUtilities/Handwriting/PencilDrawingRepresentable.swift` | `Handwriting/PencilDrawingRepresentable.swift` | Either |
| `FeatureUtilities/Preview/LatexRenderService.swift` | `Preview/LatexRenderService.swift` | Collector |
| `FeatureUtilities/Files/DatasetFileBrowserView.swift` | `Files/DatasetFileBrowserView.swift` | Either |
| `FeatureUtilities/Files/StatisticsView.swift` | `Files/StatisticsView.swift` | Collector |
| `Collector/Shared/Theme/CollectorCardStyle.swift` | `Theme/CollectorCardStyle.swift` | Collector |

### Collector-specific (extract if both apps need them)

| Source | Target in Package | Decision |
|---|---|---|
| `Collector/Modules/Files/DatasetPackageBuilder.swift` | `Files/DatasetPackageBuilder.swift` | Collector-only for now |
| `Collector/Modules/Files/PrivacyNoticeView.swift` | `Files/PrivacyNoticeView.swift` | Collector-only for now |
| `Collector/Modules/Files/SampleDetailView.swift` | `Files/SampleDetailView.swift` | Collector-only for now |
| `Collector/Modules/Preview/LatexPreviewView.swift` | `Preview/LatexPreviewView.swift` | Collector-only for now |

---

## 6. Migration Plan

### Phase 2a: Create EMathicaCollectorSharedKit Package

| Step | Action | Risk |
|---|---|---|
| 1 | Create `Projects/Packages/EMathicaCollectorSharedKit/` with `Package.swift` | Low |
| 2 | Copy 8 shared source files into `Handwriting/`, `Preview/`, `Files/`, `Theme/` subdirectories | Low |
| 3 | Add `public` access modifiers to all types and methods (package needs them) | Medium |
| 4 | Write the `Package.swift` manifest (depends on `EMathicaMathCore`, `EMathicaThemeKit`, `EMathicaMathInputKit`) | Low |

### Phase 2b: Update eMathica App

| Step | Action | Risk |
|---|---|---|
| 5 | Add EMathicaCollectorSharedKit as dependency in `eMathica.xcodeproj` | Low |
| 6 | Update imports in eMathica files that use these types | Medium |
| 7 | Update `StatisticsView` call site to use async `workspace.getStorageUsage()` API | Medium |
| 8 | Remove `FeatureUtilities/` files from eMathica xcodeproj target | Medium |
| 9 | ✅ Build & test | High |

### Phase 2c: Update OpenMathInkCollector

| Step | Action | Risk |
|---|---|---|
| 10 | Add EMathicaCollectorSharedKit as dependency in `OpenMathInkCollector.xcodeproj` | Low |
| 11 | Remove duplicate `Modules/Handwriting/`, `Modules/Files/`, `Modules/Preview/`, `Shared/Theme/` files | Medium |
| 12 | Update imports in Collector files | Medium |
| 13 | ✅ Build & test | High |

### Phase 2d: Cleanup

| Step | Action | Risk |
|---|---|---|
| 14 | Delete `Projects/eMathica/eMathica/FeatureUtilities/` | Low (after verification) |
| 15 | Delete redundant files from Collector's `Modules/` and `Shared/` | Low (after verification) |

---

## 7. Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **StatisticsView async API mismatch** — eMathica app's `CollectorWorkspaceState` may not have async `getStorageUsage()` | Medium | Build breakage | Verify `getStorageUsage()` signature in both apps; add async overload if needed |
| **HandwritingCanvasView uses `collectorCardStyle()`** — this modifier is defined in Collector's `Shared/Theme/CollectorCardStyle.swift` and must also be in the package | **Certain** | Build breakage for eMathica | Include `CollectorCardStyle.swift` in the package (lines 8) |
| **LatexRenderService imports EMathicaMathInputCore** — package dependency chain must include this | Low | Package resolution fails | Add `EMathicaMathInputKit` as dependency |
| **Access control** — all extracted types need `public` + `public init()` | High | Build breakage for cross-module access | Required for all files going into the package |
| **HandwritingToolbarView's ToolButton/ColorButton/ThicknessButton** — these are `private struct`s inside the file. Package access means they may not need to be public if the parent view is public | Low | OK as-is | Private nested types work across modules in Swift |
| **StatisticsView has diverged UI** — collector has more rows/layout differences | Low | Visual inconsistency after extraction | Use Collector version as SoT; both apps get the same view |
| **LatexRenderService extension on MathRenderer** — this is a cross-module extension and must be in a file that imports `EMathicaMathInputCore` | Low | Extension not found | Keep in the package; `EMathicaMathInputCore` is a dependency |
