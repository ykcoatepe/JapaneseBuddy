import SwiftUI
import UIKit

struct OnboardingView: View {
    @EnvironmentObject var store: DeckStore
    @State private var tab = 0
    @State private var deckChoice: DeckOption = .hiragana
    @State private var newGoal = 5
    @State private var reviewGoal = 20
    @State private var name = ""
    @State private var debugHotspot = false

    var body: some View {
        TabView(selection: $tab) {
            // Full-screen hero with tappable "Get Started" hotspot
            GeometryReader { proxy in
                ZStack {
                    if let hero = loadHeroImage() {
                        Image(uiImage: hero)
                            .resizable()
                            .scaledToFit()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .ignoresSafeArea()
                            .accessibilityLabel("Welcome")

                        // Proportional hotspot overlay mapped to the image coordinate space
                        hotspotOverlay(in: proxy.size, imageSize: hero.size) {
                            finish()
                        }

                        if debugHotspot {
                            hotspotOverlay(in: proxy.size, imageSize: hero.size, debug: true) {}
                        }
                    } else {
                        // Fallback simple welcome if image missing
                        VStack(spacing: 16) {
                            Text("Welcome").font(.largeTitle).bold()
                            Button("Get Started") { finish() }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
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
        .dynamicTypeSize(.xSmall ... .xxxLarge)
    }

    private func page(icon: String, title: String, text: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: icon).font(.system(size: 80))
            Text(title).font(.title)
            Text(text).multilineTextAlignment(.center)
        }
        .padding()
    }

    // Load hero image. Prefers an asset named "onboarding_hero" from the art/ folder,
    // falls back to the existing wellcome_1.png if present.
    private func loadHeroImage() -> UIImage? {
        // Try onboarding_hero.* under art/
        let candidates: [(String, String?)] = [
            ("onboarding_hero", "png"),
            ("onboarding_hero", "jpg"),
            ("onboarding_hero", "jpeg"),
            ("wellcome_1", "png")
        ]
        for (name, ext) in candidates {
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "art"),
               let img = UIImage(contentsOfFile: url.path) {
                return img
            }
        }
        return nil
    }

    // Normalized hotspot rect where the "Get Started" appears on the image (0-1 in both axes).
    // Adjust these values to align with your artwork.
    private var heroHotspotNormalized: CGRect {
        // Default: centered near bottom; width 60%, height 12%
        CGRect(x: 0.20, y: 0.80, width: 0.60, height: 0.12)
    }

    // Overlay that maps the normalized hotspot to the actual displayed frame
    @ViewBuilder
    private func hotspotOverlay(in containerSize: CGSize, imageSize: CGSize, debug: Bool = false, action: @escaping () -> Void = {}) -> some View {
        let W = containerSize.width
        let H = containerSize.height
        let w = imageSize.width
        let h = imageSize.height
        // Aspect-fit: ensure the entire image is visible without cropping
        let scale = min(W / max(w, 1), H / max(h, 1))
        let displayedW = w * scale
        let displayedH = h * scale
        let offsetX = (W - displayedW) / 2
        let offsetY = (H - displayedH) / 2

        let r = heroHotspotNormalized
        let x = offsetX + r.origin.x * displayedW
        let y = offsetY + r.origin.y * displayedH
        let width = r.size.width * displayedW
        let height = r.size.height * displayedH

        Group {
            if debug {
                Rectangle()
                    .strokeBorder(Color.red.opacity(0.8), lineWidth: 2)
                    .background(Color.red.opacity(0.15))
            } else {
                Button(action: action) {
                    Color.clear
                }
                .accessibilityLabel("Get Started")
                .contentShape(Rectangle())
            }
        }
        .frame(width: width, height: height)
        .position(x: x + width / 2, y: y + height / 2)
        .allowsHitTesting(true)
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
