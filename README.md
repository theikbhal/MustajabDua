# MustajabDua — Mustajab ud Dua (Nawabi Nuskha)

A tiny native macOS app that helps you read the mustajab dua **25 (or 27) times every day**, keeps your streak, and reminds you once a day with a local notification.

> **اللَّهُمَّ اغْفِرْ لِي وَلِلْمُؤْمِنِينَ وَالْمُؤْمِنَاتِ وَالْмُسْلِمِينَ وَالْمُسْلِمَاتِ**
>
> *Allahummaghfir lee wa lil mu'mineena wal mu'minaati wal muslimeena wal muslimaat.*
>
> “O Allah, forgive me and the believing men and believing women, and the Muslim men and Muslim women.”

## Features

- **Counter** — big progress ring, click or press `Space` once per recitation, `Esc` to undo, `Reset` to start the day over.
- **25 or 27** — switch target in Settings; both counts are reported in the hadith.
- **Daily push notification** — one local reminder a day at a time you choose (default `07:00`), with a test button.
- **Streak & stats** — current streak, completed days, all-time recitations; the counter rolls over automatically at midnight.
- **History** — last 14 days with per-day counts and completion marks.
- **Onboarding** — 4-page intro on first launch (what the nuskha is, how to count, reminder opt-in).
- **Help** — full Q&A inside the app (`⌘3`).
- **Local only** — nothing leaves your Mac. No account, no server, no analytics.

## Install

```bash
git clone https://github.com/theikbhal/MustajabDua.git
cd MustajabDua
scripts/build_app.sh
```

The script:

1. builds the Swift package in release mode,
2. assembles `build/MustajabDua.app` with an icon and `Info.plist`,
3. **moves it to `/Applications/MustajabDua.app`**,
4. **creates a Desktop shortcut** → `~/Desktop/MustajabDua`.

Build without installing:

```bash
scripts/build_app.sh --build-only   # then: open build/MustajabDua.app
```

Requires macOS 14+ and Xcode / Swift toolchain (`xcode-select --install`).

## Use

| Action | Shortcut |
| --- | --- |
| Count one recitation | `Space` / `Return` / click ring / “Count 1” |
| Undo last count | `Esc` |
| Counter · History · Help · Settings | `⌘1` · `⌘2` · `⌘3` · `⌘4` |

## Notifications

Settings → **Daily reminder**: toggle, pick the time, allow notifications, and send a test
notification. macOS schedules the reminder locally; the app never transmits anything.

If notifications don’t appear: **System Settings → Notifications → MustajabDua** → allow
alerts and sounds (and turn off Focus/Do Not Disturb).

## Uninstall

```bash
rm -rf /Applications/MustajabDua.app ~/Desktop/MustajabDua
defaults delete com.ikbhal.mustajabdua   # optional: forget counts & settings
```

## Docs

- [docs/help.md](docs/help.md) — in-app help content
- [docs/INSTALL.md](docs/INSTALL.md) — install, permissions, uninstall
- [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) — build, project layout, release flow

## Project layout

```
MustajabDua/
├── Package.swift              Swift package (executable target)
├── Sources/MustajabDua/
│   ├── MustajabDuaApp.swift    entry point, window, menu shortcuts
│   ├── AppState.swift          tabs + onboarding state
│   ├── DuaStore.swift          daily counts, target, streak (UserDefaults)
│   ├── NotificationManager.swift  one daily local reminder
│   ├── DuaText.swift           arabic / transliteration / translation
│   └── UI/                     Counter, History, Help, Settings, Onboarding, Root
├── Resources/AppIcon.png       generated icon
├── scripts/build_app.sh        build → .app → /Applications → Desktop shortcut
└── docs/                       help, install, development
```

## License

MIT © 2026 Ikbhal — theikbhal@gmail.com
