import SwiftUI
import StoreKit

struct LearningListView: View {
    // MARK: - State
    @State private var topics: [LearningTopic] = []
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @State private var categories: [String] = []
    @State private var selectedCategory = "Alle"
    @State private var themes: [LearnTheme] = loadLearnThemes()

    // MARK: - Persistente App-Zustände
    @AppStorage("selectedThemeIndex") private var selectedThemeIndex = 0
    @AppStorage("favoriteIDs") private var favoriteIDs = ""
    @AppStorage("appLaunchCount") private var launchCount = 0

    // MARK: - Umgebungen
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Berechnete Eigenschaften
    private var favorites: Set<String> {
        Set(favoriteIDs.split(separator: ",").map(String.init))
    }

    private var currentTheme: LearnTheme? {
        themes[safe: selectedThemeIndex]
    }

    private var filteredTopics: [LearningTopic] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return topics.filter { topic in
            let matchesCategory = selectedCategory == "Alle" || topic.category == selectedCategory
            let matchesSearch = trimmedSearch.isEmpty ||
                topic.title.localizedCaseInsensitiveContains(trimmedSearch) ||
                topic.description.localizedCaseInsensitiveContains(trimmedSearch)
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
                .padding(.vertical, 8)
                .navigationTitle("Lerninhalte")
                .onAppear {
                    loadAllTopics()
                    setupCategories()
                    increaseLaunchCountAndAskForReview()
                }
            }
        }
    }
}

// MARK: - UI-Komponenten
private extension LearningListView {
    var backgroundView: some View {
        Group {
            if let theme = currentTheme {
                theme.background.view()
            } else {
                Color(.systemBackground)
            }
        }
        .ignoresSafeArea()
    }

    var searchBar: some View {
        TextField("Suche…", text: $searchText)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, horizontalPadding)
            .font(.system(size: fontSizeBase))
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
    }

    var favoritesToggle: some View {
        Toggle(isOn: $showFavoritesOnly) {
            Label("Nur Favoriten", systemImage: "heart.fill")
                .foregroundColor(currentTheme?.accent ?? .blue)
                .font(.system(size: fontSizeSmall))
        }
        .padding(.horizontal, horizontalPadding)
    }

    var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    categoryButton(for: category)
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
        .opacity(categories.count > 1 ? 1 : 0)
    }

    func categoryButton(for category: String) -> some View {
        let isSelected = selectedCategory == category
        let color = currentTheme?.accent ?? .blue

        return Button {
            withAnimation(.spring()) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 6) {
                if let topic = topics.first(where: { $0.category == category }),
                   let icon = topic.categoryIcon {
                    let iconColor = Color(hex: topic.categoryIconColor ?? "#FFFFFF")
                    if icon.count == 1 {
                        Text(icon)
                            .foregroundColor(iconColor)
                            .font(.system(size: fontSizeSmall))
                    } else {
                        Image(systemName: icon)
                            .foregroundColor(iconColor)
                            .font(.system(size: fontSizeSmall))
                    }
                }
                Text(category)
                    .font(.system(size: fontSizeSmall, weight: .bold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color.opacity(0.85) : Color.secondary.opacity(0.2))
            .foregroundColor(isSelected ? .black : .white)
            .cornerRadius(8)
            .contentShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    var contentList: some View {
        ScrollView {
            LazyVGrid(columns: gridLayout, spacing: 16) {
                if filteredTopics.isEmpty {
                    emptyPlaceholder
                } else {
                    ForEach(filteredTopics) { topic in
                        NavigationLink(destination: LearningDetailView(topic: topic)) {
                            LearningCard(topic: topic)
                                .background(currentTheme?.buttonBackground ?? Color(.secondarySystemBackground))
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
    }

    var emptyPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text(showFavoritesOnly ? "Keine Favoriten gefunden" : "Keine Inhalte gefunden")
                .foregroundColor(.secondary)
                .font(.system(size: fontSizeBase))
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground).opacity(0.2))
        )
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 20)
    }
}

// MARK: - Layout & Dynamik
private extension LearningListView {
    var horizontalPadding: CGFloat {
        sizeClass == .regular ? 30 : 16
    }

    var fontSizeBase: CGFloat {
        sizeClass == .regular ? 18 : 16
    }

    var fontSizeSmall: CGFloat {
        sizeClass == .regular ? 16 : 14
    }

    var gridLayout: [GridItem] {
        sizeClass == .regular
            ? [GridItem(.adaptive(minimum: 300), spacing: 16)]
            : [GridItem(.flexible())]
    }
}

// MARK: - Funktionen
private extension LearningListView {
    /// 🔥 Lädt alle Lernbereiche (Swift, Metal, Shader, App)
    func loadAllTopics() {
        let fileNames = [
            "learningTopics",
            "metalData",
            "metalShaderData",
            "metalAppData"
        ]

        // Alle JSON-Dateien kombinieren
        topics = fileNames.flatMap { loadLearningTopics(from: $0) }
    }

    func setupCategories() {
        let unique = Set(topics.map { $0.category })
        categories = ["Alle"] + unique.sorted()
        if !categories.contains(selectedCategory) {
            selectedCategory = "Alle"
        }
    }

    func increaseLaunchCountAndAskForReview() {
        launchCount += 1
        if launchCount == 5 || launchCount % 10 == 0 {
            requestAppStoreReview()
        }
    }

    func requestAppStoreReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else { return }

        if #available(iOS 18.0, *) {
            AppStore.requestReview(in: scene)
        } else {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

// MARK: - Safe Array Access
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview
#Preview {
    LearningListView()
}
