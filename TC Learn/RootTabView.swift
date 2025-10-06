import SwiftUI

struct RootTabView: View {
    // MARK: - App Settings
    @AppStorage("appAppearance") private var appearanceRaw = AppAppearance.system.rawValue

    // MARK: - Themes
    @State private var themes: [LearnTheme] = []
    @State private var selectedTheme: LearnTheme?
    @State private var isLoadingThemes = true

    // MARK: - Environment
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        TabView {
            // ✅ Tab 1: Lernen / Rechner
            NavigationStack {
                LearningListView()
            }
            .tabItem {
                Label("Lernen", systemImage: "pencil")
                    .font(.system(size: tabFontSize, weight: .semibold))
            }

            // ✅ Tab 2: Themes
            NavigationStack {
                if isLoadingThemes {
                    ProgressView("Lade Themes …")
                        .font(.system(size: tabFontSize))
                        .padding()
                } else {
                    ThemePickerScreen(themes: themes)
                }
            }
            .tabItem {
                Label("Themes", systemImage: "paintpalette.fill")
                    .font(.system(size: tabFontSize, weight: .semibold))
            }

            // ✅ Tab 3: Einstellungen
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Einstellungen", systemImage: "gear")
                    .font(.system(size: tabFontSize, weight: .semibold))
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
            self.selectedTheme = loaded.first
            self.isLoadingThemes = false
        }
    }
}

// MARK: - Dynamische Größen
private extension RootTabView {
    var tabFontSize: CGFloat {
        sizeClass == .regular ? 16 : 14
    }
}

#Preview {
    RootTabView()
}
