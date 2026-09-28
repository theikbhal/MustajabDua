import SwiftUI

struct RootView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationSplitView {
            List(selection: $state.tab) {
                ForEach(AppState.Tab.allCases) { tab in
                    Label(tab.title, systemImage: tab.symbol).tag(tab)
                }
            }
            .navigationSplitViewColumnWidth(min: 170, ideal: 190)
            .listStyle(.sidebar)
        } detail: {
            switch state.tab {
            case .counter: CounterView()
            case .history: HistoryView()
            case .help: HelpView()
            case .settings: SettingsPane()
            }
        }
        .frame(minWidth: 720, minHeight: 520)
    }
}
