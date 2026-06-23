# EMathicaCollectorSharedKit Architecture Plan

> Date: 2026-06-22
> Status: Read-only design proposal — no files or packages created
> Scope: Eliminate duplicated code between `FeatureUtilities/` and `OpenMathInkCollector`

---

## Current Duplication

### File-level duplication

| # | File | App | Collector | Status |
|---|---|---|---|---|
| 1 | `DatasetFileBrowserView.swift` | 457 lines | 457 lines | **IDENTICAL** |
| 2 | `StatisticsView.swift` | 208 lines | 220 lines | **NEAR_IDENTICAL** (sync vs async API) |
| 3 | `DrawingToolSettings.swift` | 151 lines | 163 lines | **NEAR_IDENTICAL** (Collector more robust) |
| 4 | `HandwritingCanvasView.swift` | 110 lines | 104 lines | **NEAR_IDENTICAL** (badge UI differs) |
| 5 | `HandwritingToolbarView.swift` | 143 lines | 143 lines | **NEAR_IDENTICAL** (@StateObject vs @ObservedObject) |
| 6 | `PencilDrawingRepresentable.swift` | 135 lines | 135 lines | **IDENTICAL** |
| 7 | `LatexRenderService.swift` | 213 lines | 253 lines | **NEAR_IDENTICAL** (Collector richer rendering) |

**Total duplicated lines: ~1,408** (both sides combined: ~2,816 if counting both copies)

### Additional related duplicates

| File | App | Collector | Status |
|---|---|---|---|
| `FormulaLabelPreviewView.swift` | `SharedUI/Components/` (98 lines) | `Shared/Components/` (98 lines) | Near-identical (~26 byte diff) |
| `CollectorCardStyle.swift` | *(not in app)* | `Shared/Theme/` (36 lines) | Collector-only, but used by both apps via `.collectorCardStyle()` |

---

## Shared Candidates

### Classification

| File | Category | Rationale |
|---|---|---|
| `DrawingToolSettings.swift` | **SHARED_READY** | Self-contained (`Foundation`, `PencilKit`, `SwiftUI`). No app-type dependencies. |
| `PencilDrawingRepresentable.swift` | **SHARED_READY** | Depends only on `DrawingToolSettings`. No app-type dependencies. |
| `HandwritingToolbarView.swift` | **SHARED_READY** | Depends only on `DrawingToolSettings`/`DrawingToolType`. |
| `CollectorCardStyle.swift` | **SHARED_READY** | Self-contained (`SwiftUI` only). 36 lines. |
| `LatexRenderService.swift` | **SHARED_READY** | Depends on `EMathicaMathInputCore` (`MathRenderer` protocol). No app-type dependencies. Needs compile verification for `MathRenderer()` usage. |
| `HandwritingCanvasView.swift` | **NEED_MERGE** | Depends on `CollectorWorkspaceState` (app-defined). Cannot extract without abstraction. |
| `DatasetFileBrowserView.swift` | **NEED_MERGE** | Depends on `CollectorWorkspaceState`, `MathInkSample`, `SampleStatus`, `EnhancedPrivacyNoticeView`, `SampleDetailView`. Heavy app coupling. |
| `StatisticsView.swift` | **NEED_MERGE** | Depends on `CollectorWorkspaceState`. |
| `FormulaLabelPreviewView.swift` | **NEED_MERGE** | Depends on `LatexRenderService` types (`RenderServiceManager`, `LatexRenderResult`). Extractable after LatexRenderService is in package. |
| `DatasetPackageBuilder.swift` | **COLLECTOR_ONLY** | Collector-specific export logic. |
| `PrivacyNoticeView.swift` | **COLLECTOR_ONLY** | Collector-specific view. |
| `SampleDetailView.swift` | **COLLECTOR_ONLY** | Collector-specific view. |
| `LatexPreviewView.swift` | **COLLECTOR_ONLY** | Collector-specific view. |
| `KeyboardInput/*` (4 files) | **COLLECTOR_ONLY** | Math keyboard UI; Collector-specific. |
| `State/CollectorWorkspaceState.swift` | **APP_ONLY** | Both apps have their own copy. Not extracted in this phase. |

### Extraction Readiness Summary

```
SHARED_READY:   4 files (DrawingToolSettings, PencilDrawingRepresentable,
                       HandwritingToolbarView, CollectorCardStyle)

SHARED_READY+:  1 file  (LatexRenderService — needs compile check)
NEED_MERGE:     3 files (HandwritingCanvasView, DatasetFileBrowserView,
                         StatisticsView)
COLLECTOR_ONLY: 8 files (remain in Collector app)
APP_ONLY:       1 file  (remain in eMathica app)
```

---

## Package Boundary

### Hard Boundary

Files that can be extracted **without** carrying app-level types:

```
SHARED READY ──────────────────────────────────────────
│  DrawingToolSettings.swift
│  PencilDrawingRepresentable.swift
│  HandwritingToolbarView.swift
│  CollectorCardStyle.swift
│  LatexRenderService.swift  (needs compile check)
└──────────────────────────────────────────────────────
                       │
                       ▼
            EMathicaCollectorSharedKit
                       │
                       ▼
Both apps consume ─────────────────────────────────────
```

### Soft Boundary (future phase)

Files that require `CollectorWorkspaceState` (or a protocol abstraction):

```
HandwritingCanvasView.swift
  ├── PencilDrawingRepresentable   ✅ (in package)
  ├── HandwritingToolbarView       ✅ (in package)
  ├── .collectorCardStyle()        ✅ (in package)
  └── CollectorWorkspaceState      ❌ (app-defined, needs protocol)

DatasetFileBrowserView.swift
  ├── CollectorWorkspaceState      ❌
  ├── MathInkSample / SampleStatus ❌
  └── EnhancedPrivacyNoticeView    ❌

StatisticsView.swift
  ├── CollectorWorkspaceState      ❌
  └── getStorageUsage()            ❌ (method on workspace)
```

### Recommendation

**Phase A:** Extract `SHARED_READY` files now. This eliminates ~680 lines of
duplicated code (DrawingToolSettings + PencilDrawingRepresentable +
HandwritingToolbarView + CollectorCardStyle + LatexRenderService).

**Phase B (future):** Abstract `CollectorWorkspaceState` behind a protocol,
then extract the remaining 3 files (HandwritingCanvasView, DatasetFileBrowserView,
StatisticsView). This is a larger effort that may also pull in `MathInkSample`,
`SampleStatus`, and `LocalSampleStore`.

---

## Dependency Graph

### Phase A (SHARED_READY)

```
EMathicaCollectorSharedKit
  │
  ├── Foundation          │ DrawingToolSettings, LatexRenderService
  ├── SwiftUI             │ All files
  ├── PencilKit           │ DrawingToolSettings, PencilDrawingRepresentable
  └── EMathicaMathInputCore  │ LatexRenderService (MathRenderer protocol)
```

**No dependency on EMathicaMathCore, EMathicaDocumentKit, or EMathicaThemeKit.**

### Phase B (NEED_MERGE, future)

```
EMathicaCollectorSharedKit (extended)
  │
  ├── Foundation
  ├── SwiftUI
  ├── PencilKit
  ├── EMathicaMathInputCore
  └── CollectorWorkspaceStateProtocol ← defined in package
                                        ← implemented by both apps
```

### What is NOT needed

| Package | Needed? | Why |
|---|---|---|
| `EMathicaMathCore` | ❌ No | Handwriting and rendering don't use MathObject, MathExpression, etc. |
| `EMathicaDocumentKit` | ❌ No | Collector doesn't use EMathicaDocument or ProjectStore. |
| `EMathicaThemeKit` | ❌ No | `CollectorCardStyle` uses its own styling, not GlassComponents. |

---

## Package Structure

### Recommended: Single Package (Phase A)

```
Projects/Packages/EMathicaCollectorSharedKit/
├── Package.swift
├── Sources/
│   └── EMathicaCollectorSharedKit/
│       ├── Handwriting/
│       │   ├── DrawingToolSettings.swift      ← Source of Truth: Collector
│       │   ├── DrawingToolType.swift           ← extracted from DrawingToolSettings
│       │   ├── PencilDrawingRepresentable.swift ← Source of Truth: either (identical)
│       │   └── HandwritingToolbarView.swift    ← Source of Truth: Collector
│       ├── Preview/
│       │   └── LatexRenderService.swift        ← Source of Truth: Collector
│       └── Theme/
│           └── CollectorCardStyle.swift        ← Source of Truth: Collector
└── Tests/
    └── EMathicaCollectorSharedKitTests/
        └── EMathicaCollectorSharedKitTests.swift
```

### Why Single Package?

The `DrawingToolType` enum is defined inside `DrawingToolSettings.swift` today,
and both `PencilDrawingRepresentable` and `HandwritingToolbarView` reference it.
Splitting into two packages would require:

| Package | Content | Problem |
|---|---|---|
| `EMathicaCollectorCoreKit` | `DrawingToolSettings`, `DrawingToolType` | Only 2 files — too small for a package |
| `EMathicaCollectorUISharedKit` | `PencilDrawingRepresentable`, `HandwritingToolbarView`, `LatexRenderService`, `CollectorCardStyle` | Depends on CoreKit — adds complexity with no benefit |

**A single `EMathicaCollectorSharedKit` package** with internal directory
organization is sufficient. If the package grows significantly in Phase B,
it can be split at that point.

### Internal module targets (optional)

If preferred, the `Package.swift` could define two library products from the
**same source** directory:

```swift
products: [
    .library(name: "EMathicaCollectorSharedKit", targets: ["EMathicaCollectorSharedKit"]),
]
```

Or, if `DrawingToolType` needs to be imported separately for `PencilKit`-only
code paths without `SwiftUI`:

```swift
targets: [
    .target(name: "EMathicaCollectorCore", path: "Sources/Core"),     // DrawingToolSettings (Foundation + PencilKit only)
    .target(name: "EMathicaCollectorUI", dependencies: ["EMathicaCollectorCore"], path: "Sources/UI"),  // Views (SwiftUI)
]
```

But this is unnecessary complexity for Phase A. **Recommend single target.**

---

## Recommended Source Of Truth

For files where both sides exist and have diverged, the **Collector version**
is the Source of Truth in 5 out of 5 cases.

| File | SoT | Reason |
|---|---|---|
| `DrawingToolSettings.swift` | **Collector** | Safety guards (index bounds), macOS `AppKit` support, error handling in save/load |
| `HandwritingCanvasView.swift` | **Collector** *(Phase B)* | Richer status badge with icon + `status.color` |
| `HandwritingToolbarView.swift` | **Collector** | `@ObservedObject` is semantically correct for a singleton; App uses `@StateObject` (redundant) |
| `PencilDrawingRepresentable.swift` | **Either** | Identical |
| `LatexRenderService.swift` | **Collector** | Richer rendering: padding, font configuration, background, `latexSymbolReplacements`, `normalizeAndFormat()` |
| `CollectorCardStyle.swift` | **Collector** *(only copy)* | — |
| `DatasetFileBrowserView.swift` | **Either** | Identical |
| `StatisticsView.swift` | **Collector** | Async `getStorageUsage()` — more modern API |

### When moving to the package

Each file needs `public` access modifiers added. Pattern from the
EMathicaDocumentKit migration:

```swift
// Before (App-internal):
struct DrawingToolSettings { ... }

// After (Package):
public struct DrawingToolSettings { ... }
```

---

## Migration Strategy

### Phase A: Core Extraction (estimated effort: medium)

| Step | Action | Files | Risk |
|---|---|---|---|
| A1 | Create `Projects/Packages/EMathicaCollectorSharedKit/` with `Package.swift` | New | Low |
| A2 | Copy 5 files into `Sources/EMathicaCollectorSharedKit/Handwriting/`, `Preview/`, `Theme/` | 5 files | Low |
| A3 | Add `public` access modifiers to all types, methods, properties | Across 5 files | Medium |
| A4 | Write `Package.swift` manifest (depends on none — only system frameworks) | 1 file | Low |
| A5 | Add package to both xcodeproj files | 2 xcodeproj | Medium |
| A6 | Remove `DrawingToolSettings`, `PencilDrawingRepresentable`, `HandwritingToolbarView` from both app targets | 2 targets | Medium |
| A7 | Update imports in both apps (`import EMathicaCollectorSharedKit`) | ~6 files | Low |
| A8 | ✅ Build & test both apps | 2 builds | High |

### Phase B: View Extraction (estimated effort: high)

| Step | Action | Risk |
|---|---|---|
| B1 | Define `CollectorWorkspaceProviding` protocol in the package | High — must cover all used properties/methods |
| B2 | Make both apps' `CollectorWorkspaceState` conform to the protocol | Medium |
| B3 | Move `HandwritingCanvasView`, `DatasetFileBrowserView`, `StatisticsView`, `FormulaLabelPreviewView` | Medium |
| B4 | Move `MathInkSample`, `SampleStatus` (needed by `DatasetFileBrowserView`) | Medium |
| B5 | ✅ Build & test both apps | High |

### Rollout order by file

```
Phase A ───────────────────────────────────────────────
  Week 1: DrawingToolSettings + DrawingToolType
  Week 1: PencilDrawingRepresentable
  Week 1: HandwritingToolbarView
  Week 2: CollectorCardStyle
  Week 2: LatexRenderService

Phase B ───────────────────────────────────────────────
  Week 3+: CollectorWorkspaceProviding protocol design
  Week 3+: HandwritingCanvasView
  Week 4+: DatasetFileBrowserView + StatisticsView
  Week 4+: FormulaLabelPreviewView
```

---

## Risks

| Risk | Phase | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| **`LatexRenderService` calls `MathRenderer()` as a constructor** — but `MathRenderer` is a protocol | A | **Certain** | Code won't compile in package | Must verify and fix before extraction. Either change to `LatexMathRenderer()` or add a concrete type. This may be a latent bug. |
| **`HandwritingToolbarView` uses private nested types** (`ToolButton`, `ColorButton`, `ThicknessButton`) | A | Low | These are `private` — fine in same file | No change needed; private types work across module boundaries in Swift |
| **`CollectorCardStyle` is referenced via `.collectorCardStyle()` in HandwritingCanvasView** — but CanvasView stays in app during Phase A | B | None | Not a problem | HandwritingCanvasView stays in the app in Phase A |
| **DrawingToolSettings is a singleton (`shared`)** — two apps sharing a package means both apps share the same UserDefaults key | A | Medium | Cross-app settings interference | Use `appGroupIdentifier` or different `UserDefaults` suite; or document as expected behavior |
| **Neither app has a git repo yet** — no version control for the package | A | Medium | Cannot tag versions | Initialize git after extraction; semantic versioning from v0.1.0 |
| **Phase B requires protocol extraction** — `CollectorWorkspaceState` has ~30+ properties and methods | B | High | Large protocol surface; hard to maintain parity | Start with a minimal protocol covering only what shared views need; grow over time |

---

## Final Recommendation

### Package Design

| Decision | Recommendation |
|---|---|
| **Number of packages** | **1** — `EMathicaCollectorSharedKit` |
| **Internal split** | Single target, directory-organized (`Handwriting/`, `Preview/`, `Theme/`) |
| **Source of Truth** | **Collector version** for all diverged files |
| **Dependencies** | `Foundation`, `SwiftUI`, `PencilKit`, `EMathicaMathInputCore` |
| **Phase A scope** | 5 files (~540 shared lines eliminated) |
| **Phase B scope** | 4 files (~860 additional lines, requires protocol abstraction) |

### Package.swift skeleton

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "EMathicaCollectorSharedKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "EMathicaCollectorSharedKit",
            targets: ["EMathicaCollectorSharedKit"]
        )
    ],
    dependencies: [
        .package(path: "../EMathicaMathInputKit")
    ],
    targets: [
        .target(
            name: "EMathicaCollectorSharedKit",
            dependencies: [
                .product(name: "EMathicaMathInputCore", package: "EMathicaMathInputKit")
            ],
            path: "Sources/EMathicaCollectorSharedKit"
        ),
        .testTarget(
            name: "EMathicaCollectorSharedKitTests",
            dependencies: ["EMathicaCollectorSharedKit"]
        )
    ]
)
```

### Verdict

**Phase A is actionable immediately.** The 5 shared-ready files are self-contained,
have no app-type dependencies, and represent a clean extraction boundary.
The one compile-time risk (`LatexRenderService` using `MathRenderer()` as a
constructor) must be verified and fixed as part of extraction — it may already
be a latent bug in the current code.

**Phase B should be deferred** until a protocol abstraction for
`CollectorWorkspaceState` is designed. This is a larger architectural decision
that involves defining the shared interface between both apps' workspace state
implementations.
