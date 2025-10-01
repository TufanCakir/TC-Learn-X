import SwiftUI

extension Color {
    init(hex: String) {
        // 1️⃣ Alle nicht-hex Zeichen entfernen (#, Leerzeichen etc.)
        var cleaned = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        cleaned = cleaned.replacingOccurrences(of: "#", with: "")

        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch cleaned.count {
        case 3: // z.B. "F0A"
            // Verdoppeln jeder Stelle (F→FF)
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )
        case 6: // z.B. "FF9900"
            (a, r, g, b) = (
                255,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        case 8: // z.B. "80FF9900" (mit Alpha vorne)
            (a, r, g, b) = (
                int >> 24 & 0xFF,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        default:
            // Fallback: Rot anzeigen bei falschem Format
            (a, r, g, b) = (255, 255, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}
