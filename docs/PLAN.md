# Itomi build plan

One milestone ≈ one session. Each ends with something Aryan can try in the simulator.
Tick a box when Aryan has seen it working.

## Phase 1: the free app

- [x] **1. Foundation:** CLAUDE.md, `code-reviewer` subagent, SwiftData model (Project → Part → StitchTarget).
  *Done when:* a test project saves and is still there after closing the app.
- [x] **2. Projects list:** home screen, empty state, New project sheet.
  *Done when:* you create "Bunny" and it shows up in the list.
- [x] **3. Project detail + parts:** parts list, Add a part (×2 copies, rounds).
  *Done when:* Bunny has Head, Body and Ears ×2.
- [x] **4. The counter:** big tap area, stitches, undo, haptics, keep screen on, part switcher.
  *Done when:* you count 10 rounds, close the app, and it's still on round 10.
- [x] **5. Finishing:** finish screen, Finished shelf, project photos.
- [x] **6. Brand + first launch:** SF Pro Rounded, colors, app icon, loop animation, onboarding.
- [x] **7. Settings + backup/restore.**

**Checkpoint:** create `qa-tester` subagent, full test pass, TestFlight build on Aryan's iPhone.
  *Status:* qa-tester pass done Oct 20 (all flows pass). Running on Aryan's iPhone 11 straight from Xcode (Oct 21). TestFlight waits until outside testers.
- [x] **7b. Amigurumi touches** (free, what sets Itomi apart):
  "Head done → next: Body" moment when a part hits its last round (loop draws itself, one tap to the next part);
  "Welcome back" line on the counter after a day or more away.
- [x] **7c. Assembly checklist** (free): when every part is done, a checklist of sewing-up steps (stuff, sew on, embroider face) shows before Finish. Steps editable per project.

## Phase 2: Pro

Decided Oct 21: full Pro at launch, so 8 through 11b all ship in 1.0. The paywall lists only features that are built.

- [ ] **8. RevenueCat + paywall,** Pro unlocked screen, 2-project limit sheet.
- [ ] **9. Stitch targets,** "Fill in a sphere" helper, stitch warning.
- [ ] **10. Lock Screen / Dynamic Island counter** (Live Activity + App Intent).
- [ ] **11. Themes + app icons.** Pattern viewer only if there's time, else v1.1.
  Idea (Oct 20): Aryan hand-draws alternate icons on the loop theme (double loop, etc.) as Pro icons.
- [ ] **11b. Make another** (Pro): on a finished project, one tap starts a fresh copy with the same parts, rounds and stitch targets, counters at zero.

## Phase 3: ship

- [ ] **12. TelemetryDeck, privacy policy, App Store listing, screenshots, submit.**

## Log

- **Oct 20, 2026:** research, features, pricing, name, brand, 17 mockup screens + launch animation all approved. Xcode project created, private repo connected. CLAUDE.md and this plan written.
- **Oct 20, 2026 (build session):** milestones 1–7 built and checked in the simulator, so the free app is done. Commits f45d314 (data model + docs) and 40a7710 (milestones 2–7), both pushed.
  - Decisions: Ears ×2 counts one copy at a time with a "Start Ears 2 of 2" button (counting is never blocked past planned rounds); undo survives closing (last 50 taps per part); onboarding's "Start counting" makes a simple one-counter project; restore adds missing projects and never deletes or duplicates; code-reviewer runs at medium; no tab bar for v1 (MVP).
  - Later: hand-drawn final icon (Aryan draws, Claude traces); launch-screen plum renders a bit lighter than the animation (#76385E vs #6E3B5C), fix with a darker launch color; no restore link in onboarding (new-phone restore needs a throwaway project first); finish screen says "Every round counted" even with unfinished parts.
  - Build note: use the newer Xcode (`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`); xcode-select still points at Xcode 26.6, which can't open the project.
  - Next: TestFlight on Aryan's iPhone, then milestone 8 (needs App Store Connect + RevenueCat accounts and final prices).
- **Oct 21, 2026 (UI polish session):** App Store Connect record made (bundle ID registered, Paid Apps agreement already active). App installed on Aryan's iPhone 11 from Xcode instead of TestFlight.
  - Built: haptics on every control (heavy for rounds, success for finishing), home screen redo (bold titles, 3-across Finished grid, hold menu with Edit / Back to In progress / Delete), Edit project sheet, new parts list (thick bars, Done pill, ×2 badge), bold section titles on every screen, medium text weight app-wide, bigger photo box, "Row 64" card for one-counter projects, "Up next: Ears" on the home screen.
  - Added `SampleData.swift`: launch a debug build with `-sampleData` to fill an empty simulator with fake projects (also for App Store screenshots later).
  - Decisions: positioning written into CLAUDE.md (made for amigurumi, never lose your place, calm); 2-project free limit kept for now, test with real crocheters on TestFlight before launch; the paywall never shows on the counter.
  - Next: 7b (Head done → next: Body), then milestone 8 (create the yearly + lifetime products in App Store Connect, pick the yearly price, RevenueCat account).

- **Oct 21–22, 2026 (amigurumi touches + store setup):** 7b and 7c built and checked in the simulator and on Aryan's iPhone 11. Commits 0886794 (7b) and 6c00b59 (7c), both pushed.
  - Built: "Head done → Next: Body" card (loop draws itself, tap guard, Reduce Motion fade, VoiceOver line); "Welcome back · Last counted 3 days ago" on the counter; free assembly checklist ("Put it together", 4 default steps, editable, in backups); Settings → Testing → Add sample projects (debug builds only); gentle "Finish Bunny? 3 parts aren't done yet" check in the ••• menu.
  - Fixed: part rows on the project page didn't open the counter (a haptic tap gesture swallowed the tap).
  - Store: App Store Connect has group "Itomi Pro", Pro Yearly `com.aryan.Itomi.pro.yearly` ($12.99, free first week, 175 countries) and Pro Lifetime `com.aryan.Itomi.pro.lifetime` ($29.99). RevenueCat has project "Itomi", app `com.aryan.Itomi` (reuses the Outerwinds purchase key), entitlement `itomi_pro`, offering `default` (yearly + lifetime, no monthly). Family Sharing left off.
  - Decisions: paywall at launch (weighed a free 1.0 and dropped it); full Pro at launch (8 through 11b); Make another is Pro (11b); assembly checklist is free; prices $12.99 / $29.99.
  - To do for Aryan: enroll in the Small Business Program (not enrolled, 15% vs 30%); add a card for the Feb 25, 2027 developer renewal.
  - Next: milestone 8 (RevenueCat package in Xcode, ProStore, paywall from the mockup at $12.99, limit sheet, Pro unlocked screen, StoreKit test file, code-reviewer).
