# Stats Feature Audit

## $ rg -n 'beginStudy\(|endStudy\(' JapaneseBuddy/Features || true

JapaneseBuddy/Features/SRS/SRSView.swift:44:            store.beginStudy()
JapaneseBuddy/Features/SRS/SRSView.swift:47:        .onDisappear { store.endStudy(kind: .study) }
JapaneseBuddy/Features/KanaTraceView.swift:44:            store.beginStudy()
JapaneseBuddy/Features/KanaTraceView.swift:47:        .onDisappear { store.endStudy(kind: .study) }

## $ rg -n 'weeklyMinutes\(|minutesToday\(|currentStreak\(' JapaneseBuddy/Services/DeckStore.swift || true

190:    func currentStreak(now: Date = .now, cal: Calendar = .current) -> Int {
220:    func minutesToday(now: Date = .now, cal: Calendar = .current) -> Int {
227:    func weeklyMinutes(now: Date = .now, cal: Calendar = .current) -> [Int] {

## $ grep -R 'JB.Stats.TodayMinutesFmt' -n JapaneseBuddy/Resources/L10n || true

JapaneseBuddy/Resources/L10n/ja.lproj/Localized.strings:37:"JB.Stats.TodayMinutesFmt" = "きょう: %d 分";
JapaneseBuddy/Resources/L10n/en.lproj/Localized.strings:37:"JB.Stats.TodayMinutesFmt" = "Today: %d min";
JapaneseBuddy/Resources/L10n/Base.lproj/Localized.strings:37:"JB.Stats.TodayMinutesFmt" = "Today: %d min";
JapaneseBuddy/Resources/L10n/tr.lproj/Localized.strings:37:"JB.Stats.TodayMinutesFmt" = "Bugün: %d dk";

## $ grep -R 'JB.Stats.WeekMinutesFmt' -n JapaneseBuddy/Resources/L10n || true

JapaneseBuddy/Resources/L10n/ja.lproj/Localized.strings:38:"JB.Stats.WeekMinutesFmt" = "１週間: %d 分";
JapaneseBuddy/Resources/L10n/en.lproj/Localized.strings:38:"JB.Stats.WeekMinutesFmt" = "Week: %d min";
JapaneseBuddy/Resources/L10n/Base.lproj/Localized.strings:38:"JB.Stats.WeekMinutesFmt" = "Week: %d min";
JapaneseBuddy/Resources/L10n/tr.lproj/Localized.strings:38:"JB.Stats.WeekMinutesFmt" = "Hafta: %d dk";
