import SwiftUI

struct ThemePickerScreen: View {
    let themes: [LearnTheme]
    @AppStorage("selectedThemeIndex") private var selectedThemeIndex = 0

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridLayout, spacing: 16) {
                ForEach(themes.indices, id: \.self) { index in
                    let theme = themes[index]
                    themeCard(theme: theme, isSelected: index == selectedThemeIndex)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedThemeIndex = index
                            }
                            Haptic.selection()
                        }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 16)
        }
        .navigationTitle("Themes")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private func themeCard(theme: LearnTheme, isSelected: Bool) -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .background(theme.background.view().clipShape(RoundedRectangle(cornerRadius: 14)))
                .frame(height: cardHeight)
                .overlay(
                    VStack(spacing: 4) {
                        Text("123")
                            .font(.system(size: numberFontSize, weight: .regular, design: .monospaced))
                            .foregroundColor(theme.text)
                        HStack(spacing: 4) {
                            Circle().fill(theme.buttonBackground).frame(width: dotSize, height: dotSize)
                            Circle().fill(theme.accent).frame(width: dotSize, height: dotSize)
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? theme.accent : .clear, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 3)

            Text(theme.name)
                .font(.system(size: labelFontSize, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? theme.accent : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Dynamische Größen
private extension ThemePickerScreen {
    var horizontalPadding: CGFloat {
        sizeClass == .regular ? 30 : 16
    }

    var cardHeight: CGFloat {
        sizeClass == .regular ? 120 : 100
    }

    var numberFontSize: CGFloat {
        sizeClass == .regular ? 18 : 14
    }

    var labelFontSize: CGFloat {
        sizeClass == .regular ? 16 : 13
    }

    var dotSize: CGFloat {
        sizeClass == .regular ? 16 : 12
    }

    var gridLayout: [GridItem] {
        if sizeClass == .regular {
            // iPad oder Landscape → mehr Spalten
            return [GridItem(.adaptive(minimum: 220), spacing: 16)]
        } else {
            // iPhone → 2 Spalten
            return Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
        }
    }
}

// MARK: - Haptik
enum Haptic {
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
