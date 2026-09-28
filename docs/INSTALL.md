# Install, permissions, uninstall

## Requirements

- macOS 14 (Sonoma) or later
- Xcode command line tools / Swift toolchain: `xcode-select --install`

## Install (app → /Applications → Desktop)

```bash
git clone https://github.com/theikbhal/MustajabDua.git
cd MustajabDua
scripts/build_app.sh
```

What the script does, in order:

1. `swift build -c release` — compiles the package.
2. Generates `Resources/AppIcon.png` (first run only) and converts it to `AppIcon.icns`.
3. Assembles `build/MustajabDua.app` (`Contents/MacOS`, `Info.plist`, `PkgInfo`, icon).
4. Ad-hoc code signs the bundle (`codesign --force --deep --sign -`).
5. **Moves it into `/Applications/MustajabDua.app`.**
6. **Creates the Desktop shortcut:** `ln -sfn /Applications/MustajabDua.app ~/Desktop/MustajabDua`.

Build only, without touching `/Applications`:

```bash
scripts/build_app.sh --build-only
open build/MustajabDua.app
```

> The bundle id is `com.ikbhal.mustajabdua`, so macOS stores the app’s preferences, permission
> state and window frame under that domain.

## Permissions

| Permission | When it is asked | Why |
| --- | --- | --- |
| Notifications | Onboarding “Enable daily reminder”, or Settings → Allow notifications | One daily local reminder |

Nothing else is requested — the app uses no camera, microphone, contacts, files, or network.

If reminders never arrive:

1. **System Settings → Notifications → MustajabDua** → allow alerts + sounds.
2. Check **Focus / Do Not Disturb** is off for the scheduled time.
3. Settings → **Send test notification** (fires after 2 seconds).

Re-checking permission status: the app queries `UNUserNotificationCenter` on launch and when
the window becomes active.

## Launch at login / shortcut behaviour

- Desktop shortcut is a symlink to the app in `/Applications`, so it always opens the installed
  copy and keeps working after the app is updated (re-run the script).
- To make it start automatically: **System Settings → General → Login Items → +** →
  `MustajabDua`.

## Uninstall

```bash
rm -rf /Applications/MustajabDua.app ~/Desktop/MustajabDua
defaults delete com.ikbhal.mustajabdua    # optional: counts, streak, settings, permissions
build cleanup (optional): rm -rf build .build
```
