import SwiftUI
import StoreKit

enum AppAppearance: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Hell"
    case dark = "Dunkel"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.fill"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }
}

struct SettingsView: View {
    @Environment(\.requestReview) private var requestReview
    @AppStorage("appAppearance") private var appearanceRaw = AppAppearance.system.rawValue

    private var appearance: AppAppearance {
        get { AppAppearance(rawValue: appearanceRaw) ?? .system }
        set { appearanceRaw = newValue.rawValue }
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Darstellung
                Section {
                    Picker("App-Darstellung", selection: $appearanceRaw) {
                        ForEach(AppAppearance.allCases) { mode in
                            Label(mode.rawValue, systemImage: mode.icon)
                                .tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.inline)
                } header: {
                    Text("Darstellung")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                // MARK: - Feedback
                Section {
                    Button {
                        requestReview()
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("App bewerten (In-App)")
                                .foregroundColor(.primary)
                        }
                    }

                    Button {
                        openAppStoreReviewPage()
                    } label: {
                        HStack {
                            Image(systemName: "link")
                                .foregroundColor(.blue)
                            Text("Im App Store bewerten")
                                .foregroundColor(.primary)
                        }
                    }
                } header: {
                    Text("Feedback")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            .scrollContentBackground(.hidden) // moderner Look
            .background(
                LinearGradient(
                    colors: [.black.opacity(0.1), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("Einstellungen")
        }
        .preferredColorScheme(AppAppearance(rawValue: appearanceRaw)?.colorScheme)
    }

    // MARK: - App Store Review Page öffnen (Fallback)
    private func openAppStoreReviewPage() {
        let appID = "6753212783" // Deine echte App ID hier
        if let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsView()
}
