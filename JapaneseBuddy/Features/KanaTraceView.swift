import SwiftUI
import PencilKit
import UIKit

/// Practice view for tracing kana characters.
struct KanaTraceView: View {
    @EnvironmentObject var store: DeckStore

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
                        if store.showStrokeHints {
                            StrokePreviewView(strokes: StrokeData.strokes(for: card.front), playing: $playing)
                                .frame(width: side, height: side)
                                .allowsHitTesting(false)
                                .id(card.front)
                        }
                    }
                    HStack(spacing: 16) {
                        if store.showStrokeHints && !UIAccessibility.isReduceMotionEnabled {
                            Button(playing ? "Pause" : "Play") { playing.toggle() }
                                .accessibilityLabel(playing ? "Pause preview" : "Play preview")
                                .accessibilityHint("Preview stroke order")
                        }
                        Button("Clear") { canvas?.drawing = PKDrawing() }
                            .accessibilityLabel("Clear drawing")
                            .accessibilityHint("Erases your strokes")
                        Button(showHint ? "Hide" : "Hint") { showHint.toggle() }
                            .accessibilityLabel(showHint ? "Hide hint" : "Show hint")
                        Button("Speak") { speaker.speak(card.front) }
                            .accessibilityLabel("Speak character")
                            .accessibilityHint("Plays pronunciation")
                        Button("Check") { check() }
                            .accessibilityLabel("Check drawing")
                            .accessibilityHint("Grades your tracing")
                    }
                } else {
                    Text("No cards due")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear(perform: next)
        .navigationTitle("Trace")
        .dynamicTypeSize(.xSmall ... .xxxLarge)
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
