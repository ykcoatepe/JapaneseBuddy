import AVFoundation

/// Lightweight wrapper around `AVSpeechSynthesizer` for Japanese output.
/// Configures the audio session to ensure speech plays even in Silent mode
/// and gracefully ducks other audio while speaking.
final class Speaker: NSObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    private let synth = AVSpeechSynthesizer()

    override init() {
        super.init()
        synth.delegate = self
    }

    @MainActor
    func speak(_ text: String) {
        // Prepare audio session. Choose category based on user preference.
        let session = AVAudioSession.sharedInstance()
        let preferSilentOverride = (UserDefaults.standard.object(forKey: "playSpeechInSilentMode") as? Bool) ?? true
        let category: AVAudioSession.Category = preferSilentOverride ? .playback : .soloAmbient
        let options: AVAudioSession.CategoryOptions = preferSilentOverride ? [.duckOthers] : []
        do {
            try session.setCategory(category, mode: .spokenAudio, options: options)
            try session.setActive(true, options: [])
        } catch {
            // If session setup fails, attempt to speak anyway.
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        synth.speak(utterance)
    }

    // MARK: - AVSpeechSynthesizerDelegate

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            self?.deactivateSessionIfIdleMain()
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            self?.deactivateSessionIfIdleMain()
        }
    }

    @MainActor
    private func deactivateSessionIfIdleMain() {
        guard !synth.isSpeaking else { return }
        do { try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation]) } catch { }
    }
}
