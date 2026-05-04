// swiftlint:disable file_length
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
        fallbackValues[key] ?? key
    }

    static let fallbackValues: [String: String] = [
        "JB.Nav.Home": "Home", "JB.Nav.Lessons": "Lessons",
        "JB.Nav.Practice": "Practice", "JB.Nav.Review": "Review",
        "JB.Nav.Stats": "Stats", "JB.Nav.Settings": "Settings",
        "JB.Btn.ContinueLesson": "Continue", "JB.Btn.StartTrace": "Trace",
        "JB.Btn.StartReview": "Review", "JB.Btn.Speak": "Speak",
        "JB.Btn.Clear": "Clear", "JB.Btn.Hint": "Hint",
        "JB.Btn.Check": "Check", "JB.Btn.Play": "Play",
        "JB.Btn.Pause": "Pause", "JB.Btn.Hard": "Hard",
        "JB.Btn.Good": "Good", "JB.Btn.Easy": "Easy",
        "JB.Settings.Appearance": "Appearance", "JB.Settings.System": "System",
        "JB.Settings.Light": "Light", "JB.Settings.Dark": "Dark",
        "JB.Settings.ShowStrokeHints": "Show stroke hints", "JB.Settings.BackupRestore": "Backup & Restore",
        "JB.Settings.ExportDeck": "Export deck", "JB.Settings.ImportDeck": "Import deck",
        "JB.Settings.ImportComplete": "Import Complete", "JB.Settings.ImportFailed": "Import Failed",
        "JB.Settings.EnableReminder": "Enable reminder", "JB.Settings.Time": "Time",
        "JB.Settings.NewCards": "New", "JB.Settings.ReviewCards": "Review",
        "JB.Settings.Lessons": "Lessons", "JB.Settings.Profile": "Profile",
        "JB.Settings.Name": "Name", "JB.Settings.Reminders": "Reminders",
        "JB.Settings.Tracing": "Tracing", "JB.Settings.Audio": "Audio",
        "JB.Settings.PlaySpeechInSilentMode": "Play speech in silent mode",
        "JB.Settings.Theme": "Theme",
        "JB.Settings.Developer": "Developer",
        "JB.Settings.ResetOnboarding": "Reset onboarding",
        "JB.Settings.ResetOnboardingHint": "Shows the welcome flow on next launch",
        "JB.Common.Progress": "Progress",
        "JB.Common.PercentFmt": "%d percent",
        "JB.Common.CountProgressFmt": "%d of %d",
        "JB.Common.Hiragana": "Hiragana",
        "JB.Common.Katakana": "Katakana",
        "JB.Common.OK": "OK",
        "JB.Common.AppName": "JapaneseBuddy",
        "JB.Home.DailyGoal": "Daily Goal", "JB.Home.Greeting": "Hi, %@",
        "JB.Home.NextLesson": "Next lesson", "JB.Home.CourseProgress": "Course progress",
        "JB.Home.Deck": "Deck", "JB.Home.PencilOnly": "Pencil only",
        "JB.Home.DailyGoalProgress": "Daily goal progress",
        "JB.Home.DailyGoalComplete": "Goal complete",
        "JB.Home.QuickActions": "Quick Actions",
        "JB.Practice.Title": "Practice",
        "JB.Practice.Subtitle": "Keep today's lesson, tracing, and review in one rhythm.",
        "JB.Practice.Lesson": "Lesson", "JB.Practice.Trace": "Trace",
        "JB.Practice.Review": "Review", "JB.Practice.Start": "Start",
        "JB.Practice.DueFmt": "%d due", "JB.Practice.NoLesson": "Path complete",
        "JB.Review.AllCaughtUp": "All caught up",
        "JB.Review.TapToFlip": "Tap to flip",
        "JB.Review.DueFmt": "%d due",
        "JB.Review.Flip": "Flip",
        "JB.Review.SpeakCard": "Speak card",
        "JB.Review.FlipCard": "Flip card",
        "JB.Review.MarkHard": "Mark hard",
        "JB.Review.SchedulesSooner": "Schedules sooner",
        "JB.Review.MarkGood": "Mark good",
        "JB.Review.KeepsNormalPace": "Keeps normal pace",
        "JB.Review.MarkEasy": "Mark easy",
        "JB.Review.DelaysLonger": "Delays longer",
        "JB.Review.CardFront": "Card front",
        "JB.Review.CardBack": "Card back",
        "JB.Onboarding.Welcome": "Welcome",
        "JB.Onboarding.WelcomeText": "Build Japanese from zero with daily lessons, tracing, and review.",
        "JB.Onboarding.GetStarted": "Get Started",
        "JB.Onboarding.Continue": "Continue",
        "JB.Onboarding.PathTitle": "Follow the path",
        "JB.Onboarding.PathText": "Start with A1 basics, unlock A2 bridge lessons, then grow into B1 situations.",
        "JB.Onboarding.DeckTitle": "Pick your first deck",
        "JB.Onboarding.DeckText": "Begin with hiragana or katakana. You can switch any time.",
        "JB.Onboarding.Hiragana": "Hiragana",
        "JB.Onboarding.Katakana": "Katakana",
        "JB.Onboarding.TraceTitle": "Write with Pencil",
        "JB.Onboarding.TraceText": "Use stroke previews, hints, and checks to build muscle memory.",
        "JB.Onboarding.GoalsTitle": "Set a daily rhythm",
        "JB.Onboarding.GoalsText": "A good beginner day mixes new cards, reviews, and one lesson.",
        "JB.Onboarding.NameTitle": "Make it yours",
        "JB.Onboarding.NameText": "Add a name for a warmer home screen, or skip it.",
        "JB.Trace.NoCards": "No cards due", "JB.Trace.HideHint": "Hide hint",
        "JB.Trace.ShowHint": "Show hint", "JB.Trace.PlayPreview": "Play preview",
        "JB.Trace.PausePreview": "Pause preview", "JB.Trace.PreviewHint": "Preview stroke order",
        "JB.Trace.ClearDrawing": "Clear drawing", "JB.Trace.ClearHint": "Erases your strokes",
        "JB.Trace.SpeakCharacter": "Speak character", "JB.Trace.SpeakHint": "Plays pronunciation",
        "JB.Trace.CheckDrawing": "Check drawing", "JB.Trace.CheckHint": "Grades your tracing",
        "JB.Trace.CanvasFmt": "Tracing canvas for %@",
        "JB.Kanji.Title": "Kanji practice",
        "JB.Kanji.ProgressFmt": "%d of %d",
        "JB.Kanji.ReadingPlaceholder": "Type the reading",
        "JB.Kanji.SpeakKanji": "Speak kanji",
        "JB.Kanji.CheckReading": "Check reading",
        "JB.Kanji.Next": "Next",
        "JB.Kanji.Correct": "Correct!",
        "JB.Kanji.TryAgainFmt": "Try again. Reading: %@",
        "JB.Lessons.All": "All", "JB.Lessons.LevelA1": "A1 Foundation",
        "JB.Lessons.LevelA2": "A2 Bridge", "JB.Lessons.LevelB1": "B1 Intermediate",
        "JB.Lessons.LevelOther": "Other",
        "JB.Lessons.FoundationPathFmt": "%d foundation lessons",
        "JB.Lessons.BridgePathFmt": "%d bridge lessons",
        "JB.Lessons.IntermediatePathFmt": "%d intermediate lessons",
        "JB.Lessons.ExtraPathFmt": "%d extra lessons",
        "JB.Lessons.CompletedStarsFmt": "Completed with %d stars",
        "JB.Lessons.StepProgressFmt": "Step %d of %d",
        "JB.Lessons.Mode": "Mode",
        "JB.Lessons.LessonMode": "Lesson",
        "JB.Lessons.KanjiMode": "Kanji",
        "JB.Lessons.Step": "Step",
        "JB.Lessons.Filter": "Filter",
        "JB.Lessons.Back": "Back",
        "JB.Lessons.Objective": "Objective",
        "JB.Lessons.Shadow": "Shadow",
        "JB.Lessons.Listening": "Listening",
        "JB.Lessons.Reading": "Reading",
        "JB.Lessons.Check": "Check",
        "JB.Lessons.CanDoCheck": "Can-do Check",
        "JB.Lessons.Done": "Done",
        "JB.Lessons.StarRatingFmt": "%d stars",
        "JB.Lessons.PlaySegmentFmt": "Play segment %d",
        "JB.Lessons.CorrectChoice": "Correct",
        "JB.Lessons.TryAgainChoice": "Try again",
        "JB.Lessons.Next": "Next", "JB.Lessons.Open": "Open",
        "JB.Lessons.Locked": "Locked", "JB.Lessons.Completed": "Completed",
        "JB.Lessons.CompletePrevious": "Complete previous lesson",
        "JB.Lessons.CompleteTitle": "Lesson complete",
        "JB.Lessons.StartNext": "Start next lesson",
        "JB.Stats.StreakFmt": "Streak: %d", "JB.Stats.NoData": "No data",
        "JB.Stats.TodayMinutesFmt": "Today: %d min", "JB.Stats.WeekMinutesFmt": "Week: %d min",
        "JB.Stats.StreakBestFmt": "Best streak: %d",
        "JB.Stats.DayValueFmt": "Day %d, %d %@",
        "JB.Stats.MinutesUnit": "min",
        "JB.Stats.SessionsUnit": "sessions"
    ]

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
        static var home: String { localized("JB.Nav.Home") }; static var lessons: String { localized("JB.Nav.Lessons") }
        static var practice: String { localized("JB.Nav.Practice") }; static var review: String { localized("JB.Nav.Review") }
        static var stats: String { localized("JB.Nav.Stats") }; static var settings: String { localized("JB.Nav.Settings") }
    }
    enum Btn {
        static var continueLesson: String { localized("JB.Btn.ContinueLesson") }
        static var startTrace: String { localized("JB.Btn.StartTrace") }
        static var startReview: String { localized("JB.Btn.StartReview") }; static var speak: String { localized("JB.Btn.Speak") }
        static var clear: String { localized("JB.Btn.Clear") }; static var hint: String { localized("JB.Btn.Hint") }
        static var check: String { localized("JB.Btn.Check") }; static var play: String { localized("JB.Btn.Play") }
        static var pause: String { localized("JB.Btn.Pause") }; static var hard: String { localized("JB.Btn.Hard") }
        static var good: String { localized("JB.Btn.Good") }; static var easy: String { localized("JB.Btn.Easy") }
    }
    enum Settings {
        static var appearance: String { localized("JB.Settings.Appearance") }; static var system: String { localized("JB.Settings.System") }
        static var light: String { localized("JB.Settings.Light") }; static var dark: String { localized("JB.Settings.Dark") }
        static var showStrokeHints: String { localized("JB.Settings.ShowStrokeHints") }
        static var backupRestore: String { localized("JB.Settings.BackupRestore") }
        static var exportDeck: String { localized("JB.Settings.ExportDeck") }
        static var importDeck: String { localized("JB.Settings.ImportDeck") }
        static var importComplete: String { localized("JB.Settings.ImportComplete") }
        static var importFailed: String { localized("JB.Settings.ImportFailed") }
        static var enableReminder: String { localized("JB.Settings.EnableReminder") }
        static var time: String { localized("JB.Settings.Time") }; static var newCards: String { localized("JB.Settings.NewCards") }
        static var reviewCards: String { localized("JB.Settings.ReviewCards") }
        static var lessons: String { localized("JB.Settings.Lessons") }
        static var profile: String { localized("JB.Settings.Profile") }; static var name: String { localized("JB.Settings.Name") }
        static var reminders: String { localized("JB.Settings.Reminders") }; static var tracing: String { localized("JB.Settings.Tracing") }
        static var audio: String { localized("JB.Settings.Audio") }; static var theme: String { localized("JB.Settings.Theme") }
        static var playSpeechInSilentMode: String { localized("JB.Settings.PlaySpeechInSilentMode") }
        static var developer: String { localized("JB.Settings.Developer") }
        static var resetOnboarding: String { localized("JB.Settings.ResetOnboarding") }
        static var resetOnboardingHint: String { localized("JB.Settings.ResetOnboardingHint") }
    }
    enum Home {
        static var dailyGoal: String { localized("JB.Home.DailyGoal") }
        static var greeting: String { localized("JB.Home.Greeting") }
        static var nextLesson: String { localized("JB.Home.NextLesson") }
        static var courseProgress: String { localized("JB.Home.CourseProgress") }
        static var deck: String { localized("JB.Home.Deck") }
        static var pencilOnly: String { localized("JB.Home.PencilOnly") }
        static var dailyGoalProgress: String { localized("JB.Home.DailyGoalProgress") }
        static var dailyGoalComplete: String { localized("JB.Home.DailyGoalComplete") }
        static var quickActions: String { localized("JB.Home.QuickActions") }
    }
    enum Common {
        static var progress: String { localized("JB.Common.Progress") }
        static var percentFmt: String { localized("JB.Common.PercentFmt") }
        static var countProgressFmt: String { localized("JB.Common.CountProgressFmt") }
        static var hiragana: String { localized("JB.Common.Hiragana") }
        static var katakana: String { localized("JB.Common.Katakana") }
        static var okay: String { localized("JB.Common.OK") }
        static var appName: String { localized("JB.Common.AppName") }
    }
    enum Practice {
        static var title: String { localized("JB.Practice.Title") }; static var subtitle: String { localized("JB.Practice.Subtitle") }
        static var lesson: String { localized("JB.Practice.Lesson") }; static var trace: String { localized("JB.Practice.Trace") }
        static var review: String { localized("JB.Practice.Review") }; static var start: String { localized("JB.Practice.Start") }
        static var dueFmt: String { localized("JB.Practice.DueFmt") }; static var noLesson: String { localized("JB.Practice.NoLesson") }
    }
    enum Trace {
        static var noCards: String { localized("JB.Trace.NoCards") }
        static var hideHint: String { localized("JB.Trace.HideHint") }
        static var showHint: String { localized("JB.Trace.ShowHint") }
        static var playPreview: String { localized("JB.Trace.PlayPreview") }
        static var pausePreview: String { localized("JB.Trace.PausePreview") }
        static var previewHint: String { localized("JB.Trace.PreviewHint") }
        static var clearDrawing: String { localized("JB.Trace.ClearDrawing") }
        static var clearHint: String { localized("JB.Trace.ClearHint") }
        static var speakCharacter: String { localized("JB.Trace.SpeakCharacter") }
        static var speakHint: String { localized("JB.Trace.SpeakHint") }
        static var checkDrawing: String { localized("JB.Trace.CheckDrawing") }
        static var checkHint: String { localized("JB.Trace.CheckHint") }
        static var canvasFmt: String { localized("JB.Trace.CanvasFmt") }
    }
    enum Review {
        static var allCaughtUp: String { localized("JB.Review.AllCaughtUp") }
        static var tapToFlip: String { localized("JB.Review.TapToFlip") }
        static var dueFmt: String { localized("JB.Review.DueFmt") }; static var flip: String { localized("JB.Review.Flip") }
        static var speakCard: String { localized("JB.Review.SpeakCard") }; static var flipCard: String { localized("JB.Review.FlipCard") }
        static var markHard: String { localized("JB.Review.MarkHard") }
        static var schedulesSooner: String { localized("JB.Review.SchedulesSooner") }
        static var markGood: String { localized("JB.Review.MarkGood") }
        static var keepsNormalPace: String { localized("JB.Review.KeepsNormalPace") }
        static var markEasy: String { localized("JB.Review.MarkEasy") }
        static var delaysLonger: String { localized("JB.Review.DelaysLonger") }
        static var cardFront: String { localized("JB.Review.CardFront") }; static var cardBack: String { localized("JB.Review.CardBack") }
    }
    enum Onboarding {
        static var welcome: String { localized("JB.Onboarding.Welcome") }
        static var welcomeText: String { localized("JB.Onboarding.WelcomeText") }
        static var getStarted: String { localized("JB.Onboarding.GetStarted") }
        static var continueButton: String { localized("JB.Onboarding.Continue") }
        static var pathTitle: String { localized("JB.Onboarding.PathTitle") }
        static var pathText: String { localized("JB.Onboarding.PathText") }
        static var deckTitle: String { localized("JB.Onboarding.DeckTitle") }
        static var deckText: String { localized("JB.Onboarding.DeckText") }
        static var hiragana: String { localized("JB.Onboarding.Hiragana") }
        static var katakana: String { localized("JB.Onboarding.Katakana") }
        static var traceTitle: String { localized("JB.Onboarding.TraceTitle") }
        static var traceText: String { localized("JB.Onboarding.TraceText") }
        static var goalsTitle: String { localized("JB.Onboarding.GoalsTitle") }
        static var goalsText: String { localized("JB.Onboarding.GoalsText") }
        static var nameTitle: String { localized("JB.Onboarding.NameTitle") }
        static var nameText: String { localized("JB.Onboarding.NameText") }
    }
    enum Kanji {
        static var title: String { localized("JB.Kanji.Title") }
        static var progressFmt: String { localized("JB.Kanji.ProgressFmt") }
        static var readingPlaceholder: String { localized("JB.Kanji.ReadingPlaceholder") }
        static var speakKanji: String { localized("JB.Kanji.SpeakKanji") }
        static var checkReading: String { localized("JB.Kanji.CheckReading") }
        static var next: String { localized("JB.Kanji.Next") }
        static var correct: String { localized("JB.Kanji.Correct") }
        static var tryAgainFmt: String { localized("JB.Kanji.TryAgainFmt") }
    }
    enum Lessons {
        static var all: String { localized("JB.Lessons.All") }
        static var levelA1: String { localized("JB.Lessons.LevelA1") }
        static var levelA2: String { localized("JB.Lessons.LevelA2") }
        static var levelB1: String { localized("JB.Lessons.LevelB1") }
        static var levelOther: String { localized("JB.Lessons.LevelOther") }
        static var foundationPathFmt: String { localized("JB.Lessons.FoundationPathFmt") }
        static var bridgePathFmt: String { localized("JB.Lessons.BridgePathFmt") }
        static var intermediatePathFmt: String { localized("JB.Lessons.IntermediatePathFmt") }
        static var extraPathFmt: String { localized("JB.Lessons.ExtraPathFmt") }
        static var completedStarsFmt: String { localized("JB.Lessons.CompletedStarsFmt") }
        static var stepProgressFmt: String { localized("JB.Lessons.StepProgressFmt") }
        static var mode: String { localized("JB.Lessons.Mode") }
        static var lessonMode: String { localized("JB.Lessons.LessonMode") }
        static var kanjiMode: String { localized("JB.Lessons.KanjiMode") }
        static var step: String { localized("JB.Lessons.Step") }
        static var filter: String { localized("JB.Lessons.Filter") }
        static var back: String { localized("JB.Lessons.Back") }
        static var objective: String { localized("JB.Lessons.Objective") }
        static var shadow: String { localized("JB.Lessons.Shadow") }
        static var listening: String { localized("JB.Lessons.Listening") }
        static var reading: String { localized("JB.Lessons.Reading") }
        static var check: String { localized("JB.Lessons.Check") }
        static var canDoCheck: String { localized("JB.Lessons.CanDoCheck") }
        static var done: String { localized("JB.Lessons.Done") }
        static var starRatingFmt: String { localized("JB.Lessons.StarRatingFmt") }
        static var playSegmentFmt: String { localized("JB.Lessons.PlaySegmentFmt") }
        static var correctChoice: String { localized("JB.Lessons.CorrectChoice") }
        static var tryAgainChoice: String { localized("JB.Lessons.TryAgainChoice") }
        static var next: String { localized("JB.Lessons.Next") }
        static var open: String { localized("JB.Lessons.Open") }
        static var locked: String { localized("JB.Lessons.Locked") }
        static var completed: String { localized("JB.Lessons.Completed") }
        static var completePrevious: String { localized("JB.Lessons.CompletePrevious") }
        static var completeTitle: String { localized("JB.Lessons.CompleteTitle") }
        static var startNext: String { localized("JB.Lessons.StartNext") }
    }
    enum Stats {
        static var streakFmt: String { localized("JB.Stats.StreakFmt") }; static var noData: String { localized("JB.Stats.NoData") }
        static var todayMinutesFmt: String { localized("JB.Stats.TodayMinutesFmt") }
        static var weekMinutesFmt: String { localized("JB.Stats.WeekMinutesFmt") }
        static var streakBestFmt: String { localized("JB.Stats.StreakBestFmt") }
        static var dayValueFmt: String { localized("JB.Stats.DayValueFmt") }
        static var minutesUnit: String { localized("JB.Stats.MinutesUnit") }
        static var sessionsUnit: String { localized("JB.Stats.SessionsUnit") }
    }
}
