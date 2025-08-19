import AVFoundation

/// Lightweight wrapper around `AVSpeechSynthesizer` for Japanese output.
final class Speaker {
    private let synth = AVSpeechSynthesizer()

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        synth.speak(utterance)
    }
}

