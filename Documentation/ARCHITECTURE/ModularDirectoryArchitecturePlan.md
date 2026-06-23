# Modular Directory Architecture Plan

> Status: **Read-only proposal** — no files moved, no files modified.
> Scope: eMathica Hub top-level + three sub-projects (eMathica app, OpenMathInk Collector, Packages)

---

## 1. Current Problems

### 1.1 Duplicated Source Files Across Projects

| Source | Duplicate In | Status |
|---|---|---|
| `eMathica/DocumentSystem/` (11 files) | `Packages/EMathicaDocumentKit/` (10 files) | Near-identical, package lacks `LocalProjectStore.swift`. App-side copy should be deleted — the package is the canonical location. |
| `eMathica/FeatureUtilities/` (7 files) | `OpenMathInkCollector/Modules/` (9+ files) | Files have diverged (different byte sizes). `PencilDrawingRepresentable.swift` is byte-identical. Shared code not extracted to a package. |
| `eMathica/SharedUI/Components/FormulaLabelPreviewView.swift` | `OpenMathInkCollector/Shared/Components/FormulaLabelPreviewView.swift` | Near-identical (~3524 vs 3498 bytes). |
| `eMathica/App/OpenMathInkCollectorApp.swift` | `OpenMathInkCollector/App/OpenMathInkCollectorApp.swift` | Collector app entry point duplicated inside eMathica. |

### 1.2 EMathicaMathCore Trapped Inside App

`Projects/eMathica app/Packages/EMathicaMathCore/` is a full SwiftPM package (43 source files) but lives **inside** the eMathica app directory. Other packages already depend on it via a relative path:

```
// EMathicaDocumentKit/Package.swift
.package(path: "../../eMathica/eMathica/Packages/EMathicaMathCore")
```

This path would break if the app directory moves or is restructured. MathCore is the foundational package and belongs in `Projects/Packages/`.

### 1.3 Apps Referencing Each Other's Source

- `eMathica/App/OpenMathInkCollectorApp.swift` — the Collector's `@main` entry is compiled inside eMathica. This creates a tight coupling: the eMathica xcodeproj needs to know about Collector's app lifecycle.
- `eMathica/State/` contains `CollectorWorkspaceState`, `ContributorConsentManager`, `LocalSampleStore`, `ConsentFlowView` — collector-domain logic mixed into eMathica's state layer.

### 1.4 `State/` Is a Mismatch Bag

`eMathica/State/` holds:
- True state managers: `CollectorWorkspaceState`, `KeyboardShortcutManager`, `UndoRedoManager`, `OnboardingManager`
- View files: `ConsentFlowView.swift`, `SettingsView.swift`, `ConsentFlowView.swift`
- Data layer: `LocalSampleStore.swift`
- Business logic: `ContributorConsentManager.swift`

These should be split into `AppState/` (state), `Features/` (views), and `Services/` (business logic / data).

### 1.5 Docs and AI Documentation Scattered

| Location | Content |
|---|---|
| `eMathica/Docs/` | Architecture docs, Plane docs, Testing docs, archive (30+ docs) |
| `eMathica/AI/` | AI planning docs (Architecture.md, Roadmap.md, ProductDesign/) |
| `Documentation/` | Hub-level docs (RepositorySplitPreparationAudit, temp/) |
| `eMathica/OPENMATHINK_COLLECTOR_FIXES.md` | Collector-related doc inside eMathica |

The principle: **Hub `Documentation/` = project-wide cross-cutting docs only**; each app's `Docs/` = its own implementation docs; `AI/` = each app's AI-assisted development records.

### 1.6 Package Dependency References Are Fragile

`EMathicaDocumentKit/Package.swift` references MathCore via:
```swift
.package(path: "../../eMathica/eMathica/Packages/EMathicaMathCore")
```

This is a 3-level relative path that assumes the app directory name stays as `"eMathica app"` and the internal `eMathica/` source folder structure persists. Any rename or move breaks all downstream packages.

### 1.7 Resource Duplication

- `eMathica/Resources/Assets.xcassets/AppIcon.appiconset/` — contains eMathica app icons (3 PNGs)
- `OpenMathInkCollector/Resources/Assets.xcassets/AppIcon.appiconset/` — contains Collector icons (3 PNGs)
- `Assets/icon design/` — contains original icon source files (.icon, SVG, large PNG exports)

The `Assets/icon design/` is already correctly separated. App-specific icons should stay in each app's `Resources/`.

---

## 2. Target Hub Structure

```
eMathica Hub/
├── Documentation/               ← Hub-wide cross-cutting docs only
│   ├── Architecture/
│   ├── Automation/              ← migration reports, automation scripts
│   └── Decisions/               ← ADRs (Architecture Decision Records)
├── Projects/
│   ├── eMathica/                ← eMathica app repo root (xcodeproj lives here)
│   ├── OpenMathInkCollector/    ← Collector repo root
│   └── Packages/                ← shared SwiftPM packages (each is a repo)
├── Assets/
│   └── icon design/             ← source design files (SVG, .icon, master exports)
├── Data/
│   ├── Ink Data/                ← raw ink capture datasets
│   └── ML models/               ← CoreML / mlproj projects
├── scripts/                     ← CI/CD, automation, repo-wide tooling
├── .claude/                     ← (untouched)
├── .reasonix/                   ← (untouched)
└── reasonix.toml                ← (stays at root)
```

**Key changes from today:**
- `Projects/eMathica app/` → `Projects/eMathica/` (rename to remove "app" suffix; clearer as repo name)
- `Projects/OpenMathInk Collector/` → `Projects/OpenMathInkCollector/` (remove space; consistent with package naming)
- `scripts/` at root for repo-wide tooling (currently `eMathica app/Scripts/` is app-specific)
- `Documentation/Decisions/` for ADRs (currently missing)

---

## 3. Target eMathica App Structure

```
Projects/eMathica/
├── eMathica.xcodeproj/
├── eMathica/                              ← app source root
│   ├── AppShell/                          ← app lifecycle, window, dependency injection
│   │   ├── EMathicaApp.swift
│   │   ├── AppRootView.swift
│   │   ├── AppNavigationState.swift
│   │   ├── AppRoute.swift
│   │   └── Infrastructure/
│   │       └── PersistenceController.swift
│   ├── Features/                          ← feature modules, one folder per feature
│   │   ├── CoreHome/                      ← (from CoreHome/)
│   │   ├── PlaneCalculator/               ← (from CalculatorModules/Plane/)
│   │   │   ├── PlaneModule.swift
│   │   │   ├── Commands/
│   │   │   ├── Interaction/
│   │   │   ├── Rendering/
│   │   │   ├── Services/
│   │   │   ├── Tools/
│   │   │   └── Views/
│   │   ├── SpaceCalculator/               ← (from CalculatorModules/Space/)
│   │   ├── Modeling/                      ← (from CalculatorModules/Modeling/)
│   │   ├── Music/                         ← (from CalculatorModules/Music/)
│   │   ├── NotesFormula/                  ← (from CalculatorModules/Notes/)
│   │   ├── CalculatorModuleRegistry.swift ← (was at CalculatorModules/ root)
│   │   └── DefaultWorkspaceModuleProvider.swift
│   ├── Services/                          ← business logic, data access, utilities
│   │   ├── KeyboardShortcutManager.swift  ← (from State/)
│   │   └── ...                            ← any non-UI service
│   ├── AppState/                          ← global state stores, not views
│   │   ├── UndoRedoManager.swift
│   │   ├── CoreHomeState.swift
│   │   ├── CoreHomeUIState.swift
│   │   └── ...
│   ├── SharedUI/                          ← truly shared UI components
│   │   └── Components/
│   │       └── FormulaLabelPreviewView.swift
│   ├── Resources/                          ← Assets.xcassets, CoreData model
│   │   ├── Assets.xcassets/
│   │   └── eMathica.xcdatamodeld/
│   ├── Docs/                               ← app-specific docs
│   │   ├── README.md
│   │   ├── Architecture/
│   │   ├── Plane/
│   │   ├── Testing/
│   │   └── archive/
│   └── AI/                                 ← AI-assisted development records
│       ├── Core/
│       ├── Data/
│       ├── ProductDesign/
│       ├── archive/
│       └── temp/
├── Tests/                                  ← consolidated test targets
│   ├── eMathicaTests/                      ← (from eMathicaTests/)
│   └── eMathicaUITests/                    ← (from eMathicaUITests/)
├── Scripts/                                ← app-specific build/check scripts
│   ├── check_mathcore_app_target_exclusion.sh
│   └── verify_mathcore.sh
├── .gitignore
└── reasonix.toml
```

**Moves and renames:**
| Current | Target | Rationale |
|---|---|---|
| `App/` | `AppShell/` | Distinguishes app lifecycle from feature modules |
| `CalculatorModules/` | `Features/` | Standard iOS/SwiftUI convention; each calculator = one feature |
| `CalculatorModules/Plane/` | `Features/PlaneCalculator/` | More descriptive; avoids generic "Plane" |
| `CalculatorModules/Space/` | `Features/SpaceCalculator/` | Same rationale |
| `CalculatorModules/Modeling/` | `Features/Modeling/` | Keep; rename only parent |
| `CalculatorModules/Music/` | `Features/Music/` | Keep |
| `CalculatorModules/Notes/` | `Features/NotesFormula/` | Clarify it's formula notes |
| `State/` (view files) | `Features/` (by feature) | ConsentFlowView → CoreHome or a new Collector feature group |
| `State/` (state files) | `AppState/` | UndoRedoManager, workspace state |
| `State/` (services) | `Services/` | KeyboardShortcutManager, LocalSampleStore |
| `DocumentSystem/` | **Delete** (replaced by Package) | EMathicaDocumentKit is the canonical location |
| `FeatureUtilities/` | **Delete** (extract to shared Package) | Duplicated with Collector; extract to `EMathicaCollectorSharedKit` or similar |
| `PluginSystem/` | `Features/PluginSystem/` or keep at root | Small; could stay as-is or become a feature |
| `eMathicaTests/` | `Tests/eMathicaTests/` | Group under Tests/ |
| `eMathicaUITests/` | `Tests/eMathicaUITests/` | Group under Tests/ |
| `Packages/EMathicaMathCore/` | **Move** → `Projects/Packages/EMathicaMathCore/` | Belongs in shared Packages |
| `SharedUI/` | `SharedUI/` (keep) | Already well-named |
| `OPENMATHINK_COLLECTOR_FIXES.md` | `Docs/` or delete | Belongs in Collector, not eMathica |

---

## 4. Target OpenMathInk Collector Structure

```
Projects/OpenMathInkCollector/
├── OpenMathInkCollector.xcodeproj/
├── OpenMathInkCollector/                    ← app source root
│   ├── AppShell/
│   │   ├── OpenMathInkCollectorApp.swift
│   │   └── AppRootView.swift
│   ├── Features/                            ← feature modules
│   │   ├── HandwritingInput/                ← (from Modules/Handwriting/)
│   │   ├── KeyboardInput/                   ← (from Modules/KeyboardInput/)
│   │   ├── FileManagement/                  ← (from Modules/Files/)
│   │   └── Preview/                         ← (from Modules/Preview/)
│   ├── DomainModels/                        ← renamed from Models/ to avoid ML confusion
│   │   ├── MathInkSample.swift
│   │   ├── SampleStatus.swift
│   │   ├── DatasetManifest.swift
│   │   └── ContributorConsent.swift
│   ├── AppState/
│   │   ├── CollectorWorkspaceState.swift
│   │   ├── OnboardingManager.swift
│   │   └── UndoRedoManager.swift
│   ├── Services/
│   │   ├── ConsentFlowView.swift            ← if it's a view, move to Features/
│   │   ├── ContributorConsentManager.swift
│   │   ├── LocalSampleStore.swift
│   │   └── DatasetPackageBuilder.swift
│   ├── SharedUI/
│   │   ├── Components/
│   │   │   └── FormulaLabelPreviewView.swift
│   │   ├── Theme/
│   │   │   └── CollectorCardStyle.swift
│   │   └── Utilities/
│   │       └── PlatformImageLoader.swift
│   ├── Resources/
│   │   └── Assets.xcassets/
│   └── Docs/
│       └── README.md
├── Tests/
│   └── OpenMathInkCollectorTests/
├── .gitignore
└── README.md
```

**Key changes:**
| Current | Target | Rationale |
|---|---|---|
| `Models/` | `DomainModels/` | Eliminates ambiguity with `Data/ML models` |
| `Modules/` | `Features/` | Aligns with eMathica app convention |
| `State/` (views) | `Features/` or `AppState/` | Separate views from state |
| `Shared/` | `SharedUI/` | Aligns with eMathica app naming |
| `OpenMathInk Collector/` (dir name) | `OpenMathInkCollector/` | No spaces; consistent repo naming |

---

## 5. Target Packages Structure

```
Projects/Packages/
├── EMathicaMathCore/                     ← MOVED from eMathica app
│   ├── Package.swift
│   ├── Sources/EMathicaMathCore/
│   │   ├── AlgebraCore/
│   │   ├── CASCore/
│   │   ├── Coordinate/
│   │   ├── EvaluationCore/
│   │   ├── GraphCore/
│   │   ├── SamplingCore/
│   │   ├── SemanticCore/
│   │   ├── SpaceMathCore/
│   │   └── Viewport/
│   └── Tests/EMathicaMathCoreTests/
├── EMathicaDocumentKit/                  ← already in Packages/
│   ├── Package.swift
│   ├── Sources/EMathicaDocumentKit/
│   │   ├── DocumentCommand.swift
│   │   ├── EMathicaDocument.swift
│   │   ├── IO/
│   │   ├── Package/
│   │   └── ... (11 files)
│   └── Tests/EMathicaDocumentKitTests/
├── EMathicaMathInputKit/                 ← already in Packages/
│   ├── Package.swift
│   ├── Sources/EMathicaMathInputCore/
│   │   ├── AST/
│   │   ├── Engine/
│   │   ├── Serialization/
│   │   └── State/
│   ├── Sources/EMathicaMathInputUI/      ← stubs only; fill when features are extracted
│   │   └── Placeholder.swift
│   └── Tests/EMathicaMathInputCoreTests/
├── EMathicaThemeKit/                     ← already in Packages/
│   ├── Package.swift
│   ├── Sources/EMathicaThemeKit/
│   │   ├── ColorToken.swift
│   │   ├── GlassComponents.swift
│   │   ├── LiquidGlass*.swift
│   │   ├── WorkspaceTheme.swift
│   │   └── ... (10 files)
│   └── Tests/EMathicaThemeKitTests/
├── EMathicaWorkspaceKit/                 ← already in Packages/
│   ├── Package.swift
│   ├── Sources/EMathicaWorkspaceKit/
│   │   ├── Commands/
│   │   ├── History/
│   │   ├── Input/
│   │   ├── Inspector/
│   │   ├── Keyboard/
│   │   ├── ObjectPanel/
│   │   ├── Protocols/
│   │   ├── Shared/
│   │   ├── StructuredInput/
│   │   ├── Toolbar/
│   │   ├── Tools/
│   │   └── ... (38 files)
│   └── Tests/EMathicaWorkspaceKitTests/
├── EMathicaCollectorSharedKit/           ← NEW: extracted from FeatureUtilities & Collector Shared
│   ├── Package.swift
│   ├── Sources/EMathicaCollectorSharedKit/
│   │   ├── Handwriting/                  ← DrawingToolSettings, HandwritingCanvasView, etc.
│   │   ├── Preview/                      ← LatexRenderService
│   │   └── Files/                        ← DatasetFileBrowserView
│   └── Tests/
└── EMathicaHomeCoreKit/                  ← OPTIONAL: CoreHome gallery, preview, thumbnails
    ├── Package.swift
    └── Sources/EMathicaHomeCoreKit/
        ├── ProjectPreviewRenderer.swift
        ├── ProjectThumbnail*.swift
        └── ...
```

**Package dependency graph (target):**
```
EMathicaMathCore          (no deps)
  ├── EMathicaDocumentKit (depends on EMathicaMathCore)
  ├── EMathicaMathInputKit (no deps)
  ├── EMathicaThemeKit   (no deps)
  └── EMathicaWorkspaceKit (depends on EMathicaMathCore, EMathicaDocumentKit, EMathicaThemeKit, EMathicaMathInputKit)
EMathicaCollectorSharedKit (optional; depends on EMathicaMathCore, EMathicaThemeKit)
```

**Note:** After moving `EMathicaMathCore` to `Projects/Packages/`, update all `Package.swift` dependency paths from:
```swift
.package(path: "../../eMathica/eMathica/Packages/EMathicaMathCore")
```
to:
```swift
.package(path: "../EMathicaMathCore")
```

---

## 6. Naming Rules

### 6.1 Directory Naming Convention

| Directory | Purpose | Example |
|---|---|---|
| `AppShell/` | App entry point, lifecycle, DI container, routing | `EMathicaApp.swift`, `AppRootView.swift` |
| `Features/` | One subdirectory per feature (calculator, module, screen) | `Features/PlaneCalculator/`, `Features/FileManagement/` |
| `DomainModels/` | Pure data models (value types, Codable structs) — NOT ML | `MathInkSample.swift`, `SampleStatus.swift` |
| `AppState/` | Global state stores, observable objects, environment values | `UndoRedoManager.swift`, `CoreHomeState.swift` |
| `Services/` | Business logic, data access, utilities (non-UI) | `LocalSampleStore.swift`, `KeyboardShortcutManager.swift` |
| `SharedUI/` | Reusable UI components across features | `FormulaLabelPreviewView.swift`, `GlassComponents.swift` |
| `Resources/` | Asset catalogs, CoreData models, strings, plists | `Assets.xcassets/`, `eMathica.xcdatamodeld/` |
| `Tests/` | All test targets | `eMathicaTests/`, `eMathicaUITests/` |
| `Docs/` | App-specific design docs, decisions, README | `Architecture/`, `Testing/` |
| `AI/` | AI-assisted dev planning, logs, prompts | `Core/`, `ProductDesign/` |
| `Modules/` | (Reserved; avoid using) | — |

### 6.2 File Naming Convention

- **Swift source files**: `PascalCase.swift` (e.g., `PlaneHitTestService.swift`)
- **Protocols**: `ProtocolName.swift` or `NameProviding.swift` (e.g., `ModuleCommandHandling.swift`)
- **Views**: `NameView.swift` suffix (e.g., `HandwritingCanvasView.swift`)
- **State**: `NameState.swift` suffix (e.g., `CoreHomeState.swift`)
- **Services**: `NameService.swift` or `NameManager.swift` (e.g., `PlaneHitTestService.swift`)

### 6.3 Package Naming Convention

- Prefix: `EMathica` (ecosystem-wide)
- Suffix: `Kit` for UI packages, `Core` for non-UI packages
  - `EMathicaMathCore` → non-UI math engine
  - `EMathicaMathInputKit` → UI + core mixed (rename to `EMathicaMathInputCore` + extract UI later)
  - `EMathicaDocumentKit` → document model (non-UI)
  - `EMathicaThemeKit` → UI theme components
  - `EMathicaWorkspaceKit` → workspace infrastructure (mixed)

### 6.4 What NOT to Name

| Avoid | Reason | Use Instead |
|---|---|---|
| `Models/` | Ambiguous (domain vs ML vs data) | `DomainModels/` or `DataModels/` |
| `Utils/` | Too generic, becomes a dumping ground | `Services/` or `SharedUI/Utilities/` |
| `Helpers/` | Same as Utils/ | `Services/` or protocol extensions |
| `Common/` | Same as Utils/ | `SharedUI/` or `Services/` |
| `Modules/` | Overloaded in SwiftUI context | `Features/` |
| `State/` | Shouldn't contain views | `AppState/` + `Features/` |

---

## 7. Move Plan

### Phase 1: Hub-level structural moves (low risk, no Xcode impact)

| Current Path | Target Path | Move Type | Risk | Xcode Impact | Package.swift Impact | import Impact |
|---|---|---|---|---|---|---|
| `eMathica app/` | `eMathica/` | Rename | Low | ✅ Yes (xcodeproj path changes) | ✅ Yes (relative paths in downstream packages) | ❌ No |
| `OpenMathInk Collector/` | `OpenMathInkCollector/` | Rename | Low | ✅ Yes (xcodeproj path) | ❌ No | ❌ No |

### Phase 2: Package extraction (medium risk)

| Current Path | Target Path | Move Type | Risk | Xcode Impact | Package.swift Impact | import Impact |
|---|---|---|---|---|---|---|
| `eMathica/Packages/EMathicaMathCore/` | `Packages/EMathicaMathCore/` | Move (directory) | **High** | ✅ Yes (xcodeproj references) | ✅ Yes (3 packages reference it) | ❌ No (module name unchanged) |
| `eMathica/FeatureUtilities/` | `Packages/EMathicaCollectorSharedKit/` | Extract + new package | **High** | ✅ Yes (files removed from target) | ✅ Yes (new Package.swift) | ✅ Yes (import path changes) |
| `eMathica/DocumentSystem/` | **Delete** (rely on package) | Delete (after verification) | Medium | ✅ Yes (remove from target) | ❌ No | ✅ Yes (if import paths differ) |

### Phase 3: Internal app restructuring (medium-high risk)

| Current Path | Target Path | Move Type | Risk | Xcode Impact | Package.swift Impact | import Impact |
|---|---|---|---|---|---|---|
| `eMathica/App/` | `eMathica/AppShell/` | Rename | Low | ✅ Yes (folder reference) | ❌ No | ❌ No |
| `eMathica/CalculatorModules/` | `eMathica/Features/` | Rename | Low | ✅ Yes (folder reference) | ❌ No | ❌ No |
| `eMathica/CalculatorModules/Plane/` | `eMathica/Features/PlaneCalculator/` | Rename | Low | ✅ Yes (folder reference) | ❌ No | ❌ No |
| `eMathica/CalculatorModules/Space/` | `eMathica/Features/SpaceCalculator/` | Rename | Low | ✅ Yes | ❌ No | ❌ No |
| `eMathica/CalculatorModules/Notes/` | `eMathica/Features/NotesFormula/` | Rename | Low | ✅ Yes | ❌ No | ❌ No |
| `eMathica/State/` (views) | `eMathica/Features/...` | Split | **High** | ✅ Yes | ❌ No | ✅ Yes (import paths) |
| `eMathica/State/` (state managers) | `eMathica/AppState/` | Move | Medium | ✅ Yes | ❌ No | ✅ Yes (import paths) |
| `eMathica/State/` (services) | `eMathica/Services/` | Move | Medium | ✅ Yes | ❌ No | ✅ Yes (import paths) |
| `eMathica/eMathicaTests/` | `eMathica/Tests/eMathicaTests/` | Move | Medium | ✅ Yes | ❌ No | ❌ No |
| `eMathica/eMathicaUITests/` | `eMathica/Tests/eMathicaUITests/` | Move | Medium | ✅ Yes | ❌ No | ❌ No |

### Phase 4: Collector restructuring (medium risk)

| Current Path | Target Path | Move Type | Risk | Xcode Impact | Package.swift Impact | import Impact |
|---|---|---|---|---|---|---|
| `Collector/Models/` | `Collector/DomainModels/` | Rename | Low | ✅ Yes | ❌ No | ❌ No |
| `Collector/Modules/` | `Collector/Features/` | Rename | Low | ✅ Yes | ❌ No | ❌ No |
| `Collector/State/` (views) | `Collector/Features/` | Split | Medium | ✅ Yes | ❌ No | ✅ Yes (import paths) |
| `Collector/Shared/` | `Collector/SharedUI/` | Rename | Low | ✅ Yes | ❌ No | ❌ No |

---

## 8. Package Extraction Plan (EMathicaMathCore)

### 8.1 Current State

```
Projects/eMathica app/Packages/EMathicaMathCore/
├── Package.swift
├── Sources/EMathicaMathCore/  (43 files, 11 subdirs)
└── Tests/EMathicaMathCoreTests/  (12 test files)
```

Referenced by:
- `EMathicaDocumentKit/Package.swift` — via `../../eMathica/eMathica/Packages/EMathicaMathCore`
- `EMathicaWorkspaceKit/Package.swift` — same path
- `eMathica.xcodeproj` — as a local SwiftPM dependency

### 8.2 Target

```
Projects/Packages/EMathicaMathCore/
├── Package.swift              ← unchanged content
├── Sources/EMathicaMathCore/  ← unchanged
└── Tests/EMathicaMathCoreTests/  ← unchanged
```

### 8.3 Steps (for execution, not yet)

1. **Copy** `Projects/eMathica app/Packages/EMathicaMathCore/` → `Projects/Packages/EMathicaMathCore/`
2. **Update** `EMathicaDocumentKit/Package.swift`:
   ```swift
   // old
   .package(path: "../../eMathica/eMathica/Packages/EMathicaMathCore")
   // new
   .package(path: "../EMathicaMathCore")
   ```
3. **Update** `EMathicaWorkspaceKit/Package.swift` — same change
4. **Update** `eMathica.xcodeproj/project.pbxproj` — change local SwiftPM reference path or remove + re-add via Xcode
5. **Verify build** — both apps build and tests pass
6. **Delete** `Projects/eMathica app/Packages/EMathicaMathCore/` (only after verification)

### 8.4 Post-Extraction Package Dependency Paths

All `Package.swift` relative paths will reference siblings:
```
Projects/Packages/
├── EMathicaMathCore/
├── EMathicaDocumentKit/       → ../EMathicaMathCore
├── EMathicaMathInputKit/
├── EMathicaThemeKit/
└── EMathicaWorkspaceKit/      → ../EMathicaMathCore, ../EMathicaDocumentKit, ../EMathicaThemeKit, ../EMathicaMathInputKit
```

---

## 9. Risks

### 9.1 High Risk

| Risk | Impact | Mitigation |
|---|---|---|
| **MathCore package path change** | Breaks all 3 dependent packages + 2 xcodeproj files — build fails until all paths are updated atomically | Execute as one atomic change; verify build before deleting old copy |
| **State/ splitting** | Files move from one folder to 3 different folders; Xcode group structure must match | Update xcodeproj groups in lockstep; verify all targets compile |
| **FeatureUtilities deletion** | eMathica app and Collector both reference these files; deleting from one breaks the other until the shared package is ready | Extract to shared package first, update both apps to use it, then delete old copies |
| **Relative path references in xcodeproj** | `project.pbxproj` records file references as relative paths; moving files may orphan the references | Use Xcode's built-in refactoring or re-add files after move |

### 9.2 Medium Risk

| Risk | Impact | Mitigation |
|---|---|---|
| **OpenMathInkCollectorApp.swift duplicated** | Both eMathica and Collector have their own `@main`; removing from eMathica may break builds | Verify Collector app still builds standalone |
| **Docs/ path changes** | Internal doc links (README, archive) break | Plan is to not fix paths in this migration; document as known issue |
| **Assets.xcassets references** | xcodeproj references asset folders; moving app folder breaks them | Update xcodeproj references after rename |

### 9.3 Low Risk

| Risk | Impact | Mitigation |
|---|---|---|
| `.gitignore` files exist but no `.git/` | No version control yet; folder moves are pure file ops | Safe to proceed |
| `reasonix.toml` inside eMathica app | Duplicated config; harmless | Keep both until verified |
| Empty directories (`Ink Data`, `EMathicaMathInputUI/EditorView/`) | No content to lose | Safe to move |

---

## 10. Recommended Execution Order

```
Phase 1: Hub-Level Renames (safe, build-independent)
  ├── 1.1 Rename "eMathica app" → "eMathica"
  └── 1.2 Rename "OpenMathInk Collector" → "OpenMathInkCollector"

Phase 2: Package Extraction (requires build verification)
  ├── 2.1 Copy EMathicaMathCore to Packages/ (do NOT delete old yet)
  ├── 2.2 Update all Package.swift dependency paths
  ├── 2.3 Update both xcodeproj references
  ├── 2.4 ✅ Build & test verification
  └── 2.5 Delete old EMathicaMathCore from eMathica app

Phase 3: eMathica App Internal Restructure
  ├── 3.1 App/ → AppShell/ (rename)
  ├── 3.2 CalculatorModules/ → Features/ (rename)
  ├── 3.3 Flatten CalculatorModules features (Plane → Features/PlaneCalculator/ etc.)
  ├── 3.4 DocumentSystem/ → delete (confirm package covers it)
  ├── 3.5 State/ split → AppState/ + Services/ + Features/
  ├── 3.6 eMathicaTests/ → Tests/eMathicaTests/
  ├── 3.7 eMathicaUITests/ → Tests/eMathicaUITests/
  └── 3.8 ✅ Build & test verification

Phase 4: Collector Internal Restructure
  ├── 4.1 Models/ → DomainModels/
  ├── 4.2 Modules/ → Features/
  ├── 4.3 State/ split → AppState/ + Services/ + Features/
  ├── 4.4 Shared/ → SharedUI/
  └── 4.5 ✅ Build & test verification

Phase 5: Shared Package Extraction (FeatureUtilities)
  ├── 5.1 Create EMathicaCollectorSharedKit Package
  ├── 5.2 Copy shared files (Handwriting, Preview, Files)
  ├── 5.3 Update both xcodeproj to use the new package
  ├── 5.4 Remove FeatureUtilities from eMathica app
  ├── 5.5 Remove duplicates from Collector Modules/
  └── 5.6 ✅ Build & test verification (both apps)

Phase 6: Cleanup & Documentation
  ├── 6.1 Remove stale Docs from wrong locations
  ├── 6.2 Create Documentation/Decisions/
  ├── 6.3 Create scripts/ at hub root
  ├── 6.4 Final tree verification
  └── 6.5 Update AGENTS.md / reasonix.toml paths
```

---

## Appendix: Comparison of Current vs. Target State

| Aspect | Current | Target |
|---|---|---|
| Hub root dirs | 8 flat entries | 6 categorized + 1 scripts/ |
| App dir name | `eMathica app` (has space) | `eMathica` (no space) |
| Collector dir name | `OpenMathInk Collector` (has space) | `OpenMathInkCollector` (no space) |
| MathCore location | Inside eMathica app | `Projects/Packages/` |
| Shared packages | 4 in `Projects/Packages/` | 5-6 in `Projects/Packages/` |
| Duplicated source files | 15+ files across 2 apps | 0 (via shared package) |
| App internal layers | `App/`, `State/`, `CalculatorModules/`, misc | `AppShell/`, `AppState/`, `Features/`, `Services/` |
| Model naming | `Models/` (ambiguous) | `DomainModels/` (clear) |
| Docs split | Mixed across Hub, App, temp | Hub = cross-cutting, App = implementation, AI = dev records |
| Xcode projects | 2 separate xcodeproj files | 2 (unchanged count) |
