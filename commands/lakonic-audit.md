---
description: Find worthwhile simplifications across a repository
---

Audit $ARGUMENTS (default: repository source, excluding generated, vendored, and dependency files). Find high-confidence opportunities to remove duplication, unnecessary layers, obsolete options, or dependencies replaced by existing, standard-library, or platform features. Check callers and behavioral assumptions. Ignore cosmetic changes and preserve tests and safeguards. Do not edit files.

Rank findings by credible net savings: `file:line — what to remove → replacement (~N lines, ~M dependencies)`. State when scope was incomplete. Otherwise say `No convincing reductions.`
