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

- [x] **8. RevenueCat + paywall,** Pro unlocked screen, 2-project limit sheet.
- [x] **9. Stitch targets,** "Fill in a sphere" helper, stitch warning.
- [x] **10. Lock Screen / Dynamic Island counter** (Live Activity + App Intent), plus Siri, Action Button and a Control Center button.
  Home screen widgets: proposed for v1.1 (they need the saved data moved to a shared App Group folder); Aryan to confirm.
- [x] **11. Themes + app icons.** Six themes (Plum, Rose, Terracotta, Sage, Denim, Charcoal) and seven icons (same loop, theme colors + Cream). Pattern viewer moves to v1.1.
  Extra icon shapes (double loop, etc.) can be added later as more choices; Claude draws them, Aryan picks.
- [x] **11b. Make another** (Pro): on a finished project, one tap starts a fresh copy with the same parts, rounds and stitch targets, counters at zero.

## Phase 3: ship

- [ ] **12. TelemetryDeck, privacy policy, App Store listing, screenshots, submit.**
  *Done Oct 23:* privacy page (imaryanl.github.io/itomi-privacy), TelemetryDeck (9 signals), About section in Settings, Apple rating popup, full QA pass.
  *Done Oct 23 (evening):* listing drafted (`docs/app-store-listing.md`), 7 screenshots at 6.9" and 6.5" in `~/Desktop/Itomi App Store Screenshots/`, sandbox purchase passed on the iPhone 11 (Release build: $12.99 with the free week, $29.99, yearly bought with the sandbox account).
  *Submitted Oct 23, 11:15 PM:* version 1.0 (build 1) plus Itomi Pro group, Pro Yearly and Pro Lifetime, in one submission. Name "Itomi: Crochet & Knit Counter", 4+, free, all 175 countries, auto-release after approval. Privacy label: Purchases (App Functionality) and Product Interaction (Analytics), both not linked, no tracking.
  *Still to do:* wait for App Review (up to 48 hours), answer anything they ask.
  *Listing must include:* a Terms of Use link to Apple's standard EULA (required for subscriptions), privacy label "usage data, not linked to you".

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
- **Oct 22, 2026 (milestone 8):** RevenueCat package (5.97.0), ProStore, paywall, 2-project limit sheet, "You're Pro now", Pro row in Settings. Xcode builds use RevenueCat's Test Store (fake purchases, placeholder $79.99/$99.99); release builds use the App Store key. Tested in the simulator: failed, yearly and lifetime purchases, restore, Pro remembered after relaunch. code-reviewer (medium) found 4 must-fixes, all fixed (renewal text, trial only if eligible, double-tap guard, honest error text). Installed on Aryan's iPhone 11.
  - Before submitting: privacy page must exist (milestone 12; now at imaryanl.github.io/itomi-privacy, no domain); paywall lists features built in 9–11b.
  - Next: milestone 9 (stitch targets, "Fill in a sphere" helper, stitch warning).
- **Oct 22, 2026 (milestones 9, 10, 11, 11b, evening):** all of Pro for 1.0 is built. Commits 0376b8d (9), c11d176 (files into feature folders), 4e35f56 (10), b9c9f04 (Control Center), fda695a (11b), 6f313bb (11), all pushed.
  - Built: stitches per round in Add / Edit part with "Fill in a sphere" and a free locked row; amber stitch warning on the counter with Fix stitches (only when stitches were counted); Lock Screen card + Dynamic Island with + and Undo (new ItomiWidgets target, shared files in `SharedWithWidget/`); "Add a round" App Intent for Siri, Shortcuts, Action Button and a Control Center button; Pro-only "Counter on Lock Screen" switch; Make another on the Finished shelf ("Bunny 2"); Settings → Appearance with 6 themes and 7 app icons ("Match app icon", Cream icon).
  - Fixed: the stitch target now checks the round being worked on (currentRound + 1), not the last finished one.
  - Checks: code-reviewer (medium) on milestone 10 found no data-loss risk; fixed its points (no counting past a done part, only end this part's card, safer ending). qa-tester passed flows 1–4; its two "major" issues were test-tool problems (it edited the simulator's shared settings, and its quick taps can't flip iOS 26 switches).
  - Decisions: stitch warning doesn't block counting (Keep going / Fix stitches); Control Center button added as an "only Itomi has it" extra (no competitor has one); themes are muted yarn colors, not rainbow brights, every one at least 6:1 with white text; icons are the same loop in theme colors, no hand drawing needed.
  - Not tested yet: finishing a project while its card is up, Siri and the Action Button (try on the iPhone 11), dark mode with themes, stitch targets copying in Make another (sample data has none).
  - Open question: home screen widgets in v1.1 (recommended) or 1.0.
  - Next: install on the iPhone 11 and try it for real, then milestone 12 (TelemetryDeck, privacy policy, App Store listing, screenshots, submit). Idea to ask TestFlight testers: Apple Watch counter.

- **Oct 23, 2026 (iPhone test + milestone 12 start + QA):** tested on the iPhone 11, started milestone 12, full QA pass. Commits e7df834, e2fdc07, b01c676, 13b4688, all pushed.
  - Tested on the iPhone: Lock Screen card ends when a project finishes, Siri (after the name fix), dark mode with themes, Make another keeps stitch targets. Action Button can't be tested (iPhone 11 has none).
  - Built: paywall fits small phones and is centered on any screen; long names cut off with "…" (counter title, 2 lines on the project page); Siri alternate names (E Tommy, Eatomi, Itami); hook/needles choice in New/Edit project; Settings → About (Privacy Policy, Contact us, Rate Itomi); Pro row opens "You have Itomi Pro"; Apple rating popup after the first finish and after leaving the counter from 10+ rounds (once each).
  - Milestone 12: privacy page in public repo imAryanL/itomi-privacy (GitHub Pages, no domain); contact itomiapp@gmail.com (Gmail forwarding didn't take, Aryan added it to the Gmail app instead); TelemetryDeck free plan, org "Aryan Lakhani" (com.aryanlakhani), app Itomi, 9 anonymous signals in Analytics.swift; App Store Apple ID 6825188650.
  - QA fixed: Back up, Appearance (Pro) and Add photo rows ignored taps (haptic tap gesture on list rows, removed); onboarding title/subtitle clipped by the row corner; dark-mode theme colors too light for white text (now 5.5:1); delete question is a centered alert; PRO badge hidden for Pro users.
  - Testing tools (Xcode builds only): Settings → Testing → "Pretend I'm not Pro"; launch flag -showOnboarding.
  - Decisions: keep Backup (deleting the app wipes everything); no custom Terms (Apple's standard EULA, linked in the listing); rating never shows while counting.
  - Next (Oct 24): 1) icon drawing ideas: Claude mocks up new loop drawings (double loop, yarn ball, heart, hook through a loop), Aryan picks; 2) real prices on the paywall + sandbox purchase on the iPhone 11 (App Store key, sandbox Apple account); 3) App Store Connect: listing (draft first), screenshots, forms, submit. Small leftovers: launch-screen plum #76385E, finish screen "Every round counted" wording.
