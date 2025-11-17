# Agent Questions & Answers
**Project:** Aria's Magic SharePlay App

---

## How to Use This File

**Asking Questions:**
1. Add your question at the top (newest first)
2. Use the template below
3. Tag relevant agents with @AgentName
4. Mark as **[BLOCKING]** if it prevents your work

**Answering Questions:**
1. Add your answer under the question
2. Include code examples if helpful
3. Link to related files/docs
4. Mark question as **[RESOLVED]**

---

## Template

```markdown
## [Agent Name] - [Date] - [BLOCKING/NON-BLOCKING]
**Question:** [Clear, specific question]

**Context:** [Why you need to know]

**Impacts:** [What work is blocked]

**To:** @AgentName or @Coordinator

---

## [Answering Agent] - [Date]
**Answer:** [Clear answer]

**Recommendation:** [Suggested approach]

**References:** [Links to docs, code, examples]

**Status:** [RESOLVED]
```

---

## Active Questions

<!-- Post new questions here -->

_No active questions yet. Agents will post as development begins._

---

## Example Question (Remove when first real question posted)

## iOS Core Engineer - Nov 17 - NON-BLOCKING
**Question:** Should SharePlay sync every position update or throttle updates to reduce network traffic?

**Context:** When a character is dragged, we could sync every frame (60 updates/sec) or throttle to 10-20 updates/sec.

**Impacts:** Network efficiency vs sync smoothness

**To:** @Coordinator

---

## Coordinator - Nov 17
**Answer:** Throttle to 20 updates/second maximum.

**Recommendation:**
- Sync position every 50ms (20 Hz)
- Immediate sync for discrete events (spawn, action triggers)
- Use interpolation on receiving end for smooth movement

**References:**
- [GroupActivities Best Practices](https://developer.apple.com/documentation/groupactivities)
- See Agent-Lab project's sync implementation for reference

**Status:** [RESOLVED]

---

## Resolved Questions Archive

<!-- Resolved questions will be moved here for reference -->

_None yet._

---

**Last Updated:** November 17, 2025
