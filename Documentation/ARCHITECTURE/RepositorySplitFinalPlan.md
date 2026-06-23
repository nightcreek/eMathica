# eMathica Ecosystem Repository Restructuring Plan

> **Status:** Read-only proposal — no files moved, no git commands executed.
> **Date:** 2026-06-23
> **Scope:** Full ecosystem audit → per-repo structure → migration plan

---

## Table of Contents

1. [Current Directory Audit](#1-current-directory-audit)
2. [Target Repository Structure](#2-target-repository-structure)
3. [eMathica Hub Structure](#3-emathica-hub-structure)
4. [eMathica Core Structure](#4-emathica-core-structure)
5. [OpenMathInk Collector Structure](#5-openmathink-collector-structure)
6. [Shared Libraries Analysis](#6-shared-libraries-analysis)
7. [GitHub Repository Organization](#7-github-repository-organization)
8. [Local Folder Structure](#8-local-folder-structure)
9. [Migration Plan](#9-migration-plan)

---

## 1. Current Directory Audit

### Current Layout

```
/Users/night_creek/开发/eMathica Hub/
├── Assets/
│   └── icon design/              ← Design sources (eMathica + OpenMathInk icons)
├── Data/
│   ├── Ink Data/                 ← Raw ink capture data (empty)
│   └── ML models/                ← CoreML .mlproj project
├── Documentation/                ← Cross-cutting docs, ADRs, policies
│   ├── ADR/
│   ├── ARCHITECTURE/             ← Architecture plans (this doc lives here)
│   ├── ARCHIVE/
│   ├── Automation/               ← Migration reports
│   ├── POLICIES/
│   ├── Working/                  ← Active working docs
│   └── temp/
├── Projects/
│   ├── eMathica/                 ★ Git repo root (the main app)
│   │   ├── eMathica/             ← App source tree
│   │   │   ├── AI/               ← AI development records
│   │   │   ├── App/              ← App entry + routes
│   │   │   ├── CalculatorModules/ ← Feature modules (Plane, Space, etc.)
│   │   │   ├── CoreHome/         ← Home screen UI
│   │   │   ├── Docs/             ← App-specific docs (30+ files)
│   │   │   ├── FeatureUtilities/ ← Shared with Collector (duplicated!)
│   │   │   ├── PluginSystem/     ← Plugin protocol stubs
│   │   │   ├── Resources/        ← Assets.xcassets
│   │   │   ├── Services/         ← Business logic
│   │   │   ├── SharedUI/         ← Shared UI components
│   │   │   └── State/            ← Mixed: state + views + services
│   │   ├── eMathica.xcodeproj/
│   │   ├── eMathicaTests/        ← 50+ unit test files
│   │   ├── eMathicaUITests/
│   │   ├── Scripts/              ← Build verification scripts
│   │   └── Packages/             ← (EMPTY — MathCore was moved)
│   ├── OpenMathInkCollector/     ★ Standalone app (no git repo)
│   │   └── OpenMathInkCollector/
│   │       ├── OpenMathInkCollector.xcodeproj/
│   │       ├── OpenMathInkCollector/ ← App source
│   │       │   ├── App/
│   │       │   ├── Models/
│   │       │   ├── Modules/
│   │       │   ├── Shared/
│   │       │   ├── State/
│   │       │   └── Resources/
│   │       └── README.md
│   └── Packages/                 ★ Shared SwiftPM packages (no git repo)
│       ├── EMathicaMathCore/     → Math engine (43 source files)
│       ├── EMathicaDocumentKit/  → Document model
│       ├── EMathicaMathInputKit/ → Math input keyboard
│       ├── EMathicaThemeKit/     → Theme system
│       └── EMathicaWorkspaceKit/ → Workspace infrastructure (50+ files)
├── .claude/
├── .reasonix/
└── reasonix.toml
```

### Directory → Repository Mapping

| # | Current Path | Belongs To | Status | Notes |
|---|---|---|---|---|
| 1 | `Documentation/` (cross-cutting) | **Hub** | ✅ Ready | ADRs, policies, architecture plans |
| 2 | `Documentation/ARCHITECTURE/` (app-specific) | **Hub** (index) + **Core** (impl details) | ⚠️ Split needed | Some docs are Hub-level, some are app-internal |
| 3 | `Assets/icon design/` | **Hub** | ✅ Ready | Shared design assets |
| 4 | `Data/Ink Data/` | **Hub** (dataset reference) | ✅ Ready | Empty, just a placeholder |
| 5 | `Data/ML models/` | **Hub** (reference) or **Collector** | 🤔 Consider | mlproj is small; could live in Hub or Collector |
| 6 | `Projects/eMathica/` (app source) | **Core** | ⚠️ Needs cleanup | Must strip Collector duplicate files first |
| 7 | `Projects/OpenMathInkCollector/` | **Collector** | ⚠️ Needs restructuring | Rename dir, restructure internals |
| 8 | `Projects/Packages/EMathicaMathCore/` | **Core** (as dep) or **Shared** | ✅ Ready | Already a standalone package; decide repo placement |
| 9 | `Projects/Packages/EMathicaDocumentKit/` | **Core** (as dep) or **Shared** | ✅ Ready | Standalone package |
| 10 | `Projects/Packages/EMathicaMathInputKit/` | **Core** or **Shared** | ✅ Ready | Standalone package |
| 11 | `Projects/Packages/EMathicaThemeKit/` | **Core** or **Shared** | ✅ Ready | Standalone package |
| 12 | `Projects/Packages/EMathicaWorkspaceKit/` | **Core** or **Shared** | ✅ Ready | Standalone package |
| 13 | `Projects/eMathica/eMathica/Docs/` (app docs) | **Core** | ⚠️ Needs dedup | Move cross-cutting docs to Hub |
| 14 | `Projects/eMathica/eMathica/AI/` | **Core** | ✅ Ready | AI dev records stay with Core |
| 15 | `Projects/eMathica/eMathica/FeatureUtilities/` | **Collector** (duplicate) | 🔴 Remove | Already lives in Collector; must be deleted from Core |
| 16 | `Projects/eMathica/eMathica/State/Collector*` | **Collector** | 🔴 Remove | Collector state files inside Core |
| 17 | `Projects/eMathica/eMathica/State/UndoRedoManager.swift` | **Core** or **Shared** | ⚠️ Consider | If Collector has duplicate, extract to package |
| 18 | `Projects/eMathica/eMathica/App/OpenMathInkCollectorApp.swift` | **Collector** | 🔴 Remove | Duplicate @main entry |
| 19 | `.claude/` | Local only | ❌ Never commit | Agent config |
| 20 | `.reasonix/` | Local only | ❌ Never commit | Agent config |
| 21 | `reasonix.toml` | **Hub** or per-repo | ⚠️ Keep in Hub only | Remove from Core after split |

### Duplicate Files Inventory

| File | Core | Collector | Action |
|------|------|-----------|--------|
| `OpenMathInkCollectorApp.swift` | ✅ Has copy | ✅ Has copy | Delete from Core |
| `CollectorWorkspaceState.swift` | ✅ Has copy | ✅ Has copy | Delete from Core |
| `ConsentFlowView.swift` | ✅ Has copy | ✅ Has copy | Delete from Core |
| `ContributorConsentManager.swift` | ✅ Has copy | ✅ Has copy | Delete from Core |
| `LocalSampleStore.swift` | ✅ Has copy | ✅ Has copy | Delete from Core |
| `OnboardingManager.swift` | ✅ Has copy | ✅ Has copy | Delete from Core |
| `SettingsView.swift` | ✅ Has copy | ✅ Has copy | Delete from Core |
| `UndoRedoManager.swift` | ✅ Has copy | ✅ Has copy | Keep both or extract to shared |
| `FormulaLabelPreviewView.swift` | ✅ Has copy | ✅ Has copy | Extract to shared package |
| `DrawingToolSettings.swift` | ✅ Has copy | ✅ Has copy | Delete from Core (Collector has it) |
| `HandwritingCanvasView.swift` | ✅ Has copy | ✅ Has copy | Delete from Core |
| `HandwritingToolbarView.swift` | ✅ Has copy | ✅ Has copy | Delete from Core |
| `PencilDrawingRepresentable.swift` | ✅ Has copy | ✅ Has copy | Delete from Core |
| `DatasetFileBrowserView.swift` | ✅ Has copy | ✅ Has copy | Delete from Core |
| `StatisticsView.swift` | ✅ Has copy | ✅ Has copy | Delete from Core |
| `LatexRenderService.swift` | ✅ Has copy | ✅ Has copy | Delete from Core |

---

## 2. Target Repository Structure

### Three-Category Convention

Per the requirement: distinguish **Current Reality** ↔ **Current Development** ↔ **Future Possibilities**.

```
eMathica Hub/
├── Current Reality/
│   ├── README.md              ← Project intro, badges, quick links
│   ├── REPOSITORIES.md        ← Index of all repos with URLs
│   ├── ROADMAP.md             ← Current roadmap
│   ├── ARCHITECTURE.md        ← System architecture overview
│   └── docs/                  ← Cross-cutting documentation
│       ├── index.md
│       ├── architecture/
│       └── decisions/         ← ADRs
├── Current Development/
│   ├── STATUS.md              ← Current development status
│   ├── SPRINT.md              ← Active sprint info
│   └── CONTRIBUTING.md        ← How to contribute
├── Future Possibilities/
│   ├── VISION.md              ← Long-term vision
│   ├── VOTING.md              ← Community voting / RFC process
│   └── ideas/                 ← RFCs, proposals
└── Assets/                    ← Shared assets (icons, logos)
```

---

## 3. eMathica Hub Structure

```
eMathica Hub/                     ★ GitHub: nightcreek/eMathica
├── README.md                     ← Project intro, badges, links to all repos
├── REPOSITORIES.md               ← Full repo index with URLs + descriptions
├── ROADMAP.md                    ← Current + planned milestones
├── STATUS.md                     ← Current development status across all projects
├── CONTRIBUTING.md               ← Contribution guidelines
├── VISION.md                     ← Long-term vision / future possibilities
├── VOTING.md                     ← RFC / community voting process
├── ARCHITECTURE.md               ← High-level system architecture
├── Current Reality/
│   ├── README.md
│   ├── guides/
│   │   ├── GETTING_STARTED.md
│   │   └── BUILDING.md
│   ├── docs/
│   │   ├── index.md
│   │   ├── architecture/         ← Cross-cutting architecture docs
│   │   └── decisions/            ← ADRs
│   └── assets/
│       ├── icons/                ← eMathica + OpenMathInk icons
│       └── screenshots/
├── Current Development/
│   ├── STATUS.md                 ← Active development status
│   ├── SPRINT.md                 ← Sprint information
│   └── CONTRIBUTING.md
├── Future Possibilities/
│   ├── VISION.md
│   ├── VOTING.md
│   └── proposals/                ← RFCs
└── Assets/
    └── icon design/              ← Design source files (SVG, .icon)
```

**Key principles:**
- Hub has **zero** Swift/Xcode files
- Hub README links to other repos via URLs only
- `Assets/` stores only shared design assets
- `Data/` (Ink Data, ML models) → decide later; could stay in Hub or move to Collector

---

## 4. eMathica Core Structure

```
eMathica Core/                    ★ GitHub: nightcreek/eMathica-Core
├── README.md                     ← App description, build instructions, link to Hub
├── eMathica.xcodeproj/
├── eMathica/                     ← App source root
│   ├── AppShell/                 ← App lifecycle, DI, routing
│   │   ├── EMathicaApp.swift
│   │   ├── AppRootView.swift
│   │   ├── AppNavigationState.swift
│   │   ├── AppRoute.swift
│   │   └── Infrastructure/
│   │       └── PersistenceController.swift
│   ├── Features/                 ★ Replaces CalculatorModules/
│   │   ├── CoreHome/             ← Home screen (from CoreHome/)
│   │   ├── PlaneCalculator/      ← from CalculatorModules/Plane/
│   │   ├── SpaceCalculator/      ← from CalculatorModules/Space/
│   │   ├── Modeling/             ← from CalculatorModules/Modeling/
│   │   ├── Music/                ← from CalculatorModules/Music/
│   │   ├── NotesFormula/         ← from CalculatorModules/Notes/
│   │   ├── PluginSystem/         ← from PluginSystem/
│   │   ├── CalculatorModuleRegistry.swift
│   │   └── DefaultWorkspaceModuleProvider.swift
│   ├── Services/                 ← Business logic, data access
│   │   ├── KeyboardShortcutManager.swift
│   │   ├── LocalProjectStore.swift
│   │   └── ...
│   ├── AppState/                 ★ Global state stores
│   │   ├── UndoRedoManager.swift
│   │   ├── CoreHomeState.swift
│   │   ├── CoreHomeUIState.swift
│   │   └── ...
│   ├── SharedUI/                 ← Shared UI components
│   │   └── Components/
│   │       └── FormulaLabelPreviewView.swift
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   └── eMathica.xcdatamodeld/
│   ├── Docs/                     ← App-specific docs
│   │   ├── Architecture/
│   │   ├── Plane/
│   │   ├── Testing/
│   │   └── archive/
│   └── AI/                       ← AI-assisted dev records
│       ├── Core/
│       ├── Data/
│       ├── ProductDesign/
│       └── archive/
├── Tests/
│   ├── eMathicaTests/            ← From eMathicaTests/
│   └── eMathicaUITests/          ← From eMathicaUITests/
├── Scripts/                      ← App-specific scripts
├── Packages/                     ★ Local package checkouts (resolved by SwiftPM)
│   └── (empty — all deps via Package.swift)
├── .gitignore
└── reasonix.toml                 ← Per-repo Reasonix config (minimal)
```

### Animation Clarification
As stated: **Animation is NOT a standalone app**. It is a shared capability used by:
- **Plane** (2D geometry canvas animations)
- **Space** (3D scene animations)

Keep animation code within `Features/PlaneCalculator/` and `Features/SpaceCalculator/` respectively, or extract to `SharedUI/` if truly shared across both.

### AI Clarification
As stated: **AI is not a core product capability**. The `AI/` directory contains only development records (plans, logs, prompts). No online AI services are planned. The `AI/` folder stays in **Core** as development documentation.

---

## 5. OpenMathInk Collector Structure

```
OpenMathInk Collector/            ★ GitHub: nightcreek/OpenMathInk-Collector
├── README.md                     ← Collector description, link to Hub
├── OpenMathInkCollector.xcodeproj/
├── OpenMathInkCollector/         ← App source root
│   ├── AppShell/
│   │   ├── OpenMathInkCollectorApp.swift
│   │   └── AppRootView.swift
│   ├── Features/                 ★ Replaces Modules/
│   │   ├── HandwritingInput/     ← from Modules/Handwriting/
│   │   ├── KeyboardInput/        ← from Modules/KeyboardInput/
│   │   ├── FileManagement/       ← from Modules/Files/
│   │   └── Preview/              ← from Modules/Preview/
│   ├── DomainModels/             ← Renamed from Models/
│   │   ├── MathInkSample.swift
│   │   ├── SampleStatus.swift
│   │   ├── DatasetManifest.swift
│   │   └── ContributorConsent.swift
│   ├── AppState/
│   │   ├── CollectorWorkspaceState.swift
│   │   ├── OnboardingManager.swift
│   │   └── UndoRedoManager.swift
│   ├── Services/
│   │   ├── ContributorConsentManager.swift
│   │   ├── LocalSampleStore.swift
│   │   ├── DatasetPackageBuilder.swift
│   │   └── LatexRenderService.swift
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

### Key Changes from Current State

| Current | Target | Rationale |
|---------|--------|-----------|
| `Models/` | `DomainModels/` | Avoid ambiguity with ML models |
| `Modules/` | `Features/` | Align with Core app convention |
| Most of `State/` | `AppState/` + `Services/` | Separate state from views from business logic |
| `Shared/` | `SharedUI/` | Align with Core app naming |
| `ConsentFlowView.swift` (in State/) | `Features/FileManagement/` | It's a view, belongs in a feature |

---

## 6. Shared Libraries Analysis

### Current Packages

| Package | Sources | Deps | Status | Future Independent? |
|---------|---------|------|--------|-------------------|
| **EMathicaMathCore** | 43 files | None | ✅ Already standalone | ⭐ **Yes — first candidate** |
| **EMathicaDocumentKit** | 11 files | MathCore | ✅ Already standalone | ✅ Yes |
| **EMathicaMathInputKit** | 9 files | None | ✅ Already standalone | ✅ Yes |
| **EMathicaThemeKit** | 10 files | None | ✅ Already standalone | ✅ Yes |
| **EMathicaWorkspaceKit** | 50+ files | MathCore, DocumentKit, ThemeKit, MathInputKit | ✅ Already standalone | ✅ Yes |

### Future Shared Library Candidates

These are identified as **Future Possibilities** — NOT to be split now, but analyzed for independence:

| Potential Package | Source Domain | Depends On | Why Independent Later |
|-------------------|--------------|-----------|----------------------|
| **EMathicaMathInputKit** (→ already exists) | Keyboard input | None | Could be reused in any math app |
| **EMathicaSymbolKit** | Symbol/notation system | MathCore | Would allow standalone symbol editing |
| **EMathicaCASKit** (→ part of MathCore) | CAS engine | MathCore | Could be a thinner wrapper over MathCore |
| **EMathicaNotebookKit** | Notebook/document model | MathCore, DocumentKit | Could serve as a standalone note-taking foundation |
| **EMathicaAnimationKit** | Animation primitives | MathCore, ThemeKit | Plane + Space both use animation; extracting would prevent duplication |

### Package Dependency Graph

```
EMathicaMathCore (no deps)
  ├── EMathicaDocumentKit
  ├── EMathicaWorkspaceKit
  └── EMathicaMathInputKit (no deps)
EMathicaThemeKit (no deps)
  └── EMathicaWorkspaceKit
```

### Repository Placement Decision

**Recommended approach:** Since all packages share the `EMathica` prefix and are tightly coupled to Core, group them into a **single `SharedLibraries/` repo** within the Core ecosystem, rather than one repo per package. This keeps monorepo-like convenience while achieving ecosystem separation.

Alternatively, once packages stabilize and the community grows, each can graduate to its own repo.

---

## 7. GitHub Repository Organization

```
GitHub: nightcreek/
├── eMathica                       ← Hub (navigation, no code)
│   ├── README.md                  ← Project intro + links
│   ├── REPOSITORIES.md            ← Repo index
│   ├── ROADMAP.md
│   ├── docs/
│   └── assets/
│
├── eMathica-Core                  ← Main application
│   ├── eMathica.xcodeproj
│   ├── eMathica/                  ← Source
│   │   ├── AppShell/
│   │   ├── Features/
│   │   ├── Services/
│   │   ├── AppState/
│   │   ├── SharedUI/
│   │   └── Resources/
│   ├── Tests/
│   └── Scripts/
│   (Depends on SharedLibraries via SwiftPM)
│
├── OpenMathInk-Collector          ← Handwriting data collection
│   ├── OpenMathInkCollector.xcodeproj
│   ├── OpenMathInkCollector/      ← Source
│   └── Tests/
│   (Depends on EMathicaMathCore via SwiftPM)
│
├── OpenMathInk-Dataset            ← Future: public dataset
│   └── (placeholder — no code yet)
│
└── SharedLibraries                ← All SwiftPM packages
    ├── EMathicaMathCore/
    ├── EMathicaDocumentKit/
    ├── EMathicaMathInputKit/
    ├── EMathicaThemeKit/
    └── EMathicaWorkspaceKit/
    (Each has its own Package.swift;
     published as a single repo for convenience)
```

### Alternative: Package-per-Repo

For maximum modularity when the community grows:

```
GitHub: nightcreek/
├── eMathica (Hub)
├── eMathica-Core
├── OpenMathInk-Collector
├── OpenMathInk-Dataset
├── EMathicaMathCore               ← Independent repo
├── EMathicaDocumentKit            ← Independent repo
├── EMathicaMathInputKit           ← Independent repo
├── EMathicaThemeKit               ← Independent repo
└── EMathicaWorkspaceKit           ← Independent repo
```

**Recommended:** Start with the single `SharedLibraries` repo approach. It is lower overhead and all packages are developed together anyway. Split into individual repos only when external contributors need one package independently.

---

## 8. Local Folder Structure

```
Projects/
├── eMathicaHub/                   ← Maps to GitHub: nightcreek/eMathica
│   ├── README.md
│   ├── REPOSITORIES.md
│   ├── ROADMAP.md
│   ├── Current Reality/
│   ├── Current Development/
│   └── Future Possibilities/
│
├── eMathicaCore/                  ★ Renamed from "eMathica app" / "eMathica"
│   ├── eMathica.xcodeproj
│   ├── eMathica/                  ← Source
│   ├── Tests/
│   ├── Scripts/
│   └── Packages/                  ← Local checkout (SwiftPM resolves from SharedLibraries)
│
├── OpenMathInkCollector/          ★ Renamed from "OpenMathInk Collector"
│   ├── OpenMathInkCollector.xcodeproj
│   ├── OpenMathInkCollector/      ← Source
│   └── Tests/
│
└── SharedLibraries/               ← Maps to GitHub: nightcreek/SharedLibraries
    ├── EMathicaMathCore/
    ├── EMathicaDocumentKit/
    ├── EMathicaMathInputKit/
    ├── EMathicaThemeKit/
    └── EMathicaWorkspaceKit/
```

**Naming decisions:**
- `eMathicaHub/` — camelCase for Hub, matches GitHub repo name
- `eMathicaCore/` — "Core" suffix to distinguish from Hub repo
- `OpenMathInkCollector/` — no space, consistent casing
- `SharedLibraries/` — clear, follows the task requirement

---

## 9. Migration Plan

### Phase 0: Preparation (Read-Only Audit)

| Step | Action | Risk | Verification |
|------|--------|------|-------------|
| 0.1 | Document current file list for every source directory | None | File inventory matches this document |
| 0.2 | Check all Xcode project references resolve correctly | None | No missing file references in pbxproj |
| 0.3 | Verify git status of existing repo (eMathica) | None | git status shows no unstaged changes |
| 0.4 | Make backup / snapshot of entire ecosystem folder | None | Copy to safe location |

---

### Phase 1: Clean Duplicate Collector Files from Core

**Goal:** Before splitting repos, remove all Collector-specific files from the Core app tree.  
**Risk:** Medium — must ensure Core still builds without these files.

| Step | Action | Details |
|------|--------|---------|
| 1.1 | Delete `App/OpenMathInkCollectorApp.swift` from Core | It's Collector's @main, not Core's |
| 1.2 | Delete `State/CollectorWorkspaceState.swift` from Core | Collector-specific state |
| 1.3 | Delete `State/ConsentFlowView.swift` from Core | Collector-specific view |
| 1.4 | Delete `State/ContributorConsentManager.swift` from Core | Collector-specific service |
| 1.5 | Delete `State/LocalSampleStore.swift` from Core | Collector-specific data store |
| 1.6 | Delete `State/OnboardingManager.swift` from Core | Collector-specific manager |
| 1.7 | Delete `State/SettingsView.swift` from Core | Collector-specific view |
| 1.8 | Delete `FeatureUtilities/` entire directory from Core | All 7 files duplicated in Collector |
| 1.9 | Delete `SharedUI/Components/FormulaLabelPreviewView.swift` from Core | Duplicated in Collector's SharedUI |
| 1.10 | Update Xcode project to remove deleted files from target membership | Must uncheck all deleted files |
| 1.11 | ✅ **Build & test verification** | Core must compile and pass tests |

**Note on `State/UndoRedoManager.swift`:**
This file exists in **both** Core and Collector. Two options:
- **Option A:** Keep in both (simple, works as long as each is self-contained)
- **Option B:** Extract to a shared package (cleaner, but adds overhead)

Recommend **Option A for now** — UndoRedoManager is small (~100 lines) and may diverge per app.

---

### Phase 2: Internal Restructure Core (Directory Renames)

**Goal:** Apply the target directory structure to the Core app.  
**Risk:** Medium — Xcode project references must be updated.

| Step | Action | Impact |
|------|--------|--------|
| 2.1 | Rename `App/` → `AppShell/` | Update Xcode folder ref |
| 2.2 | Rename `CalculatorModules/` → `Features/` | Update Xcode folder ref |
| 2.3 | Rename `CalculatorModules/Plane/` → `Features/PlaneCalculator/` | Update Xcode folder ref |
| 2.4 | Rename `CalculatorModules/Space/` → `Features/SpaceCalculator/` | Update Xcode folder ref |
| 2.5 | Rename `CalculatorModules/Notes/` → `Features/NotesFormula/` | Update Xcode folder ref |
| 2.6 | Split `State/`: create `AppState/` and `Services/`, move files accordingly | Update import paths in Swift files |
| 2.7 | Move `eMathicaTests/` → `Tests/eMathicaTests/` | Update Xcode test target path |
| 2.8 | Move `eMathicaUITests/` → `Tests/eMathicaUITests/` | Update Xcode UI test target path |
| 2.9 | ✅ **Build & test verification** | All tests pass |

---

### Phase 3: Internal Restructure Collector

**Goal:** Apply the target directory structure to the Collector app.  
**Risk:** Low-Medium.

| Step | Action | Impact |
|------|--------|--------|
| 3.1 | Rename `Modules/` → `Features/` | Xcode folder ref update |
| 3.2 | Rename `Models/` → `DomainModels/` | Xcode folder ref update |
| 3.3 | Rename `Shared/` → `SharedUI/` | Xcode folder ref update |
| 3.4 | Split `State/`: create `AppState/` and `Services/`, move files | Import path updates |
| 3.5 | ✅ **Build & test verification** | Collector builds standalone |

---

### Phase 4: Hub Setup

**Goal:** Create the Hub repository structure with proper three-category organization.  
**Risk:** Low — no code, only Markdown.

| Step | Action | Details |
|------|--------|---------|
| 4.1 | Create `Current Reality/` directory | Move existing real docs here |
| 4.2 | Create `Current Development/` directory | Development status docs |
| 4.3 | Create `Future Possibilities/` directory | Vision, voting, RFCs |
| 4.4 | Write `README.md` | Project intro, badges, links to all repos |
| 4.5 | Write `REPOSITORIES.md` | Full repo index with URLs |
| 4.6 | Write `ROADMAP.md` | Current + planned milestones |
| 4.7 | Move shared docs from `Documentation/` → `Current Reality/docs/` | Deduplicate |
| 4.8 | Move icon design assets to `Assets/` | Already done in prior migration |
| 4.9 | Initialize git repo in Hub root | `git init` at top level |

---

### Phase 5: Package Consolidation

**Goal:** Ensure all shared packages are in `SharedLibraries/` with correct dependency paths.  
**Risk:** High — relative paths in Package.swift must be correct.

| Step | Action | Details |
|------|--------|---------|
| 5.1 | Verify EMathicaMathCore is in `Projects/SharedLibraries/` (not inside Core) | Already moved in prior migration |
| 5.2 | Update `EMathicaDocumentKit/Package.swift` path: `../EMathicaMathCore` | Fix relative path |
| 5.3 | Update `EMathicaWorkspaceKit/Package.swift` paths | All 4 dependency paths |
| 5.4 | Update `eMathica.xcodeproj` to reference packages from `SharedLibraries/` | Update local SwiftPM references |
| 5.5 | ✅ **Build & test verification** | Both apps build, all tests pass |
| 5.6 | Delete old Package references if any remain | Clean up |

---

### Phase 6: Git Repository Initialization

**Goal:** Create independent Git repos for each component.  
**Risk:** Low — pure git operations, no file moves.

| Step | Action | Details |
|------|--------|---------|
| 6.1 | **Hub repo:** `git init` at Hub root | Write Hub `.gitignore` |
| 6.2 | **Core repo:** `cd Projects/eMathicaCore && git init` | Preserve existing history? Use `git log` from old repo |
| 6.3 | **Collector repo:** `cd Projects/OpenMathInkCollector && git init` | Write Collector `.gitignore` |
| 6.4 | **SharedLibraries repo:** `cd Projects/SharedLibraries && git init` | Write `.gitignore` |
| 6.5 | Write `README.md` for each repo | Brief description + link back to Hub |
| 6.6 | Update Hub `REPOSITORIES.md` with actual GitHub URLs | After repos are created on GitHub |

**Git history preservation:**
The existing Git repo is at `Projects/eMathica/`. Options:
- **Option A:** Keep history in Core repo (use `git filter-branch` or `git subtree split`)
- **Option B:** Start fresh (clean history) for all repos

Recommend **Option A for Core** (preserve existing history) and **fresh starts** for Hub, Collector, and SharedLibraries.

---

### Phase 7: GitHub Upload

**Goal:** Push all repos to GitHub.  
**Risk:** Low — standard git push.

| Step | Action | Details |
|------|--------|---------|
| 7.1 | Create `nightcreek/eMathica` on GitHub | Hub repo |
| 7.2 | Create `nightcreek/eMathica-Core` on GitHub | Core repo |
| 7.3 | Create `nightcreek/OpenMathInk-Collector` on GitHub | Collector repo |
| 7.4 | Create `nightcreek/SharedLibraries` on GitHub | Shared packages repo |
| 7.5 | Create `nightcreek/OpenMathInk-Dataset` (placeholder) | Future dataset |
| 7.6 | Set remotes and push each repo | `git remote add origin <url> && git push` |
| 7.7 | Update Hub `REPOSITORIES.md` with final URLs | Cross-reference all repos |

---

### Summary Timeline

```
Phase 0: Audit & Snapshot       [1 session]
    ↓
Phase 1: Clean Collector Duplicates from Core  [1-2 sessions]
    ↓
Phase 2: Restructure Core Internally   [1 session]
    ↓
Phase 3: Restructure Collector Internally  [1 session]
    ↓
Phase 4: Setup Hub Structure      [1 session]
    ↓
Phase 5: Package Consolidation   [1 session]
    ↓
Phase 6: Git Init Per Repo       [1 session]
    ↓
Phase 7: GitHub Upload           [1 session]
```

**Total: ~7-9 sessions**

---

## Appendix A: File Move Summary

### Files to DELETE from Core (duplicated in Collector)

| File | Current Path |
|------|-------------|
| `OpenMathInkCollectorApp.swift` | `Projects/eMathica/eMathica/App/` |
| `CollectorWorkspaceState.swift` | `Projects/eMathica/eMathica/State/` |
| `ConsentFlowView.swift` | `Projects/eMathica/eMathica/State/` |
| `ContributorConsentManager.swift` | `Projects/eMathica/eMathica/State/` |
| `LocalSampleStore.swift` | `Projects/eMathica/eMathica/State/` |
| `OnboardingManager.swift` | `Projects/eMathica/eMathica/State/` |
| `SettingsView.swift` | `Projects/eMathica/eMathica/State/` |
| `FormulaLabelPreviewView.swift` | `Projects/eMathica/eMathica/SharedUI/Components/` |
| Entire `FeatureUtilities/` directory | `Projects/eMathica/eMathica/FeatureUtilities/` |

### Files to MOVE within Core (restructure)

| File | From | To |
|------|------|----|
| `App/` | `eMathica/App/` | `eMathica/AppShell/` |
| `CalculatorModules/` | `eMathica/CalculatorModules/` | `eMathica/Features/` |
| `CalculatorModules/Plane/` | `.../Plane/` | `.../Features/PlaneCalculator/` |
| `CalculatorModules/Space/` | `.../Space/` | `.../Features/SpaceCalculator/` |
| `CalculatorModules/Notes/` | `.../Notes/` | `.../Features/NotesFormula/` |
| `UndoRedoManager.swift` | `eMathica/State/` | `eMathica/AppState/` |
| `KeyboardShortcutManager.swift` | `eMathica/State/` | `eMathica/Services/` |
| `eMathicaTests/` | `eMathica/eMathicaTests/` | `eMathica/Tests/eMathicaTests/` |
| `eMathicaUITests/` | `eMathica/eMathicaUITests/` | `eMathica/Tests/eMathicaUITests/` |

### Files to RENAME within Collector (restructure)

| From | To |
|------|----|
| `Models/` | `DomainModels/` |
| `Modules/` | `Features/` |
| `Shared/` | `SharedUI/` |
| `State/CollectorWorkspaceState.swift` | `State/` remains (keep) |
| `State/OnboardingManager.swift` | `AppState/` |
| `State/UndoRedoManager.swift` | `AppState/` |
| `State/ContributorConsentManager.swift` | `Services/` |
| `State/ConsentFlowView.swift` | `Features/FileManagement/` |
| `State/SettingsView.swift` | `Features/Settings/` (new) |

---

## Appendix B: Risk Registry

| Risk | Phase | Severity | Mitigation |
|------|-------|----------|------------|
| Deleting Collector files breaks Core build | 1 | High | Delete from Xcode project *before* deleting files; build-verify before moving on |
| Relative package paths invalid after rename | 5 | High | Update all Package.swift + xcodeproj references atomically |
| Xcode folder references orphaned after moves | 2, 3 | Medium | Use Xcode's built-in refactoring or re-add files; never move files without updating pbxproj |
| Lost git history | 6 | Medium | Use `git filter-branch` or `git subtree` to preserve Core history |
| Broken internal doc links | All | Low | Accept as known issue; fix proactively in a cleanup pass |
