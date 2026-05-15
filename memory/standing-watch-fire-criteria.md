---
name: standing-watch-fire-criteria
description: "GOV standing watches work because they're written with an explicit, testable fire criterion — not a vague \"keep an eye on it\""
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 2f08fa7f-6fba-48db-aec7-3b0b6f579bbb
---

GOV-02 L03 left a standing watch on `casey-pipeline` worded with a concrete fire criterion: "re-check once cycle-28 lands RC6 — *if RC6 closes and the pipeline still won't start*, that residual gap is GOV-shaped." When RC6 landed (L04), that criterion was directly testable: RC6 closed ✓, pipeline still crash-looped ✓ → GOV-02 took the work without re-litigating scope.

**Why:** A standing watch is only useful if a future session (or a future GOV sprint) can mechanically decide whether it fired. "Keep an eye on casey-pipeline" would have required re-deriving the whole scope question. "If X closes and Y is still broken, it's GOV-shaped" is a closed test — it carries its own scope decision.

**How to apply:** When writing a standing watch or carryover note, include (1) the trigger event to re-check after, (2) the observable test, and (3) the pre-decided routing if the test passes. Carryover entries in `.foreman/cycle.json` should read as closed tests, not reminders. Related: [[cascade-rc-rename-consumer-runtime-gap]].
