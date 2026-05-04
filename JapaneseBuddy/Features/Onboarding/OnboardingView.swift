import SwiftUI
import UIKit

struct OnboardingView: View {
    @EnvironmentObject var store: DeckStore
    @State private var tab = 0
    @State private var deckChoice: DeckOption = .hiragana
    @State private var newGoal = 5
    @State private var reviewGoal = 20
    @State private var lessonGoal = 1
    @State private var name = ""

    var body: some View {
        TabView(selection: $tab) {
            heroPage.tag(0)
            setupPage(icon: "map.fill", title: L10n.Onboarding.pathTitle, text: L10n.Onboarding.pathText) { tab = 2 }.tag(1)
            setupPage(icon: "rectangle.stack.fill", title: L10n.Onboarding.deckTitle, text: L10n.Onboarding.deckText) {
                Picker(L10n.Home.deck, selection: $deckChoice) {
                    Text(L10n.Onboarding.hiragana).tag(DeckOption.hiragana)
                    Text(L10n.Onboarding.katakana).tag(DeckOption.katakana)
                }
                .pickerStyle(.segmented)
            } action: { tab = 3 }
            .tag(2)
            setupPage(icon: "pencil.and.outline", title: L10n.Onboarding.traceTitle, text: L10n.Onboarding.traceText) { tab = 4 }
            .tag(3)
            setupPage(icon: "target", title: L10n.Onboarding.goalsTitle, text: L10n.Onboarding.goalsText) {
                VStack(spacing: Theme.Spacing.small) {
                    goalStepper(L10n.Settings.newCards, value: $newGoal, range: 0...50)
                    goalStepper(L10n.Settings.reviewCards, value: $reviewGoal, range: 0...200)
                    goalStepper(L10n.Settings.lessons, value: $lessonGoal, range: 0...10)
                }
            } action: { tab = 5 }
            .tag(4)
            setupPage(icon: "person.crop.circle", title: L10n.Onboarding.nameTitle, text: L10n.Onboarding.nameText) {
                TextField(L10n.Settings.name, text: $name)
                    .textContentType(.name)
                    .textFieldStyle(.roundedBorder)
            } action: { finish() }
            .tag(5)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
        .background(Color.washi.ignoresSafeArea())
    }

    private var heroPage: some View {
        GeometryReader { proxy in
            ZStack {
                if let hero = loadHeroImage() {
                    Image(uiImage: hero)
                        .resizable()
                        .scaledToFit()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .ignoresSafeArea()
                        .accessibilityLabel(L10n.Onboarding.welcome)
                } else {
                    Color.washi.ignoresSafeArea()
                }
                VStack(spacing: Theme.Spacing.medium) {
                    Spacer()
                    Typography.title(L10n.Onboarding.welcome)
                    Text(L10n.Onboarding.welcomeText)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    JBButton(L10n.Onboarding.getStarted) { tab = 1 }
                        .frame(maxWidth: 360)
                }
                .padding(Theme.Spacing.large)
            }
        }
    }

    private func setupPage<Content: View>(
        icon: String,
        title: String,
        text: String,
        @ViewBuilder content: () -> Content = { EmptyView() },
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: icon)
                .font(.system(size: 72))
                .foregroundStyle(Color.accentColor)
            VStack(spacing: Theme.Spacing.small) {
                Text(title).font(.title.bold())
                Text(text)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            content()
                .frame(maxWidth: 460)
            JBButton(tab == 5 ? L10n.Onboarding.getStarted : L10n.Onboarding.continueButton, action: action)
                .frame(maxWidth: 360)
        }
        .padding(Theme.Spacing.large)
        .frame(maxWidth: 760)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func goalStepper(_ title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        Stepper(value: value, in: range) {
            Text("\(title) \(value.wrappedValue)")
        }
        .accessibilityLabel(title)
        .accessibilityValue(String(value.wrappedValue))
    }

    private func loadHeroImage() -> UIImage? {
        let candidates: [(String, String?)] = [
            ("onboarding_hero", "png"),
            ("onboarding_hero", "jpg"),
            ("onboarding_hero", "jpeg"),
            ("wellcome_1", "png")
        ]
        for (name, ext) in candidates {
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "art"),
               let image = UIImage(contentsOfFile: url.path) {
                return image
            }
        }
        return nil
    }

    private func finish() {
        store.currentType = deckChoice.cardType
        store.dailyGoal = DailyGoal(newTarget: newGoal, reviewTarget: reviewGoal, lessonTarget: lessonGoal)
        store.displayName = name.isEmpty ? nil : name
        store.hasOnboarded = true
    }

    enum DeckOption: Hashable {
        case hiragana, katakana
        var cardType: CardType {
            switch self {
            case .hiragana: return .hiragana
            case .katakana: return .katakana
            }
        }
    }
}
