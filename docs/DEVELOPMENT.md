# Development

Native macOS app written in Swift + SwiftUI, packaged as a Swift Package Manager executable and
bundled into a `.app` by a shell script — no Xcode project required.

## Everyday commands

```bash
swift build                 # debug build
swift run MustajabDua       # run from the terminal (window only, no bundle id)
scripts/build_app.sh --build-only   # release build + .app in build/
scripts/build_app.sh                # same, then install to /Applications + Desktop
open build/MustajabDua.app          # run the bundled app (notifications need the bundle)
```

> Notifications only work from a real app bundle (a stable `CFBundleIdentifier`). Use
> `scripts/build_app.sh --build-only` while developing notification behaviour.

## Layout

| Path | Role |
| --- | --- |
| `Package.swift` | executable target `MustajabDua`, macOS 14 |
| `Sources/MustajabDua/MustajabDuaApp.swift` | `@main`, window sizing, menu commands (`⌘1`–`⌘4`) |
| `AppState.swift` | sidebar tabs, onboarding show/hide (`onboarding.done`, `onboarding.repeat`) |
| `DuaStore.swift` | per-day counts (`dua.counts`), target (`dua.target`), streak, totals |
| `NotificationManager.swift` | authorization + one `UNCalendarNotificationTrigger` daily reminder |
| `DuaText.swift` | Arabic, transliteration, translation, hadith line |
| `UI/` | `RootView` (NavigationSplitView) + Counter, History, Help, Settings, Onboarding |
| `scripts/build_app.sh` | release build → `.app` → `/Applications` → Desktop symlink |
| `scripts/make_icon.swift` | renders `Resources/AppIcon.png` (gradient + SF Symbol) |
| `docs/` | help, install, this file |

## Data model

Everything lives in `UserDefaults` under `com.ikbhal.mustajabdua`:

- `dua.counts` — JSON `[ "yyyy-MM-dd": count ]`
- `dua.target` — `25` (default) or `27`
- `reminders.on` / `reminders.hour` / `reminders.minute`
- `onboarding.done` / `onboarding.repeat`

Day keys come from `DuaStore.dayKey(_:)` with `yyyy-MM-dd` in `en_US_POSIX`, so streak and
history survive timezone changes better than relative day indexes.

## Patterns used

- `@StateObject` for `AppState` + `DuaStore` at the app root, injected with `.environmentObject`.
- `NotificationManager.shared` singleton observed via `@ObservedObject` where needed.
- `NSEvent.addLocalMonitorForEvents` in `CounterView` for `Space`/`Return`/`Esc` counting keys
  (the monitor ignores keystrokes while a text field is editing).
- Counts are written through `didSet` → `persist()`, so every UI mutation is saved immediately.

## Release flow

1. Bump `VERSION` in `scripts/build_app.sh` and the About text in `UI/SettingsPane.swift`.
2. `scripts/build_app.sh` (rebuilds and reinstalls to `/Applications`).
3. `git add -A && git commit` → `gh repo create theikbhal/MustajabDua --public --source . --push`
   (or push to the existing remote).
4. Tag: `git tag v1.0.0 && git push --tags`.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `tabViewStyle(.page)` unavailable | macOS has no paged TabView — onboarding uses a custom pager instead |
| Notification never fires | run the app from a bundle, check System Settings → Notifications |
| Stale UI after midnight | counts are keyed by day; the window refreshes on scene activation |
| Old binary running | `pkill -x MustajabDua` before reinstalling |
