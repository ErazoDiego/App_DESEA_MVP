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
- Hive CE for local persistence with type adapters (.g.dart)
- State providers in presentation/providers/
- Route definitions in presentation/routes/
- Immutable state with copyWith pattern
- ProviderScope.overrides for test dependency injection
- In-memory Hive fakes (FakeGuardadasBox, etc.) for widget tests
- Dark theme only with custom AppColorsTheme
- Spanish docstrings with English code identifiers
- Conventional commits (feat:, chore:, fix:)

### SDD Workflow
- Always create proposal BEFORE specs (sdd-propose → sdd-spec → sdd-design → sdd-tasks → sdd-apply → sdd-verify → sdd-archive)
- Use Given/When/Then format for scenarios in specs
- Include rollback plan in proposals for risky changes
- Tasks must be small enough to complete in one session
- Run `flutter test` during verify phase
- Compare implementation against every spec scenario
- Coverage: use `flutter test --coverage`

## Project Conventions

| File | Path | Notes |
|------|------|-------|
| AGENTS.md | ~/.config/opencode/AGENTS.md | Senior architect persona, SDD workflow, engram protocol |
| openspec/config.yaml | openspec/config.yaml | SDD config with detected stack and testing capabilities |

## Project: DESEA-MVP

**Stack**: Flutter 3.41.9, Dart 3.11.5, Riverpod, Hive CE, go_router
**Architecture**: Clean Architecture (data/domain/presentation)
**Testing**: flutter test ✅ (332 tests, all pass), flutter analyze ✅, dart format ✅
**Strict TDD**: enabled
**Status**: Active development with SDD workflow established
**Directory**: /home/pc_dae/DESEA-MVP/
