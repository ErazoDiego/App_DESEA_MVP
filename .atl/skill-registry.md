# Skill Registry — DESEA-MVP

**Delegator use only.** Any agent that launches sub-agents reads this registry to resolve compact rules, then injects them directly into sub-agent prompts. Sub-agents do NOT read this registry or individual SKILL.md files.

## SDD Workflow Skills

| Trigger | Skill | Path |
|---------|-------|------|
| sdd init, openspec init | sdd-init | ~/.config/opencode/skills/sdd-init/SKILL.md |
| sdd explore, investigate | sdd-explore | ~/.config/opencode/skills/sdd-explore/SKILL.md |
| sdd propose, new change | sdd-propose | ~/.config/opencode/skills/sdd-propose/SKILL.md |
| sdd spec, specifications | sdd-spec | ~/.config/opencode/skills/sdd-spec/SKILL.md |
| sdd design, architecture | sdd-design | ~/.config/opencode/skills/sdd-design/SKILL.md |
| sdd tasks, breakdown | sdd-tasks | ~/.config/opencode/skills/sdd-tasks/SKILL.md |
| sdd apply, implement | sdd-apply | ~/.config/opencode/skills/sdd-apply/SKILL.md |
| sdd verify, validation | sdd-verify | ~/.config/opencode/skills/sdd-verify/SKILL.md |
| sdd archive, close change | sdd-archive | ~/.config/opencode/skills/sdd-archive/SKILL.md |
| sdd onboard, walkthrough | sdd-onboard | ~/.config/opencode/skills/sdd-onboard/SKILL.md |
| judgment day, adversarial review | judgment-day | ~/.config/opencode/skills/judgment-day/SKILL.md |
| create skill, new skill | skill-creator | ~/.config/opencode/skills/skill-creator/SKILL.md |
| PR, pull request | branch-pr | ~/.config/opencode/skills/branch-pr/SKILL.md |
| issue, report bug | issue-creation | ~/.config/opencode/skills/issue-creation/SKILL.md |

## Compact Rules

### Flutter / Riverpod (DESEA-MVP)
- Use Riverpod for state management (flutter_riverpod)
- Follow Clean Architecture: data/domain/presentation layers
- Repository pattern for data access
- Use go_router for navigation
- Hive for local persistence with type adapters
- State providers in presentation/providers/
- Route definitions in presentation/routes/
- Hive adapters in data/models/adapters/

### SDD Workflow
- Always create proposal BEFORE specs (sdd-propose → sdd-spec → sdd-design → sdd-tasks → sdd-apply → sdd-verify → sdd-archive)
- Use Given/When/Then format for scenarios in specs
- Include rollback plan in proposals for risky changes
- Tasks must be small enough to complete in one session
- Run tests if test infrastructure exists during verify
- Compare implementation against every spec scenario

### go-testing (contextual)
- Only load when Go/Bubbletea testing detected
- Use teatest for TUI testing patterns

## Project Conventions

| File | Path | Notes |
|------|------|-------|
| AGENTS.md | ~/.config/opencode/AGENTS.md | Senior architect persona, SDD workflow, engram protocol |
| engram-convention.md | ~/.config/opencode/skills/_shared/engram-convention.md | Engram artifact naming convention |

## Project: DESEA-MVP

**Stack**: Flutter 3.41.9, Dart 3.11.5, Riverpod, Hive, go_router
**Architecture**: Clean Architecture (data/domain/presentation)
**Testing**: flutter test ✅, dart analyze ✅, dart format ✅
**Strict TDD**: enabled
**Status**: Greenfield (no code yet)
**Directory**: /home/pc_dae/DESEA-MVP/
