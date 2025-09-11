import SwiftUI

/// Plays each segment with Japanese TTS for shadowing practice.
struct ShadowingView: View {
    struct Segment: Identifiable { let id = UUID(); let idx: Int; let text: String }
    let lessonID: String
    let segments: [String]
    private let speaker = Speaker()

    var body: some View {
        let items = segments.enumerated().map { Segment(idx: $0.offset + 1, text: $0.element) }
        return VStack(alignment: .leading, spacing: 16) {
            ForEach(items) { seg in
                HStack {
                    Text(seg.text)
                    Spacer()
                    Button {
                        speaker.playSegment(lessonID: lessonID, index: seg.idx, text: seg.text)
                    } label: {
                        Image(systemName: "play.circle").font(.title2)
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}
