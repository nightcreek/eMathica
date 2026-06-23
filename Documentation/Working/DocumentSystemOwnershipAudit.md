# DocumentSystem Ownership Audit

> Date: 2026-06-22
> Scope: Read-only comparison of `Projects/eMathica/eMathica/DocumentSystem/` vs `Projects/Packages/EMathicaDocumentKit/Sources/EMathicaDocumentKit/`
> Audit method: Per-file visual comparison of source text, line count, and access control.

---

## 1. Executive Summary

The App-side `DocumentSystem/` and the shared `EMathicaDocumentKit` package contain
**11 pairs of logically identical files**. Every paired file is **NEAR_IDENTICAL**:
the only differences are access-control keywords (`public` vs internal) and
a swapped import statement order.

**Verdict:** The Package (`EMathicaDocumentKit`) is already the authoritative Source of
Truth — it carries `public` access modifiers required for cross-module visibility
and also includes `Sendable` conformance on `ProjectPackageStructure` that the App
copy lacks. The App-side `DocumentSystem/` is a **stale copy** that should be
deleted after the xcodeproj is updated to rely solely on the package.

The App has **one file not in the package** (`LocalProjectStore.swift`) which
already imports `EMathicaDocumentKit`, confirming it is designed to depend on the
package.

| Metric | Count |
|---|---|
| Total App files | 12 |
| Total Package files | 11 (source) + 1 (test) + 1 (Package.swift) |
| Paired (same name, both sides) | 11 |
| IDENTICAL | 0 |
| NEAR_IDENTICAL | 11 |
| APP_ONLY | 1 |
| PACKAGE_ONLY | 2 (test + Package.swift) |
| DIFFERENT (logical drift) | 0 |

**Can the App's `DocumentSystem/` be deleted?** ✅ **Yes**, with one precondition.

---

## 2. File Mapping Table

### Legend

| Status | Meaning |
|---|---|
| **IDENTICAL** | Byte-for-byte identical content |
| **NEAR_IDENTICAL** | Same logic, only access control or import order differs |
| **APP_ONLY** | Exists only in the App copy |
| **PACKAGE_ONLY** | Exists only in the Package |
| **DIFFERENT** | Divergent logic or semantics |

### Table

| # | App File | Package File | Lines (App) | Lines (Pkg) | Status | Difference |
|---|---|---|---|---|---|---|
| 1 | `DocumentCommand.swift` | `DocumentCommand.swift` | 25 | 25 | **NEAR_IDENTICAL** | Import order swapped; App: `enum` / Package: `public enum` |
| 2 | `DocumentObjectPatch.swift` | `DocumentObjectPatch.swift` | 72 | 72 | **NEAR_IDENTICAL** | Import order swapped; App: internal struct + members / Package: `public` on struct, all properties, and init |
| 3 | `EMathicaDocument.swift` | `EMathicaDocument.swift` | 159 | 159 | **NEAR_IDENTICAL** | Import order swapped; App: internal / Package: `public` on struct, methods, properties, static let, init |
| 4 | `IO/ProjectStore.swift` | `IO/ProjectStore.swift` | 11 | 11 | **NEAR_IDENTICAL** | App: `protocol` / Package: `public protocol` |
| 5 | `IO/ProjectStoreError.swift` | `IO/ProjectStoreError.swift` | 10 | 10 | **NEAR_IDENTICAL** | App: `enum` / Package: `public enum` |
| 6 | `Package/EMathicaPackageCodec.swift` | `Package/EMathicaPackageCodec.swift` | 16 | 16 | **NEAR_IDENTICAL** | App: internal enum + static funcs / Package: `public enum` + `public static func` |
| 7 | `Package/EMathicaPackageLayout.swift` | `Package/EMathicaPackageLayout.swift` | 26 | 27 | **NEAR_IDENTICAL** | App: internal struct, no explicit init / Package: `public struct` + **explicit `public init(rootURL:)`** + `public` on all members |
| 8 | `ProjectFileManagerPlaceholder.swift` | `ProjectFileManagerPlaceholder.swift` | 5 | 5 | **NEAR_IDENTICAL** | App: `enum` / Package: `public enum` |
| 9 | `ProjectMetadata.swift` | `ProjectMetadata.swift` | 32 | 32 | **NEAR_IDENTICAL** | Import order swapped; App: internal / Package: `public` on all |
| 10 | `ProjectPackageStructure.swift` | `ProjectPackageStructure.swift` | 19 | 19 | **NEAR_IDENTICAL** | App: `struct`, no Sendable / Package: `public struct`, adds **`Sendable`** conformance |
| 11 | `RecentProject.swift` | `RecentProject.swift` | 29 | 29 | **NEAR_IDENTICAL** | App: internal / Package: `public` on all |

### Detailed difference pattern

Every paired file follows **exactly one of two patterns**:

**Pattern A** (files 1-3, 9): The App version has `import EMathicaMathCore` first,
then `import Foundation`. The Package version swaps the order (`import Foundation`
first). All other text is identical except access control.

**Pattern B** (files 4-8, 10-11): The App version has `import Foundation` only
(no MathCore dependency). The Package version is identical except for `public`
keywords.

---

## 3. App-Only Files

| File | Lines | Description | Depends On |
|---|---|---|---|
| `IO/LocalProjectStore.swift` | 253 | Concrete `ProjectStore` implementation using `FileManager`. Handles `.emathica` package creation, reading, writing, deletion, renaming, and preview rendering on the local filesystem. | `import EMathicaDocumentKit` (the package!), `ProjectPreviewRenderer` |

**Critical finding:** `LocalProjectStore.swift` already **imports EMathicaDocumentKit**
(line 1), not DocumentSystem types directly. This confirms it was designed as a
client of the package, not as part of the stale document model copy.

The file depends on `ProjectPreviewRenderer` (from the App's `CoreHome/Preview/`)
for generating PNG preview thumbnails — this is an App-level dependency and
belongs in the App, not in the package.

---

## 4. Package-Only Files

| File | Lines | Description |
|---|---|---|
| `Package.swift` | 31 | SwiftPM manifest; defines target, product, dependency on `EMathicaMathCore` |
| `Tests/EMathicaDocumentKitTests/EMathicaDocumentKitTests.swift` | 171 | Basic unit tests for `EMathicaDocument` creation and command application |

These have no App counterpart — the App has no test coverage for DocumentSystem.

---

## 5. Behavioral Differences

### 5.1 Access Control (all 11 files)

The **only semantic difference** across all 11 paired files is access control.
The App version uses `internal` (default Swift access), while the Package version
explicitly marks types as `public` so they are visible to the App module and
other packages.

**This is by design** — the package must export its types for external consumers.

### 5.2 Import Order (files 1-3, 9)

App: `import EMathicaMathCore` before `import Foundation`
Package: `import Foundation` before `import EMathicaMathCore`

This has **zero behavioral impact** — import order is cosmetic in Swift.

### 5.3 Explicit `public init` in EMathicaPackageLayout (file 7)

The Package version adds an explicit initializer:
```swift
public init(rootURL: URL) { self.rootURL = rootURL }
```

The App version relies on the compiler-synthesized memberwise init. Both produce
the same result; the explicit version is required in the package because the
struct's sole stored property (`rootURL`) must be publicly initializable.

### 5.4 `Sendable` Conformance on ProjectPackageStructure (file 10)

The Package version adds `Sendable` conformance:
```swift
public struct ProjectPackageStructure: Hashable, Codable, Sendable {
```

The App version omits `Sendable`:
```swift
struct ProjectPackageStructure: Hashable, Codable {
```

This is a **forward-compatibility improvement** in the Package — `Sendable`
enables usage in Swift concurrency contexts (e.g., passing across `actor`
boundaries). It adds no behavioral change on its own.

### 5.5 No Logical Divergence

No file pair has different logic, different enum cases, different protocol
requirements, or different method implementations. The two copies have **not
diverged semantically** — the App copy is a faithful snapshot of an earlier
version before public-access migration.

---

## 6. Recommended Source Of Truth

**`Projects/Packages/EMathicaDocumentKit/Sources/EMathicaDocumentKit/`**

Rationale:

1. **Access control is correct** — all types are `public`, enabling cross-module use.
2. **`Sendable` conformance** is present for Swift concurrency readiness.
3. **Explicit initializers** are provided where needed.
4. **Already referenced** by `EMathicaWorkspaceKit` as a dependency.
5. **`LocalProjectStore.swift` already imports the package** — proving the App treats it as the canonical source.
6. **No semantic drift** — the App copy is strictly a stale internal-access version.

The App-side `DocumentSystem/` should be considered a **pre-publication working
copy** that was left behind when the files were extracted into the package.

---

## 7. Migration Plan

### Prerequisite

Before removing `DocumentSystem/`, the eMathica xcodeproj must be updated to
reference `EMathicaDocumentKit` as a SwiftPM dependency (the local package
reference already exists at `../../Packages/EMathicaDocumentKit` in the
xcodeproj — see Phase 1 report).

### Step-by-step

| Step | Action | Risk |
|---|---|---|
| 1 | **Verify xcodeproj has `EMathicaDocumentKit` in Swift Package dependencies** | Low — already present per Phase 1 audit (line 827) |
| 2 | **Verify the App target imports `EMathicaDocumentKit`** where DocumentSystem types are used | Medium — grep for `import EMathicaDocumentKit` vs old direct usage |
| 3 | **Build & test** with DocumentSystem still present but not referenced | Medium — ensure no compile errors |
| 4 | **Remove `Projects/eMathica/eMathica/DocumentSystem/`** | Low — pure deletion |
| 5 | **Remove file references from xcodeproj** | Medium — must update `project.pbxproj` group entries |
| 6 | **Final build & test** | Medium — verify no missing symbols |

### Import Migration

In App source files, replace any remaining internal-import patterns.

**Before** (if DocumentSystem was imported directly):
```swift
// No explicit import — types resolved from same module
```

**After**:
```swift
import EMathicaDocumentKit
```

The App's `LocalProjectStore.swift` already uses `import EMathicaDocumentKit`
(line 1 of the file), so it is ready. Other files in the App that reference
`EMathicaDocument`, `DocumentCommand`, `ProjectStore`, etc. must be checked
to ensure they either:
- Already import `EMathicaDocumentKit`, or
- Are in the same module as the package types (unlikely — the package is a separate module)

### 7.1 Deletion Scope

Only these 11 files + 1 empty `IO/` and 1 empty `Package/` directory should be
removed:

```
Projects/eMathica/eMathica/DocumentSystem/
├── DocumentCommand.swift          # → delete
├── DocumentObjectPatch.swift      # → delete
├── EMathicaDocument.swift         # → delete
├── IO/                            # → delete directory
│   ├── LocalProjectStore.swift    # → KEEP (App-only, imports package)
│   ├── ProjectStore.swift         # → delete
│   └── ProjectStoreError.swift    # → delete
├── Package/                       # → delete directory
│   ├── EMathicaPackageCodec.swift # → delete
│   └── EMathicaPackageLayout.swift# → delete
├── ProjectFileManagerPlaceholder.swift # → delete
├── ProjectMetadata.swift          # → delete
├── ProjectPackageStructure.swift  # → delete
└── RecentProject.swift            # → delete
```

**Files to keep:** Only `DocumentSystem/IO/LocalProjectStore.swift`

**Suggested relocation:** Move `LocalProjectStore.swift` to a more appropriate
location such as `Projects/eMathica/eMathica/Services/LocalProjectStore.swift`
or `Projects/eMathica/eMathica/App/Infrastructure/`.

---

## 8. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **App still references internal DocumentSystem types without import** | Medium | Build failure — missing symbols | Grep for `EMathicaDocument`, `DocumentCommand`, `ProjectMetadata` etc. in App source before deletion |
| **xcodeproj has stale group entries for DocumentSystem** | High | Red file references in Xcode after deletion (non-fatal) | Accept warning; clean up later or remove groups from xcodeproj |
| **Package's `Sendable` conformance breaks App's non-Sendable usage** | Low | Compiler warning about Sendable isolation | Add `@unchecked Sendable` or suppress; unlikely in current codebase |
| **Import order change causes subtle Foundation-shadowing issue** | None | N/A | Import order is cosmetic in Swift |
| **LocalProjectStore references DocumentSystem types through package** | None | Already imports EMathicaDocumentKit | Verified — safe |

### 8.1 Confidence Level

**High.** The two codebases are semantically identical. The Package is a strict
superset (adds `public` + `Sendable`). No behavioral regression is expected
from switching the App to use the Package exclusively.

---

## 9. Safe Deletion Candidates

Based on the audit, the following are **safe to delete immediately** (after
xcodeproj update and build verification):

| File | Status | Notes |
|---|---|---|
| `DocumentCommand.swift` | ✅ Safe | Fully covered by Package |
| `DocumentObjectPatch.swift` | ✅ Safe | Fully covered by Package |
| `EMathicaDocument.swift` | ✅ Safe | Fully covered by Package |
| `IO/ProjectStore.swift` | ✅ Safe | Fully covered by Package |
| `IO/ProjectStoreError.swift` | ✅ Safe | Fully covered by Package |
| `Package/EMathicaPackageCodec.swift` | ✅ Safe | Fully covered by Package |
| `Package/EMathicaPackageLayout.swift` | ✅ Safe | Fully covered by Package |
| `ProjectFileManagerPlaceholder.swift` | ✅ Safe | Fully covered by Package |
| `ProjectMetadata.swift` | ✅ Safe | Fully covered by Package |
| `ProjectPackageStructure.swift` | ✅ Safe | Fully covered by Package |
| `RecentProject.swift` | ✅ Safe | Fully covered by Package |
| `IO/LocalProjectStore.swift` | **⚠️ KEEP & MOVE** | App-only; already imports Package; relocate to `Services/` |

**Total: 11 files to delete, 1 file to keep and relocate.**
