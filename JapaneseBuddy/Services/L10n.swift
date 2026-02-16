import Foundation

enum L10n {
    enum Nav {
        static var home: String { NSLocalizedString("JB.Nav.Home", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var lessons: String { NSLocalizedString("JB.Nav.Lessons", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var practice: String { NSLocalizedString("JB.Nav.Practice", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var review: String { NSLocalizedString("JB.Nav.Review", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var stats: String { NSLocalizedString("JB.Nav.Stats", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var settings: String { NSLocalizedString("JB.Nav.Settings", tableName: "Localized", bundle: .main, value: "", comment: "") }
    }
    enum Btn {
        static var continueLesson: String { NSLocalizedString("JB.Btn.ContinueLesson", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var startTrace: String { NSLocalizedString("JB.Btn.StartTrace", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var startReview: String { NSLocalizedString("JB.Btn.StartReview", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var speak: String { NSLocalizedString("JB.Btn.Speak", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var clear: String { NSLocalizedString("JB.Btn.Clear", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var hint: String { NSLocalizedString("JB.Btn.Hint", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var check: String { NSLocalizedString("JB.Btn.Check", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var play: String { NSLocalizedString("JB.Btn.Play", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var pause: String { NSLocalizedString("JB.Btn.Pause", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var hard: String { NSLocalizedString("JB.Btn.Hard", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var good: String { NSLocalizedString("JB.Btn.Good", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var easy: String { NSLocalizedString("JB.Btn.Easy", tableName: "Localized", bundle: .main, value: "", comment: "") }
    }
    enum Settings {
        static var appearance: String { NSLocalizedString("JB.Settings.Appearance", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var system: String { NSLocalizedString("JB.Settings.System", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var light: String { NSLocalizedString("JB.Settings.Light", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var dark: String { NSLocalizedString("JB.Settings.Dark", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var showStrokeHints: String { NSLocalizedString("JB.Settings.ShowStrokeHints", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var backupRestore: String { NSLocalizedString("JB.Settings.BackupRestore", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var exportDeck: String { NSLocalizedString("JB.Settings.ExportDeck", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var importDeck: String { NSLocalizedString("JB.Settings.ImportDeck", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var enableReminder: String { NSLocalizedString("JB.Settings.EnableReminder", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var time: String { NSLocalizedString("JB.Settings.Time", tableName: "Localized", bundle: .main, value: "", comment: "") }
    }
    enum Home {
        static var dailyGoal: String { NSLocalizedString("JB.Home.DailyGoal", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var greeting: String { NSLocalizedString("JB.Home.Greeting", tableName: "Localized", bundle: .main, value: "", comment: "") }
    }
    enum Stats {
        static var streakFmt: String { NSLocalizedString("JB.Stats.StreakFmt", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var noData: String { NSLocalizedString("JB.Stats.NoData", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var weekMinutesFmt: String { NSLocalizedString("JB.Stats.WeekMinutesFmt", tableName: "Localized", bundle: .main, value: "", comment: "") }
        static var streakBestFmt: String { NSLocalizedString("JB.Stats.StreakBestFmt", tableName: "Localized", bundle: .main, value: "", comment: "") }
    }
}
