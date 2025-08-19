import SwiftUI
import PencilKit

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
                        if store.showStrokeHints {
                            Button(playing ? "Pause" : "Play") { playing.toggle() }
                        }
                        Button("Clear") { canvas?.drawing = PKDrawing() }
                        Button(showHint ? "Hide" : "Hint") { showHint.toggle() }
                        Button("Speak") { speaker.speak(card.front) }
                        Button("Check") { check() }
                    }
                } else {
                    Text("No cards due")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear(perform: next)
        .navigationTitle("Trace")
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
        let score = TraceEvaluator.overlapScore(drawing: drawn, template: template)
        let strokeCount = canvas.drawing.strokes.count
        let expected = StrokeData.expectedCount(for: card.front)
        if score > 0.6 && strokeCount >= expected && strokeCount <= expected + 1 {
            var updated = card
            let wasNew = updated.interval == 0
            SRS.apply(.good, to: &updated)
            store.update(updated)
            if wasNew { store.logNew(for: updated) }
            next()
        }
    }
}

