import SwiftUI
import PencilKit

// Responsive kana tracing view with dynamic template rendering
struct KanaTraceView: View {
    @EnvironmentObject var store: DeckStore

    @State private var current: Card?
    @State private var canvasRef: PKCanvasView?
    @State private var message = ""
    @State private var showHint = true

    var body: some View {
        GeometryReader { proxy in
            // Kare pano: 420–900 px arası, ekrana göre ayarlanır (11" ve 13" için ideal)
            let side = max(420, min(min(proxy.size.width, proxy.size.height) - 160, 900))
            let fontSize = side * 0.74

            VStack(spacing: 16) {
                if let card = current {
                    Text(card.front)
                        .font(.system(size: 48))
                        .padding(.top, 8)

                    ZStack {
                        Rectangle()
                            .fill(Color(white: 0.97))
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.quaternary))

                        TraceCanvas(canvasView: $canvasRef, pencilOnly: store.pencilOnly)
                            .frame(width: side, height: side)

                        if showHint {
                            Text(card.front)
                                .font(.system(size: fontSize, weight: .regular))
                                .foregroundStyle(.gray.opacity(0.25))
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(height: side)
                    .padding(.horizontal)

                    HStack(spacing: 12) {
                        Button("Kontrol Et") { check() }
                        Button(showHint ? "İpucunu Gizle" : "İpucunu Göster") { showHint.toggle() }
                    }

                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ProgressView().onAppear { pickNext() }
                }
            }
            .navigationTitle("Kana İzleme")
        }
        .onAppear { pickNext() }
    }

    private func pickNext() {
        current = store.dueCards(type: .kana).first
        canvasRef?.drawing = PKDrawing()
        message = "Şablonu izleyerek çizin."
        showHint = true
    }

    private func check() {
        guard let card = current, let canvas = canvasRef else { return }
        // Dinamik pano boyutunu canvas’tan al
        let size = canvas.bounds.size
        let drawn = TraceEvaluator.snapshot(canvas, size: size)
        let template = TemplateRenderer.image(for: card.front, size: size)
        let score = TraceEvaluator.overlapScore(drawing: drawn, template: template)
        if score >= 0.6 {
            var updated = card
            SRS.apply(.good, to: &updated)
            store.update(updated)
            message = "Başarılı (\(Int(score * 100))%). Sıradaki!"
            pickNext()
        } else {
            message = "Biraz daha dikkatli izleyin (\(Int(score * 100))%)."
        }
    }
}

// Preview stub (will not compile until DeckStore/Card/TraceCanvas exist)
#if DEBUG
struct KanaTraceView_Previews: PreviewProvider {
    static var previews: some View {
        KanaTraceView().environmentObject(DeckStore())
    }
}
#endif

