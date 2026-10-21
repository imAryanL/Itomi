# Itomi build plan

One milestone ≈ one session. Each ends with something Aryan can try in the simulator.
Tick a box when Aryan has seen it working.

## Phase 1: the free app

- [ ] **1. Foundation:** CLAUDE.md, `code-reviewer` subagent, SwiftData model (Project → Part → StitchTarget).
  *Done when:* a test project saves and is still there after closing the app.
- [ ] **2. Projects list:** home screen, empty state, New project sheet.
  *Done when:* you create "Bunny" and it shows up in the list.
- [ ] **3. Project detail + parts:** parts list, Add a part (×2 copies, rounds).
  *Done when:* Bunny has Head, Body and Ears ×2.
- [ ] **4. The counter:** big tap area, stitches, undo, haptics, keep screen on, part switcher.
  *Done when:* you count 10 rounds, close the app, and it's still on round 10.
- [ ] **5. Finishing:** finish screen, Finished shelf, project photos.
- [ ] **6. Brand + first launch:** SF Pro Rounded, colors, app icon, loop animation, onboarding.
- [ ] **7. Settings + backup/restore.**

**Checkpoint:** create `qa-tester` subagent, full test pass, TestFlight build on Aryan's iPhone.

## Phase 2: Pro

- [ ] **8. RevenueCat + paywall,** Pro unlocked screen, 2-project limit sheet.
- [ ] **9. Stitch targets,** "Fill in a sphere" helper, stitch warning.
- [ ] **10. Lock Screen / Dynamic Island counter** (Live Activity + App Intent).
- [ ] **11. Themes + app icons.** Pattern viewer only if there's time, else v1.1.

## Phase 3: ship

- [ ] **12. TelemetryDeck, privacy policy, App Store listing, screenshots, submit.**

## Log

- **Oct 20, 2026:** research, features, pricing, name, brand, 17 mockup screens + launch animation all approved. Xcode project created, private repo connected. CLAUDE.md and this plan written.
