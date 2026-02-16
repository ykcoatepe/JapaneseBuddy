import SwiftUI
import PencilKit
import UIKit

/// Practice view for tracing kana characters.
struct KanaTraceView: View {
    @EnvironmentObject var store: DeckStore
    @Environment(\.scenePhase) private var scenePhase

    @State private var current: Card?
    @State private var canvas: PKCanvasView?
    @State private var showHint = true
    @State private var playing = false
    private let speaker = Speaker()

    var body: some View {
        GeometryReader { geo in
            let side = min(max(min(geo.size.width, geo.size.height) - 160, 420), 900)
            VStack(spacing: 24) {
                if let card = current {
                    Text(card.front).font(.largeTitle)
                    ZStack {
                        TraceCanvas(canvasView: $canvas, pencilOnly: store.pencilOnly)
                            .frame(width: side, height: side)
                            .background(RoundedRectangle(cornerRadius: 20).stroke(Color.secondary))
                        if showHint {
                            Text(card.front)
                                .font(.system(size: side * 0.75))
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        if store.showStrokeHints && !UIAccessibility.isReduceMotionEnabled {
                            StrokePreviewView(strokes: StrokeData.strokes(for: card.front), playing: $playing)
                                .frame(width: side, height: side)
                                .allowsHitTesting(false)
                                .id(card.front)
                        }
                    }
                } else {
                    Text("No cards due")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            store.beginStudy()
            next()
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .inactive, .background:
                store.endStudy(kind: .study)
            case .active:
                if current != nil { store.beginStudy() }
            @unknown default:
                break
            }
        }
        .onDisappear { store.endStudy(kind: .study) }
        .navigationTitle(L10n.Nav.practice)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
        .safeAreaInset(edge: .bottom) {
            if let card = current {
                HStack(spacing: Theme.Spacing.small) {
                    if store.showStrokeHints && !UIAccessibility.isReduceMotionEnabled {
                        JBButton(playing ? L10n.Btn.pause : L10n.Btn.play, kind: .secondary) { playing.toggle() }
                            .accessibilityLabel(playing ? "Pause preview" : "Play preview")
                            .accessibilityHint("Preview stroke order")
                    }
                    JBButton(L10n.Btn.clear, kind: .secondary) { canvas?.drawing = PKDrawing() }
                        .accessibilityLabel("Clear drawing")
                        .accessibilityHint("Erases your strokes")
                    JBButton(showHint ? "Hide" : L10n.Btn.hint, kind: .secondary) { showHint.toggle() }
                        .accessibilityLabel(showHint ? "Hide hint" : "Show hint")
                    JBButton(L10n.Btn.speak, kind: .secondary) { speaker.speak(card.front) }
                        .accessibilityLabel("Speak character")
                        .accessibilityHint("Plays pronunciation")
                    JBButton(L10n.Btn.check) { check() }
                        .accessibilityLabel("Check drawing")
                        .accessibilityHint("Grades your tracing")
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
    }

    private func next() {
        current = store.dueCards(type: store.currentType).first
        canvas?.drawing = PKDrawing()
        showHint = true
        playing = false
    }

    private func check() {
        guard let card = current, let canvas else { return }
        let size = canvas.bounds.size
        let drawn = TraceEvaluator.snapshot(canvas, size: size)
        let template = TemplateRenderer.image(for: card.front, size: size)
        Task {
            let score = await Task.detached(priority: .background) {
                TraceEvaluator.overlapScore(drawing: drawn, template: template)
            }.value
            let strokeCount = canvas.drawing.strokes.count
            let expected = StrokeData.expectedCount(for: card.front)
            await MainActor.run {
                if score > 0.6 && strokeCount >= expected && strokeCount <= expected + 1 {
                    Log.app.log("trace pass for \(card.front)")
                    Haptics.light()
                    var updated = card
                    let wasNew = updated.interval == 0
                    SRS.apply(.good, to: &updated)
                    store.update(updated)
                    if wasNew { store.logNew(for: updated) }
                    next()
                } else {
                    Log.app.log("trace fail for \(card.front)")
                }
            }
        }
    }
}
