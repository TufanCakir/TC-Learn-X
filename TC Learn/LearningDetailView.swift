import SwiftUI

struct LearningDetailView: View {
    let topic: LearningTopic
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header
                LinearGradient(
                    colors: topic.colors.backgroundColors.map { Color(hex: $0) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(topic.title)
                            .font(.title.bold())
                            .foregroundColor(Color(hex: topic.colors.textColors.first ?? "#FFFFFF"))
                            .shadow(radius: 4)
                            .padding()
                    },
                    alignment: .bottomLeading
                )
                .padding(.horizontal)
                .shadow(radius: 5)
                
                // MARK: - Beschreibung
                if !topic.description.isEmpty {
                    Text(topic.description)
                        .font(.body)
                        .padding(.horizontal)
                }
                
                // MARK: - Schritte
                if !topic.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Schritte")
                            .font(.headline)
                        ForEach(topic.steps, id: \.self) { step in
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 14))
                                Text(step)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // MARK: - Code-Anzeige
                VStack(alignment: .leading, spacing: 8) {
                    Text("Code-Beispiel")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    CodeView(code: topic.code)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(
            (colorScheme == .dark ? Color.black : Color.white).ignoresSafeArea()
        )
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
