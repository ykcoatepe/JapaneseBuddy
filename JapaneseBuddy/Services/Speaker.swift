import AVFoundation

/// Lightweight wrapper around `AVSpeechSynthesizer` for Japanese output.
/// Configures the audio session to ensure speech plays even in Silent mode
/// and gracefully ducks other audio while speaking.
final class Speaker: NSObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    private let synth = AVSpeechSynthesizer()
    private static let audioQueue = DispatchQueue(label: "Speaker.AudioSession")
    private var deactivateWorkItem: DispatchWorkItem?
    private var sessionActive = false

    override init() {
        super.init()
        synth.delegate = self
}

// MARK: - Shadowing audio fallback
extension Speaker {
    // Plays a pre-recorded segment if bundled, otherwise falls back to TTS.
    func playSegment(lessonID: String, index: Int, text: String) {
        if let url = AudioEngine.shared.findAudio(lessonID: lessonID, index: index) {
            // Stop any ongoing TTS if needed (no-op if not speaking)
            synth.stopSpeaking(at: .immediate)
            AudioEngine.shared.play(url: url)
        } else {
            speak(text)
        }
    }
}
    @MainActor
    func speak(_ text: String) {
        let preferSilentOverride = (UserDefaults.standard.object(forKey: "playSpeechInSilentMode") as? Bool) ?? true
        let category: AVAudioSession.Category = preferSilentOverride ? .playback : .soloAmbient
        // For spoken content, use .spokenAudio with ducking
        let options: AVAudioSession.CategoryOptions = preferSilentOverride ? [.duckOthers] : [.duckOthers]
        Self.audioQueue.async { [weak self] in
            guard let self else { return }
            let session = AVAudioSession.sharedInstance()
            do {
                // Configure once if needed (safe to call repeatedly)
                try session.setCategory(category, mode: .spokenAudio, options: options)
                if !self.sessionActive {
                    try session.setActive(true, options: [])
                    self.sessionActive = true
                }
            } catch { }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                let utterance = AVSpeechUtterance(string: text)
                utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
                self.synth.speak(utterance)
            }
        }
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
        // debounce deactivation a bit; recheck speaking state before deactivating
        deactivateWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                guard !self.synth.isSpeaking else { return }
                Self.audioQueue.async { [weak self] in
                    guard let self else { return }
                    do {
                        try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
                        self.sessionActive = false
                    } catch { }
                }
            }
        }
        deactivateWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: work)
    }
}
