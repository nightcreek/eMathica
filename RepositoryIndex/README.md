# Repository Index

> 所有 eMathica 生态系统仓库的索引。
>
> URL 将在仓库创建后更新。

---

| Repository | Purpose | URL |
|------------|---------|-----|
| **eMathica Hub** | 项目导航、理念、路线图、仓库索引、社区投票 | TBD |
| **eMathica** | 主应用 — 平面几何、空间解析、计算器、主屏幕 | TBD |
| **OpenMathInk Collector** | 手写数学数据采集 — PencilKit 采集、标注、导出 | TBD |
| **SharedLibraries** | 共享 SwiftPM 包（EMathicaMathCore、DocumentKit、MathInputKit、ThemeKit、WorkspaceKit） | TBD |
| **OpenMathInk Dataset** | 开源数学手写数据集（规划中） | TBD |

---

## Repository Relationships

```
eMathica Hub  (navigation only, no source code)
    │
    ├── points to → eMathica Core          (via URL)
    ├── points to → OpenMathInk Collector  (via URL)
    ├── points to → SharedLibraries        (via URL)
    └── points to → OpenMathInk Dataset    (via URL)

eMathica Core
    └── depends on → SharedLibraries (local path, SwiftPM)

OpenMathInk Collector
    └── depends on → SharedLibraries (local path, SwiftPM)
```

> **Note:** Each repository will be independent. Cross-references are via URL only from Hub to other repositories. Package-level dependencies between Core/Collector and SharedLibraries are managed through SwiftPM.
