import SwiftUI

struct LearningCard: View {
    let topic: LearningTopic
    
    // Favoriten persistent speichern
    @AppStorage("favoriteIDs") private var favoriteIDs = ""
    @State private var showShareSheet = false
    
    private var favorites: Set<String> {
        Set(favoriteIDs.split(separator: ",").map(String.init))
    }
    
    private var primaryTextColor: Color {
        Color(hex: topic.colors.textColors.first ?? "#FFFFFF")
    }

    private var secondaryTextColor: Color {
        let hex = topic.colors.textColors.dropFirst().first ?? (topic.colors.textColors.first ?? "#FFFFFF")
        return Color(hex: hex).opacity(0.9)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: topic.colors.backgroundColors.map { Color(hex: $0) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
            
            if let icon = topic.icon {
                Text(icon)
                    .font(.largeTitle)
                    .padding([.top, .trailing])
            }

            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                Text(topic.title)
                    .font(.headline.bold())
                    .foregroundColor(primaryTextColor)
                    .lineLimit(2)
                Text(topic.description)
                    .font(.caption)
                    .foregroundColor(secondaryTextColor)
                    .lineLimit(2)
                
                HStack {
                    Button {
                        toggleFavorite()
                    } label: {
                        Label("Favorit", systemImage: favorites.contains(topic.id) ? "heart.fill" : "heart")
                            .font(.caption)
                            .foregroundColor(primaryTextColor)
                    }
                    
                    Spacer()
                    
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Teilen", systemImage: "square.and.arrow.up")
                            .font(.caption)
                            .foregroundColor(primaryTextColor)
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [topic.code])
        }
    }
    
    private func toggleFavorite() {
        var set = favorites
        if set.contains(topic.id) {
            set.remove(topic.id)
        } else {
            set.insert(topic.id)
        }
        favoriteIDs = set.joined(separator: ",")
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
