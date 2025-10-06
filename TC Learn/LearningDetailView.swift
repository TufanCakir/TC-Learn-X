import SwiftUI

struct LearningDetailView: View {
    let topic: LearningTopic
    @Environment(\.colorScheme) private var colorScheme
    
    // Dynamische Breite für iPad/iPhone
    private var maxContentWidth: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 600 : .infinity
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header
                LinearGradient(
                    colors: topic.colors.backgroundColors.map { Color(hex: $0) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 250 : 180)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(topic.title)
                            .font(.system(.title, design: .rounded).bold())
                            .minimumScaleFactor(0.7) // Text verkleinert sich bei langen Titeln
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
                        .lineSpacing(4)
                        .frame(maxWidth: maxContentWidth, alignment: .leading)
                        .padding(.horizontal)
                }
                
                // MARK: - Schritte
                if !topic.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Schritte")
                            .font(.headline)
                        ForEach(topic.steps, id: \.self) { step in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 16))
                                Text(step)
                                    .font(.subheadline)
                                    .fixedSize(horizontal: false, vertical: true) // Mehrzeilig
                            }
                        }
                    }
                    .frame(maxWidth: maxContentWidth, alignment: .leading)
                    .padding(.horizontal)
                }
                
                // MARK: - Code-Anzeige
                VStack(alignment: .leading, spacing: 8) {
                    Text("Code-Beispiel")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    CodeView(code: topic.code)
                        .frame(maxWidth: maxContentWidth)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity) // nutzt ganze Breite
        }
        .background(
            (colorScheme == .dark ? Color.black : Color.white).ignoresSafeArea()
        )
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
