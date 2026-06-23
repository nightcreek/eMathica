#!/bin/bash
# ============================================================================
# Phase 4: Local Workspace Flattening — Migration Script (v2)
# ============================================================================
#
# 用途: 将 eMathica 生态系统从嵌套结构迁移为扁平结构
#
# 迁移前结构:
#   开发/eMathica Hub/
#     ├── Projects/eMathica/          (Core)
#     ├── Projects/OpenMathInkCollector/ (Collector)
#     ├── Projects/Packages/          (SharedLibraries)
#     └── (Hub content)
#
# 迁移后结构:
#   开发/
#     ├── eMathica-Hub/               (Hub)
#     ├── eMathica/                   (Core)
#     ├── OpenMathInkCollector/       (Collector)
#     ├── SharedLibraries/            (Shared Libraries)
#     └── OpenMathInkDataset/         (Dataset placeholder)
#
# 使用方式:
#   chmod +x Phase4_MigrationScript_v2.sh
#   ./Phase4_MigrationScript_v2.sh
#
# Version: 2 (fixes C1/C2/C3 from review)
#
# ============================================================================

set -euo pipefail

# ---- 0. 配置 ----
HUB_DIR="/Users/night_creek/开发/eMathica Hub"
PARENT_DIR="/Users/night_creek/开发"
BACKUP_DIR="/tmp/emathica-phase4-backup-$(date +%Y%m%d_%H%M%S)"

# Target directories (used for re-run protection)
TARGET_CORE="$PARENT_DIR/eMathica"
TARGET_COLLECTOR="$PARENT_DIR/OpenMathInkCollector"
TARGET_SHARED="$PARENT_DIR/SharedLibraries"
TARGET_DATASET="$PARENT_DIR/OpenMathInkDataset"
TARGET_HUB="$PARENT_DIR/eMathica-Hub"

echo "=========================================="
echo " Phase 4: Workspace Flattening Migration"
echo "            Script v2"
echo "=========================================="
echo ""
echo "Hub directory:     $HUB_DIR"
echo "Parent directory:  $PARENT_DIR"
echo "Backup directory:  $BACKUP_DIR"
echo ""

# ---- 1. 预检查 ----
echo "=== [Step 0] Pre-flight checks ==="

# 1a. Hub directory exists
if [ ! -d "$HUB_DIR" ]; then
    echo "❌ Hub directory not found: $HUB_DIR"
    exit 1
fi
echo "✅ Hub directory exists: $HUB_DIR"

# 1b. Required subdirectories exist
for sub in "Projects/eMathica" "Projects/OpenMathInkCollector" "Projects/Packages"; do
    if [ ! -d "$HUB_DIR/$sub" ]; then
        echo "❌ Required subdirectory not found: $HUB_DIR/$sub"
        exit 1
    fi
    echo "✅ Subdirectory exists: $sub"
done

# 1c. Re-run protection: check target directories don't already exist
echo ""
echo "--- Checking for existing target directories ---"
any_conflict=0
for target in "$TARGET_CORE" "$TARGET_COLLECTOR" "$TARGET_SHARED" "$TARGET_DATASET" "$TARGET_HUB"; do
    if [ -e "$target" ]; then
        echo "❌ Target already exists: $target"
        any_conflict=1
    else
        echo "✅ Target path free: $(basename "$target")"
    fi
done

# 1d. Also check reverse: source directories might have been moved already
if [ ! -d "$HUB_DIR/Projects/eMathica" ] || [ ! -d "$HUB_DIR/Projects/OpenMathInkCollector" ]; then
    echo "❌ One or more source directories already missing — migration may be partial"
    echo "   Run rollback before retrying. See Phase4_LocalWorkspaceFlatteningPlan.md"
    exit 1
fi

if [ "$any_conflict" -ne 0 ]; then
    echo ""
    echo "❌ One or more target directories already exist."
    echo "   This may indicate a previous partial migration."
    echo "   Run rollback before retrying."
    exit 1
fi
echo "✅ No target directory conflicts — clean state confirmed"

# ---- 2. 确认提示 ----
echo ""
echo "============================================"
echo "⚠️  This script will MOVE and RENAME directories:"
echo ""
echo "  1. $HUB_DIR/Projects/eMathica"
echo "     → $TARGET_CORE"
echo ""
echo "  2. $HUB_DIR/Projects/OpenMathInkCollector"
echo "     → $TARGET_COLLECTOR"
echo ""
echo "  3. $HUB_DIR/Projects/Packages"
echo "     → $TARGET_SHARED"
echo ""
echo "  4. $HUB_DIR"
echo "     → $TARGET_HUB"
echo ""
echo "  5. Create $TARGET_DATASET (placeholder)"
echo ""
echo "  After migration, the original Hub directory will no longer exist."
echo "  A full backup will be created at: $BACKUP_DIR"
echo "============================================"
echo ""
echo "Type 'yes' to continue:"
read -r CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi
echo ""

# ---- 3. 备份 ----
echo "=== [Step 1] Creating full backup ==="
mkdir -p "$BACKUP_DIR"

# Backup the three sub-projects
echo "  Backing up Core..."
cp -R "$HUB_DIR/Projects/eMathica" "$BACKUP_DIR/eMathica"
echo "  Backing up Collector..."
cp -R "$HUB_DIR/Projects/OpenMathInkCollector" "$BACKUP_DIR/OpenMathInkCollector"
echo "  Backing up SharedLibraries..."
cp -R "$HUB_DIR/Projects/Packages" "$BACKUP_DIR/Packages"

# Backup entire Hub content (fixes C1)
echo "  Backing up Hub content (Philosophy, Documentation, Assets, Data, etc.)..."
cp -R "$HUB_DIR" "$BACKUP_DIR/eMathica-Hub"

# Verify backup
BACKUP_SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
echo "✅ Full backup created at: $BACKUP_DIR"
echo "   Backup size: $BACKUP_SIZE"
echo ""

# ---- 4. 移动 Core ----
echo "=== [Step 2] Moving Core ==="
echo "  $HUB_DIR/Projects/eMathica → $TARGET_CORE"
mv "$HUB_DIR/Projects/eMathica" "$TARGET_CORE"
echo "✅ Core moved"
echo ""

# ---- 5. 移动 Collector ----
echo "=== [Step 3] Moving OpenMathInkCollector ==="
echo "  $HUB_DIR/Projects/OpenMathInkCollector → $TARGET_COLLECTOR"
mv "$HUB_DIR/Projects/OpenMathInkCollector" "$TARGET_COLLECTOR"
echo "✅ Collector moved"
echo ""

# ---- 6. 移动 SharedLibraries ----
echo "=== [Step 4] Moving Shared Libraries ==="
echo "  $HUB_DIR/Projects/Packages → $TARGET_SHARED"
mv "$HUB_DIR/Projects/Packages" "$TARGET_SHARED"
echo "✅ SharedLibraries moved"
echo ""

# ---- 7. 创建 OpenMathInkDataset ----
echo "=== [Step 5] Creating OpenMathInkDataset placeholder ==="
mkdir -p "$TARGET_DATASET"
cat > "$TARGET_DATASET/README.md" << 'README_EOF'
# OpenMathInk Dataset

> 开源数学手写数据集（规划中）

## Status

📋 **Planning** — 数据集尚未开始采集。

## Future Plans

- 基于 OpenMathInk Collector 采集的手写数据
- 标准化格式
- 学术研究用途

## License

TBD
README_EOF
echo "✅ OpenMathInkDataset placeholder created"
echo ""

# ---- 8. 重命名 Hub 目录 ----
echo "=== [Step 6] Renaming Hub directory ==="
echo "  $HUB_DIR → $TARGET_HUB"
mv "$HUB_DIR" "$TARGET_HUB"
echo "✅ Hub renamed to eMathica-Hub"
echo ""

# ---- 9. 清理 Hub 中的空 Projects 目录 ----
echo "=== [Step 7] Cleaning up empty Projects/ directory ==="
if [ -d "$TARGET_HUB/Projects" ]; then
    rmdir "$TARGET_HUB/Projects" 2>/dev/null && echo "✅ Projects/ removed (was empty)" \
        || echo "ℹ️  Projects/ not empty (check manually)"
fi
echo ""

# ---- 10. 创建 .gitignore 文件 ----
echo "=== [Step 8] Creating .gitignore files ==="

# Hub .gitignore
cat > "$TARGET_HUB/.gitignore" << 'GITIGNORE_EOF'
# macOS
.DS_Store
__MACOSX/

# Agent / IDE
.claude/
.reasonix/
reasonix.toml

# Derived data
DerivedData/
GITIGNORE_EOF
echo "✅ eMathica-Hub/.gitignore created"

# Core .gitignore
cat > "$TARGET_CORE/.gitignore" << 'GITIGNORE_EOF'
# SwiftPM
.build/
.swiftpm/
Packages/*/.build/
Packages/*/.swiftpm/

# Xcode user data
*.xcuserstate
*.xcuserdata/
**/xcuserdata/
**/UserInterfaceState.xcuserstate

# macOS
.DS_Store
__MACOSX/

# DerivedData
DerivedData/

# Agent / IDE
.reasonix/
reasonix.toml
GITIGNORE_EOF
echo "✅ eMathica/.gitignore created"

# Collector .gitignore — created at TOP level (fixes C3)
cat > "$TARGET_COLLECTOR/.gitignore" << 'GITIGNORE_EOF'
# Xcode
build/
DerivedData/
*.xcuserstate
*.xcuserdata/
**/xcuserdata/

# SwiftPM
.build/
.swiftpm/

# macOS
.DS_Store
__MACOSX/

# Agent / IDE
.claude/
.reasonix/
reasonix.toml
GITIGNORE_EOF
echo "✅ OpenMathInkCollector/.gitignore created at root level"

# SharedLibraries .gitignore
cat > "$TARGET_SHARED/.gitignore" << 'GITIGNORE_EOF'
# SwiftPM
.build/
.swiftpm/

# macOS
.DS_Store
__MACOSX/
GITIGNORE_EOF
echo "✅ SharedLibraries/.gitignore created"

# Dataset .gitignore
cat > "$TARGET_DATASET/.gitignore" << 'GITIGNORE_EOF'
# macOS
.DS_Store
__MACOSX/
GITIGNORE_EOF
echo "✅ OpenMathInkDataset/.gitignore created"
echo ""

# ---- 11. 更新 Xcode 包引用路径 ----
echo "=== [Step 9] Updating Xcode project package paths ==="

# Core: ../Packages/ → ../SharedLibraries/
CORE_PBXPROJ="$TARGET_CORE/eMathica.xcodeproj/project.pbxproj"
if [ -f "$CORE_PBXPROJ" ]; then
    sed -i '' 's|../Packages/EMathicaMathCore|../SharedLibraries/EMathicaMathCore|g' "$CORE_PBXPROJ"
    sed -i '' 's|../Packages/EMathicaDocumentKit|../SharedLibraries/EMathicaDocumentKit|g' "$CORE_PBXPROJ"
    sed -i '' 's|../Packages/EMathicaThemeKit|../SharedLibraries/EMathicaThemeKit|g' "$CORE_PBXPROJ"
    sed -i '' 's|../Packages/EMathicaWorkspaceKit|../SharedLibraries/EMathicaWorkspaceKit|g' "$CORE_PBXPROJ"
    sed -i '' 's|../Packages/EMathicaMathInputKit|../SharedLibraries/EMathicaMathInputKit|g' "$CORE_PBXPROJ"
    echo "✅ Core xcodeproj: 5 package paths updated (../Packages/ → ../SharedLibraries/)"
fi

# Collector: ../../Packages/ → ../SharedLibraries/
COL_PBXPROJ="$TARGET_COLLECTOR/OpenMathInkCollector/OpenMathInkCollector.xcodeproj/project.pbxproj"
if [ -f "$COL_PBXPROJ" ]; then
    sed -i '' 's|../../Packages/EMathicaMathInputKit|../SharedLibraries/EMathicaMathInputKit|g' "$COL_PBXPROJ"
    echo "✅ Collector xcodeproj: 1 package path updated (../../Packages/ → ../SharedLibraries/)"
fi
echo ""

# ---- 12. 更新 Hub README -----
echo "=== [Step 10] Updating Hub CurrentReality/README.md ==="
echo "ℹ️  Note: Update CurrentReality/README.md source paths manually:"
echo "     Projects/eMathica/          → ../eMathica/"
echo "     Projects/OpenMathInkCollector/ → ../OpenMathInkCollector/"
echo "     Projects/Packages/          → ../SharedLibraries/"
echo ""

# ---- 13. 验证 ----
echo "=== [Step 11] Verification ==="
echo ""
echo "Expected structure under $PARENT_DIR:"
echo "  ├── eMathica-Hub/"
echo "  ├── eMathica/"
echo "  ├── OpenMathInkCollector/"
echo "  ├── SharedLibraries/"
echo "  └── OpenMathInkDataset/"
echo ""

all_ok=0

# Check target directories exist
for dir in "eMathica-Hub" "eMathica" "OpenMathInkCollector" "SharedLibraries" "OpenMathInkDataset"; do
    if [ -d "$PARENT_DIR/$dir" ]; then
        echo "  ✅ $dir/ exists"
    else
        echo "  ❌ $dir/ MISSING"
        all_ok=1
    fi
done

# Check source directory no longer exists
echo ""
echo "--- Source directory cleanup check ---"
if [ -d "$HUB_DIR" ]; then
    echo "  ❌ Original Hub directory STILL EXISTS: $HUB_DIR"
    all_ok=1
else
    echo "  ✅ Original Hub directory successfully removed"
fi

if [ -d "$HUB_DIR/Projects" ]; then
    echo "  ❌ Projects/ directory STILL EXISTS"
    all_ok=1
else
    echo "  ✅ Projects/ directory no longer exists"
fi

echo ""
if [ "$all_ok" -eq 0 ]; then
    echo "✅ All checks passed."
else
    echo "⚠️  Some checks failed — review output above."
fi

echo ""
echo "=========================================="
echo " Migration complete!"
echo "=========================================="
echo ""
echo "Backup available at: $BACKUP_DIR"
echo ""
echo "Next steps:"
echo "  1. Open Xcode and verify Core builds"
echo "  2. Open Xcode and verify Collector builds"
echo "  3. Verify SharedLibraries packages resolve"
echo "  4. Update Hub CurrentReality/README.md paths"
echo "  5. Run Core tests"
echo "  6. Review and commit each repo"
echo ""
echo "Rollback: see Phase4_LocalWorkspaceFlatteningPlan.md → Section 4"