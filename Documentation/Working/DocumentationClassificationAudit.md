# Documentation Classification Audit

> Date: 2026-06-22
> Scope: Hub-level `Documentation/` directory only (app-internal `Docs/` and `AI/` are out of scope per the architecture plan — each app owns its implementation docs)
> Mode: Read-only — no files moved, deleted, or modified

---

## Current Structure

```
Documentation/
├── Automation/
│   ├── ModularDirectoryArchitecturePlan.md        ← created 2026-06-22
│   ├── Phase1_PackageExtractionReport.md           ← created 2026-06-22
│   └── RepositoryStructureMigrationReport.md       ← created 2026-06-22
├── Working/
│   ├── DocumentSystemOwnershipAudit.md             ← created 2026-06-22
│   └── FeatureUtilitiesOwnershipAudit.md           ← created 2026-06-22
└── temp/
    └── RepositorySplitPreparationAudit.md          ← pre-existing, 514 lines
```

**6 total documents** across 3 subdirectories. No files at `Documentation/` root level.

---

## CORE

**Definition:** README, ROADMAP, ARCHITECTURE, PROJECT_PHILOSOPHY, POLICIES

| Status | File | Notes |
|---|---|---|
| ❌ **Missing** | `Documentation/README.md` | No hub-level README exists. The only README is inside `Projects/eMathica/eMathica/Docs/README.md` (app-specific). |
| ❌ **Missing** | `Documentation/ROADMAP.md` | No hub-level roadmap. A roadmap exists in `Projects/eMathica/eMathica/AI/Core/Roadmap.md` (AI-dev scope). |
| ❌ **Missing** | `Documentation/ARCHITECTURE.md` | No hub-level architecture doc. Architecture docs are scattered across `Projects/eMathica/eMathica/AI/Core/Architecture.md` and `Docs/Architecture/`. |
| ❌ **Missing** | `Documentation/POLICIES.md` | No coding policies or conventions doc exists anywhere. |

**Current CORE count: 0 files.**

### Recommended CORE structure (future state)

```
Documentation/
├── README.md                     ← What is eMathica Hub? Quick start
├── ARCHITECTURE.md               ← Hub-level architecture overview
├── ROADMAP.md                    ← Cross-project roadmap
└── POLICIES.md                   ← Coding conventions, PR guidelines, decision process
```

These files do not yet exist and must be **created**, not moved.

---

## KNOWLEDGE

**Definition:** Architecture plans, Research docs, ADRs (Architecture Decision Records), long-term design documents

| File | Classification | Rationale |
|---|---|---|
| `Automation/ModularDirectoryArchitecturePlan.md` | ✅ **KNOWLEDGE** | Long-term architecture design for the entire Hub — a forward-looking reference document, not an execution report. Describes the target state, naming conventions, package dependency graph, and multi-phase migration plan. |

**Current KNOWLEDGE count: 1 file.**

The `ModularDirectoryArchitecturePlan.md` is currently stored in `Automation/` but
is more of a long-term architecture document than an execution log. It should
be moved to `Documentation/ARCHITECTURE/` or `Documentation/Decisions/` (as
the plan itself suggested in its target structure).

### Missed ADR opportunities

No ADRs exist anywhere in the project — not in `Documentation/`, not in `Docs/`,
not in `AI/`. Important decisions have been made (package extraction, directory
restructuring, code deduplication) without formal ADR records.

---

## WORKING

**Definition:** Audits, Migration reports, Reviews, Execution Reports

| File | Classification | Rationale |
|---|---|---|
| `temp/RepositorySplitPreparationAudit.md` | ✅ **WORKING** | Pre-existing audit of the repository structure before the current migration. Documents the "before" state. |
| `Automation/RepositoryStructureMigrationReport.md` | ✅ **WORKING** | Execution report from the first migration pass (flat → Hub/Projects/Assets/Data). |
| `Automation/Phase1_PackageExtractionReport.md` | ✅ **WORKING** | Execution report from Phase 1 (renames + MathCore extraction). |
| `Working/DocumentSystemOwnershipAudit.md` | ✅ **WORKING** | Audit comparing DocumentSystem vs EMathicaDocumentKit. |
| `Working/FeatureUtilitiesOwnershipAudit.md` | ✅ **WORKING** | Audit comparing FeatureUtilities vs Collector Modules. |

**Current WORKING count: 5 files.**

These are correctly classified but **poorly organized across inconsistent
subdirectories** (`Automation/`, `Working/`, `temp/`). See §Recommended Moves.

---

## ARCHIVE

**Definition:** Historical/abandoned documents, superseded reports, pre-consolidation snapshots

| File | Classification | Rationale |
|---|---|---|
| *(none at Hub level)* | — | The Hub-level `Documentation/` has no historical archive yet. All archive content (30+ docs) lives in `Projects/eMathica/eMathica/Docs/archive/` at the app level. |

**Current ARCHIVE count: 0 files.**

The Hub `Documentation/` is young (mostly created in the last 24 hours) and
has nothing to archive yet. Over time, superseded audit reports and migration
plans should be rotated into `Documentation/ARCHIVE/`.

---

## Recommended Moves

These are **recommendations only** — no files were moved.

### Problem: Three inconsistent working-doc directories

The current structure uses **three** subdirectories for what are all WORKING
documents: `Automation/`, `Working/`, and `temp/`. This inconsistency emerged
because this session created files organically without a settled convention.

### Target structure

```
Documentation/
├── README.md                              ← (create) Hub overview
├── ARCHITECTURE.md                        ← (create) Hub-level architecture
├── ROADMAP.md                             ← (create) Cross-project roadmap
├── POLICIES.md                            ← (create) Coding conventions
├── ARCHITECTURE/                          ← KNOWLEDGE
│   └── ModularDirectoryArchitecturePlan.md   ← MOVE from Automation/
├── ADR/                                   ← KNOWLEDGE (create, future use)
├── WORKING/                               ← WORKING (rename from Working/)
│   ├── RepositorySplitPreparationAudit.md    ← MOVE from temp/
│   ├── RepositoryStructureMigrationReport.md ← MOVE from Automation/
│   ├── Phase1_PackageExtractionReport.md     ← MOVE from Automation/
│   ├── DocumentSystemOwnershipAudit.md       ← already in Working/
│   └── FeatureUtilitiesOwnershipAudit.md     ← already in Working/
├── ARCHIVE/                               ← (create, future use)
└── temp/                                  ← DELETE or repurpose
```

### Move table

| Current Path | Recommended Path | Reason |
|---|---|---|
| `Automation/ModularDirectoryArchitecturePlan.md` | `ARCHITECTURE/ModularDirectoryArchitecturePlan.md` | It's an architecture design doc, not an automation/report |
| `temp/RepositorySplitPreparationAudit.md` | `WORKING/RepositorySplitPreparationAudit.md` | It's an audit report, not "temp" |
| `Automation/RepositoryStructureMigrationReport.md` | `WORKING/RepositoryStructureMigrationReport.md` | It's an execution report, belongs with other working docs |
| `Automation/Phase1_PackageExtractionReport.md` | `WORKING/Phase1_PackageExtractionReport.md` | It's an execution report, belongs with other working docs |

### Subdirectory rename

| Current | Target | Reason |
|---|---|---|
| `Working/` | `WORKING/` | Uppercase consistency with other planned dirs (`ARCHITECTURE/`, `ADR/`, `ARCHIVE/`) |

---

## Safe Deletions

| File | Recommendation | Rationale |
|---|---|---|
| *(none)* | — | No documents are safe to delete. All 6 files are either current working artifacts or a reference architecture plan. |

### After-consolidation cleanup

Once the recommended moves are executed, the following empty directories can be
removed:

| Directory | Action | Rationale |
|---|---|---|
| `Automation/` | Delete (after moving files) | All content relocated to appropriate categories |
| `temp/` | Delete (after moving file) | Single file relocated to WORKING/; dir name "temp" meaningless in docs |

---

## Appendix: Classification Rules Applied

| Rule | Applied |
|---|---|
| README → CORE | No README at Hub level yet |
| Architecture docs → KNOWLEDGE | `ModularDirectoryArchitecturePlan.md` → KNOWLEDGE |
| Audit/Migration/Report → WORKING | All 5 remaining docs → WORKING |
| History/Abandoned → ARCHIVE | None at Hub level |
| ADR → KNOWLEDGE | No ADRs exist yet — gap identified |
| App-internal docs NOT reclassified | `Docs/` and `AI/` are app-owned per the architecture plan |
