# ROADMAP — 路线图

> 已决定开发、但尚未完成的里程碑。
>
> 不是未来可能性。不是未决定的设想。

---

## eMathica Core

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| Plane Geometry Dependency System | 部分完成 | P1 | 几何依赖关系解析、重新计算服务、预览已实现。语义意图解析器需进一步完善。 |
| Plane Intersection Preview | 部分完成 | P1 | 交点预览逻辑已基本实现，需覆盖更多曲线类型。 |
| Plane Sampling Quality | 部分完成 | P2 | 采样质量策略、适配器已实现。跨模块一致性需要验证。 |
| Space Geometry Resolver | 部分完成 | P1 | 3D 几何解析器已实现。命中测试和线框渲染基础功能就绪。 |
| Input System (MathInputKit) | 部分完成 | P1 | 键盘输入引擎、AST、状态管理已实现。InputUI 占位，需要完整 SwiftUI 键盘视图。 |
| Object Panel | 部分完成 | P1 | 对象面板、检查器基础 UI 已实现。需扩展支持更多几何对象类型。 |
| Notebook (Notes) | 占位阶段 | P3 | 基础 UI 框架就绪，功能尚未实现。 |
| Modeling Module | 占位阶段 | P3 | 占位视图存在，未开始开发。 |
| Music Module | 占位阶段 | P3 | 占位视图存在，未开始开发。 |

---

## OpenMathInk Collector

| Item | Status | Priority | Notes |
|------|--------|----------|-------|
| Handwriting Canvas | 部分完成 | P1 | PencilKit 集成完成。笔触管理、工具设置、撤销/重做就绪。UI 适配需完善。 |
| Data Export Pipeline | 部分完成 | P1 | DatasetPackageBuilder 已实现。导出流程需进一步测试和优化。 |
| Consent & Onboarding | 部分完成 | P1 | 同意书管理层已完成。Onboarding 流程 UI 存在但需打磨。 |
| Settings & Privacy | 部分完成 | P2 | 设置视图已实现。隐私说明、许可证信息视图待完善。 |

---

## 工作区重组

| Phase | Status | Description |
|-------|--------|-------------|
| Phase 1: Core → Collector 清理 | ✅ Done | 18 个重复文件已删除 |
| Phase 2: Hub 文档 | ✅ Done | 本文档及关联页面 |
| Phase 3: 目录扁平化 | ⏳ **Pending** | 将 Core、Collector、Shared Libraries 从 `Projects/` 提升为一级目录 |
| Phase 4: 内部目录重构 | Pending | CalculatorModules → Features, App → AppShell, State 拆分 |
| Phase 5: Git 初始化 | Pending | 各仓库独立初始化 |
| Phase 6: GitHub 上传 | Pending | 创建 remote 并推送（后续任务） |

---

## 基础设施

| Item | Status | Notes |
|------|--------|-------|
| Xcode 包路径修复 | ✅ Done | `../../Packages/` → `../Packages/` |
| Package 依赖验证 | ✅ Done | 所有 5 个包引用正确 |
| 测试套件 | ⏳ 待验证 | 构建通过后需运行完整测试套件 |
