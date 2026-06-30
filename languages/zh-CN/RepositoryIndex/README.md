# Repository Index

> eMathica 生态系统入口索引。

`SharedLibraries/` 是当前真实 package root；未来 `Packages/shared/`、`Packages/emathica-only/`、`Packages/openmathink-only/` 仍只是 target taxonomy。

## 当前索引

| 名称 | 类型 | 用途 | 当前说明 |
|------|------|------|----------|
| `eMathica` | 主应用目录 | eMathica app shell | 当前主应用与 HomeFeature 消费端 |
| `SharedLibraries` | 共享包目录 | 6 个 SwiftPM 包 | 当前真实 package root |
| `OpenMathInkCollector` | 采集工具目录 | 手写采集与标注 | 采集 app，应该保持 openmathink-only |
| `OpenMathInkDataset` | 数据集目录 | 开源数据集 | 规划中 |
| `eMathica-Hub` | 门户目录 | 哲学、索引、当前状态 | 入口文档与导航 |

## 关系说明

- Hub 提供导航和文档入口，不承载业务代码。
- eMathica app 依赖 SharedLibraries。
- OpenMathInkCollector 也依赖 SharedLibraries。
- SharedLibraries 的当前物理路径仍然是单个目录，不是最终 taxonomy。
