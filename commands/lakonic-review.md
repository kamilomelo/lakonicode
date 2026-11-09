---
description: Find safe simplifications in current changes
---

Review $ARGUMENTS (default: staged, unstaged, and untracked changes). Read enough surrounding code and callers to identify safe cuts: duplication, dead code, needless indirection, or custom code already covered by standard libraries or the platform. Ignore cosmetic shortening; preserve behavior, tests, and safeguards. Do not edit files.

Report each finding as `file:line — what to remove → simpler replacement (~N lines saved)`, largest first. Estimate savings only when credible. Otherwise say `Nothing worth cutting.`
