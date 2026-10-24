<p align="center">
  <img src="Itomi/Assets.xcassets/AppIcon.appiconset/AppIcon.png" width="120" alt="Itomi app icon" />
</p>

<h1 align="center">Itomi</h1>

<p align="center"><em>A calm row and stitch counter for crochet, made for amigurumi.</em></p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift" />
  <img src="https://img.shields.io/badge/SwiftUI-0D96F6?style=for-the-badge&logo=swift&logoColor=white" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/SwiftData-6E3B5C?style=for-the-badge&logo=swift&logoColor=white" alt="SwiftData" />
  <img src="https://img.shields.io/badge/iOS-26-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS 26" />
  <img src="https://img.shields.io/badge/App_Store-In_Review-0D96F6?style=for-the-badge&logo=app-store&logoColor=white" alt="App Store: in review" />
</p>

Itomi (ee-TOH-mee, "beautiful thread") is a row and stitch counter for crocheters and knitters. Split an amigurumi into parts like Head, Body and Ears ×2, count each one with a single tap, and always see which pieces are left. Every tap is saved right away, so you never lose your place, even after days away.

## Screenshots

<p align="center">
  <img src="docs/screenshots/1-counter.png" width="160" alt="Counter" />
  <img src="docs/screenshots/2-parts.png" width="160" alt="Parts" />
  <img src="docs/screenshots/3-lockscreen.png" width="160" alt="Lock Screen counter" />
  <img src="docs/screenshots/4-partdone.png" width="160" alt="Part done" />
</p>
<p align="center">
  <img src="docs/screenshots/5-stitchwarning.png" width="160" alt="Stitch warning" />
  <img src="docs/screenshots/6-home.png" width="160" alt="Home" />
  <img src="docs/screenshots/7-appearance.png" width="160" alt="Themes and icons" />
</p>

## Features

- [x] Projects with photo, hook or needle size, yarn and notes
- [x] Big tap-anywhere row/round counter, stitch counter and undo, saved after every tap
- [x] Parts (Head, Body, Ears ×2), each with its own counter
- [x] "Head done, next: Body" moment and a "Welcome back" note after time away
- [x] Assembly checklist (stuff, sew on, embroider the face), then a Finished shelf
- [x] Backup and restore, always free
- [x] Pro (yearly or lifetime): Lock Screen and Dynamic Island counter, Siri, Action Button and Control Center counting, stitch-count warnings, unlimited projects, themes and app icons, and "Make another"
- [x] No ads, no account

## Why I Built It

Most counter apps treat a project as one long list of rows. Amigurumi doesn't work that way: a bunny is a head, a body and two ears, each with its own rounds. I wanted a counter built around those parts, fully native in SwiftUI, and calm to use, with no ads and nothing in the way while you're counting.

## Tech Stack

| Layer | Technology |
|-------|------------|
| App | Swift, SwiftUI, iOS 26 |
| Local data | SwiftData |
| Lock Screen and Dynamic Island | ActivityKit (Live Activity) |
| Siri, Action Button, Control Center | App Intents, WidgetKit |
| Purchases | RevenueCat |
| Analytics | TelemetryDeck (anonymous) |

## Privacy Policy

[Privacy Policy](https://imaryanl.github.io/itomi-privacy)

## Contact

Built by **Aryan Lakhani**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/aryan-lakhani/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/imAryanL)
