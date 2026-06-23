# DocumentSystem Removal Report

> Date: 2026-06-22
> Scope: Remove stale `DocumentSystem/` copy, keep `LocalProjectStore.swift`, clean xcodeproj

---

## Files Moved

| File | From | To | Status |
|---|---|---|---|
| `LocalProjectStore.swift` | `DocumentSystem/IO/LocalProjectStore.swift` | `Services/LocalProjectStore.swift` | ✅ Moved |

`LocalProjectStore.swift` was relocated to a new `Services/` directory in the app
source root. Its imports were not modified — it already had `import EMathicaDocumentKit`
and `import Foundation`. Its single app-target dependency (`ProjectPreviewRenderer`)
is injected via a closure parameter default; no changes needed.

---

## Files Deleted

The following 11 files were deleted from `DocumentSystem/` (they are fully
covered by `EMathicaDocumentKit` package):

| # | File | Lines | Replaced By |
|---|---|---|---|
| 1 | `DocumentCommand.swift` | 25 | `EMathicaDocumentKit` |
| 2 | `DocumentObjectPatch.swift` | 72 | `EMathicaDocumentKit` |
| 3 | `EMathicaDocument.swift` | 159 | `EMathicaDocumentKit` |
| 4 | `IO/ProjectStore.swift` | 11 | `EMathicaDocumentKit` |
| 5 | `IO/ProjectStoreError.swift` | 10 | `EMathicaDocumentKit` |
| 6 | `Package/EMathicaPackageCodec.swift` | 16 | `EMathicaDocumentKit` |
| 7 | `Package/EMathicaPackageLayout.swift` | 27 | `EMathicaDocumentKit` |
| 8 | `ProjectFileManagerPlaceholder.swift` | 5 | `EMathicaDocumentKit` |
| 9 | `ProjectMetadata.swift` | 32 | `EMathicaDocumentKit` |
| 10 | `ProjectPackageStructure.swift` | 19 | `EMathicaDocumentKit` |
| 11 | `RecentProject.swift` | 29 | `EMathicaDocumentKit` |

The entire `DocumentSystem/` directory (including now-empty `IO/` and `Package/`
subdirectories) was removed.

---

## Xcode Changes

### Modified file

`Projects/eMathica/eMathica.xcodeproj/project.pbxproj`

### What changed

Removed 24 lines from the `EXCLUDED_SOURCE_FILE_NAMES` build setting across
two build configurations (Debug + Release). The removed entries were:

```
"**/DocumentSystem/GeometryDefinition.swift",     ← (stray — file never existed)
"**/DocumentSystem/EMathicaDocument.swift",
"**/DocumentSystem/DocumentCommand.swift",
"**/DocumentSystem/DocumentObjectPatch.swift",
"**/DocumentSystem/ProjectMetadata.swift",
"**/DocumentSystem/RecentProject.swift",
"**/DocumentSystem/ProjectPackageStructure.swift",
"**/DocumentSystem/ProjectFileManagerPlaceholder.swift",
"**/DocumentSystem/IO/ProjectStore.swift",
"**/DocumentSystem/IO/ProjectStoreError.swift",
"**/DocumentSystem/Package/EMathicaPackageCodec.swift",
"**/DocumentSystem/Package/EMathicaPackageLayout.swift",
```

These were exclusion patterns that prevented the stale DocumentSystem files from
being compiled alongside the package. With the files deleted, the patterns are
no longer needed.

No PBXGroup or PBXFileReference entries existed for DocumentSystem — the files
were only referenced through the exclusion globs.

---

## Verification

| Check | Result |
|---|---|
| `DocumentSystem/` directory exists | ❌ Removed ✅ |
| Any `.swift` file references "DocumentSystem" path | ✅ Zero matches |
| Any `.pbxproj` references "DocumentSystem" | ✅ Zero matches |
| Any `.toml` file references "DocumentSystem" | ✅ Zero matches |
| `Services/LocalProjectStore.swift` exists | ✅ Present |
| `import EMathicaDocumentKit` coverage | ✅ Confirmed 100% in prior audit (77/77 files) |

---

## Remaining Risks

| Risk | Severity | Resolution |
|---|---|---|
| Xcode may show warning if workspace cache references old paths | Low | Clean build folder (Cmd+Shift+K) resolves it |
| `GeometryDefinition.swift` was referenced in exclude list but never existed | None | Stray entry — harmless and now removed |
| `DocumentSystem/` may still appear in Xcode's project navigator if cached | Low | Close and reopen project, or clean DerivedData |

---

## Next Recommended Step

### Phase 2: FeatureUtilities → EMathicaCollectorSharedKit

The next deduplication target is `FeatureUtilities/` (7 files duplicated with
OpenMathInkCollector). The preparation audit
(`Documentation/Working/FeatureUtilitiesOwnershipAudit.md`) is already complete.

**Key differences from DocumentSystem:**
- Files have **diverged** (not identical — Collector has improvements)
- New Package must be **created**, not just relied upon
- Both xcodeproj files need updating
- Source of Truth decisions already documented (5 files → Collector version)

### Optional cleanup

- Remove empty `Documentation/Automation/` and `Documentation/temp/` directories
- Add `Documentation/ARCHITECTURE/ModularDirectoryArchitecturePlan.md` to
  version control tracking
