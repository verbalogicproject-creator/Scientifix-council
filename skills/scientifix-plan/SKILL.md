---
name: scientifix-plan
description: Convert an idea that has passed (or that the user trusts) into an actionable implementation plan. Uses the same 5 council agents pointed at the BUILD instead of the concept — Adversarial attacks the build path, Data-Grounding verifies tools, Red Team finds runtime failures, Outside-the-Box finds shortcuts, Steelman constructs the minimum viable build. Output is a ranked sequence with BUILD-FIRST / VERIFY-FIRST / SKIP labels per step, saved to .scientifix/plan_<ISO>.md. Use when the user runs /scientifix-plan, asks for "an implementation plan from this idea", "turn this into a build plan", "what's the first step", "show me how to build this", "council-grade plan for X", or wants to convert a verified concept into ordered actionable steps.
allowed-tools: Read, Write, Bash, Agent
argument-hint: The idea, hypothesis, or concept to convert into an implementation plan
---

Run the `scientifix-council:scientifix-plan` slash command with the provided idea as `$ARGUMENTS`.

The skill is a thin wrapper around the `/scientifix-plan` command. The actual orchestration logic lives in `commands/scientifix-plan.md` — read that file for the full coordinator instructions, then execute its protocol on the input.

## Why this skill exists separately from the command

- The slash command form (`/scientifix-plan`) is for explicit user invocation
- This skill form is for Claude's autonomous invocation — when Claude detects the user has accepted an idea as sound and is about to start building, it can proactively convene the council in BUILD mode to extract the optimal sequence before any code is written

Both forms produce the same output and write the same `.scientifix/plan_<ISO>.md` artifact.
