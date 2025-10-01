import SwiftUI

struct CodeView: View {
    let code: String
    
    // Swift Keywords zum Highlighten
    private let keywords: [String] = [
        "import", "struct", "var", "let", "func", "return",
        "if", "else", "for", "in", "while", "class",
        "enum", "switch", "case", "default", "View", "body"
    ]
    
    @State private var showCopied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header mit Copy-Button
            HStack {
                Text("Swift Code")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                Spacer()
                Button {
                    UIPasteboard.general.string = code
                    withAnimation { showCopied = true }
                    // Meldung nach 1 Sekunde ausblenden
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation { showCopied = false }
                    }
                } label: {
                    Label("Kopieren", systemImage: "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Codeblock
            ScrollView(.horizontal, showsIndicators: false) {
                Text(makeHighlighted(code: code))
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .overlay(
            Group {
                if showCopied {
                    Text("✅ Kopiert")
                        .font(.caption2.bold())
                        .padding(6)
                        .background(.thinMaterial)
                        .cornerRadius(8)
                        .transition(.scale)
                        .padding(.top, 4)
                }
            },
            alignment: .topTrailing
        )
    }
    
    // MARK: - Syntax Highlighting
    private func makeHighlighted(code: String) -> AttributedString {
        var attr = AttributedString(code)
        
        // Keywords
        for keyword in keywords {
            let pattern = "\\b\(keyword)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let nsRange = NSRange(code.startIndex..<code.endIndex, in: code)
                let matches = regex.matches(in: code, range: nsRange)
                for match in matches {
                    if let swiftRange = Range(match.range, in: code),
                       let range = attr.range(of: String(code[swiftRange])) {
                        attr[range].foregroundColor = .blue
                        attr[range].font = .system(.body, design: .monospaced).bold()
                    }
                }
            }
        }
        
        // Kommentare
        if let regex = try? NSRegularExpression(pattern: "//.*") {
            let nsRange = NSRange(code.startIndex..<code.endIndex, in: code)
            for match in regex.matches(in: code, range: nsRange) {
                if let swiftRange = Range(match.range, in: code),
                   let range = attr.range(of: String(code[swiftRange])) {
                    attr[range].foregroundColor = .green
                }
            }
        }
        
        // Strings
        if let regex = try? NSRegularExpression(pattern: "\".*?\"") {
            let nsRange = NSRange(code.startIndex..<code.endIndex, in: code)
            for match in regex.matches(in: code, range: nsRange) {
                if let swiftRange = Range(match.range, in: code),
                   let range = attr.range(of: String(code[swiftRange])) {
                    attr[range].foregroundColor = .red
                }
            }
        }
        
        return attr
    }
}
