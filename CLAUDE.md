# Itomi

**Itomi: Crochet & Knit Counter.** A native iOS row and stitch counter, built for crochet first (amigurumi parts and rounds) and usable for knitting. Pronounced ee-TOH-mee, "beautiful thread" (ito 糸 = thread).

Aryan owns every decision and sees everything before it ships. Claude is the engineer. Today's goal and progress live in **`docs/PLAN.md`**: read it at the start of every session.

## Product (decided, don't reopen)

**Free, forever, no ads**
- Projects: name, photo, hook/needle size, yarn, notes
- Counter: big tap area for rows/rounds, stitch counter, undo, saves after every tap
- Parts (Head, Body, Ears ×2), each with its own counter
- Finish a project → moves to the Finished shelf
- Backup / export / restore, always free
- **2 active projects.** Finished ones don't count. Existing projects are never locked. The limit only shows when tapping + (New project).

**Pro** (yearly with 7-day trial ~$12.99–14.99, lifetime ~$29.99, no monthly, RevenueCat)
1. Counter everywhere: Lock Screen Live Activity, Dynamic Island, widgets, Control Center, Action Button, Siri (one App Intent)
2. Stitch-count warning: expected stitches per round + alert when a round doesn't add up
3. Unlimited active projects
4. Pattern viewer (PDF/photo, row marker); may slip to v1.1
5. Themes and app icons

**Later (v1.1+):** pattern helper (paste a pattern → rounds), knitting-specific features (charts, repeats).

**Never:** charge for the counter or the user's own data, ads, accounts, cloud backup in v1.

## Design

- Mockups: `docs/Itomi screens.pdf` (17 screens). Live canvas, source of truth: https://claude.ai/artifact/DoJY8WLPdSwzz9goFEvqmZ
- Very iOS-native: stock SwiftUI components, inset grouped lists, Liquid Glass on controls (toolbars, buttons), never on content.
- Font: SF Pro Rounded (`.fontDesign(.rounded)`). SF Symbols for icons.
- Colors: plum `#6E3B5C` (primary), cream `#F6ECE4` (secondary), warm background `#FBF7F3`, text `#2A1F26`, secondary text `#6F5F68`.
- The counter number stays solid and high-contrast (audience skews older, ~58 avg). Tap targets ≥ 44pt. Dynamic Type supported.
- Icon: one-line loop (single cream thread looping on plum). No mascot.
- Launch: the loop draws itself (`.trim` animation), ~1.2s, every launch. Native SwiftUI animation only, no Rive in v1.
- Light mode first. Dark mode handled during the build, not in mockups.

## Code style (Aryan's rules)

- Write code the way Aryan would write it: plain, spelled-out, easy to follow. No clever one-liners, chained tricks, or "senior" architecture.
- Apple's standard way first: plain SwiftUI + SwiftData, no extra libraries beyond RevenueCat (and TelemetryDeck later).
- Small views with obvious names. Clear `if`/`else`, simple loops.
- Comments: one short line on what a part does (`// Add a round and reset stitches`). Never 1–2 sentence explanations, never on styling lines.
- One-line header comment at the top of each file saying what it's for.
- Some code can't be simple (Live Activity, App Intents, RevenueCat, SwiftData relationships). Keep it in its own file and mark it with a short comment like `// Apple's required Live Activity setup`.

## Project setup

- Xcode project at the repo root, target `Itomi`, bundle `com.aryan.Itomi`.
- iPhone only, iOS 26 minimum, portrait only. Display name Itomi.
- Storage: SwiftData (added by hand, no template sample code).
- Repo: https://github.com/imAryanL/Itomi (private).

## Workflow

- Each session has one goal from `docs/PLAN.md`. Say it at the start, Aryan approves, build it, show it working in the simulator, then tick it off in the plan.
- Commits: only for meaningful work, never tiny setting tweaks (roll those into the next real commit). Show the message first, 5–6 short bullets in Aryan's voice, and ask before committing. Never add a `Co-Authored-By` line.
- Roles: the main session is the engineer (Opus, high effort). Subagents in `.claude/agents/` are checkers only: `code-reviewer` (read-only, Sonnet) runs only on the risky milestones: 1 (data model), 4 (counter), 8 (purchases) and 10 (Lock Screen counter). Medium effort for 4, high for 1, 8 and 10. `qa-tester` (Sonnet, low effort; Aryan also tests flows himself) builds, runs and taps through the simulator after the reviewer, once a milestone has screens to test. No agent teams. Say before running one.
- End of session (when Aryan says "wrap up"): tick finished boxes and add a dated log entry in `docs/PLAN.md`, update this file only if a rule or decision changed, and update the Itomi memory notes.
- Research behind the product: `~/Desktop/reports/Crochet iOS app market research.md`.
