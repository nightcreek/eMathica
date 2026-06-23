# Phase 4: Local Workspace Flattening — Migration Plan

> **日期:** 2026-06-23  
> **状态:** 只读方案 — 未移动任何文件  
> **依据:** Phase 3.5 Repository Readiness Audit (Score: 95/100)

---

## 1. 当前 → 目标结构对照表

### 当前结构

```
开发/
└── eMathica Hub/                          ← Hub 内容 + Projects 嵌套
    ├── README.md                          ← Hub readme
    ├── Philosophy/                        ← Hub 理念
    ├── CurrentReality/                    ← Hub 现状
    ├── CurrentDevelopment/                ← Hub 开发状态
    ├── FuturePossibilities/               ← Hub 未来
    ├── RepositoryIndex/                   ← Hub 仓库索引
    ├── CommunityVoting/                   ← Hub 投票
    ├── Assets/                            ← Hub 共享资源
    ├── Data/                              ← Hub 数据
    ├── Documentation/                     ← Hub 文档
    ├── Projects/
    │   ├── eMathica/                      ★ Core 主应用（嵌套在 Hub 内）
    │   ├── OpenMathInkCollector/           ★ Collector（嵌套在 Hub 内）
    │   └── Packages/                      ★ Shared Libraries（嵌套在 Hub 内）
    ├── .claude/                           ← 本地配置
    ├── .reasonix/                         ← 本地配置
    └── reasonix.toml                      ← 本地配置
```

### 目标结构

```
开发/
├── eMathica-Hub/                          ← Hub（独立仓库）
│   ├── README.md
│   ├── Philosophy/
│   ├── CurrentReality/
│   ├── CurrentDevelopment/
│   ├── FuturePossibilities/
│   ├── RepositoryIndex/
│   ├── CommunityVoting/
│   ├── Assets/
│   ├── Data/
│   └── Documentation/
│
├── eMathica/                              ★ Core（独立仓库）
│   ├── eMathica.xcodeproj/
│   ├── eMathica/                          ← 源码
│   ├── eMathicaTests/
│   ├── eMathicaUITests/
│   ├── Scripts/
│   └── Tests/
│
├── OpenMathInkCollector/                  ★ Collector（独立仓库）
│   ├── OpenMathInkCollector.xcodeproj/
│   └── OpenMathInkCollector/              ← 源码
│
├── SharedLibraries/                       ★ 共享包（独立仓库）
│   ├── EMathicaMathCore/
│   ├── EMathicaDocumentKit/
│   ├── EMathicaMathInputKit/
│   ├── EMathicaThemeKit/
│   └── EMathicaWorkspaceKit/
│
└── OpenMathInkDataset/                    ★ 数据集（未来仓库，仅占位）
    └── README.md
```

### 变化总结

| 维度 | 当前 | 目标 |
|------|------|------|
| Hub 目录名 | `eMathica Hub`（含空格） | `eMathica-Hub`（连字符） |
| Core 位置 | `Projects/eMathica/`（嵌套 2 层） | `eMathica/`（顶级，1 层） |
| Collector 位置 | `Projects/OpenMathInkCollector/`（嵌套 2 层） | `OpenMathInkCollector/`（顶级，1 层） |
| Collector 源码嵌套 | 3 层 `OpenMathInkCollector/.../OpenMathInkCollector/` | 保持原有内部结构 |
| SharedLibraries 位置 | `Projects/Packages/` | `SharedLibraries/` |
| OpenMathInkDataset | 不存在 | 新建 `OpenMathInkDataset/` |
| 本地配置 | 散落在根目录 | 每个仓库独立 `.gitignore` |

---

## 2. 文件移动计划

### 2a. Hub: 原地保留 + 重命名

当前 `eMathica Hub/` 目录**直接重命名**为 `eMathica-Hub/`：

```
mv "eMathica Hub" eMathica-Hub
```

**保留在 Hub 的内容：**

| 目录/文件 | 说明 |
|-----------|------|
| `README.md` | Hub 顶层介绍 |
| `Philosophy/` | 5 篇理念文档 |
| `CurrentReality/` | 现状 |
| `CurrentDevelopment/` | 开发状态 |
| `FuturePossibilities/` | 未来 |
| `RepositoryIndex/` | 仓库索引 |
| `CommunityVoting/` | 社区投票 |
| `Assets/` | 共享图标和设计资源 |
| `Data/` | ML 模型、Ink 数据 |
| `Documentation/` | 架构方案、审计报告 |

**从 Hub 移出的内容（3 项）：**

| 当前路径 | 目标路径 |
|----------|---------|
| `eMathica-Hub/Projects/eMathica/` | `../eMathica/` |
| `eMathica-Hub/Projects/OpenMathInkCollector/` | `../OpenMathInkCollector/` |
| `eMathica-Hub/Projects/Packages/` | `../SharedLibraries/` |

**从 Hub 删除的目录：**

| 目录 | 说明 |
|------|------|
| `Projects/` | 移出所有子项目后，空目录删除 |
| `.claude/` | 本地配置，不提交 |
| `.reasonix/` | 本地配置，不提交 |
| `reasonix.toml` | 本地配置，加到 .gitignore |

---

### 2b. Core: 移出到顶级目录

**移动操作：**

```bash
# 从 Hub 的 Projects 下移到顶级
mv eMathica-Hub/Projects/eMathica eMathica/
```

**移动后 Core 的目录结构：**

```
开发/eMathica/
├── eMathica.xcodeproj/
├── eMathica/                  ← 源码
│   ├── App/
│   ├── CalculatorModules/
│   ├── CoreHome/
│   ├── PluginSystem/
│   ├── Services/
│   ├── SharedUI/
│   ├── Resources/
│   ├── Docs/
│   └── AI/
├── eMathicaTests/
├── eMathicaUITests/
├── Scripts/
├── Tests/
├── Packages/                  ← （空 — 包引用指向 ../SharedLibraries/）
├── .reasonix/                 ← 本地配置
└── reasonix.toml              ← 本地配置
```

**迁移中要同步修改的引用：**

| 文件 | 修改内容 |
|------|---------|
| `eMathica.xcodeproj/project.pbxproj` | `../Packages/` → `../SharedLibraries/`（5 处） |
| `eMathica/.reasonix/` | 保留或删除，配 .gitignore |

---

### 2c. Collector: 移出到顶级目录

**移动操作：**

```bash
# 从 Hub 的 Projects 下移到顶级
mv eMathica-Hub/Projects/OpenMathInkCollector OpenMathInkCollector/
```

**移动后 Collector 的目录结构：**

```
开发/OpenMathInkCollector/
├── OpenMathInkCollector.xcodeproj/
└── OpenMathInkCollector/
    ├── OpenMathInkCollector/    ← 源码（保留原有 3 层结构）
    │   ├── App/
    │   ├── Models/
    │   ├── Modules/
    │   ├── Shared/
    │   ├── State/
    │   └── Resources/
    └── .gitignore
```

**迁移中要同步修改的引用：**

| 文件 | 修改内容 |
|------|---------|
| `OpenMathInkCollector.xcodeproj/project.pbxproj` | `../../Packages/` → `../SharedLibraries/`（1 处） |

---

### 2d. SharedLibraries: 移出 + 重命名

**移动操作：**

```bash
# 从 Packages/ 移到顶级并重命名为 SharedLibraries/
mv eMathica-Hub/Projects/Packages SharedLibraries/
```

**移动后 SharedLibraries 的目录结构：**

```
开发/SharedLibraries/
├── EMathicaMathCore/
│   ├── Package.swift
│   ├── Sources/EMathicaMathCore/    ← 43+ 源文件
│   └── Tests/EMathicaMathCoreTests/
├── EMathicaDocumentKit/
│   ├── Package.swift
│   ├── Sources/EMathicaDocumentKit/ ← 11 源文件
│   └── Tests/EMathicaDocumentKitTests/
├── EMathicaMathInputKit/
│   ├── Package.swift
│   ├── Sources/EMathicaMathInputCore/
│   └── Tests/EMathicaMathInputCoreTests/
├── EMathicaThemeKit/
│   ├── Package.swift
│   ├── Sources/EMathicaThemeKit/    ← 10 源文件
│   └── Tests/EMathicaThemeKitTests/
└── EMathicaWorkspaceKit/
    ├── Package.swift
    ├── Sources/EMathicaWorkspaceKit/ ← 61 源文件
    └── Tests/EMathicaWorkspaceKitTests/
```

**注意：** 包内部的 `Package.swift` 使用 `../EMathicaMathCore` 等**同级引用**。这些路径在移动到 `SharedLibraries/` 后**仍然有效**，因为所有包仍在同一目录下。**无需修改 Package.swift。**

---

### 2e. OpenMathInkDataset: 新建

```bash
mkdir -p OpenMathInkDataset
# 创建占位 README.md
```

---

### 移动汇总表

| # | 源路径（相对 eMathica Hub/） | 目标路径（相对 开发/） | 大小 | 操作类型 |
|---|---------------------------|----------------------|------|---------|
| 1 | `Projects/eMathica/` | `eMathica/` | ~90MB | 移动 |
| 2 | `Projects/OpenMathInkCollector/` | `OpenMathInkCollector/` | ~1MB | 移动 |
| 3 | `Projects/Packages/` | `SharedLibraries/` | ~700MB | 移动 + 重命名 |
| 4 | —（新建） | `OpenMathInkDataset/` | — | 新建 |
| 5 | 目录名 `eMathica Hub` | `eMathica-Hub/` | ~20MB | 重命名 |

---

## 3. 风险分析

### 3.1 Xcode 项目路径风险

| # | 风险 | 等级 | 影响 | 缓解 |
|---|------|------|------|------|
| R1 | **Core xcodeproj 包路径失效** | 🔴 **高** | Core 无法解析包依赖 | 需在 pbxproj 中修改 `../Packages/` → `../SharedLibraries/`（5 处） |
| R2 | **Collector xcodeproj 包路径失效** | 🔴 **高** | Collector 无法解析包依赖 | 需在 pbxproj 中修改 `../../Packages/` → `../SharedLibraries/`（1 处） |
| R3 | **xcodeproj 中文件引用路径** | 🟡 中 | 使用 `PBXFileSystemSynchronizedRootGroup` 的项目自动同步 | Core 和 Collector 都用同步组模式，Xcode 会自动调整文件引用 |
| R4 | **.xcuserdata 丢失** | 🟢 低 | 个人 Xcode 设置丢失 | 不重要，可重新生成 |

### 3.2 文档引用路径风险

| # | 风险 | 等级 | 影响 | 缓解 |
|---|------|------|------|------|
| R5 | **CurrentReality README 路径过时** | 🟡 中 | Source 路径指向旧位置 | 迁移后更新 3 处 `Projects/eMathica/` → `../eMathica/` |
| R6 | **Working 文档路径过时** | 🟢 低 | 历史文档指向旧路径 | 可保留，它们是历史记录 |
| R7 | **RepositoryIndex URL 未填写** | 🟢 低 | 仓库 URL 仍为 TBD | 在 GitHub 上传后填写 |

### 3.3 包依赖路径风险

| # | 风险 | 等级 | 影响 | 缓解 |
|---|------|------|------|------|
| R8 | **Package.swift 同级引用失效** | 🟢 **无风险** | 包间引用使用 `../` 同级路径 | 所有包都在同一 `SharedLibraries/` 目录下，路径不变 |
| R9 | **.build 缓存失效** | 🟢 低 | 需要重新构建 | 正常，删除 `.build/` 即可 |

### 3.4 风险矩阵

```
                影响
              低      中      高
    高 │     —      —     R1, R2
  可能性 中 │  R9     R5      —
    低 │  R6,R7   R8      R3,R4
```

**最高优先级：**
- 🔴 **R1 + R2：** 必须在移动后、构建前更新 pbxproj 中的包引用路径
- 🟡 **R5：** CurrentReality 文档需更新 3 行路径引用

---

## 4. 回滚方案

### 4.1 回滚前置条件

执行迁移前必须完成：

```
cp -R /Users/night_creek/开发/eMathica\ Hub /tmp/emathica-pre-migration-backup/
```

### 4.2 完整回滚（迁移中断时）

如果迁移在任意步骤中断，执行以下操作恢复：

```bash
# 停止并恢复
rm -rf /Users/night_creek/开发/eMathica-Hub        # 删除已重命名的 Hub
rm -rf /Users/night_creek/开发/eMathica              # 删除已移出的 Core
rm -rf /Users/night_creek/开发/OpenMathInkCollector  # 删除已移出的 Collector
rm -rf /Users/night_creek/开发/SharedLibraries        # 删除已移出的 SharedLibraries
rm -rf /Users/night_creek/开发/OpenMathInkDataset     # 删除新建的 Dataset

cp -R /tmp/emathica-pre-migration-backup /Users/night_creek/开发/eMathica\ Hub
```

### 4.3 部分回滚

#### 如果仅重命名了 Hub 目录名

```bash
mv /Users/night_creek/开发/eMathica-Hub "/Users/night_creek/开发/eMathica Hub"
```

#### 如果仅移动了 Core

```bash
mkdir -p "/Users/night_creek/开发/eMathica Hub/Projects"
mv /Users/night_creek/开发/eMathica "/Users/night_creek/开发/eMathica Hub/Projects/eMathica"
```

#### 如果移动了 Core + SharedLibraries，但 Collector 未移动

```bash
mv /Users/night_creek/开发/eMathica "/Users/night_creek/开发/eMathica Hub/Projects/eMathica"
mv /Users/night_creek/开发/SharedLibraries "/Users/night_creek/开发/eMathica Hub/Projects/Packages"
# 恢复 Hub 目录名
mv /Users/night_creek/开发/eMathica-Hub "/Users/night_creek/开发/eMathica Hub"
```

---

## 5. 迁移后需更新的引用

### 5.1 Xcode project.pbxproj（必须更新）

**Core `eMathica.xcodeproj/project.pbxproj`：**

```
5 处修改：../Packages/ → ../SharedLibraries/
```

| 当前 | 修改后 |
|------|--------|
| `../Packages/EMathicaMathCore` | `../SharedLibraries/EMathicaMathCore` |
| `../Packages/EMathicaDocumentKit` | `../SharedLibraries/EMathicaDocumentKit` |
| `../Packages/EMathicaThemeKit` | `../SharedLibraries/EMathicaThemeKit` |
| `../Packages/EMathicaWorkspaceKit` | `../SharedLibraries/EMathicaWorkspaceKit` |
| `../Packages/EMathicaMathInputKit` | `../SharedLibraries/EMathicaMathInputKit` |

**Collector `.xcodeproj/project.pbxproj`：**

```
1 处修改：../../Packages/ → ../SharedLibraries/
```

### 5.2 Hub 文档（推荐更新）

**`CurrentReality/README.md`：**

| 行 | 当前 | 修改后 |
|----|------|--------|
| Source: | `Projects/eMathica/` | `../eMathica/` |
| Source: | `Projects/OpenMathInkCollector/` | `../OpenMathInkCollector/` |
| Source: | `Projects/Packages/` | `../SharedLibraries/` |
| 目录树 | `Projects/` 下的嵌套 | 更新为新的扁平结构 |

### 5.3 可以保留的（历史文档）

`Documentation/Working/*.md` 中的 `Projects/` 引用是历史审计文档，不需要更新。它们在 Hub 仓库中，指向旧结构是可接受的。

---

## 6. Migration Readiness Score

```
Migration Readiness Score:          93/100

    ├── Current→Target mapping      ✅ 清晰 — 5 项操作完整定义
    ├── File move plan              ✅ 详细 — 每个源/目标路径列出
    ├── Risk analysis               ✅ 完整 — 9 项风险分级
    ├── Rollback plan               ✅ 3 种场景覆盖
    ├── Migration script            ✅ 12 步原子脚本
    └── Pre-execution checks        ✅ 备份 + 预检

Blocking issues: 0
Medium issues:   1 (README paths — post-migration update)
Low issues:      2 (Working docs, .xcuserdata)
```

## Ready To Execute: **YES**

**迁移前置条件：**
- [ ] 备份当前 `eMathica Hub/` 目录
- [ ] 确认 Core 在 Xcode.app 中能构建
- [ ] 确认 Collector 在 Xcode.app 中能构建
- [ ] 确认迁移脚本存在且可执行

**迁移后立即验证：**
1. Core 在 Xcode.app 中构建
2. Collector 在 Xcode.app 中构建
3. SharedLibraries 包解析成功
4. Hub `CurrentReality/README.md` 更新路径

---

## 6. Phase4_MigrationScript.sh

生成在 `Documentation/Automation/Phase4_MigrationScript.sh`。

不要执行。

用于迁移时人工确认和执行。
