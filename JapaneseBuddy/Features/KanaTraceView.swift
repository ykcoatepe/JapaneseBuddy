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
            let side = canvasSide(for: geo.size)
            ScrollView {
                VStack(spacing: Theme.Spacing.large) {
                    if let card = current {
                        JBCard {
                            VStack(spacing: Theme.Spacing.medium) {
                                traceHeader(card)
                                ZStack {
                                    TraceCanvas(canvasView: $canvas, pencilOnly: store.pencilOnly)
                                        .frame(width: side, height: side)
                                        .background(RoundedRectangle(cornerRadius: 20).stroke(Color.secondary))
                                    if showHint {
                                        Text(card.front)
                                            .font(.system(size: side * 0.75))
                                            .foregroundColor(.gray.opacity(0.3))
                                            .accessibilityHidden(true)
                                    }
                                    if store.showStrokeHints && !UIAccessibility.isReduceMotionEnabled {
                                        StrokePreviewView(strokes: StrokeData.strokes(for: card.front), playing: $playing)
                                            .frame(width: side, height: side)
                                            .allowsHitTesting(false)
                                            .id(card.front)
                                    }
                                }
                                .accessibilityLabel(String(format: L10n.Trace.canvasFmt, card.front))
                                controls(for: card)
                            }
                        }
                    } else {
                        JBCard {
                            VStack(spacing: Theme.Spacing.small) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(Color.accentColor)
                                    .accessibilityHidden(true)
                                Text(L10n.Trace.noCards)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, minHeight: 220)
                        }
                    }
                }
                .frame(maxWidth: 980)
                .padding(Theme.Spacing.large)
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color.washi.ignoresSafeArea())
        .onAppear {
            next()
            if let current {
                store.beginStudy(for: current)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .inactive, .background:
                store.endStudy(kind: .study)
            case .active:
                if let current {
                    store.beginStudy(for: current)
                }
            @unknown default:
                break
            }
        }
        .onDisappear { store.endStudy(kind: .study) }
        .navigationTitle(L10n.Nav.practice)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
    }

    private func traceHeader(_ card: Card) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xsmall) {
                Text(card.front)
                    .font(.largeTitle.bold())
                Text(card.reading)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(deckTitle)
                .font(.caption.bold())
                .padding(.horizontal, Theme.Spacing.small)
                .padding(.vertical, Theme.Spacing.xsmall)
                .background(Color.accentColor.opacity(0.12), in: Capsule())
        }
    }

    private var deckTitle: String {
        switch store.currentType {
        case .hiragana: return L10n.Common.hiragana
        case .katakana: return L10n.Common.katakana
        case .vocab: return L10n.Practice.review
        }
    }

    private func controls(for card: Card) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: Theme.Spacing.small)], spacing: Theme.Spacing.small) {
            if store.showStrokeHints && !UIAccessibility.isReduceMotionEnabled {
                JBButton(playing ? L10n.Btn.pause : L10n.Btn.play, kind: .secondary) { playing.toggle() }
                    .accessibilityLabel(playing ? L10n.Trace.pausePreview : L10n.Trace.playPreview)
                    .accessibilityHint(L10n.Trace.previewHint)
            }
            JBButton(L10n.Btn.clear, kind: .secondary) { canvas?.drawing = PKDrawing() }
                .accessibilityLabel(L10n.Trace.clearDrawing)
                .accessibilityHint(L10n.Trace.clearHint)
            JBButton(showHint ? L10n.Trace.hideHint : L10n.Btn.hint, kind: .secondary) { showHint.toggle() }
                .accessibilityLabel(showHint ? L10n.Trace.hideHint : L10n.Trace.showHint)
            JBButton(L10n.Btn.speak, kind: .secondary) { speaker.speak(card.front) }
                .accessibilityLabel(L10n.Trace.speakCharacter)
                .accessibilityHint(L10n.Trace.speakHint)
            JBButton(L10n.Btn.check) { check() }
                .accessibilityLabel(L10n.Trace.checkDrawing)
                .accessibilityHint(L10n.Trace.checkHint)
        }
    }

    private func canvasSide(for size: CGSize) -> CGFloat {
        min(max(min(size.width - 64, size.height - 220), 320), 760)
    }

    private func next() {
        current = store.dueCards(type: store.currentType).first
        if let current {
            store.beginStudy(for: current)
        } else {
            store.endStudy(kind: .study)
        }
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
