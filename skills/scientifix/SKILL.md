---
name: scientifix
description: Convene the Scientifix Council to evaluate an idea, hypothesis, architecture proposal, or concept. Dispatches 5 specialist agents in parallel (Adversarial, Data-Grounding, Red Team, Outside-the-Box, Steelman) and synthesizes a HOLDS/WEAK/DISCARD verdict per claim. Use when the user runs /scientifix, asks for a "council review" of an idea, says "evaluate this concept", "check if this holds", "is this a good idea", "stress-test this proposal", "find the holes in this", or any phrasing that maps to rigorous epistemic vetting of a "big idea" before commitment. Eyal uses this as a firewall against his own optimism bias.
allowed-tools: Read, Write, Bash, Agent
argument-hint: The idea, hypothesis, or proposal to evaluate
---

Run the `scientifix-council:scientifix` slash command with the provided idea as `$ARGUMENTS`.

The skill is a thin wrapper around the `/scientifix` command. The actual orchestration logic lives in `commands/scientifix.md` — read that file for the full coordinator instructions, then execute its protocol on the input.

## Why this skill exists separately from the command

- The slash command form (`/scientifix`) is for explicit user invocation
- This skill form is for Claude's autonomous invocation — when Claude decides an idea needs vetting based on conversational context (e.g., user says "I had a thought" and starts describing an unverified architectural claim that would benefit from council review)

Both forms produce the same output and run the same 5-agent dispatch.
