import Foundation

enum L10n {
    enum Nav {
        static var home: String { NSLocalizedString("JB.Nav.Home", comment: "") }
        static var lessons: String { NSLocalizedString("JB.Nav.Lessons", comment: "") }
        static var practice: String { NSLocalizedString("JB.Nav.Practice", comment: "") }
        static var review: String { NSLocalizedString("JB.Nav.Review", comment: "") }
        static var stats: String { NSLocalizedString("JB.Nav.Stats", comment: "") }
        static var settings: String { NSLocalizedString("JB.Nav.Settings", comment: "") }
    }
    enum Btn {
        static var continueLesson: String { NSLocalizedString("JB.Btn.ContinueLesson", comment: "") }
        static var startTrace: String { NSLocalizedString("JB.Btn.StartTrace", comment: "") }
        static var startReview: String { NSLocalizedString("JB.Btn.StartReview", comment: "") }
        static var speak: String { NSLocalizedString("JB.Btn.Speak", comment: "") }
        static var clear: String { NSLocalizedString("JB.Btn.Clear", comment: "") }
        static var hint: String { NSLocalizedString("JB.Btn.Hint", comment: "") }
        static var check: String { NSLocalizedString("JB.Btn.Check", comment: "") }
        static var play: String { NSLocalizedString("JB.Btn.Play", comment: "") }
        static var pause: String { NSLocalizedString("JB.Btn.Pause", comment: "") }
        static var hard: String { NSLocalizedString("JB.Btn.Hard", comment: "") }
        static var good: String { NSLocalizedString("JB.Btn.Good", comment: "") }
        static var easy: String { NSLocalizedString("JB.Btn.Easy", comment: "") }
    }
    enum Settings {
        static var appearance: String { NSLocalizedString("JB.Settings.Appearance", comment: "") }
        static var system: String { NSLocalizedString("JB.Settings.System", comment: "") }
        static var light: String { NSLocalizedString("JB.Settings.Light", comment: "") }
        static var dark: String { NSLocalizedString("JB.Settings.Dark", comment: "") }
        static var showStrokeHints: String { NSLocalizedString("JB.Settings.ShowStrokeHints", comment: "") }
        static var backupRestore: String { NSLocalizedString("JB.Settings.BackupRestore", comment: "") }
        static var exportDeck: String { NSLocalizedString("JB.Settings.ExportDeck", comment: "") }
        static var importDeck: String { NSLocalizedString("JB.Settings.ImportDeck", comment: "") }
        static var enableReminder: String { NSLocalizedString("JB.Settings.EnableReminder", comment: "") }
        static var time: String { NSLocalizedString("JB.Settings.Time", comment: "") }
    }
    enum Home {
        static var dailyGoal: String { NSLocalizedString("JB.Home.DailyGoal", comment: "") }
        static var greeting: String { NSLocalizedString("JB.Home.Greeting", comment: "") }
    }
    enum Stats {
        static var streakFmt: String { NSLocalizedString("JB.Stats.StreakFmt", comment: "") }
    }
}
