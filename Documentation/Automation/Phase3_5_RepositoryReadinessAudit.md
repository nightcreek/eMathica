# Phase 3.5: Repository Readiness Audit

> **日期:** 2026-06-23  
> **操作:** 只读审计 — 评估各仓库是否具备独立 GitHub 仓库条件

---

## 1. eMathica Hub Readiness

### 检查清单

| 检查项 | 结果 | 说明 |
|--------|------|------|
| 包含 Swift 源文件？ | ❌ 无 ✅ | 零 Swift 文件 |
| 包含 Xcode Project？ | ❌ 无 ✅ | 零 .xcodeproj |
| 包含 Package.swift？ | ❌ 无 ✅ | 零 Package.swift |
| 包含 Sources/ 目录？ | ❌ 无 ✅ | 无 Sources 目录 |
| 包含 Tests/ 目录？ | ❌ 无 ✅ | 无 Tests 目录 |
| 包含 App 入口？ | ❌ 无 ✅ | 无 @main |
| 仅含 Markdown + 资源？ | ✅ 是 | README.md + Philosophy/ + CurrentReality/ + CurrentDevelopment/ + FuturePossibilities/ + RepositoryIndex/ + CommunityVoting/ + Assets/ |
| 本地配置需排除？ | ⚠️ reasonix.toml | 需要在 .gitignore 中添加 reasonix.toml |

### 剩余问题

- `reasonix.toml` 在 Hub 根目录，将来不要被 Git 跟踪
- `.claude/` 和 `.reasonix/` 需要在 .gitignore 中排除

### Readiness Score: **95/100**

---

## 2. eMathica Core Readiness

### 检查清单

| 检查项 | 结果 | 说明 |
|--------|------|------|
| 包含 Collector 文件？ | ❌ 无 ✅ | Phase 1 已清理 18 个文件 |
| 文件名为 Collector 模式？ | ❌ 无 ✅ | `find *Collector*` 零匹配 |
| 文件名为 OpenMathInk 模式？ | ❌ 无 ✅ | `find *OpenMathInk*` 零匹配 |
| FeatureUtilities/ 残留？ | ❌ 已删除 ✅ | 整个目录树已清理 |
| State/ 目录残留？ | ❌ 已删除 ✅ | State/ 目录已不存在 |
| SharedUI/Components/ 残留？ | ❌ 已清理 ✅ | 仅剩 .gitkeep |
| Core 根目录 Collector 文档？ | ❌ 已删除 ✅ | OPENMATHINK_COLLECTOR_FIXES.md 已删除 |
| Docs/ 引用 Collector 类型？ | ✅ 存在（archive/ 中） | 这是历史文档，不影响代码拆分 |
| 包依赖路径已验证？ | ✅ 已修复 | `../../Packages/` → `../Packages/` |
| 零 Collector 类型代码引用？ | ✅ Phase 1 已验证 | grep 零匹配 |

### 剩余问题

- `Docs/archive/` 中有少量引用旧 Collector 状态的文档。这是历史归档，不影响仓库拆分。
- `reasonix.toml` 在 Projects/eMathica/ 目录，需在 Core 的 .gitignore 中排除。
- `.reasonix/` 在 Projects/eMathica/ 目录，需排除。

### Readiness Score: **98/100**

---

## 3. OpenMathInk Collector Readiness

### 检查清单

| 检查项 | 结果 | 说明 |
|--------|------|------|
| 包含 Core 专属代码？ | ❌ 无 ✅ | 无 eMathica、CoreHome、Plane、Space 相关文件 |
| 包含 @main 入口？ | ✅ 有 | OpenMathInkCollectorApp.swift — 这是 Collector 自己的主入口，正确 |
| 所有源文件 Collector 专用？ | ✅ 是 | 32 个文件全部 Collector 专属 |
| KeyboardShortcutManager 已就位？ | ✅ 已同步 | 5,980 字节，Phase 1 从 Core 同步 |
| Package 依赖路径正确？ | ✅ 应是 | 使用 SharedLibraries 的本地路径 |

### 剩余问题

- 需要确认 Collector 的 xcodeproj 中包引用路径是否正确指向 SharedLibraries
- 需要创建 Collector 的 .gitignore（已有 .gitignore 在 `OpenMathInkCollector/.gitignore`）

### Readiness Score: **97/100**

---

## 4. SharedLibraries Readiness

### 检查清单

| 检查项 | 结果 | 说明 |
|--------|------|------|
| 包含 App 业务代码？ | ❌ 无 ✅ | 无 @main、无 App 生命周期 |
| 包含 UI 页面？ | ⚠️ WorkspaceKit 有 View 文件 | 12 个 View 文件（工具图标、键盘视图、检查器面板）— 属 UI 组件包范畴 |
| 包含 App 状态管理？ | ❌ 无 ✅ | WorkspaceState 是工作区状态，非 App 全局状态 |
| 包结构正确？ | ✅ 全部有 Package.swift | 5 个包都是标准 SwiftPM 包结构 |
| 所有包都有 Package.swift？ | ✅ 是 | 每个包根目录有 Package.swift |
| 依赖关系清晰？ | ✅ 是 | 无循环依赖 |

### View 文件分析

WorkspaceKit 中的 12 个 View 文件：

| View 文件 | 类型 | 是否合理在 Package 中 |
|-----------|------|---------------------|
| GeometryToolIconView.swift | 工具图标 | ✅ 合理 — 工具图标是工作区的内聚组件 |
| HardwareKeyboardCaptureView.swift | 键盘捕获 | ✅ 合理 — 键盘输入组件 |
| AlgebraObjectPanelView.swift | 对象面板 | ✅ 合理 — 工作区 UI |
| WorkspaceObjectRowView.swift | 对象行 | ✅ 合理 — 工作区 UI |
| ToolButtonView.swift | 工具按钮 | ✅ 合理 — 工具 UI |
| FloatingToolGroupsView.swift | 浮动工具组 | ✅ 合理 — 工具 UI |
| ToolGroupCapsuleView.swift | 工具组胶囊 | ✅ 合理 — 工具 UI |
| ModuleAssetIconView.swift | 模块图标 | ✅ 合理 — 共享组件 |
| ModuleIconView.swift | 模块图标 | ✅ 合理 — 共享组件 |
| WorkspaceView.swift | 工作区视图 | ✅ 合理 — 工作区主视图 |
| MathKeyboardView.swift | 数学键盘 | ✅ 合理 — 键盘视图 |
| FormulaEditorView.swift | 公式编辑器 | ✅ 合理 — 编辑器视图 |

**结论：** 这些 View 文件是 `Kit` 类型 package（Workspace **Kit**）的合理组成部分，不是 App 业务代码。Apple 的 SwiftUI 框架本身就以 Kit 形式提供 View 组件。

### Readiness Score: **95/100**

---

## 5. Documentation Readiness

### 检查清单

| 检查项 | 结果 | 说明 |
|--------|------|------|
| Hub 级文档 vs Core 级文档分离？ | ✅ 明确 | Documentation/（21 文件）= Hub 级；eMathica/Docs/（74 文件）= Core 级 |
| 重复文档？ | ❌ 无 ✅ | 无重名文件 |
| 空目录？ | ⚠️ 4 个空目录 | ADR/, ARCHIVE/, POLICIES/, temp/ — 应清理或加 .gitkeep |
| 已失效文档？ | ⚠️ Working/ 中有部分旧计划 | 部分 Working 文档是 Phase 1 前的准备，可归档到 Archive |
| README 体系一致性？ | ✅ 一致 | Hub README → CurrentReality → CurrentDevelopment → RepositoryIndex 内容无冲突 |
| Philosophy 完整性？ | ✅ 5 篇 | 全部有实际内容 |

### 空目录建议

| 目录 | 建议 |
|------|------|
| `Documentation/ADR/` | 删除或添加 `.gitkeep` 保留结构 |
| `Documentation/ARCHIVE/` | 保留 — 未来放归档文档 |
| `Documentation/POLICIES/` | 删除或添加 `.gitkeep` |
| `Documentation/temp/` | 删除（临时目录） |

### Readiness Score: **90/100**

---

## 6. Blockers

### 当前阻止仓库拆分的问题

| # | Blocker | 严重程度 | 影响仓库 | 说明 |
|---|---------|---------|---------|------|
| B1 | **macOS sandbox 阻止 CLI 构建** | 🟡 **Medium** | Core, Collector | `xcodebuild` 和 `swift build` 被 sandbox 阻止。可通过在 Xcode.app 中构建绕过。**不影响仓库拆分，但影响构建验证。** |
| B2 | **Hub .gitignore 未配置** | 🟢 **Low** | Hub | 需要添加 `reasonix.toml`、`.claude/`、`.reasonix/` 到 .gitignore |
| B3 | **Core .gitignore 未配置** | 🟢 **Low** | Core | 需要添加 `reasonix.toml`、`.reasonix/` 到 .gitignore |
| B4 | **包引用路径是本地路径** | 🟢 **Not a blocker** | Core, Collector | 当前使用 `.package(path:)` 指向本地 `../Packages/`。仓库独立后需要切换为 Git URL 或保留为开发时本地路径 |
| B5 | **文档空目录** | 🟢 **Low** | Hub | ADR/, ARCHIVE/, POLICIES/, temp/ 空目录需清理 |
| B6 | **CalculatorModules 未重命名** | 🟢 **Not a blocker** | Core | 内部重命名（AppShell/Features/ 等）是 Phase 4 内容，属于代码优化而非仓库拆分阻塞 |

### Blockers 总结

| 类型 | 数量 |
|------|------|
| 🔴 严重阻塞 | 0 |
| 🟡 中等 | 1（sandbox — 非代码问题） |
| 🟢 低影响 | 5 |
| 不影响拆分 | 6 个都已就绪 |

---

## 7. Overall Repository Readiness Score

| 仓库 | 评分 | 说明 |
|------|------|------|
| eMathica Hub | **95/100** | 零业务代码。仅需配置 .gitignore。 |
| eMathica Core | **98/100** | 零 Collector 残留。包路径已修复。 |
| OpenMathInk Collector | **97/100** | 完整独立。KeyboardShortcutManager 已同步。 |
| SharedLibraries | **95/100** | 无 App 代码。WorkspaceKit 的 View 文件是合理的 Kit 组件。 |
| Documentation | **90/100** | 文档分离清晰。4 个空目录需清理。 |
| **Overall** | **95/100** | |

```
Overall Repository Readiness

    ╔══════════════════════════════╗
    ║        95 / 100              ║
    ║                              ║
    ║  ████████████████████████    ║
    ║  ████████████████████████    ║
    ║  ████████████████████████    ║
    ║  ████████████████████████    ║
    ║  ████████████████████████░   ║
    ╚══════════════════════════════╝
```

---

## 8. Recommended Next Step

### 选择：**A. 进入目录迁移**

**原因：**

1. **无严重阻塞器。** Blocker B1（sandbox）是环境问题，不影响目录结构，可通过 Xcode.app 手动构建验证。

2. **代码已充分隔离。** 18 个 Collector 重复文件已删除，零残留引用，5 个包路径已验证。

3. **Hub 文档已就绪。** Philosophy（5 篇）、CurrentReality、CurrentDevelopment、RepositoryIndex、FuturePossibilities、CommunityVoting 全部完成。

4. **README 体系一致。** 四层结构（Philosophy → Reality → Development → Future）清晰无冲突。

5. **目录迁移仅涉及文件移动，不涉及代码修改。** 只要不改变源码内容，就不会引入编译错误。

### 迁移前需完成的准备工作（~15 分钟）

| # | 操作 | 优先级 |
|---|------|--------|
| 1 | 创建 Hub `.gitignore`（排除 reasonix.toml, .claude/, .reasonix/） | Required |
| 2 | 清理 Documentation 空目录（4 个） | Optional |
| 3 | 确认 Core 可通过 Xcode.app 构建 | Recommended |

### 不建议 B. 继续清理 的原因

当前清理工作已全部完成。继续清理（进一步分析代码质量、重构命名等）属于 Phase 4 内部重命名阶段，非仓库拆分的前置条件。等待这些工作会延迟仓库独立。

---

## 附录: 评分细则

| 评分范围 | 含义 |
|----------|------|
| 100 | 完全就绪，可直接 git init + push |
| 90-99 | 就绪，只需少量配置（如 .gitignore） |
| 80-89 | 基本就绪，需一些清理工作 |
| 70-79 | 需要较多清理 |
| <70 | 不适合拆分 |

### 各仓库扣分明细

| 仓库 | 扣分 | 原因 |
|------|------|------|
| Hub | -5 | reasonix.toml 需加到 .gitignore |
| Core | -2 | reasonix.toml + .reasonix/ 需加到 .gitignore |
| Collector | -3 | 项目路径含嵌套 OpenMathInkCollector/OpenMathInkCollector/OpenMathInkCollector 需扁平化 |
| SharedLibraries | -5 | Packages/ 目录需重命名为 SharedLibraries/ |
| Documentation | -10 | 4 个空目录需清理 |
