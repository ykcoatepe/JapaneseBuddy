import SwiftUI

/// Plays each segment with Japanese TTS for shadowing practice.
struct ShadowingView: View {
    struct Segment: Identifiable { let id = UUID(); let text: String }
    let segments: [String]
    private let speaker = Speaker()

    var body: some View {
        let items = segments.map { Segment(text: $0) }
        return VStack(alignment: .leading, spacing: 16) {
            ForEach(items) { seg in
                HStack {
                    Text(seg.text)
                    Spacer()
                    Button {
                        speaker.speak(seg.text)
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

