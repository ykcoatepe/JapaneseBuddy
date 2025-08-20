import SwiftUI
import UIKit

struct OnboardingView: View {
    @EnvironmentObject var store: DeckStore
    @State private var tab = 0
    @State private var deckChoice: DeckOption = .hiragana
    @State private var newGoal = 5
    @State private var reviewGoal = 20
    @State private var name = ""

    var body: some View {
        TabView(selection: $tab) {
            VStack(spacing: 20) {
                if let hero = loadWelcomeImage() {
                    Image(uiImage: hero)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 260)
                        .accessibilityLabel("Welcome illustration")
                }
                Text("Welcome")
                    .font(.title)
                Text("Learn kana with a friendly SRS.")
                    .multilineTextAlignment(.center)
            }
            .tag(0)
            VStack(spacing: 20) {
                Text("Pick deck")
                Picker("Deck", selection: $deckChoice) {
                    Text("Hiragana").tag(DeckOption.hiragana)
                    Text("Katakana").tag(DeckOption.katakana)
                    Text("Both").tag(DeckOption.both)
                }
                .pickerStyle(.segmented)
            }
            .tag(1)
            VStack(spacing: 20) {
                Text("Tracing tips")
                Text("Pass with 60% overlap and right stroke count. Use Play to preview.")
                    .multilineTextAlignment(.center)
            }
            .tag(2)
            VStack(spacing: 20) {
                Text("Daily goals")
                Stepper("New \(newGoal)", value: $newGoal, in: 0...50)
                Stepper("Review \(reviewGoal)", value: $reviewGoal, in: 0...200)
            }
            .tag(3)
            VStack(spacing: 20) {
                Text("Your name (optional)")
                TextField("Name", text: $name)
                    .textContentType(.name)
                Button("Get Started") { finish() }
            }
            .tag(4)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page)
        .padding()
        .dynamicTypeSize(.xSmall ... .xxxLarge)
    }

    private func page(icon: String, title: String, text: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: icon).font(.system(size: 80))
            Text(title).font(.title)
            Text(text).multilineTextAlignment(.center)
        }
    }

    private func loadWelcomeImage() -> UIImage? {
        if let url = Bundle.main.url(forResource: "wellcome_1", withExtension: "png", subdirectory: "art") {
            return UIImage(contentsOfFile: url.path)
        }
        return nil
    }

    private func finish() {
        store.currentType = deckChoice.cardType
        store.dailyGoal = DailyGoal(newTarget: newGoal, reviewTarget: reviewGoal)
        store.displayName = name.isEmpty ? nil : name
        store.hasOnboarded = true
    }

    enum DeckOption: Hashable {
        case hiragana, katakana, both
        var cardType: CardType {
            switch self {
            case .hiragana: return .hiragana
            case .katakana: return .katakana
            case .both: return .hiragana
            }
        }
    }
}
