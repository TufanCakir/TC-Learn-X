import Foundation


struct LearningTopic: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String?
    let steps: [String]
    let colors: ColorInfo
    let code: String
    let category: String     // 🔥 neu
    let categoryIcon: String? // ✅ neu
    let categoryIconColor: String? // ✅ neu

    
    struct ColorInfo: Codable {
        let backgroundColors: [String]
        let textColors: [String]
    }
}

func loadLearningTopics() -> [LearningTopic] {
    guard let url = Bundle.main.url(forResource: "learningTopics", withExtension: "json") else {
        print("⚠️ learningTopics.json nicht gefunden")
        return []
    }
    do {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([LearningTopic].self, from: data)
    } catch {
        print("⚠️ Fehler beim Dekodieren: \(error)")
        return []
    }
}
