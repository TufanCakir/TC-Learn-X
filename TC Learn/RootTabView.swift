import SwiftUI

struct RootTabView: View {
    // MARK: - App Settings
    @AppStorage("appAppearance") private var appearanceRaw = AppAppearance.system.rawValue

    // MARK: - Themes
    @State private var themes: [LearnTheme] = []
    @State private var selectedTheme: LearnTheme?

    var body: some View {
        TabView {
            // ✅ Tab 1: Lernen / Rechner
            NavigationStack {
                LearningListView()
            }
            .tabItem {
                Label("Rechner", systemImage: "plus.slash.minus")
            }

            // ✅ Tab 2: Themes
            NavigationStack {
                if themes.isEmpty {
                    ProgressView("Lade Themes …")
                } else {
                    ThemePickerScreen(themes: themes)
                }
            }
            .tabItem {
                Label("Themes", systemImage: "paintpalette.fill")
            }

            // ✅ Tab 3: Einstellungen
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Einstellungen", systemImage: "gearshape.fill")
            }
        }
        .preferredColorScheme(AppAppearance(rawValue: appearanceRaw)?.colorScheme)
        .task {
            await loadThemes()
        }
    }

    // MARK: - Themes asynchron laden
    private func loadThemes() async {
        let loaded = loadLearnThemes()
        await MainActor.run {
            self.themes = loaded
            if selectedTheme == nil {
                self.selectedTheme = loaded.first
            }
        }
    }
}

#Preview {
    RootTabView()
}
