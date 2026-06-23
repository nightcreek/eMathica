# Phase 1 Package Extraction Report

> Date: 2026-06-22
> Scope: Directory renames + EMathicaMathCore extraction + Package.swift path updates
> Status: **Complete, with one blocked item** (see §7)

---

## 1. Summary

Phase 1 of the Modular Directory Architecture Plan was executed. Three structural
changes were completed successfully:

| # | Operation | Status |
|---|---|---|
| 1 | Rename `Projects/eMathica app` → `Projects/eMathica` | ✅ Done |
| 2 | Rename `Projects/OpenMathInk Collector` → `Projects/OpenMathInkCollector` | ✅ Done |
| 3 | Move `Projects/eMathica/Packages/EMathicaMathCore` → `Projects/Packages/EMathicaMathCore` | ✅ Done |
| 4 | Update Package.swift relative paths for EMathicaMathCore | ✅ Done |
| 4b | Update `eMathica.xcodeproj` local SwiftPM reference path | ⛔ **Blocked** (see §7) |

No source files were modified. No files were deleted. No git commands were run.
`DocumentSystem` and `FeatureUtilities` were left untouched.

---

## 2. Directories Renamed

| Old Name | New Name | Reason |
|---|---|---|
| `Projects/eMathica app` | `Projects/eMathica` | Remove space; align with repo naming convention |
| `Projects/OpenMathInk Collector` | `Projects/OpenMathInkCollector` | Remove space; align with repo naming convention |

Both were simple `mv` operations. No content conflicts occurred.

---

## 3. Directories Moved

| Source | Destination |
|---|---|
| `Projects/eMathica/Packages/EMathicaMathCore/` | `Projects/Packages/EMathicaMathCore/` |

EMathicaMathCore is a SwiftPM package with 43 source files across 11 subdirectories
and 12 test files. It is the foundational math engine dependency for both
EMathicaDocumentKit and EMathicaWorkspaceKit.

The old `Projects/eMathica/Packages/` directory is now empty and can be removed
once the xcodeproj reference is updated.

**Target path verified:**
```
Projects/Packages/
├── EMathicaDocumentKit/
├── EMathicaMathCore/          ← newly moved
├── EMathicaMathInputKit/
├── EMathicaThemeKit/
└── EMathicaWorkspaceKit/
```

---

## 4. Package.swift Changes

### 4.1 EMathicaDocumentKit

**File:** `Projects/Packages/EMathicaDocumentKit/Package.swift` (line 17)

| Before | After |
|---|---|
| `.package(path: "../../eMathica/eMathica/Packages/EMathicaMathCore")` | `.package(path: "../EMathicaMathCore")` |

The other dependency reference on line 22 (`dependencies: ["EMathicaMathCore"]`)
is the target-level dependency name, not a path — it was left unchanged.

### 4.2 EMathicaWorkspaceKit

**File:** `Projects/Packages/EMathicaWorkspaceKit/Package.swift` (line 17)

| Before | After |
|---|---|
| `.package(path: "../../eMathica/eMathica/Packages/EMathicaMathCore")` | `.package(path: "../EMathicaMathCore")` |

### 4.3 Not Modified

- `EMathicaMathInputKit/Package.swift` — had no MathCore dependency
- `EMathicaThemeKit/Package.swift` — had no MathCore dependency
- `EMathicaMathCore/Package.swift` — self-referential; no external deps

---

## 5. Skipped Items

The following items were intentionally skipped per the Phase 1 scope rules:

| Item | Rule | Status |
|---|---|---|
| `Projects/eMathica/eMathica/DocumentSystem/` | "不要删除" | ❌ Skipped |
| `Projects/eMathica/eMathica/FeatureUtilities/` | "不要删除" | ❌ Skipped |
| Internal source dirs (App/, State/, etc.) | "不要重命名内部源码目录" | ❌ Skipped |
| Swift source code | "不要修改 Swift 源码" | ✅ Not touched |
| .xcodeproj (eMathica) | "先停止并报告" | ⛔ **See §7** |
| .xcodeproj (OpenMathInkCollector) | No MathCore reference found | ✅ Not needed |
| .build, .DS_Store, xcuserdata | "不要清理" | ✅ Not touched |
| Git operations | "不要执行 git 命令" | ✅ Not executed |

---

## 6. Risks

### 6.1 Resolved Risks

| Risk | Mitigation |
|---|---|
| Package dependency path stale after rename | Path was updated to `../EMathicaMathCore` — resolves correctly from `Projects/Packages/` |
| Target directory already exists | `Projects/Packages/EMathicaMathCore/` did not exist; no conflict |
| Old Packages/ dir still has content | After move, the old `Projects/eMathica/Packages/` is empty |

### 6.2 Open Risk: xcodeproj Reference

The xcodeproj at `Projects/eMathica/eMathica.xcodeproj/project.pbxproj` contains:

```
// line 823 — old (broken)
relativePath = Packages/EMathicaMathCore;

// line 827 — example of how siblings are correctly referenced
relativePath = ../../Packages/EMathicaDocumentKit;
```

The old path resolves to `Projects/eMathica/Packages/EMathicaMathCore/`, which no
longer exists. The correct path should be:

```
relativePath = ../../Packages/EMathicaMathCore;
```

This affects two product references (lines 846, 851) that depend on this
XCLocalSwiftPackageReference entry. The build will fail until this is updated.

This is the only xcodeproj change required — all other package references
(`EMathicaDocumentKit`, `EMathicaThemeKit`, `EMathicaWorkspaceKit`,
`EMathicaMathInputKit`) already use the correct `../../Packages/` prefix and
remain valid.

**OpenMathInkCollector's xcodeproj does not reference EMathicaMathCore** —
no change needed.

---

## 7. Required Manual Checks

### 7.1 eMathica.xcodeproj — Must Update SwiftPM Reference

**Location:** `Projects/eMathica/eMathica.xcodeproj/project.pbxproj`

**Change required:**

| Line | Current Value | Correct Value |
|---|---|---|
| 823 | `relativePath = Packages/EMathicaMathCore;` | `relativePath = ../../Packages/EMathicaMathCore;` |

This is a one-line change in the XCLocalSwiftPackageReference section. It aligns
the MathCore reference with how all other shared packages are already referenced
(e.g., `../../Packages/EMathicaDocumentKit` on line 827).

**Action:** Either:
- Open the project in Xcode, remove and re-add the local package reference, OR
- Edit line 823 of the `project.pbxproj` file directly (text editor safe)

### 7.2 Verify Build

After updating the xcodeproj:
1. Open `Projects/eMathica/eMathica.xcodeproj` in Xcode
2. Clean build folder (Cmd+Shift+K)
3. Build and run
4. Run tests

### 7.3 Clean Up Empty Directory

After build verification, remove the now-empty:
```
Projects/eMathica/Packages/
```

---

## 8. Final Directory State

```
eMathica Hub/
├── Assets/
├── Data/
├── Documentation/
│   └── Automation/
│       ├── RepositoryStructureMigrationReport.md
│       ├── ModularDirectoryArchitecturePlan.md
│       └── Phase1_PackageExtractionReport.md       ← this file
├── Projects/
│   ├── eMathica/                                    ← renamed
│   │   ├── eMathica.xcodeproj/
│   │   ├── eMathica/
│   │   ├── eMathicaTests/
│   │   ├── eMathicaUITests/
│   │   ├── Packages/                                ← empty (MathCore moved out)
│   │   └── ...
│   ├── OpenMathInkCollector/                        ← renamed
│   │   ├── OpenMathInkCollector.xcodeproj/
│   │   └── OpenMathInkCollector/
│   └── Packages/
│       ├── EMathicaMathCore/                        ← newly moved here
│       ├── EMathicaDocumentKit/
│       ├── EMathicaMathInputKit/
│       ├── EMathicaThemeKit/
│       └── EMathicaWorkspaceKit/
└── reasonix.toml
```
