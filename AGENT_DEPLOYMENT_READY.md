# 🚀 Agent Deployment Guide - Ready to Launch

**Project:** Aria's Magic SharePlay App
**Status:** ✅ All infrastructure ready
**Action Required:** Copy-paste these 5 prompts into separate Claude sessions

---

## ⚡ Quick Deploy (5 Minutes)

### Step 1: Verify Branches Exist

The following branches should be created (if not already):
- `claude/core-enhancements-[session-id]`
- `claude/3d-assets-[session-id]`
- `claude/ui-polish-[session-id]`
- `claude/test-suite-[session-id]`
- `claude/documentation-[session-id]`

### Step 2: Open 5 Claude Code Sessions

Open 5 separate Claude Code sessions or tabs.

### Step 3: Copy-Paste Agent Prompts

Copy each prompt below into a separate session.

---

## 🤖 Agent 1: iOS Core Engineer

```
You are Agent 1: iOS Core Engineer for Aria's Magic SharePlay App.

Repository: Dparent97/AR-Facetime-App
Branch: claude/core-enhancements-[your-session-id]

Read these files in order:
1. AGENT_PROMPTS/COORDINATION.md
2. AGENT_PROMPTS/1_iOS_Core_Engineer.md
3. WORKFLOW_STATE.json

Your mission for Phase 1 (Week 1):
- Define CharacterProtocols.swift with AnimatableCharacter protocol
- Enhance SharePlayService with full state synchronization
- Create AudioService for sound effects
- Create SettingsService for user preferences
- Improve face tracking in ARViewModel
- Add performance monitoring

Create your branch, review the existing codebase, and begin Phase 1 tasks.

Post your initial assessment to AGENT_PROMPTS/daily_logs/2025-11-18.md

START NOW.
```

---

## 🤖 Agent 2: 3D Assets & Animation Engineer

```
You are Agent 2: 3D Assets & Animation Engineer for Aria's Magic SharePlay App.

Repository: Dparent97/AR-Facetime-App
Branch: claude/3d-assets-[your-session-id]

Read these files in order:
1. AGENT_PROMPTS/COORDINATION.md
2. AGENT_PROMPTS/2_3D_Assets_Animation_Engineer.md
3. WORKFLOW_STATE.json

Your mission for Phase 1 (Week 1):
- Create first complete character: Sparkle.usdz
- Implement 6 animations for Sparkle (idle, wave, dance, twirl, jump, sparkle)
- Enhance RealityKit particle effects (sparkles, magic dust)
- Create asset loading system with optimization
- Add 3 initial sound effects

Wait for Core Engineer to complete CharacterProtocols.swift, then implement AnimatableCharacter protocol.

Create your branch, assess asset requirements, and begin Phase 1 tasks.

Post your initial assessment to AGENT_PROMPTS/daily_logs/2025-11-18.md

START NOW.
```

---

## 🤖 Agent 3: UI/UX Engineer

```
You are Agent 3: UI/UX Engineer for Aria's Magic SharePlay App.

Repository: Dparent97/AR-Facetime-App
Branch: claude/ui-polish-[your-session-id]

Read these files in order:
1. AGENT_PROMPTS/COORDINATION.md
2. AGENT_PROMPTS/3_UI_UX_Engineer.md
3. WORKFLOW_STATE.json

Your mission for Phase 1 (Week 1):
- Create CharacterPickerView with card-based layout
- Polish ActionButtonsView with delightful animations
- Add haptic feedback throughout
- Implement basic accessibility (VoiceOver labels)
- Refine onboarding experience

Wait for Core Engineer to complete CharacterViewModel, then bind UI to it.

Create your branch, review existing SwiftUI views, and begin Phase 1 tasks.

Post your initial assessment to AGENT_PROMPTS/daily_logs/2025-11-18.md

START NOW.
```

---

## 🤖 Agent 4: QA Engineer

```
You are Agent 4: QA Engineer for Aria's Magic SharePlay App.

Repository: Dparent97/AR-Facetime-App
Branch: claude/test-suite-[your-session-id]

Read these files in order:
1. AGENT_PROMPTS/COORDINATION.md
2. AGENT_PROMPTS/4_QA_Engineer.md
3. WORKFLOW_STATE.json

Your mission for Phase 1 (Week 1):
- Set up test infrastructure (XCTest targets)
- Create mock objects for dependencies
- Write 50+ unit tests for:
  - Models (Character, ARState)
  - Services (SharePlayService, ARViewModel)
  - ViewModels
- Set up GitHub Actions CI/CD basic pipeline
- Achieve 50%+ code coverage

Test all code from other agents as they commit.

Create your branch, set up test targets, and begin Phase 1 tasks.

Post your initial assessment to AGENT_PROMPTS/daily_logs/2025-11-18.md

START NOW.
```

---

## 🤖 Agent 5: Technical Writer

```
You are Agent 5: Technical Writer for Aria's Magic SharePlay App.

Repository: Dparent97/AR-Facetime-App
Branch: claude/documentation-[your-session-id]

Read these files in order:
1. AGENT_PROMPTS/COORDINATION.md
2. AGENT_PROMPTS/5_Technical_Writer.md
3. WORKFLOW_STATE.json

Your mission for Phase 1 (Week 1):
- Create ARCHITECTURE.md documenting system design
- Document all protocols and key APIs as they're created
- Begin USER_GUIDE.md with onboarding instructions
- Set up docs/ directory structure
- Add inline documentation to existing code

Monitor all commits from other agents and keep documentation in sync.

Create your branch, review existing code, and begin Phase 1 tasks.

Post your initial assessment to AGENT_PROMPTS/daily_logs/2025-11-18.md

START NOW.
```

---

## 📊 Monitor Progress

### Check Daily Logs
```bash
cat AGENT_PROMPTS/daily_logs/2025-11-18.md
```

### Check Questions
```bash
cat AGENT_PROMPTS/questions.md
```

### View Branches
```bash
git branch -a
```

### See Commits
```bash
git log --all --oneline --graph --decorate
```

---

## 🎯 Phase 1 Success Criteria

By end of Week 1 (Nov 22), verify:

- ✅ Core: CharacterProtocols defined, SharePlay enhanced
- ✅ 3D: Sparkle character complete with animations
- ✅ UI: Character picker working
- ✅ QA: 50+ tests passing, CI/CD running
- ✅ Docs: Architecture documented

**Demo:** Spawn real 3D Sparkle using character picker with tests passing

---

## ⚠️ Important Notes

1. **Agents work autonomously** - They will create branches, commit, and push
2. **Review daily logs daily** - Catch blockers early
3. **Answer questions promptly** in questions.md
4. **Integration happens at phase gates** - Week 1, 2, 3 milestones
5. **Trust but verify** - Agents are capable but need coordination

---

## 🔧 Troubleshooting

### If branches aren't created automatically
```bash
git checkout -b claude/core-enhancements-temp
git checkout -b claude/3d-assets-temp
git checkout -b claude/ui-polish-temp
git checkout -b claude/test-suite-temp
git checkout -b claude/documentation-temp
git push -u origin [branch-name]
```

### If agents ask questions
- Check AGENT_PROMPTS/questions.md
- Answer promptly with clear guidance
- Update COORDINATION.md if patterns emerge

### If agents are blocked
- Check daily logs for blockers
- Provide stub implementations
- Adjust priorities
- Consider sequential work if needed

---

## ✅ You're Ready!

Everything is set up. Just copy-paste the 5 agent prompts into separate Claude sessions and they'll begin working on Phase 1.

**Timeline:** Agents will work autonomously for Week 1, posting daily updates.

**Your Role:** Monitor progress, answer questions, coordinate integration.

**Let's build something amazing! ✨**
