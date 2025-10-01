import SwiftUI

struct ThemePickerScreen: View {
    let themes: [LearnTheme]
    @AppStorage("selectedThemeIndex") private var selectedThemeIndex = 0  // ✅ NEU

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(themes.indices, id: \.self) { index in
                    let theme = themes[index]
                    themeCard(theme: theme, isSelected: index == selectedThemeIndex)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedThemeIndex = index  // ✅ schreibt den Index
                            }
                            Haptic.selection()
                        }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationTitle("Themes")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    private func themeCard(theme: LearnTheme, isSelected: Bool) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .background(theme.background.view().clipShape(RoundedRectangle(cornerRadius: 14)))
                .frame(height: 100)
                .overlay(
                    VStack(spacing: 4) {
                        Text("123")
                            .font(.caption2.monospacedDigit())
                            .foregroundColor(theme.text)
                        HStack(spacing: 4) {
                            Circle().fill(theme.buttonBackground).frame(width: 14, height: 14)
                            Circle().fill(theme.accent).frame(width: 14, height: 14)
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? theme.accent : .clear, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 3)

            Text(theme.name)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? theme.accent : .secondary)
                .lineLimit(1)
        }
    }
}

enum Haptic {
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
