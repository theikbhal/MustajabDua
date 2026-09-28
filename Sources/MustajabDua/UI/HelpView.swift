import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Help")
                    .font(.largeTitle.bold())

                Text("Mustajab ud Dua — Nawabi Nuskha")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(DuaText.arabic)
                    .font(.title2)
                    .environment(\.layoutDirection, .rightToLeft)
                Text(DuaText.transliteration)
                    .font(.callout.italic())
                    .foregroundStyle(.secondary)
                Text(DuaText.translation)
                    .font(.callout)
                    .foregroundStyle(.secondary)

                qa("What is the nuskha?",
                   "Read this dua 25 times — or 27 times — in one sitting after your prayers or at any fixed time of day. The name means “the recipe for having your dua answered”.")
                qa("What does the dua ask for?",
                   "Forgiveness for you and for every believing man and woman, and every Muslim man and woman — a broad, generous supplication.")
                qa("Which hadith is it from?",
                   DuaText.hadith + " It is also taught for someone who has passed away.")
                qa("How do I count?",
                   "Counter tab → press Space or Return, click the ring, or use the big Count 1 button. Escape (or −) undoes the last count; Reset clears today.")
                qa("25 or 27 — which is better?",
                   "Both are reported. Pick one and stay consistent: Settings → Target count → 25 or 27.")
                qa("Does the counter reset?",
                   "Yes — counts are stored per calendar day and roll over automatically at midnight. The streak counts consecutive completed days.")
                qa("Reminders?",
                   "One local notification each day at the time you choose (default 07:00). Toggle, change time, or send a test in Settings. Notifications stay on your Mac — no server, no account.")
                qa("Where is my data?",
                   "Local only, in this app's preferences on your Mac. Nothing is uploaded.")
                qa("Keyboard shortcuts?",
                   "Space / Return count · Escape undoes · ⌘1 Counter · ⌘2 History · ⌘3 Help · ⌘4 Settings.")
                qa("Onboarding again?",
                   "Settings → Show onboarding on next launch, then relaunch the app.")
                qa("How do I install / uninstall?",
                   "Run scripts/build_app.sh — it builds the app, copies it to /Applications and adds a Desktop shortcut. Uninstall: delete /Applications/MustajabDua.app and the Desktop shortcut. See docs/INSTALL.md.")
                qa("Is the app free and open source?",
                   "Yes — MIT licensed, source on GitHub at theikbhal/MustajabDua.")

                Text("Developed by Ikbhal · theikbhal@gmail.com")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .padding(22)
            .frame(maxWidth: 720, alignment: .leading)
        }
    }

    private func qa(_ q: String, _ a: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(q).font(.headline)
            Text(a).font(.subheadline).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 10))
    }
}
