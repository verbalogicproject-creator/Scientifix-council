# Scientifix Council

A Claude Code plugin that convenes a council of 5 specialist agents to stress-test ideas and convert surviving concepts into actionable build plans.

Two modes. Same 5 agents. Different verb.

---

## The Problem It Solves

You have a big idea. You've thought about it for a day, maybe longer. It feels solid. You're about to start building.

The problem: ideas feel most compelling right before you commit to them, which is exactly when optimism bias is highest. The Scientifix Council is a structured firewall — it dispatches 5 agents with hostile, empirical, failure-scanning, intersection-finding, and steelmanning lenses in parallel, then synthesizes a verdict you can trust.

If the idea survives, `/scientifix-plan` converts it into a ranked build sequence — BUILD-FIRST, VERIFY-FIRST, or SKIP per step — so you start with what matters and skip what doesn't.

---

## The 5 Agents

| Agent | Role | Stance | Tools |
|---|---|---|---|
| **Adversarial** | Hostile peer review | Attacks assumptions, finds the fatal flaw, forces a defense | WebSearch |
| **Data-Grounding** | Empirical audit | Classifies every assumption: VERIFIED / THEORETICAL / UNSUBSTANTIATED / FALSE | WebSearch |
| **Red Team** | Failure mode scanner | Ranks failure modes by likelihood × blast radius (memory, tokens, Termux, <4B model gaps) | WebSearch |
| **Outside-the-Box** | Intersection finder | Applies Obscure Research Framework — cross-category fusion, continuous loop test, chain-of-three | WebSearch, AskUserQuestion |
| **Steelman** | Strongest-version constructor | Based on Rapoport's Rules — rebuilds the proposal at its best before the council tears it down | WebSearch |

**Why 5?** Three attack agents (Adversarial, Data-Grounding, Red Team) + one exploration agent (Outside-the-Box) + zero defense agents = asymmetric. Without the Steelman, the council always wins against any idea by sheer attack volume. The Steelman creates the Adversarial↔Steelman dialectic — the live contention between the two is often the most valuable signal.

---

## Two Modes

### Mode 1: Idea Evaluation — `/scientifix`

Dispatches all 5 agents against the **concept**. Synthesizes a per-claim verdict:

- **HOLDS** — Survives all 5 agents. Steelman articulated a strong version, Data-Grounding confirmed, Adversarial and Red Team attacks rebutted.
- **WEAK** — One or more agents raised unresolved concerns. Needs verification before relying on it.
- **DISCARD** — Fatal flaw that even the best version can't survive. Do not build on this.

Use this first. If the core idea doesn't hold, there's nothing to plan.

### Mode 2: Build Planning — `/scientifix-plan`

Same 5 agents re-directed at the **implementation**. Produces a ranked build sequence:

- **BUILD-FIRST** — All agents greenlit, tools verified, no critical failure, no shortcut replaces it. Start here.
- **VERIFY-FIRST** — A tool is THEORETICAL or a concern is unresolved. Do a 30-minute spike before full commit.
- **SKIP** — A shortcut replaces it, it's premature optimization, or Red Team flagged critical failure with no mitigation.

Saves the full plan to `.scientifix/plan_<ISO>.md` in your current working directory.

---

## Usage

```
/scientifix your idea or proposal text here
```

```
/scientifix-plan the idea that passed evaluation — build this
```

Both commands accept freeform text. The more concrete the input, the more useful the output.

**Examples:**

```
/scientifix Build a local knowledge graph using SQLite + embeddings, 
where every Claude Code session automatically ingests new conversation 
context, queryable at session start

/scientifix-plan Build a local knowledge graph using SQLite + embeddings
```

---

## Output Format

### `/scientifix` output

```
╔══════════════════════════════════════════════╗
║         SCIENTIFIX COUNCIL VERDICT           ║
╚══════════════════════════════════════════════╝

PROPOSAL: [summary]

✓ HOLDS  (survives all 5 agents)
  • [claim]

⚠ WEAK  (needs verification)
  • [claim] — what would resolve it: [specific test]

✗ DISCARD  (do not build on this)
  • [claim] — why: [reason]

⚡ ADVERSARIAL vs STEELMAN  (live dialectic)
  • [contention point]: Attack — [claim] / Defense — [rebuttal]

NET SIGNAL: [one sentence]
CORE INSIGHT: [irreducible kernel]
MOST DANGEROUS ASSUMPTION: [if this is wrong, the idea collapses]
UNEXPLORED ANGLE: [what the proposal missed]
```

### `/scientifix-plan` output

```
╔══════════════════════════════════════════════╗
║      SCIENTIFIX COUNCIL — BUILD PLAN         ║
╚══════════════════════════════════════════════╝

Step 1: [BUILD-FIRST] — [name]
  What: [action]
  Tools: [verified tools]
  Risk: LOW / Effort: [estimate]

Step 2: [VERIFY-FIRST] — [name]
  Verify: [30-minute spike]
  ...

✗ SKIP — [steps to drop and why]
⚡ SHORTCUTS — [3-step chain replacements]
⚠ FAILURE MODES — [ranked risks]
NET SIGNAL — start with / watch out for / don't build

Plan saved to: .scientifix/plan_<ISO>.md
```

---

## Installation

### Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code/getting-started) installed (`npm install -g @anthropic-ai/claude-code`)
- Python 3 (for `install.sh`)

### Quick Install (Linux / macOS)

```bash
git clone https://github.com/<your-repo>/scientifix-council.git
cd scientifix-council
bash install.sh
```

Then in Claude Code:
```
/reload-plugins
```

That's it. The script handles all 4 required registration files automatically.

Verify with `/plugin` — you should see `scientifix-council` listed with 2 commands, 5 agents, 2 skills.

---

### Where Claude Code stores config

| Platform | Config directory |
|---|---|
| Linux / macOS | `~/.claude/` |
| Windows | `%APPDATA%\Claude\` |
| Termux (Android) | `~/.claude/` (same path, different root) |

The install script targets `~/.claude/` — which works on Linux and macOS without any changes. On Windows use WSL or run the equivalent steps manually (see Manual Registration below).

---

### What the install script does

Claude Code requires **4 state files** to be in sync for a plugin to load. Missing any single one causes silent failure.

| File | Purpose |
|---|---|
| `~/.claude/plugins/installed_plugins.json` | Registry entry — maps plugin name to source directory |
| `~/.claude/plugins/known_marketplaces.json` | Marketplace source lookup |
| `~/.claude/settings.json` → `extraKnownMarketplaces` | Duplicate marketplace declaration (required) |
| `~/.claude/settings.json` → `enabledPlugins` | Explicit enable flag per plugin |

`install.sh` writes all 4. It also adds the plugin to your marketplace's `marketplace.json` index if one exists.

---

### Manual Registration

If you prefer not to run the script, or are on Windows without WSL:

**1. `~/.claude/plugins/installed_plugins.json`**

Add to the `plugins` object:
```json
"scientifix-council@eyal-local": [{
  "scope": "user",
  "installPath": "/absolute/path/to/scientifix-council",
  "version": "unknown",
  "installedAt": "2024-01-01T00:00:00.000Z",
  "lastUpdated": "2024-01-01T00:00:00.000Z"
}]
```

**2. Marketplace index** — your marketplace's `.claude-plugin/marketplace.json`

Create a marketplace directory if you don't have one:
```bash
mkdir -p ~/claude-plugins/.claude-plugin
```

`~/claude-plugins/.claude-plugin/marketplace.json`:
```json
{
  "name": "my-plugins",
  "plugins": [
    {
      "name": "scientifix-council",
      "description": "5-agent epistemic council",
      "category": "productivity",
      "source": "./scientifix-council"
    }
  ]
}
```

Then symlink or copy the plugin into place:
```bash
cp -r /path/to/scientifix-council ~/claude-plugins/scientifix-council
```

**3. `~/.claude/settings.json` → `extraKnownMarketplaces`**

```json
{
  "extraKnownMarketplaces": [
    { "id": "my-plugins", "path": "/home/yourname/claude-plugins" }
  ]
}
```

**4. `~/.claude/settings.json` → `enabledPlugins`**

```json
{
  "enabledPlugins": {
    "scientifix-council@my-plugins": true
  }
}
```

**5. Reload**

```
/reload-plugins
```

---

## The Philosophy

**Rapoport's Rules** (Anatol Rapoport, *Fights, Games, and Debate*, 1960; popularized by Daniel Dennett): Before criticizing a position, you must be able to re-state it in a form the proponent would recognize as fair and accurate. The Steelman agent operationalizes this rule — it constructs the strongest version of the idea before the council attacks it, ensuring the council defeats the *best* version, not a straw man.

**Why parallel dispatch?** Sequential review compounds bias — each agent sees prior critiques and adjusts. Parallel dispatch forces independent analysis. The coordinator synthesizes independently-arrived-at positions, producing more reliable signal.

**Why save to `.scientifix/`?** Evaluations decay in conversation context. The timestamped artifact is a permanent record of what the council said, when, and on what input — reviewable when you're six sprints in and wondering why you made a decision.

---

## File Inventory

```
scientifix-council/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest (name, version, author)
├── agents/
│   ├── adversarial.md           # Hostile peer review agent
│   ├── data-grounding.md        # Empirical audit agent
│   ├── red-team.md              # Failure mode scanner
│   ├── outside-the-box.md       # Intersection-finding agent (Obscure Research Framework)
│   └── steelman.md              # Strongest-version constructor (Rapoport's Rules)
├── commands/
│   ├── scientifix.md            # /scientifix coordinator (eval mode)
│   └── scientifix-plan.md       # /scientifix-plan coordinator (build mode)
├── skills/
│   ├── scientifix/
│   │   └── SKILL.md             # Skill wrapper for autonomous Claude invocation (eval)
│   └── scientifix-plan/
│       └── SKILL.md             # Skill wrapper for autonomous Claude invocation (build)
├── install.sh                   # One-shot registration script
└── README.md                    # This file
```

---

## Troubleshooting

**Plugin doesn't appear after `/reload-plugins`**
- Check that all 4 registration files are in sync (installed_plugins.json, marketplace.json, settings.json/extraKnownMarketplaces, settings.json/enabledPlugins)
- Verify `installPath` in installed_plugins.json points to the source directory (not a cache copy)
- Confirm marketplace.json lists the plugin — the loader reads the index, not just the directory

**Commands silently fail or produce no output**
- Check that no command file uses bare `---` as a visual separator in the body. The YAML parser treats bare `---` as a new document separator, causing silent parse failure. Use `━━━` (U+2501) instead.

**"Plugin not found in marketplace" error**
- The marketplace.json at your marketplace root must list the plugin. Having files on disk is insufficient.

---

## Author

Eyal Nof — verbalogic.project@gmail.com

Version 1.2.0
