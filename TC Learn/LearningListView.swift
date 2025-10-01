import SwiftUI
import StoreKit

struct LearningListView: View {
    // MARK: - Daten
    @State private var topics = loadLearningTopics()
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @State private var categories: [String] = []
    @State private var selectedCategory: String = "Alle"

    @State private var themes: [LearnTheme] = loadLearnThemes()
    @AppStorage("selectedThemeIndex") private var selectedThemeIndex = 0
    @AppStorage("favoriteIDs") private var favoriteIDs = ""
    @AppStorage("appLaunchCount") private var launchCount = 0

    // MARK: - Hilfs-Properties
    private var favorites: Set<String> {
        Set(favoriteIDs.split(separator: ",").map(String.init))
    }

    private var currentTheme: LearnTheme? {
        themes.indices.contains(selectedThemeIndex) ? themes[selectedThemeIndex] : nil
    }

    private var filteredTopics: [LearningTopic] {
        topics.filter { topic in
            let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesCategory = selectedCategory == "Alle" || topic.category == selectedCategory
            let matchesSearch = search.isEmpty
                || topic.title.localizedCaseInsensitiveContains(search)
                || topic.description.localizedCaseInsensitiveContains(search)
            let matchesFavorites = !showFavoritesOnly || favorites.contains(topic.id)
            return matchesCategory && matchesSearch && matchesFavorites
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView
            NavigationStack {
                VStack(spacing: 12) {
                    searchBar
                    favoritesToggle
                    categoryTabs
                    contentList
                }
                .onAppear {
                    setupCategories()
                    increaseLaunchCountAndAskForReview()
                }
            }
        }
    }
}

// MARK: - UI Components
private extension LearningListView {
    var backgroundView: some View {
        Group {
            if let theme = currentTheme {
                theme.background.view().ignoresSafeArea()
            } else {
                Color(.systemBackground).ignoresSafeArea()
            }
        }
    }

    var searchBar: some View {
        TextField("Suche…", text: $searchText)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
    }

    var favoritesToggle: some View {
        Toggle(isOn: $showFavoritesOnly) {
            Label("Nur Favoriten anzeigen", systemImage: "heart.fill")
                .foregroundColor(currentTheme?.accent ?? .blue)
        }
        .padding(.horizontal)
    }

    var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        withAnimation(.spring()) { selectedCategory = category }
                    } label: {
                        HStack(spacing: 6) {
                            if let topic = topics.first(where: { $0.category == category }),
                               let icon = topic.categoryIcon {
                                let iconColor = Color(hex: topic.categoryIconColor ?? "#FFFFFF")
                                if icon.count == 1 {
                                    Text(icon).foregroundColor(iconColor)
                                } else {
                                    Image(systemName: icon).foregroundColor(iconColor)
                                }
                            }
                            Text(category)
                                .font(.subheadline.bold())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedCategory == category
                                    ? (currentTheme?.accent ?? .blue).opacity(0.85)
                                    : Color.secondary.opacity(0.2))
                        .foregroundColor(selectedCategory == category ? .white : .primary)
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
        .opacity(categories.count > 1 ? 1 : 0) // Tabs nur zeigen, wenn Kategorien existieren
    }

    @ViewBuilder
    var contentList: some View {
        if filteredTopics.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "tray")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                Text("Keine Inhalte gefunden")
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredTopics) { topic in
                        NavigationLink(destination: LearningDetailView(topic: topic)) {
                            LearningCard(topic: topic)
                                .background(currentTheme?.buttonBackground
                                            ?? Color(.secondarySystemBackground))
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Funktionen
private extension LearningListView {
    func setupCategories() {
        let unique = Set(topics.map { $0.category })
        categories = ["Alle"] + unique.sorted()
        if !categories.contains(selectedCategory) {
            selectedCategory = "Alle"
        }
    }

    func increaseLaunchCountAndAskForReview() {
        launchCount += 1
        if launchCount == 5 || launchCount % 10 == 0 { requestAppStoreReview() }
    }

    func requestAppStoreReview() {
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            if #available(iOS 18.0, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LearningListView()
}
