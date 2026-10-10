---
framework: Foreman^^
document_type: case-study
distribution: DAcumen
status: reference
---

# Case Study — The Local Judge That Failed Its Own Test

*An estate wanted to know whether a local language model could label commits better than the cheap path-based rule it already used. The pass bar was written down and committed before any data existed. The model failed it. The question closed in one cycle, at no outside cost, and nobody has reopened it.*

This is a worked example of pre-registration applied to an internal tooling decision. The model, the numbers, and the labels are one setup's. The order of operations is the portable part.

## The question

Every commit in the estate carries a scope line saying whether it touched a product or internal tooling. A regex over the changed paths could guess that line. The question was whether a local model, already running on hardware the estate owned, could guess it better, and know when to trust itself. Behind that sat a second question, carried for a cycle: should the estate pay an outside grading service for the same judgment?

## Step 1 — Commit the rule before the data

The rule went into a doctrine file in its own commit, before the truth set was exported and before any model call. That commit's hash and timestamp became the anchor every later document cites. The section is never edited once results exist.

The rule named a **deciding arm** in advance: the model sees the commit subject, the changed paths, and the diff stats, but not the commit body. Three checks, all on out-of-fold predictions over every labelled commit:

1. Accuracy at least 0.05 above the path-regex baseline.
2. Expected calibration error, over 10 quantile bins, at most 0.10.
3. Some confidence threshold at or below 0.90 where accuracy reaches 0.95 on at least half the commits.

## Step 2 — Write the outcome table, including the outcomes you don't want

| outcome | ruling |
|---|---|
| all three pass | the local judge is the substitute; don't buy; next phase unlocks |
| check 1 fails | the model adds nothing over the regex; don't buy, don't build further; keep the regex |
| 1 passes, 2 fails | accurate but uncalibrated; re-run with calibration and an ensemble |
| 1 and 2 pass, 3 fails | calibrated, low yield; advisory column only, no auto-label |
| more than 20% of rows unverifiable | no ruling |

No row says "buy the outside service". The estate had no access to it and no quote, and the table said so instead of implying a comparison it could not make. What the table decides is narrower: is calibrated judgment achievable locally against the estate's own labels? If not, the table is the spec an outside vendor would have to beat.

## Step 3 — Run it, then let a second agent recompute

Over 286 labelled commits, the deciding arm scored 0.6364 accuracy against the regex baseline of 0.6469. Check 1 needed 0.6969. Check 2 passed: calibration error was 0.0501. Check 3 failed: no threshold reached the bar. Two non-deciding arms scored slightly higher. Because the deciding arm was named in advance, "which arm looks best" was never a choice anyone could make afterward.

The run took about two hours of local GPU time. An independent verifier recomputed all three checks from the raw results file and held the ruling. The close step checked that the rule's commit predates the results file's own timestamp.

## Step 4 — Record the decision with a reopen condition

The ruling went into a one-row decision ledger: what was decided, why, the authority (the outcome-table row), the status, and what it supersedes. The ledger also says what would reopen the question: a different judge, truth set, or threshold, registered under a fresh dated commit before any new run. "Do we buy it?" stopped being a parked item and became a closed one.

## What to take from it

- **A dated commit is the cheapest honesty tool you have.** If the bar is written after the numbers, nobody can tell whether it was tuned. If the bar is committed first, the history proves it was not.
- **Name the deciding arm before you look.** Every extra measurement is a chance to pick the flattering one. Informational arms are fine. Deciding arms are chosen in advance.
- **Put the unwanted outcomes in the table.** A table with only "pass" rows is a hope, not a rule. The "fails" row is the one that closes questions.
- **A clean negative is a result.** This one cost two GPU hours and nothing in cash, and it ended a recurring "should we buy something?" conversation. Record it as a decision with a reopen condition, so it does not drift back as a parked item.

*Source: the orchestration-head implementation's doctrine, eval write-up, and decision ledger, ruled 2026-09-18, mirrored here 2026-10-10.*
