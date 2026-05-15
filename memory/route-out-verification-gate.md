---
name: route-out-verification-gate
description: "A GOV route-out isn't fire-and-forget — the next GOV fresh sweep is the verification gate that confirms the owner actually picked the item up"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 55c33bab-ad10-4990-89a8-4f86283d20a3
---

When a GOV sprint finds work that has a natural owner, it routes the item out with a paper trail rather than absorbing it into the GOV pool (GOV-02 dellatech-chunking, GOV-03 NCAA-baseball, GOV-04 F2/F3 telemetry-contract gaps). GOV-04 L04 routed F2 (telemetry-contract checker unscheduled) + F3 (2 failing contracts) to the telemetry-contract surface owner, and the paper trail said explicitly: *"if F2/F3 are still ownerless when GOV-05 runs its fresh health-check sweep, that sweep re-surfaces them — and at that point they'd be genuinely GOV-shaped."*

GOV-05 L01's sweep was that gate. Result: F2 resolved (checker now scheduled — `observatory-telemetry-contract-check.timer` enabled + active), F3 resolved (`telemetry-contract-status.json` 5 pass / 0 fail). The owner picked them up. First full round-trip proof that the route-out discipline is a **closed loop**, not a hand-wave.

**Why:** A route-out that's never re-checked is indistinguishable from dropping the work on the floor — same failure shape as [[silent-failure-refresh-mechanisms]]. The discipline only holds if there's a structural point where "did the owner act?" gets answered. The GOV operating model already has that point for free: every GOV sprint opens from a fresh health-check sweep, and that sweep re-tests routed-out items as a matter of course. The route-out's paper trail and the next sweep are two halves of one mechanism.

**How to apply:** When routing an item out of a GOV sprint, write the paper trail as a closed test for the *next* sweep to run (same shape as [[standing-watch-fire-criteria]]): name the item, name the owner/surface, and state the observable that decides "resolved" vs "still ownerless." The next GOV sweep then has two honest outcomes — owner resolved it (success, codify and move on) or it's still ownerless (now genuinely GOV-shaped, pool it). Don't re-litigate scope at route-out time; let the sweep gate decide.
