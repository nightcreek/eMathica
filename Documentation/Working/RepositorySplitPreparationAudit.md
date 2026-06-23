# Repository Split Preparation Audit

**Date:** 2026-06-22  
**Project root:** `/Users/night_creek/开发/eMathica`  
**Audit type:** Read-only (no files moved, no git commands executed)

---

## 1. Current Directory Overview

```
/Users/night_creek/开发/eMathica/
├── .claude/                        # Claude desktop settings (local)
├── .reasonix/                      # Reasonix agent work directory (local)
├── ML models/                      # CoreML model project (1 .mlproj)
├── OpenMathInk Collector/          # Collector app source + Xcode project
├── Packages/                       # Shared Swift Packages (4 packages)
│   ├── EMathicaDocumentKit/        #   Package.swift ✓
│   ├── EMathicaMathInputKit/       #   Package.swift ✓
│   ├── EMathicaThemeKit/           #   Package.swift ✓
│   └── EMathicaWorkspaceKit/       #   Package.swift ✓
├── eMathica/                       # Git repository root (the "real" project)
│   └── eMathica/                   #   App source tree
│       ├── .git/                   #   ← Git repo lives here
│       ├── Packages/               #   Package source: EMathicaMathCore
│       ├── Scripts/                #   Build verification scripts
│       ├── Tests/                  #   App unit tests (50+ test files)
│       ├── eMathica/               #   Actual app source
│       │   ├── AI/                 #     AI research docs (archive/temp)
│       │   ├── App/                #     App entry + routes
│       │   ├── CalculatorModules/  #     Module registry + modules
│       │   ├── CoreHome/           #     Home screen UI
│       │   ├── Docs/               #     Architecture docs (archive)
│       │   ├── DocumentSystem/     #     Document model (duplicated in Package)
│       │   ├── FeatureUtilities/   #     Shared feature utils
│       │   ├── PluginSystem/       #     Plugin protocol stubs
│       │   ├── Resources/          #     Assets.xcassets
│       │   ├── SharedUI/           #     Shared UI components
│       │   └── State/              #     App state (partly duplicated for Collector)
│       ├── eMathica.xcodeproj/     #   App Xcode project
│       ├── eMathicaTests/          #   Unit tests (50 files)
│       └── eMathicaUITests/        #   UI tests (2 files)
└── icon design/                    # Icon source files + exports
    ├── eMathica.icon/              #   eMathica icon SVG sources
    ├── eMathica Exports/           #   PNG exports (1-2 MB each)
    ├── openmathink.icon/           #   OpenMathInk icon SVG sources
    └── openmathink Exports/        #   PNG exports (1-2 MB each)
```

**Key observation:** The root directory `/Users/night_creek/开发/eMathica` has an unusual nesting — the actual Git repository root is at `eMathica/eMathica/` (2 levels deep), while `eMathica/` (1 level deep) is an intermediate directory within the larger ecosystem folder.

---

## 2. Existing Git Repository Check

| Path | Git Repo? | Remote? |
|------|-----------|---------|
| `/Users/night_creek/开发/eMathica/eMathica/` | **Yes** (`.git/` found at `eMathica/eMathica/.git`) | Not checked (read-only) |
| Root `/Users/night_creek/开发/eMathica/` | No | N/A |
| `OpenMathInk Collector/` | No (only `.gitignore`) | N/A |
| `Packages/` | No | N/A |
| `ML models/` | No | N/A |
| `icon design/` | No | N/A |

**Only one Git repository exists**, at `eMathica/eMathica/`. It tracks only the app source inside `eMathica/eMathica/eMathica/` plus the xcodeproj. Everything else at the ecosystem root (`Packages/`, `OpenMathInk Collector/`, `ML models/`, `icon design/`) is **outside version control**.

Two `.gitignore` files found:
1. `eMathica/eMathica/.gitignore` — covers `.build/`, `.swiftpm/`, xcuserdata, `.DS_Store`, DerivedData
2. `OpenMathInk Collector/OpenMathInkCollector/.gitignore` — covers Xcode build artifacts, `.swiftpm/`, secret files, `.DS_Store`

---

## 3. Proposed Repository Mapping

| # | Current Path | Target Repository | Must Move? | Risk | Notes |
|---|-------------|-------------------|------------|------|-------|
| 1 | `eMathica/eMathica/.git` + docs root | **eMathica-Hub** (`nightcreek/eMathica`) | ✅ Yes — create new root | High — current git root is nested 2 levels deep | Keep only: README, roadmap, governance, architecture index. Move all source out. |
| 2 | `eMathica/eMathica/eMathica/` (app source) | **eMathica-App** (`nightcreek/eMathica-App`) | ✅ Yes | Medium — update xcodeproj paths | Must re-point package deps to the new `eMathica-Packages` repo |
| 3 | `eMathica/eMathica/eMathica.xcodeproj` | **eMathica-App** | ✅ Yes | Medium | Ship with the app repo |
| 4 | `Packages/EMathica*Kit/` (4 packages) | **eMathica-Packages** (`nightcreek/eMathica-Packages`) | ✅ Yes | Medium — relative paths in Package.swift must change | Currently depends on `EMathicaMathCore` by relative path `../../eMathica/eMathica/Packages/` |
| 5 | `eMathica/eMathica/eMathica/Packages/EMathicaMathCore` | **eMathica-Packages** | ✅ Yes | Medium | Must move alongside other packages, update all relative dependency references |
| 6 | `OpenMathInk Collector/` | **OpenMathInk-Collector** (`nightcreek/OpenMathInk-Collector`) | ✅ Yes | Low | Already a standalone Xcode project with its own `.gitignore` |
| 7 | `ML models/` | **eMathica-ML** (`nightcreek/eMathica-ML`) | ✅ Yes | Low | Small project metadata files only; no large weights yet |
| 8 | `icon design/` | **eMathica-Hub** or **eMathica-App** | ⚠️ Depends | Low | See Section 6 analysis below |
| 9 | `.claude/`, `.reasonix/`, `reasonix.toml` | **None** (local config) | ❌ No | — | Local agent/IDE config, not part of any repo |
| 10 | `eMathica/eMathica/eMathica/AI/` | **eMathica-Hub** (archive) or **eMathica-App** (docs) | ⚠️ Depends | Low | Audit documents — some belong as ADRs in Hub, some are app-specific |

---

## 4. Package Inventory

### Shared Packages (at `/Users/night_creek/开发/eMathica/Packages/`)

| Package | Package.swift | Swift Tools | Dependencies | Sources |
|---------|:------------:|:-----------:|-------------|---------|
| **EMathicaDocumentKit** | ✅ | 6.0 | `EMathicaMathCore` (relative: `../../eMathica/eMathica/Packages/EMathicaMathCore`) | 11 Swift files |
| **EMathicaMathInputKit** | ✅ | 5.10 | None | 9 Swift files |
| **EMathicaThemeKit** | ✅ | 6.0 | None | 10 Swift files |
| **EMathicaWorkspaceKit** | ✅ | 6.0 | `EMathicaMathCore`, `EMathicaDocumentKit`, `EMathicaThemeKit`, `EMathicaMathInputKit` (all relative) | 50+ Swift files |

### App-Internal Package (`at eMathica/eMathica/eMathica/Packages/`)

| Package | Package.swift | Swift Tools | Dependencies | Sources |
|---------|:------------:|:-----------:|-------------|---------|
| **EMathicaMathCore** | ✅ | 6.0 | None | 75+ Swift files (the core math engine) |

### Critical Dependency Issue

The shared packages use **relative path dependencies** pointing into the app's internal structure:
- `EMathicaDocumentKit` → `.package(path: "../../eMathica/eMathica/Packages/EMathicaMathCore")`
- `EMathicaWorkspaceKit` → `.package(path: "../../eMathica/eMathica/Packages/EMathicaMathCore")` and `../EMathicaDocumentKit`, `../EMathicaThemeKit`, `../EMathicaMathInputKit`

These relative paths **will break** when the packages move to an independent repository. All must be converted to **URL-based dependencies** or use a package registry.

### Build Artifacts Found in Packages

| Package | `.build/` dir | Size |
|---------|:------------:|------|
| EMathicaMathInputKit | ✅ | ~50 MB (debug build artifacts) |
| EMathicaWorkspaceKit | ✅ | ~100 MB (debug build + test artifacts) |
| EMathicaMathCore (app-internal) | ✅ | ~50 MB (debug build + test artifacts) |
| EMathicaDocumentKit | ❌ | Clean |
| EMathicaThemeKit | ❌ | Clean |

---

## 5. App Project Inventory

**App root:** `eMathica/eMathica/eMathica/`  
**Xcode project:** `eMathica/eMathica/eMathica/eMathica.xcodeproj/`  
**Project.pbxproj:** 35,602 bytes  
**Contains xcuserdata:** ✅ Yes (`xcuserdata/night_creek.xcuserdatad/`)

### App Source Structure

| Directory | Files | Description |
|-----------|-------|-------------|
| `App/` | 5 Swift | EMathicaApp, AppRootView, AppRoute, AppNavigationState, OpenMathInkCollectorApp |
| `CoreHome/` | 30 Swift | Home screen, gallery, project cards, background themes |
| `CalculatorModules/` | 10+ Swift | Module registry, Plane/Modeling/Music/Notes/Space modules |
| `DocumentSystem/` | 8 Swift | Document model, project IO (see duplication note) |
| `PluginSystem/` | 5 Swift | Plugin protocol stubs |
| `State/` | 8 Swift | App state, onboarding, settings (also duplicated in Collector) |
| `FeatureUtilities/` | 7 Swift | Handwriting, file browser, preview services |
| `SharedUI/` | 1 Swift | Formula label components |
| `Resources/` | 1 | Assets.xcassets |
| `Docs/` | 10+ | Markdown docs + archive (see Section 10) |
| `AI/` | 10+ | Audit reports + archive |

### Important: App Contains Duplicate Code

The app source at `eMathica/eMathica/eMathica/` contains:

1. **`DocumentSystem/`** — Files like `EMathicaDocument.swift`, `DocumentCommand.swift`, `DocumentObjectPatch.swift`, `ProjectMetadata.swift`, etc. — these are duplicated from the `Packages/EMathicaDocumentKit/` package. The package versions should replace the app-internal ones.

2. **`State/`** — Files like `CollectorWorkspaceState.swift`, `UndoRedoManager.swift`, `ContributorConsentManager.swift`, `ConsentFlowView.swift`, `LocalSampleStore.swift` — these are also present in the `OpenMathInk Collector/` project. They were created in the main app first and documented as needing to be copied to the Collector (see `OPENMATHINK_COLLECTOR_FIXES.md`).

3. **`FeatureUtilities/Handwriting/`** — Files like `PencilDrawingRepresentable.swift`, `DrawingToolSettings.swift`, `HandwritingToolbarView.swift`, `HandwritingCanvasView.swift` — also present in the Collector project.

### Unit Tests

- `eMathicaTests/`: 50 test files (~2 MB total)
- `eMathicaUITests/`: 2 test files

---

## 6. Collector Project Inventory

**Project root:** `OpenMathInk Collector/OpenMathInkCollector/`  
**Xcode project:** `OpenMathInkCollector.xcodeproj/`  
**Has xcuserdata:** ✅ Yes  
**Has .gitignore:** ✅ Yes (comprehensive)  
**Has README:** ✅ Yes (describes MVP scope)

### Source Files

| Directory | Files | Description |
|-----------|-------|-------------|
| `App/` | 2 Swift | OpenMathInkCollectorApp, AppRootView |
| `Models/` | 4 Swift | MathInkSample, DatasetManifest, SampleStatus, ContributorConsent |
| `State/` | 6 Swift | WorkspaceState, UndoRedoManager, ConsentFlow, etc. |
| `Shared/` | 3 Swift | Theme, components, utilities |
| `Modules/Handwriting/` | 4 Swift | Drawing tools, canvas |
| `Modules/Files/` | 5 Swift | File browser, export |
| `Modules/Preview/` | 2 Swift | LaTeX preview renderer |
| `Modules/KeyboardInput/` | 4 Swift | Math keyboard, input state |

**Total: ~30 Swift files** — a small, focused app. Standalone Xcode project, no dependencies on eMathica packages. Clean candidate for its own repo.

---

## 7. ML / Model File Inventory

**Location:** `ML models/Writing to Character.mlproj/`

| File | Size | Type |
|------|------|------|
| `Project.json` | 791 B | Project metadata |
| `Data Sources/mathwriting-2024.json` | 977 B | Data source reference (JSON stub) |
| `Data Sources/train.json` | 1.1 KB | Training data reference |
| `Model Containers/Writing to Character 1.json` | 4.0 KB | Model configuration |
| `Model Containers/Writing to Character 2.json` | 2.8 KB | Model configuration |
| `Snapshots/` | (empty) | Empty directory |

**No large files found.** All files are under 5 KB. This is a Create ML project with metadata stubs — no actual model weights (`*.mlmodelc`, `*.mlpackage`) or large datasets present.

**Recommendation:** This can safely go into `eMathica-ML` repo in its current state. The `.gitignore` should include patterns for large model weights and datasets (`*.mlmodelc`, `*.mlpackage`, `*.bin`, large JSON/CSV files) to prevent accidental commits.

---

## 8. Files That Should Not Be Committed

### Found and present in the source tree:

| File/Directory | Path(s) | Status |
|----------------|---------|--------|
| `.DS_Store` | 18 instances across the entire tree | Found — should be gitignored |
| `UserInterfaceState.xcuserstate` | `eMathica/eMathica/eMathica/eMathica.xcodeproj/project.xcworkspace/xcuserdata/night_creek.xcuserdatad/` | Found — already in `.gitignore` |
| `UserInterfaceState.xcuserstate` | `OpenMathInk Collector/OpenMathInkCollector/OpenMathInkCollector.xcodeproj/project.xcworkspace/xcuserdata/night_creek.xcuserdatad/` | Found — already in `.gitignore` |
| `xcuserdata/` dirs | 9 total (app xcodeproj, collector xcodeproj, 4x package `.swiftpm/xcode/xcuserdata`) | Found — covered by `.gitignore` |
| `.build/` dirs | 3 total (MathInputKit, WorkspaceKit, app-internal MathCore) | Found — ~200 MB accumulative build artifacts |
| `.swiftpm/` dirs | Present in all packages | Found — should be gitignored |

### Potentially problematic (large icon PNGs):

| File | Size |
|------|------|
| `icon design/eMathica Exports/eMathica-iOS-Dark-1024x1024@1x.png` | 2.2 MB |
| `icon design/eMathica Exports/eMathica-watchOS-Default-1088x1088@1x.png` | 2.0 MB |
| `icon design/eMathica Exports/eMathica-iOS-Default-1024x1024@1x.png` | 1.9 MB |
| All other icon exports | 0.6–1.6 MB each |

These PNG exports are regeneratable from SVG sources and should generally **not** be committed to any repo, or at most the final App assets in the App repo.

### Not currently present (but should be gitignored):

- `DerivedData/` — not found, but pattern is in `.gitignore` ✅
- Large model weights (`*.mlmodelc`, `*.mlpackage`, `*.bin`) — not present yet
- Large datasets (`.json`, `.csv` > 10 MB) — not present yet

---

## 9. Suggested Target Folder Structure

### eMathica-Hub (`nightcreek/eMathica`)

```
/
├── README.md                   # Project overview
├── ARCHITECTURE.md             # Architecture index (linking to sub-repos)
├── ROADMAP.md                  # Product roadmap
├── GOVERNANCE.md               # Contribution guidelines, license
├── REPOSITORIES.md             # Index of all sub-repos
├── ADR/                        # Architecture Decision Records
└── LICENSE
```

**Do NOT include:** any source code, Xcode projects, packages, models.

### eMathica-App (`nightcreek/eMathica-App`)

```
/
├── eMathica.xcodeproj/
├── .gitignore
├── eMathica/                   # App source (name aligns with Xcode target)
│   ├── App/
│   ├── CoreHome/
│   ├── CalculatorModules/
│   ├── DocumentSystem/         # ✂️ Remove duplicated files, use package instead
│   ├── PluginSystem/
│   ├── Resources/
│   ├── SharedUI/
│   ├── FeatureUtilities/       # ✂️ If Collector-specific, move to Collector
│   ├── State/                  # ✂️ Remove Collector-duplicated files
│   ├── Docs/
│   └── AI/                     # App-specific audit docs only
├── eMathicaTests/
├── eMathicaUITests/
├── Scripts/
└── Package.swift               # ← New: depend on eMathica-Packages via URL
```

### OpenMathInk-Collector (`nightcreek/OpenMathInk-Collector`)

```
/
├── OpenMathInkCollector.xcodeproj/
├── .gitignore
├── README.md
├── OpenMathInkCollector/
│   ├── App/
│   ├── Models/
│   ├── State/                  # Fully self-contained
│   ├── Shared/
│   └── Modules/
```

### eMathica-Packages (`nightcreek/eMathica-Packages`)

```
/
├── Package.swift               # ← New: workspace or meta-package
├── Sources/
├── Tests/
├── .gitignore
├── README.md
├── EMathicaMathCore/
│   ├── Package.swift
│   ├── Sources/
│   └── Tests/
├── EMathicaDocumentKit/
│   ├── Package.swift
│   ├── Sources/
│   └── Tests/
├── EMathicaMathInputKit/
│   ├── Package.swift
│   ├── Sources/
│   └── Tests/
├── EMathicaThemeKit/
│   ├── Package.swift
│   ├── Sources/
│   └── Tests/
└── EMathicaWorkspaceKit/
    ├── Package.swift
    ├── Sources/
    └── Tests/
```

**Key changes:**
- All relative path dependencies changed to URL-based: `.package(url: "https://github.com/nightcreek/eMathica-Packages.git", ...)`
- `EMathicaMathCore` moves from inside the App to this shared repo
- Add a top-level `Package.swift` workspace or `Package.swift` for local development convenience

### eMathica-ML (`nightcreek/eMathica-ML`)

```
/
├── .gitignore                  # Must exclude *.mlmodelc, *.mlpackage, large datasets
├── README.md
├── Writing to Character.mlproj/
│   ├── Project.json
│   ├── Data Sources/
│   ├── Model Containers/
│   └── Snapshots/
└── scripts/                    # Training/evaluation scripts (future)
```

### eMathica-Plugins (`nightcreek/eMathica-Plugins`)

Currently no content. Can be initialized with:
```
/
├── .gitignore
├── README.md                   # Plugin system overview + template instructions
├── TEMPLATE.md                 # Plugin development guide
└── examples/                   # Future examples
```

---

## 10. Safe Migration Plan

### Phase 0: Backup before moving

1. **Full project backup** — create a time-machine or `.zip` backup of the entire `/Users/night_creek/开发/eMathica` directory
2. **Git commit** — commit any pending changes in the current repository at `eMathica/eMathica/`
3. **Export git log** — save the git log, tags, and branch info for reference:

```bash
# Record current state (for reference, DO NOT RUN in audit)
# cd /Users/night_creek/开发/eMathica/eMathica
# git log --all --oneline > /tmp/emathica_git_log.txt
# git branch -a > /tmp/emathica_branches.txt
# git tag > /tmp/emathica_tags.txt
```

### Phase 1: Create target folders

1. Create the desired target folder layout under a new sibling directory, e.g. `/Users/night_creek/开发/eMathica-Repos/`
2. Or create each as a separate clone/init

```
/Users/night_creek/开发/eMathica-Repos/
├── eMathica-Hub/
├── eMathica-App/
├── OpenMathInk-Collector/
├── eMathica-Packages/
├── eMathica-ML/
└── eMathica-Plugins/
```

### Phase 2: Move packages

1. Copy `Packages/EMathicaDocumentKit/`, `EMathicaMathInputKit/`, `EMathicaThemeKit/`, `EMathicaWorkspaceKit/` into `eMathica-Packages/`
2. Copy `eMathica/eMathica/eMathica/Packages/EMathicaMathCore/` into `eMathica-Packages/`
3. **Update all Package.swift dependency paths** from relative to URL-based:
   - `.package(path: "../../eMathica/eMathica/Packages/EMathicaMathCore")` → `.package(url: "https://github.com/nightcreek/eMathica-Packages.git", from: "1.0.0")`
4. Initialize `eMathica-Packages` as a git repo
5. Build and test all packages in isolation

### Phase 3: Move app

1. Copy `eMathica/eMathica/eMathica/` → `eMathica-App/eMathica/`
2. Copy `eMathica/eMathica/eMathica.xcodeproj/` → `eMathica-App/`
3. Copy `eMathica/eMathica/eMathicaTests/` + `eMathicaUITests/` → `eMathica-App/`
4. Copy `eMathica/eMathica/Scripts/` → `eMathica-App/`
5. **Remove duplicated files** from the app source:
   - `DocumentSystem/` — these 8 files are now provided by `EMathicaDocumentKit` package
   - `State/` files that belong to the Collector project (CollectorWorkspaceState, UndoRedoManager, etc.)
   - `FeatureUtilities/Handwriting/` — belongs to Collector
6. **Add a top-level `Package.swift`** to `eMathica-App/` that references `eMathica-Packages` via URL
7. **Update `eMathica.xcodeproj`** to use the new remote package dependency
8. Initialize git repo and verify the project builds

### Phase 4: Move collector

1. Copy `OpenMathInk Collector/OpenMathInkCollector/` → `OpenMathInk-Collector/`
2. Ensure it remains a standalone Xcode project with no external package dependencies
3. Clean up: remove any stale duplicate references to main app files
4. Initialize git repo, verify build

### Phase 5: Move ML

1. Copy `ML models/` → `eMathica-ML/`
2. Add `.gitignore` with patterns for large model files: `*.mlmodelc`, `*.mlpackage`, `*.bin`, large `.json`, large `.csv`
3. Initialize git repo

### Phase 6: Verify build paths

1. **eMathica-App:** Open Xcode, verify scheme resolves packages from the new `eMathica-Packages` URL
2. **eMathica-Packages:** Run `swift test` for each individual package
3. **OpenMathInk-Collector:** Open Xcode, verify it builds without referencing main app paths
4. **Cross-repo verification:** Change a file in `eMathica-Packages`, verify it reflects in `eMathica-App`

### Phase 7: Prepare Git repositories

For each target repo:
1. `git init`
2. `git add` — but **only** the files that belong (use a careful `.gitignore`)
3. `git commit -m "Initial commit: import from monolith"`
4. `git remote add origin <url>`
5. Do **not push** until after the remaining Docs/AI/docs cleanup (Phase 8)

**Phase 7.5 (optional):** Clean up archived/historical docs:
- `Docs/archive/consolidated-2026-06-16/` — 24 old audit reports
- `Docs/archive/pre-consolidation-2026-06-16/` — 36 older audit reports
- `AI/archive/Audits/` — 8 audit docs
- `AI/archive/Design/` — 5 design docs
- `AI/temp/` — 5 working docs

These are historical artifacts. Consider whether they belong in the Hub (as ADRs), the App repo (as app-specific historical docs), or a separate archive.

---

## 11. Risks and Manual Checks

### 🔴 High Risk

| # | Risk | Description | Mitigation |
|---|------|-------------|------------|
| R1 | **Relative path dependencies** | All 4 shared packages use relative paths (`../../eMathica/...`). These will break when repos are separated. | Convert to URL-based dependencies before splitting. Test build after change. |
| R2 | **Duplicated code — DocumentSystem** | `eMathica/eMathica/eMathica/DocumentSystem/` duplicates `Packages/EMathicaDocumentKit/`. If removed from App, ensure the package version is API-compatible. | Audit API surface of both; prefer the package version. Keep a shim layer in App if needed. |
| R3 | **EMathicaMathCore location** | Currently deep inside the app tree (`eMathica/eMathica/eMathica/Packages/`). Moving it to the shared packages repo changes every dependency path. | Move it first, update all Package.swift files, rebuild. |

### 🟡 Medium Risk

| # | Risk | Description | Mitigation |
|---|------|-------------|------------|
| R4 | **Duplicated code — Collector vs App** | 7+ files exist in both `State/` and `FeatureUtilities/` in the App and the Collector. After the split, the Collector files in the App repo become dead weight. | Manually audit each: remove from App repo what belongs to Collector; ensure Collector has what it needs. |
| R5 | **Xcode project scheme paths** | The xcodeproj references package paths. These will need updating after the move. | Open Xcode, resolve package references, check "Package Dependencies" tab. |
| R6 | **Archive docs cleanup** | >60 archived audit/design docs in `Docs/archive/` and `AI/archive/`. Heavy historical baggage. | Either keep them in the App repo (as historical record) or archive externally. |
| R7 | **Git history loss** | Current git history is only for `eMathica/eMathica/`. Moving files to new repos loses history. | Use `git filter-branch` or `git subtree split` to preserve history for each sub-repo if needed. |

### 🟢 Low Risk

| # | Risk | Description | Mitigation |
|---|------|-------------|------------|
| R8 | **Icon design exports** | 13 PNG export files (0.6–2.2 MB each) in `icon design/`. Large for any repo. | Keep only SVG sources in version control; regenerate PNGs as build artifacts. |
| R9 | **ML models empty** | The `.mlproj` has no actual model weights, only metadata stubs. Low risk. | Ensure `.gitignore` has proper patterns before adding large files. |
| R10 | **Multiple `.DS_Store`** | 18 `.DS_Store` files scattered across tree. | Run `find . -name '.DS_Store' -delete` after backup; ensure `.gitignore` covers them. |
| R11 | **Build artifacts in packages** | `.build/` dirs in 3 packages (~200 MB total). | Delete before committing: `find . -name '.build' -type d -exec rm -rf {} +` |

### Manual Checks Required Before Each Phase

1. **Before Phase 1:** Run `swift build` in the current repo to confirm it compiles
2. **Before Phase 2:** Verify all package tests pass: `swift test` for each package
3. **Before Phase 3:** Verify App builds and runs in Xcode
4. **Before Phase 4:** Verify Collector builds and runs in Xcode
5. **After Phase 6:** Full build + test of all 5 repos
6. **Before Phase 7:** Final cleanup of `icon design/`, `AI/temp/`, and archive docs

---

## Summary of Findings

### Most Critical Issues

1. **Git repo is nested 2 levels deep** — after the split, it becomes the Hub repo but needs a new root
2. **All package dependencies use relative paths** — must change to URL-based before splitting
3. **Significant duplicated code** across DocumentSystem (App vs Package) and State/FeatureUtils (App vs Collector)
4. **No version control for Packages, Collector, ML, or icons** — these 4 directories are outside any git repo

### What Can Be Migrated Immediately (No Code Changes)

- `OpenMathInk Collector/` → standalone repo (fully self-contained)
- `ML models/` → standalone repo (tiny, no dependencies)
- `icon design/` → Hub or App repo assets (or archive)

### What Needs Preparation (Code/Dependency Changes)

- `Packages/` + `EMathicaMathCore` → shared repo (change dependency paths)
- `eMathica/eMathica/eMathica/` → App repo (update xcodeproj, remove duplicates, add Package.swift)
- Current git repo at `eMathica/eMathica/` → Hub repo (extract source, keep only docs)
