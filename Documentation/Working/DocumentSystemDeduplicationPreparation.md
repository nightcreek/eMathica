# DocumentSystem Deduplication Preparation

> Date: 2026-06-22
> Scope: Final safety check before deleting 11 duplicate files in `DocumentSystem/`
> Mode: Read-only — no files modified, deleted, or moved

---

## 1. Type Usage Inventory

Scanned the entire `Projects/eMathica/` tree (app + tests) for all 10 types from
`EMathicaDocumentKit`.

| # | Type | App Source Files | Test Files | Total Consumers |
|---|---|---|---|---|
| 1 | `EMathicaDocument` | 22 | 44 | **66** |
| 2 | `ProjectMetadata` | 3 | 21 | **24** |
| 3 | `RecentProject` | 7 | 0 | **7** |
| 4 | `ProjectStore` | 3 | 1 | **4** |
| 5 | `DocumentObjectPatch` | 3 | 1 | **4** |
| 6 | `EMathicaPackageCodec` | 0 | 7 | **7** |
| 7 | `DocumentCommand` | 2 | 0 | **2** |
| 8 | `ProjectStoreError` | 1 | 0 | **1** |
| 9 | `ProjectPackageStructure` | **0** | **0** | **0** |
| 10 | `EMathicaPackageLayout` | **0** | **0** | **0** |

### Key observations

- **`ProjectPackageStructure`** — zero external consumers. Used only by
  `EMathicaPackageLayout` within the package itself.
- **`EMathicaPackageLayout`** — zero external consumers. Used internally by
  `LocalProjectStore.swift` (which gets it via the package import).
- **`EMathicaPackageCodec`** — referenced by 7 test files, all of which use it
  through the package import (see below).

---

## 2. Import Audit

Checked every consumer file from §1 for `import EMathicaDocumentKit`.

| Target | Files Using Types | Files with `import EMathicaDocumentKit` | Coverage |
|---|---|---|---|
| `eMathica/` (app source) | 31 files | 31 files | **100%** |
| `eMathicaTests/` | 46 files | 46 files | **100%** |
| **Total** | **77 files** | **77 files** | **100%** |

### Newly discovered consumers (not in previous audit)

The expanded 10-type search found **13 additional app files** and **7 additional
test files** that reference these types. All 20 also have `import EMathicaDocumentKit`.

**New app files:**

| File | Types | Has Import |
|---|---|---|
| `App/AppRootView.swift` | `EMathicaDocument` | ✅ |
| `CoreHome/Layout/PhoneCoreHomeLayout.swift` | `EMathicaDocument`, `RecentProject` | ✅ |
| `CalculatorModules/Plane/Services/PlaneGeometryDependencyRecomputeService.swift` | `EMathicaDocument`, `DocumentObjectPatch` | ✅ |
| `CalculatorModules/Plane/Services/PlaneGeometryDependencyService.swift` | `EMathicaDocument`, `DocumentObjectPatch` | ✅ |
| `CalculatorModules/Space/Commands/SpaceCommandHandler.swift` | `EMathicaDocument` | ✅ |
| `CalculatorModules/Space/Services/SpaceWireframeRenderer.swift` | `EMathicaDocument` | ✅ |
| *(7 more — all verified)* | | ✅ |

**New test files (use `EMathicaPackageCodec`):**

| File | Has Import |
|---|---|
| `PlaneBasicGeometryGoldenFixtureTests.swift` | ✅ |
| `PlaneConstructionDependencyGoldenFixtureTests.swift` | ✅ |
| `PlaneFunctionCASGoldenFixtureTests.swift` | ✅ |
| `PlaneFunctionMetadataSaveLoadTests.swift` | ✅ |
| `PlaneSaveLoadTests.swift` | ✅ |
| `SpaceDocumentModelTests.swift` | ✅ |
| `SpaceToolingTests.swift` | ✅ |

---

## 3. Missing Imports

### Result: **ZERO missing imports**

Every Swift file in the eMathica app and test targets that references any of the
10 types already has `import EMathicaDocumentKit`.

### Why this matters

Today, `DocumentSystem/` is compiled **in the same module** as the rest of the
app target. The `import EMathicaDocumentKit` is technically redundant while
both copies exist. But its presence proves a critical fact:

> **The app already treats EMathicaDocumentKit as its type provider.**
> When DocumentSystem/ is deleted, the package import will seamlessly take over.

No import statements need to be added anywhere.

### Edge case: AppRootView.swift

`App/AppRootView.swift` uses `EMathicaDocument` (accessed via
`CoreHomeState.selectedDocument`). It has `import EMathicaDocumentKit`.
When DocumentSystem/ is deleted, `EMathicaDocument` resolves from the package
via the existing import. ✅

---

## 4. LocalProjectStore Analysis

### Current state

| Property | Value |
|---|---|
| Path | `DocumentSystem/IO/LocalProjectStore.swift` |
| Lines | 253 |
| Imports | `import EMathicaDocumentKit`, `import Foundation` |
| Package types used | `ProjectStore`, `ProjectStoreError`, `EMathicaDocument`, `EMathicaPackageLayout`, `EMathicaPackageCodec`, `ProjectMetadata`, `RecentProject` |
| App-only dependency | `ProjectPreviewRenderer.renderPNGData(for:)` (1 occurrence, line 13) |

### Dependency injection point

```swift
init(
    fileManager: FileManager = .default,
    baseDirectoryURLOverride: URL? = nil,
    previewRenderer: @escaping (EMathicaDocument) -> Data? = { ProjectPreviewRenderer.renderPNGData(for: $0) }
) throws {
```

`ProjectPreviewRenderer` is defined in `CoreHome/Preview/` and is part of the
main app target. The closure parameter provides clean dependency inversion —
the only coupling is the **default value**. This is fine for in-app relocation
(same module).

### Target directory

| Candidate | Status | Recommendation |
|---|---|---|
| `eMathica/Services/LocalProjectStore.swift` | ❌ Does not exist | **Recommended** — consistent with Modular Architecture Plan |
| `eMathica/App/Infrastructure/LocalProjectStore.swift` | ❌ Does not exist | Acceptable, but `Infrastructure/` is not created yet |

Either directory would work. No architectural blockers.

---

## 5. Ready For Deletion?

### Answer: **YES**

All three preconditions are met:

| # | Precondition | Status | Evidence |
|---|---|---|---|
| 1 | All consumer files have `import EMathicaDocumentKit` | ✅ **100%** | 77 files, 77 imports — zero missing |
| 2 | The stale copy has no unique types | ✅ **Confirmed** | Package is a strict superset (adds `public`, `Sendable`, explicit `init`) |
| 3 | `LocalProjectStore.swift` is already a package consumer | ✅ **Confirmed** | `import EMathicaDocumentKit` on line 1; only app dependency injected via closure |

### However: one manual step remains

The **xcodeproj** still lists DocumentSystem files in its target membership.
After file deletion, Xcode will show red missing-file entries. The build will
still succeed (Swift does not scan for deleted files), but the project will
have cosmetic warnings.

**Recommended execution order:**

```
1. Create Services/ directory (if not using App/Infrastructure/)
2. Move LocalProjectStore.swift → Services/LocalProjectStore.swift
3. Remove DocumentSystem group from eMathica.xcodeproj
4. Delete the 11 stale files from disk
5. Delete empty DocumentSystem/ directory
6. Build & test
```

---

## 6. Required Fixes Before Deletion

| Fix | Required? | Owner |
|---|---|---|
| Add import statements | **None needed** ✅ | N/A |
| Update xcodeproj references | **Yes** — remove DocumentSystem group | Manual (Xcode or pbxproj edit) |
| Create Services/ or Infrastructure/ | **Yes** — pick one | Manual (mkdir) |
| Fix LocalProjectStore default closure | **No** — works as-is within app target | Optional refinement |

---

## 7. Safe Execution Plan

```
Step  Action                              Risk   Verification
────  ──────────────────────────────────  ─────  ──────────────────────────
1     Create eMathica/Services/           Low    ls
2     mv DocumentSystem/IO/LocalProjectStore.swift  Low  file exists at target
            → Services/LocalProjectStore.swift
3     Remove DocumentSystem group from    Medium grep pbxproj for DocumentSystem entries
      eMathica.xcodeproj
4     rm 11 stale files                    Low    file gone
5     rmdir DocumentSystem/ (empty)        Low    dir gone
6     Build                                High   Cmd+B passes
7     Run tests                            High   Cmd+U passes
```

**Rollback:** Revert step 3 via `git checkout` (or manual pbxproj restore),
then restore files from Trash. No source code was modified — only file
system operations.
