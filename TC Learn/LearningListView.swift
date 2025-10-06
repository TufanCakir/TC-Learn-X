import StoreKit
import SwiftUI

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

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Hilfs-Properties
    private var favorites: Set<String> {
        Set(favoriteIDs.split(separator: ",").map(String.init))
    }

    private var currentTheme: LearnTheme? {
        themes.indices.contains(selectedThemeIndex)
            ? themes[selectedThemeIndex] : nil
    }

    private var filteredTopics: [LearningTopic] {
        topics.filter { topic in
            let search = searchText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            let matchesCategory =
                selectedCategory == "Alle" || topic.category == selectedCategory
            let matchesSearch =
                search.isEmpty
                || topic.title.localizedCaseInsensitiveContains(search)
                || topic.description.localizedCaseInsensitiveContains(search)
            let matchesFavorites =
                !showFavoritesOnly || favorites.contains(topic.id)
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
                .navigationTitle("TC Learn")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
}

// MARK: - UI Components
extension LearningListView {
    fileprivate var backgroundView: some View {
        Group {
            if let theme = currentTheme {
                theme.background.view().ignoresSafeArea()
            } else {
                Color(.systemBackground).ignoresSafeArea()
            }
        }
    }

    fileprivate var searchBar: some View {
        TextField("Suche…", text: $searchText)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, horizontalPadding)
            .font(.system(size: fontSizeBase))
    }

    fileprivate var favoritesToggle: some View {
        Toggle(isOn: $showFavoritesOnly) {
            Label("Nur Favoriten", systemImage: "heart.fill")
                .foregroundColor(currentTheme?.accent ?? .blue)
                .font(.system(size: fontSizeSmall))
        }
        .padding(.horizontal, horizontalPadding)
    }

    fileprivate var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        withAnimation(.spring()) { selectedCategory = category }
                    } label: {
                        HStack(spacing: 6) {
                            if let topic = topics.first(where: {
                                $0.category == category
                            }),
                                let icon = topic.categoryIcon
                            {
                                let iconColor = Color(
                                    hex: topic.categoryIconColor ?? "#FFFFFF"
                                )
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
                                .font(
                                    .system(size: fontSizeSmall, weight: .bold)
                                )
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            selectedCategory == category
                                ? (currentTheme?.accent ?? .blue).opacity(0.85)
                                : Color.secondary.opacity(0.2)
                        )
                        .foregroundColor(
                            selectedCategory == category ? .black : .white
                        )
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
        .opacity(categories.count > 1 ? 1 : 0)
    }

    @ViewBuilder
    fileprivate var contentList: some View {
        ScrollView {
            LazyVGrid(
                columns: gridLayout,
                spacing: 16
            ) {
                if filteredTopics.isEmpty {
                    // Platzhalter in eigenem Grid-Abschnitt
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text(
                            showFavoritesOnly
                                ? "Keine Favoriten gefunden"
                                : "Keine Inhalte gefunden"
                        )
                        .foregroundColor(.secondary)
                        .font(.system(size: fontSizeBase))
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                Color(.secondarySystemBackground).opacity(0.2)
                            )
                    )
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 20)
                } else {
                    ForEach(filteredTopics) { topic in
                        NavigationLink(
                            destination: LearningDetailView(topic: topic)
                        ) {
                            LearningCard(topic: topic)
                                .frame(maxWidth: .infinity)
                                .background(
                                    currentTheme?.buttonBackground
                                        ?? Color(.secondarySystemBackground)
                                )
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
    }

}

// MARK: - Dynamik & Layout
extension LearningListView {
    fileprivate var horizontalPadding: CGFloat {
        sizeClass == .regular ? 30 : 16
    }

    fileprivate var fontSizeBase: CGFloat {
        sizeClass == .regular ? 18 : 16
    }

    fileprivate var fontSizeSmall: CGFloat {
        sizeClass == .regular ? 16 : 14
    }

    fileprivate var gridLayout: [GridItem] {
        if sizeClass == .regular {
            return [GridItem(.adaptive(minimum: 300), spacing: 16)]
        } else {
            return [GridItem(.flexible())]
        }
    }
}

// MARK: - Funktionen
extension LearningListView {
    fileprivate func setupCategories() {
        let unique = Set(topics.map { $0.category })
        categories = ["Alle"] + unique.sorted()
        if !categories.contains(selectedCategory) {
            selectedCategory = "Alle"
        }
    }

    fileprivate func increaseLaunchCountAndAskForReview() {
        launchCount += 1
        if launchCount == 5 || launchCount % 10 == 0 { requestAppStoreReview() }
    }

    fileprivate func requestAppStoreReview() {
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        {
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
