# Phase 1.1 Xcode Package Reference Fix

> Date: 2026-06-22
> Scope: Fix stale `EMathicaMathCore` local SwiftPM reference in `eMathica.xcodeproj/project.pbxproj`
> Status: ✅ Complete

---

## Modified References

### File

`Projects/eMathica/eMathica.xcodeproj/project.pbxproj`

### Change

| Field | Before (broken) | After (fixed) |
|---|---|---|
| Line 821 (comment) | `XCLocalSwiftPackageReference "Packages/EMathicaMathCore"` | `XCLocalSwiftPackageReference "../../Packages/EMathicaMathCore"` |
| Line 823 (`relativePath`) | `relativePath = Packages/EMathicaMathCore;` | `relativePath = ../../Packages/EMathicaMathCore;` |

### Before

```pbxproj
A1B2C3D4E5F6012345678904 /* XCLocalSwiftPackageReference "Packages/EMathicaMathCore" */ = {
    isa = XCLocalSwiftPackageReference;
    relativePath = Packages/EMathicaMathCore;       // ❌ resolves to Projects/eMathica/Packages/EMathicaMathCore (empty)
};
```

### After

```pbxproj
A1B2C3D4E5F6012345678904 /* XCLocalSwiftPackageReference "../../Packages/EMathicaMathCore" */ = {
    isa = XCLocalSwiftPackageReference;
    relativePath = ../../Packages/EMathicaMathCore;  // ✅ resolves to Projects/Packages/EMathicaMathCore
};
```

### Resolution check

The xcodeproj is located at:

```
Projects/eMathica/eMathica.xcodeproj/     ← base
```

`../../Packages/EMathicaMathCore` resolves to:

```
Projects/eMathica/      ← ../
Projects/               ← ../../
Projects/Packages/EMathicaMathCore/  ← ../../Packages/EMathicaMathCore
```

---

## Verified Package References

All 5 local SwiftPM package references in `project.pbxproj` are now correct
and consistent:

| # | Package | Line | `relativePath` | Resolves To | Status |
|---|---|---|---|---|---|
| 1 | **EMathicaMathCore** | 823 | `../../Packages/EMathicaMathCore` | `Projects/Packages/EMathicaMathCore/` | ✅ Fixed |
| 2 | **EMathicaDocumentKit** | 827 | `../../Packages/EMathicaDocumentKit` | `Projects/Packages/EMathicaDocumentKit/` | ✅ Correct |
| 3 | **EMathicaThemeKit** | 831 | `../../Packages/EMathicaThemeKit` | `Projects/Packages/EMathicaThemeKit/` | ✅ Correct |
| 4 | **EMathicaWorkspaceKit** | 835 | `../../Packages/EMathicaWorkspaceKit` | `Projects/Packages/EMathicaWorkspaceKit/` | ✅ Correct |
| 5 | **EMathicaMathInputKit** | 839 | `../../Packages/EMathicaMathInputKit` | `Projects/Packages/EMathicaMathInputKit/` | ✅ Correct |

### Package.swift dependency paths also verified

| Package.swift | Dependency Path | Status |
|---|---|---|
| `EMathicaDocumentKit/Package.swift` | `../EMathicaMathCore` | ✅ Correct |
| `EMathicaWorkspaceKit/Package.swift` | `../EMathicaMathCore` | ✅ Correct |
| `EMaticaMathInputKit/Package.swift` | *(no dependencies)* | ✅ N/A |
| `EMaticaThemeKit/Package.swift` | *(no dependencies)* | ✅ N/A |

### Package on-disk verification

All 5 packages confirmed present at `Projects/Packages/` with their
`Package.swift` files:

```
Projects/Packages/
├── EMathicaMathCore/Package.swift          ✅
├── EMathicaDocumentKit/Package.swift       ✅
├── EMathicaThemeKit/Package.swift          ✅
├── EMathicaWorkspaceKit/Package.swift      ✅
└── EMathicaMathInputKit/Package.swift      ✅
```

### Old location

```
Projects/eMathica/Packages/                 (now empty — all packages moved out)
```

---

## Remaining Issues

### 1. Comment strings in XCSwiftPackageProductDependency (cosmetic only)

Two product-dependency entries still have stale comments referencing the old
package name format:

| Line | Current Comment | Impact |
|---|---|---|
| 846 | `XCLocalSwiftPackageReference "Packages/EMathicaMathCore"` | ❌ Cosmetic only |
| 851 | `XCLocalSwiftPackageReference "Packages/EMathicaMathCore"` | ❌ Cosmetic only |

These are **Xcode comments** inside `/* */` markers. They do **not** affect
package resolution — Xcode uses the `package` field (a UUID reference) to
look up the actual path from the XCLocalSwiftPackageReference section. The
comment is purely for human readability in the pbxproj file.

Recommended to fix them for consistency, but **not required for the build to
succeed**.

### 2. No other stale references found

A full scan of the `project.pbxproj` for any remaining `"Packages/EMathicaMathCore"`
or `relativePath = Packages/` entries found **no additional stale references**.

---

## Manual Verification Steps

After this fix, verify the build:

1. Open `Projects/eMathica/eMathica.xcodeproj` in Xcode
2. Check **File → Packages → Resolve Package Versions** (or Cmd+Shift+K for clean build)
3. Verify in Xcode's **Project Navigator → Package Dependencies** that all 5 packages resolve:
   - EMathicaMathCore
   - EMathicaDocumentKit
   - EMathicaThemeKit
   - EMathicaWorkspaceKit
   - EMathicaMathInputKit
4. Run a build (Cmd+B)
5. Run tests (Cmd+U)

If any package fails to resolve, check that `relativePath` paths are correct
relative to the xcodeproj file location (`Projects/eMathica/eMathica.xcodeproj/`).
