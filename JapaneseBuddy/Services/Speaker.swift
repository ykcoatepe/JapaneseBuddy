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

    @MainActor
    func speak(_ text: String) {
        // Prevent overlap: if local audio is playing, stop it before TTS.
        AudioEngine.shared.onPlaybackEnded = nil
        AudioEngine.shared.stop()
        let preferSilentOverride = (UserDefaults.standard.object(forKey: "playSpeechInSilentMode") as? Bool) ?? true
        let category: AVAudioSession.Category = preferSilentOverride ? .playback : .soloAmbient
        // For spoken content, use .spokenAudio with ducking
        let options: AVAudioSession.CategoryOptions = [.duckOthers]
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
                // If speech/local audio is still active, retry deactivation a bit later.
                guard !self.synth.isSpeaking && !AudioEngine.shared.isPlaying else {
                    self.deactivateSessionIfIdleMain()
                    return
                }
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

// MARK: - Shadowing audio fallback
extension Speaker {
    // Plays a pre-recorded segment if bundled, otherwise falls back to TTS.
    @MainActor
    func playSegment(lessonID: String, index: Int, text: String) {
        if let url = AudioEngine.shared.findAudio(lessonID: lessonID, index: index) {
            deactivateWorkItem?.cancel()
            deactivateWorkItem = nil
            // Stop any ongoing TTS if needed (no-op if not speaking)
            synth.stopSpeaking(at: .immediate)
            AudioEngine.shared.onPlaybackEnded = { [weak self] in
                self?.deactivateSessionIfIdleMain()
            }
            let played = AudioEngine.shared.play(url: url)
            guard played else {
                AudioEngine.shared.stop()
                speak(text)
                return
            }
        } else {
            // Ensure local audio is stopped before TTS fallback to avoid overlap.
            AudioEngine.shared.stop()
            speak(text)
        }
    }
}

// MARK: - Inlined dependencies to avoid project-file churn
final class AudioEngine: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioEngine()
    private var player: AVAudioPlayer?
    private(set) var isPlaying = false
    @MainActor var onPlaybackEnded: (() -> Void)?
    private var sessionCategory: AVAudioSession.Category {
        let playInSilentMode = (UserDefaults.standard.object(forKey: "playSpeechInSilentMode") as? Bool) ?? true
        return playInSilentMode ? .playback : .soloAmbient
    }

    private override init() {
        super.init()
        configureSessionCategory()
    }

    func play(url: URL) -> Bool {
        configureSessionCategory()
        stop()
        isPlaying = false
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            if player?.play() == true {
                isPlaying = true
                return true
            }
            player = nil
            isPlaying = false
            return false
        } catch {
            player = nil
            isPlaying = false
            return false
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        Task { @MainActor [weak self] in
            self?.onPlaybackEnded?()
        }
    }

    // Locate bundled audio with multiple bundle-safe fallbacks.
    func findAudio(lessonID: String, index: Int) -> URL? {
        let candidates = [
            "audio/\(lessonID)/seg-\(index).m4a",
            "Resources/audio/\(lessonID)/seg-\(index).m4a",
            "lessons/audio/\(lessonID)/seg-\(index).m4a"
        ]
        return candidates.compactMap { Bundle.main.url(forResource: $0, withExtension: nil) }.first
    }

    private func configureSessionCategory() {
        do {
            try AVAudioSession.sharedInstance().setCategory(sessionCategory)
        } catch {}
    }

    // MARK: - AVAudioPlayerDelegate
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        Task { @MainActor [weak self] in
            self?.onPlaybackEnded?()
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        isPlaying = false
        self.player = nil
        Task { @MainActor [weak self] in
            self?.onPlaybackEnded?()
        }
    }
}

private extension L10n {
    @inline(__always)
    static func localized(_ key: String) -> String {
        let value = localizationBundle.localizedString(forKey: key, value: "", table: "Localized")
        return value == key ? fallbackValue(for: key) : value
    }

    static func fallbackValue(for key: String) -> String {
        switch key {
        case "JB.Nav.Home": return "Home"
        case "JB.Nav.Lessons": return "Lessons"
        case "JB.Nav.Practice": return "Practice"
        case "JB.Nav.Review": return "Review"
        case "JB.Nav.Stats": return "Stats"
        case "JB.Nav.Settings": return "Settings"
        case "JB.Btn.ContinueLesson": return "Continue"
        case "JB.Btn.StartTrace": return "Trace"
        case "JB.Btn.StartReview": return "Review"
        case "JB.Btn.Speak": return "Speak"
        case "JB.Btn.Clear": return "Clear"
        case "JB.Btn.Hint": return "Hint"
        case "JB.Btn.Check": return "Check"
        case "JB.Btn.Play": return "Play"
        case "JB.Btn.Pause": return "Pause"
        case "JB.Btn.Hard": return "Hard"
        case "JB.Btn.Good": return "Good"
        case "JB.Btn.Easy": return "Easy"
        case "JB.Settings.Appearance": return "Appearance"
        case "JB.Settings.System": return "System"
        case "JB.Settings.Light": return "Light"
        case "JB.Settings.Dark": return "Dark"
        case "JB.Settings.ShowStrokeHints": return "Show stroke hints"
        case "JB.Settings.BackupRestore": return "Backup & Restore"
        case "JB.Settings.ExportDeck": return "Export deck"
        case "JB.Settings.ImportDeck": return "Import deck"
        case "JB.Settings.EnableReminder": return "Enable reminder"
        case "JB.Settings.Time": return "Time"
        case "JB.Home.DailyGoal": return "Daily Goal"
        case "JB.Home.Greeting": return "Hi, %@"
        case "JB.Stats.StreakFmt": return "Streak: %d"
        case "JB.Stats.NoData": return "No data"
        case "JB.Stats.TodayMinutesFmt": return "Today: %d min"
        case "JB.Stats.WeekMinutesFmt": return "Week: %d min"
        case "JB.Stats.StreakBestFmt": return "Best streak: %d"
        default: return key
        }
    }

    static var localizationBundle: Bundle {
        let orderedLanguages = NSLocale.preferredLanguages + Bundle.main.preferredLocalizations + ["Base"]
        var seen = Set<String>()
        for language in orderedLanguages where seen.insert(language).inserted {
            if let bundle = preferredBundle(for: language) {
                return bundle
            }
        }
        return preferredBundle(for: "Base") ?? Bundle.main
    }

    static func preferredBundle(for language: String) -> Bundle? {
        let l10nDirectories = ["L10n", "lessons/L10n"]
        let candidates = [language, language.split(separator: "-").first.map(String.init)].compactMap { $0 }

        for candidate in candidates {
            if let path = Bundle.main.path(forResource: candidate, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                return bundle
            }

            for directory in l10nDirectories {
                if let path = Bundle.main.path(forResource: candidate, ofType: "lproj", inDirectory: directory),
                   let bundle = Bundle(path: path) {
                    return bundle
                }
            }
        }
        return nil
    }
}

enum L10n {
    enum Nav {
        static var home: String { localized("JB.Nav.Home") }
        static var lessons: String { localized("JB.Nav.Lessons") }
        static var practice: String { localized("JB.Nav.Practice") }
        static var review: String { localized("JB.Nav.Review") }
        static var stats: String { localized("JB.Nav.Stats") }
        static var settings: String { localized("JB.Nav.Settings") }
    }
    enum Btn {
        static var continueLesson: String { localized("JB.Btn.ContinueLesson") }
        static var startTrace: String { localized("JB.Btn.StartTrace") }
        static var startReview: String { localized("JB.Btn.StartReview") }
        static var speak: String { localized("JB.Btn.Speak") }
        static var clear: String { localized("JB.Btn.Clear") }
        static var hint: String { localized("JB.Btn.Hint") }
        static var check: String { localized("JB.Btn.Check") }
        static var play: String { localized("JB.Btn.Play") }
        static var pause: String { localized("JB.Btn.Pause") }
        static var hard: String { localized("JB.Btn.Hard") }
        static var good: String { localized("JB.Btn.Good") }
        static var easy: String { localized("JB.Btn.Easy") }
    }
    enum Settings {
        static var appearance: String { localized("JB.Settings.Appearance") }
        static var system: String { localized("JB.Settings.System") }
        static var light: String { localized("JB.Settings.Light") }
        static var dark: String { localized("JB.Settings.Dark") }
        static var showStrokeHints: String { localized("JB.Settings.ShowStrokeHints") }
        static var backupRestore: String { localized("JB.Settings.BackupRestore") }
        static var exportDeck: String { localized("JB.Settings.ExportDeck") }
        static var importDeck: String { localized("JB.Settings.ImportDeck") }
        static var enableReminder: String { localized("JB.Settings.EnableReminder") }
        static var time: String { localized("JB.Settings.Time") }
    }
    enum Home {
        static var dailyGoal: String { localized("JB.Home.DailyGoal") }
        static var greeting: String { localized("JB.Home.Greeting") }
    }
    enum Stats {
        static var streakFmt: String { localized("JB.Stats.StreakFmt") }
        static var noData: String { localized("JB.Stats.NoData") }
        static var todayMinutesFmt: String { localized("JB.Stats.TodayMinutesFmt") }
        static var weekMinutesFmt: String { localized("JB.Stats.WeekMinutesFmt") }
        static var streakBestFmt: String { localized("JB.Stats.StreakBestFmt") }
    }
}
