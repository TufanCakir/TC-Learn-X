import SwiftUI

// MARK: - Hintergrundtyp für Themes
enum ThemeBackground: Codable, Equatable {
    case solid(String)
    case linear([String])
    case radial([String])

    private enum CodingKeys: String, CodingKey { case type, colors }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = (try? c.decode(String.self, forKey: .type)) ?? "solid"
        let colors = (try? c.decode([String].self, forKey: .colors)) ?? ["#FFFFFF"]

        switch type.lowercased() {
        case "linear": self = .linear(colors)
        case "radial": self = .radial(colors)
        default:       self = .solid(colors.first ?? "#FFFFFF")
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .solid(let hex):
            try c.encode("solid", forKey: .type)
            try c.encode([hex], forKey: .colors)
        case .linear(let list):
            try c.encode("linear", forKey: .type)
            try c.encode(list, forKey: .colors)
        case .radial(let list):
            try c.encode("radial", forKey: .type)
            try c.encode(list, forKey: .colors)
        }
    }

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .solid(let hex):
            Color(hex: hex)
        case .linear(let list):
            LinearGradient(
                colors: list.map { Color(hex: $0) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .radial(let list):
            RadialGradient(
                colors: list.map { Color(hex: $0) },
                center: .center,
                startRadius: 5,
                endRadius: 500
            )
        }
    }
}

// MARK: - Finale Theme-Struktur
struct LearnTheme: Identifiable, Equatable {
    let id: UUID
    var name: String
    var background: ThemeBackground
    var textHex: String
    var buttonBackgroundHex: String
    var buttonTextHex: String
    var accentHex: String

    var text: Color { Color(hex: textHex) }
    var buttonBackground: Color { Color(hex: buttonBackgroundHex) }
    var buttonText: Color { Color(hex: buttonTextHex) }
    var accent: Color { Color(hex: accentHex) }
}

// MARK: - Interne JSON-Struktur
private struct RawTheme: Decodable {
    let id: UUID?
    let name: String?
    let backgroundHex: String?
    let background: ThemeBackground?
    let textHex: String?
    let buttonBackgroundHex: String?
    let buttonTextHex: String?
    let accentHex: String?
}

// MARK: - Ladefunktion für Themes
func loadLearnThemes() -> [LearnTheme] {
    guard let url = Bundle.main.url(forResource: "LearnThemes", withExtension: "json") else {
        print("⚠️ LearnThemes.json nicht gefunden!")
        return []
    }
    print("✅ Themes-Datei gefunden: \(url.lastPathComponent)")

    guard let data = try? Data(contentsOf: url) else {
        print("⚠️ Konnte Themes-Daten nicht laden.")
        return []
    }

    do {
        let rawThemes = try JSONDecoder().decode([RawTheme].self, from: data)
        print("✅ \(rawThemes.count) Themes geladen.")
        return rawThemes.map { raw in
            LearnTheme(
                id: raw.id ?? UUID(),
                name: raw.name ?? "Standard",
                background: raw.background ?? .solid(raw.backgroundHex ?? "#FFFFFF"),
                textHex: raw.textHex ?? "#000000",
                buttonBackgroundHex: raw.buttonBackgroundHex ?? "#E0E0E0",
                buttonTextHex: raw.buttonTextHex ?? "#000000",
                accentHex: raw.accentHex ?? "#007AFF"
            )
        }
    } catch {
        print("⚠️ Fehler beim Dekodieren der Themes: \(error)")
        return []
    }
}



