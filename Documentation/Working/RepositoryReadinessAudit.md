# Repository Readiness Audit

> Date: 2026-06-22
> Mode: Read-only — no files modified, no git commands executed
> Scope: Evaluate `eMathica`, `OpenMathInkCollector`, `Packages`, and `Documentation/`
> for independent Git repository initialization

---

## eMathica

### Status: **NOT READY**

### Prerequisite checks

| Check | Result | Details |
|---|---|---|
| `eMathica.xcodeproj` exists and valid | ✅ PASS | `project.pbxproj` 34,342 bytes, valid structure |
| All 5 SwiftPM package references valid | ✅ PASS | `../../Packages/EMathicaMathCore`, `../../Packages/EMathicaDocumentKit`, `../../Packages/EMathicaThemeKit`, `../../Packages/EMathicaWorkspaceKit`, `../../Packages/EMathicaMathInputKit` — all resolve correctly |
| No stale internal Packages/ | ✅ PASS | `Projects/eMathica/Packages/` exists but is empty |
| DocumentSystem fully removed | ✅ PASS | No files, no xcodeproj references, zero grep matches |
| No hardcoded external path references | ✅ PASS | No source code references paths outside its own tree |

### Blocking items

| # | Blocker | Severity | Details |
|---|---|---|---|
| **B1** | **FeatureUtilities/ still has duplicated files** | 🔴 **High** | 7 files in `eMathica/FeatureUtilities/` are duplicated with `OpenMathInkCollector`. They are **excluded from the build target** (membership exceptions), but they are physically present. An independent eMathica repo should not ship Collector code. |
| **B2** | **OpenMathInkCollector files inside eMathica source tree** | 🔴 **High** | 10 files from the Collector app remain in the eMathica tree, all **excluded from build target**: `App/OpenMathInkCollectorApp.swift`, `State/CollectorWorkspaceState.swift`, `State/ConsentFlowView.swift`, `State/ContributorConsentManager.swift`, `State/KeyboardShortcutManager.swift`, `State/LocalSampleStore.swift`, `State/OnboardingManager.swift`, `State/SettingsView.swift`, `State/UndoRedoManager.swift`, `SharedUI/Components/FormulaLabelPreviewView.swift`. These must be removed or relocated to the Collector before eMathica can be an independent repo. |

### Non-blocking items (should be cleaned up eventually)

| Issue | Notes |
|---|---|
| `eMathica/Scripts/` contains app-specific tooling | Fine — belongs in eMathica repo |
| `eMathica/reasonix.toml` duplicates hub config | Minor — can be kept per-repo |

---

## OpenMathInkCollector

### Status: **NOT READY**

### Prerequisite checks

| Check | Result | Details |
|---|---|---|
| `OpenMathInkCollector.xcodeproj` exists and valid | ✅ PASS | `project.pbxproj` 13,272 bytes, valid structure |
| Has own `.gitignore` | ✅ PASS | `OpenMathInkCollector/.gitignore` (918 bytes), comprehensive |
| No file references outside own tree | ✅ PASS | Uses `PBXFileSystemSynchronizedRootGroup` pointing to its own source folder |
| No dependency on eMathica internal source code | ✅ PASS | No PBXFileReference entries pointing outside its directory |
| Only external dependency is EMathicaMathInputKit | ✅ PASS | Single `XCLocalSwiftPackageReference` entry |

### Blocking items

| # | Blocker | Severity | Details |
|---|---|---|---|
| **B3** | **Package reference path is BROKEN** | 🔴 **CRITICAL** | The xcodeproj at `Projects/OpenMathInkCollector/OpenMathInkCollector/OpenMathInkCollector.xcodeproj/` has `relativePath = ../../Packages/EMathicaMathInputKit`. This resolves to `Projects/OpenMathInkCollector/Packages/EMathicaMathInputKit` — **which does not exist**. The correct path is `../../../Packages/EMathicaMathInputKit` (3 levels up, then into `Projects/Packages/`). **The project cannot resolve its dependency and would fail to build.** |

### Path resolution detail

```
xcodeproj location:
  Projects/OpenMathInkCollector/OpenMathInkCollector/OpenMathInkCollector.xcodeproj/

Current (broken):
  ../../Packages/EMathicaMathInputKit
  → Projects/OpenMathInkCollector/Packages/EMathicaMathInputKit  ❌

Correct:
  ../../../Packages/EMathicaMathInputKit
  → Projects/Packages/EMathicaMathInputKit  ✅
```

### Additional consideration

The xcodeproj is nested **3 levels deep** inside the Collector directory:
`OpenMathInkCollector/OpenMathInkCollector/OpenMathInkCollector.xcodeproj/`.

This triple nesting (`OpenMathInkCollector/OpenMathInkCollector/OpenMathInkCollector/`)
is unusual and may cause issues with Git repo initialization. Typically a
single-project repo would have the xcodeproj at the repo root or one level deep.
After repoing, consider flattening to:

```
OpenMathInkCollector/
├── OpenMathInkCollector.xcodeproj/
├── OpenMathInkCollector/           (source)
├── Packages/                       (local deps, if any)
├── Tests/
├── .gitignore
└── README.md
```

---

## Packages

### Status: **READY** ✅

### Prerequisite checks

| Check | Result | Details |
|---|---|---|
| All 5 packages have `Package.swift` | ✅ PASS | EMathicaMathCore, EMathicaDocumentKit, EMathicaMathInputKit, EMathicaThemeKit, EMathicaWorkspaceKit — all have valid manifests |
| `swift-tools-version` declarations | ✅ PASS | All use `// swift-tools-version: 6.0` (MathInputKit uses 5.10 — acceptable) |
| No stale/incorrect relative paths | ✅ PASS | All paths use `../OtherPackage` which resolves correctly from `Projects/Packages/` |
| No circular dependencies | ✅ PASS | Clean DAG with no cycles |
| No dependencies outside `Projects/Packages/` | ✅ PASS | All paths stay within sibling directories |

### Dependency graph

```
EMathicaMathCore          (no deps)         ← leaf
EMathicaThemeKit          (no deps)         ← leaf
EMathicaMathInputKit      (no deps)         ← leaf
    ↑
EMathicaDocumentKit       (→ MathCore)
    ↑
EMathicaWorkspaceKit      (→ MathCore, DocumentKit, ThemeKit, MathInputKit)
```

### Path reference summary

| Package | Dependency | Path | Resolves To | Status |
|---|---|---|---|---|
| EMathicaDocumentKit | EMathicaMathCore | `../EMathicaMathCore` | `Projects/Packages/EMathicaMathCore/` | ✅ |
| EMathicaWorkspaceKit | EMathicaMathCore | `../EMathicaMathCore` | `Projects/Packages/EMathicaMathCore/` | ✅ |
| EMathicaWorkspaceKit | EMathicaDocumentKit | `../EMathicaDocumentKit` | `Projects/Packages/EMathicaDocumentKit/` | ✅ |
| EMathicaWorkspaceKit | EMathicaThemeKit | `../EMathicaThemeKit` | `Projects/Packages/EMathicaThemeKit/` | ✅ |
| EMathicaWorkspaceKit | EMathicaMathInputKit | `../EMathicaMathInputKit` | `Projects/Packages/EMathicaMathInputKit/` | ✅ |

### Cleanup suggestion (low priority)

The `.build/` and `.swiftpm/` directories inside individual packages contain
derived data and should be `.gitignore`'d:

```
Projects/Packages/EMathicaMathInputKit/.build/
Projects/Packages/EMathicaWorkspaceKit/.build/
```

Not a blocker — standard SwiftPM behavior.

---

## Documentation

### Status: **NOT READY**

### Structure check

| Requirement | Exists? | Has Content? | Status |
|---|---|---|---|
| `ARCHITECTURE/` | ✅ Yes | ✅ 1 file (`EMathicaCollectorSharedKitArchitecturePlan.md`) | ✅ |
| `ADR/` | ✅ Yes | ❌ **Empty** | ❌ |
| `POLICIES/` | ✅ Yes | ❌ **Empty** | ❌ |
| `WORKING/` | ✅ Yes (as `Working/`) | ✅ 10 files | ✅ (cosmetic: lowercase) |
| `ARCHIVE/` | ✅ Yes | ❌ **Empty** | ❌ |

### Blocking items

| # | Blocker | Severity | Details |
|---|---|---|---|
| **B4** | **ADR/, POLICIES/, ARCHIVE/ are empty** | 🟡 **Medium** | Created as future-use directories but contain no documents. Not a repo blocker per se, but the structure is incomplete. |
| **B5** | **Legacy empty directories present** | 🟢 **Low** | `Automation/` and `temp/` are empty and should be removed before repo init. |

### Non-blocking

| Issue | Notes |
|---|---|
| `Working/` is lowercase, not `WORKING/` | macOS APFS case-insensitive — no practical impact |
| No `CORE` documents exist | README, ROADMAP, ARCHITECTURE.md at root — should be created but not a blocker |

---

## Summary

### Readiness by project

| Project | Status | Blockers |
|---|---|---|
| **eMathica** | ❌ **NOT READY** | 2 high-severity blockers: Collector files in source tree, FeatureUtilities duplication |
| **OpenMathInkCollector** | ❌ **NOT READY** | 1 critical blocker: package reference path is broken |
| **Packages** | ✅ **READY** | 0 blockers — all packages independently buildable |
| **Documentation** | ❌ **NOT READY** | 1 medium blocker: empty dirs, 1 low: legacy dirs |

### Blocker severity heatmap

```
🔴 CRITICAL: B3 — OpenMathInkCollector path broken (build cannot resolve)
🔴 HIGH:     B1 — FeatureUtilities duplication in eMathica
🔴 HIGH:     B2 — Collector files inside eMathica tree
🟡 MEDIUM:   B4 — Empty ADR/POLICIES/ARCHIVE dirs
🟢 LOW:      B5 — Legacy empty dirs (Automation/, temp/)
```

---

## Recommended Next Action

### Choice: **B. Fix Repository Blockers**

**Rationale:** 3 out of 4 projects have blockers that prevent clean repository
initialization. The highest-impact fix is **B3** (OpenMathInkCollector xcodeproj
path) which only requires a one-line change. The highest-effort fix is
**B1/B2** (removing Collector code from eMathica tree), which requires either:

a) Completing the `EMathicaCollectorSharedKit` extraction (Phase A), or
b) Simply deleting the 10 membership-excluded Collector files + 7 FeatureUtilities
   files from the eMathica tree (these are already excluded from the build and
   not needed there).

### Why not A or C

| Option | Why not |
|---|---|
| **A. Initialize Git Repositories** | Blockers B1-B3 would ship stale/duplicated/broken code into the initial commit — poor hygiene for `git init`. |
| **C. Continue SharedKit Extraction** | The SharedKit extraction (Phase A) is a separate effort that resolves B1. But B2 (Collector files in eMathica tree) and B3 (broken xcodeproj path) are independent issues that should be fixed first. B3 in particular is a one-line fix. |

### Execution order for B

```
Priority 1: Fix B3 — OpenMathInkCollector xcodeproj path
  (one-line change, 5 minutes)

Priority 2: Fix B2 — Remove Collector-specific files from eMathica tree
  (10 files, already excluded from build — safe to delete)

Priority 3: Fix B1 — Remove FeatureUtilities/ from eMathica tree
  (7 files, already excluded from build — safe to delete,
   OR complete SharedKit extraction first)

Priority 4: Fix B4 — Remove or populate empty ADR/POLICIES/ARCHIVE/

Priority 5: Fix B5 — Remove Automation/ and temp/
```

### After fixes are applied

```
eMathica:              ✅ READY
OpenMathInkCollector:  ✅ READY (after B3 fixed)
Packages:              ✅ READY (already)
Documentation:         ✅ READY (after B4, B5 fixed)
```
