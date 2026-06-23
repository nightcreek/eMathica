#!/bin/bash
# ============================================================================
# Phase 4: Local Workspace Flattening — Migration Script
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
#   chmod +x Phase4_MigrationScript.sh
#   ./Phase4_MigrationScript.sh
#
# 注意:
#   - 本脚本将在执行前创建备份
#   - 执行后需要验证构建
#   - 有关回滚方式，见 Phase4_LocalWorkspaceFlatteningPlan.md
#
# ============================================================================

set -euo pipefail

# ---- 0. 配置 ----
HUB_DIR="/Users/night_creek/开发/eMathica Hub"
PARENT_DIR="/Users/night_creek/开发"
BACKUP_DIR="/tmp/emathica-phase4-backup-$(date +%Y%m%d_%H%M%S)"
LOG_FILE="/tmp/emathica-phase4-migration.log"

echo "=========================================="
echo " Phase 4: Workspace Flattening Migration"
echo "=========================================="
echo ""
echo "Hub directory:     $HUB_DIR"
echo "Parent directory:  $PARENT_DIR"
echo "Backup directory:  $BACKUP_DIR"
echo "Log file:         $LOG_FILE"
echo ""

# ---- 1. 预检查 ----
echo "=== Step 0: Pre-flight checks ==="

# Check Hub directory exists
if [ ! -d "$HUB_DIR" ]; then
    echo "❌ Hub directory not found: $HUB_DIR"
    exit 1
fi
echo "✅ Hub directory exists"

# Check required subdirectories exist
for sub in "Projects/eMathica" "Projects/OpenMathInkCollector" "Projects/Packages"; do
    if [ ! -d "$HUB_DIR/$sub" ]; then
        echo "❌ Required subdirectory not found: $HUB_DIR/$sub"
        exit 1
    fi
    echo "✅ Required subdirectory exists: $sub"
done

# Check target directories don't already exist
for target in "$PARENT_DIR/eMathica" "$PARENT_DIR/OpenMathInkCollector" "$PARENT_DIR/SharedLibraries" "$PARENT_DIR/OpenMathInkDataset"; do
    if [ -e "$target" ]; then
        echo "❌ Target already exists: $target"
        exit 1
    fi
done
echo "✅ No target directory conflicts"

echo ""

# ---- 2. 备份 ----
echo "=== Step 1: Creating backup ==="
mkdir -p "$BACKUP_DIR"
cp -R "$HUB_DIR/Projects/eMathica" "$BACKUP_DIR/eMathica"
cp -R "$HUB_DIR/Projects/OpenMathInkCollector" "$BACKUP_DIR/OpenMathInkCollector"
cp -R "$HUB_DIR/Projects/Packages" "$BACKUP_DIR/Packages"
echo "✅ Backup created at $BACKUP_DIR"
echo ""

# ---- 3. 移动 Core ----
echo "=== Step 2: Moving Core ==="
echo "  $HUB_DIR/Projects/eMathica → $PARENT_DIR/eMathica"
mv "$HUB_DIR/Projects/eMathica" "$PARENT_DIR/eMathica"
echo "✅ Core moved"
echo ""

# ---- 4. 移动 Collector ----
echo "=== Step 3: Moving OpenMathInkCollector ==="
echo "  $HUB_DIR/Projects/OpenMathInkCollector → $PARENT_DIR/OpenMathInkCollector"
mv "$HUB_DIR/Projects/OpenMathInkCollector" "$PARENT_DIR/OpenMathInkCollector"
echo "✅ Collector moved"
echo ""

# ---- 5. 移动 SharedLibraries ----
echo "=== Step 4: Moving Shared Libraries ==="
echo "  $HUB_DIR/Projects/Packages → $PARENT_DIR/SharedLibraries"
mv "$HUB_DIR/Projects/Packages" "$PARENT_DIR/SharedLibraries"
echo "✅ SharedLibraries moved"
echo ""

# ---- 6. 创建 OpenMathInkDataset ----
echo "=== Step 5: Creating OpenMathInkDataset placeholder ==="
mkdir -p "$PARENT_DIR/OpenMathInkDataset"
cat > "$PARENT_DIR/OpenMathInkDataset/README.md" << 'README_EOF'
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

# ---- 7. 重命名 Hub 目录 ----
echo "=== Step 6: Renaming Hub directory ==="
echo "  $HUB_DIR → $PARENT_DIR/eMathica-Hub"
mv "$HUB_DIR" "$PARENT_DIR/eMathica-Hub"
echo "✅ Hub renamed"
echo ""

# ---- 8. 清理 Hub 中的空 Projects 目录 ----
echo "=== Step 7: Cleaning up empty Hub subdirectories ==="
# Projects/ should already be empty after moving all three subdirectories
if [ -d "$PARENT_DIR/eMathica-Hub/Projects" ]; then
    rmdir "$PARENT_DIR/eMathica-Hub/Projects" 2>/dev/null && echo "✅ Projects/ removed" || echo "ℹ️ Projects/ not empty (check manually)"
fi
echo ""

# ---- 9. 创建 .gitignore 文件（各仓库） ----
echo "=== Step 8: Creating .gitignore files ==="

# Hub .gitignore
cat > "$PARENT_DIR/eMathica-Hub/.gitignore" << 'GITIGNORE_EOF'
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
cat > "$PARENT_DIR/eMathica/.gitignore" << 'GITIGNORE_EOF'
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

# Collector .gitignore (already has one — check if update needed)
if [ -f "$PARENT_DIR/OpenMathInkCollector/OpenMathInkCollector/.gitignore" ]; then
    echo "✅ OpenMathInkCollector already has .gitignore (check if reasonix exclusion needed)"
fi

# SharedLibraries .gitignore
cat > "$PARENT_DIR/SharedLibraries/.gitignore" << 'GITIGNORE_EOF'
# SwiftPM
.build/
.swiftpm/

# macOS
.DS_Store
__MACOSX/
GITIGNORE_EOF
echo "✅ SharedLibraries/.gitignore created"

# Dataset .gitignore
cat > "$PARENT_DIR/OpenMathInkDataset/.gitignore" << 'GITIGNORE_EOF'
# macOS
.DS_Store
__MACOSX/
GITIGNORE_EOF
echo "✅ OpenMathInkDataset/.gitignore created"
echo ""

# ---- 10. 更新 Xcode 包引用路径 ----
echo "=== Step 9: Updating Xcode project package paths ==="

# Core: ../Packages/ → ../SharedLibraries/
CORE_PBXPROJ="$PARENT_DIR/eMathica/eMathica.xcodeproj/project.pbxproj"
if [ -f "$CORE_PBXPROJ" ]; then
    sed -i '' 's|../Packages/EMathicaMathCore|../SharedLibraries/EMathicaMathCore|g' "$CORE_PBXPROJ"
    sed -i '' 's|../Packages/EMathicaDocumentKit|../SharedLibraries/EMathicaDocumentKit|g' "$CORE_PBXPROJ"
    sed -i '' 's|../Packages/EMathicaThemeKit|../SharedLibraries/EMathicaThemeKit|g' "$CORE_PBXPROJ"
    sed -i '' 's|../Packages/EMathicaWorkspaceKit|../SharedLibraries/EMathicaWorkspaceKit|g' "$CORE_PBXPROJ"
    sed -i '' 's|../Packages/EMathicaMathInputKit|../SharedLibraries/EMathicaMathInputKit|g' "$CORE_PBXPROJ"
    echo "✅ Core xcodeproj: 5 package paths updated"
fi

# Collector: ../../Packages/ → ../SharedLibraries/
COL_PBXPROJ="$PARENT_DIR/OpenMathInkCollector/OpenMathInkCollector/OpenMathInkCollector.xcodeproj/project.pbxproj"
if [ -f "$COL_PBXPROJ" ]; then
    sed -i '' 's|../../Packages/EMathicaMathInputKit|../SharedLibraries/EMathicaMathInputKit|g' "$COL_PBXPROJ"
    echo "✅ Collector xcodeproj: 1 package path updated"
fi
echo ""

# ---- 11. 更新 Hub README ----
echo "=== Step 10: Updating Hub CurrentReality/README.md ==="
# This is best done manually since the README content may have structure changes
echo "ℹ️  Note: Update CurrentReality/README.md source paths manually:"
echo "     Projects/eMathica/ → ../eMathica/"
echo "     Projects/OpenMathInkCollector/ → ../OpenMathInkCollector/"
echo "     Projects/Packages/ → ../SharedLibraries/"
echo ""

# ---- 12. 验证 ----
echo "=== Step 11: Verification ==="
echo ""
echo "Expected structure:"
echo "  /Users/night_creek/开发/"
echo "    ├── eMathica-Hub/     (directory)"
echo "    ├── eMathica/         (directory)"
echo "    ├── OpenMathInkCollector/ (directory)"
echo "    ├── SharedLibraries/  (directory)"
echo "    └── OpenMathInkDataset/ (directory)"
echo ""

# Verify each directory
for dir in "eMathica-Hub" "eMathica" "OpenMathInkCollector" "SharedLibraries" "OpenMathInkDataset"; do
    if [ -d "$PARENT_DIR/$dir" ]; then
        echo "  ✅ $dir/ exists"
    else
        echo "  ❌ $dir/ MISSING"
    fi
done

echo ""
echo "=========================================="
echo " Migration complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Open Xcode and verify Core builds"
echo "  2. Open Xcode and verify Collector builds"
echo "  3. Verify SharedLibraries packages resolve"
echo "  4. Update Hub CurrentReality/README.md paths"
echo "  5. Run Core tests"
echo "  6. Review and commit each repo"
echo ""
echo "Backup available at: $BACKUP_DIR"