import Foundation

private extension L10n {
    @inline(__always)
    static func localized(_ key: String) -> String {
        localizationBundle.localizedString(forKey: key, value: "", table: "Localized")
    }

    static var localizationBundle: Bundle {
        // Respect app-level language first, then fall back to device preferences.
        let orderedLanguages = Bundle.main.preferredLocalizations + NSLocale.preferredLanguages
        var seen = Set<String>()
        for language in orderedLanguages where seen.insert(language).inserted {
            if let bundle = preferredBundle(for: language) {
                return bundle
            }
        }
        return preferredBundle(for: "Base") ?? Bundle.main
    }

    static func preferredBundle(for language: String) -> Bundle? {
        if let path = Bundle.main.path(forResource: language, ofType: "lproj", inDirectory: "L10n"),
           let bundle = Bundle(path: path) {
            return bundle
        }

        let code = language.split(separator: "-").first.map(String.init)
        if let code,
           let path = Bundle.main.path(forResource: code, ofType: "lproj", inDirectory: "L10n"),
           let bundle = Bundle(path: path) {
            return bundle
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
        static var weekMinutesFmt: String { localized("JB.Stats.WeekMinutesFmt") }
        static var streakBestFmt: String { localized("JB.Stats.StreakBestFmt") }
    }
}
