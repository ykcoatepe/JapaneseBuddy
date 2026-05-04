import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: DeckStore

    var body: some View {
        let mins = store.weeklyMinutes()
        let weekTotal = store.weeklyTotalMinutes()
        let maxM = max(1, mins.max() ?? 1)
        let activity = store.weeklyActivity()
        let maxA = max(1, activity.max() ?? 1)
        let hasEntries = !store.sessionLog.isEmpty
        let hasMinuteData = store.sessionLog.contains { $0.durationSec != nil }

        return Group {
            if !hasEntries {
                EmptyState(systemImage: "chart.bar", message: L10n.Stats.noData)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                        if hasMinuteData {
                            statTiles(primary: String(format: L10n.Stats.weekMinutesFmt, weekTotal))
                            chart(
                                title: String(format: L10n.Stats.weekMinutesFmt, weekTotal),
                                values: mins,
                                maxValue: maxM,
                                unit: L10n.Stats.minutesUnit
                            )
                        } else {
                            statTiles(primary: String(format: L10n.Stats.streakFmt, store.currentStreak()))
                            chart(title: L10n.Nav.stats, values: activity, maxValue: maxA, unit: L10n.Stats.sessionsUnit)
                        }
                    }
                    .frame(maxWidth: 760)
                    .padding(Theme.Spacing.large)
                    .frame(maxWidth: .infinity)
                }
                .background(Color.washi.ignoresSafeArea())
            }
        }
        .navigationTitle(L10n.Nav.stats)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
    }

    private func statTiles(primary: String) -> some View {
        HStack(spacing: Theme.Spacing.small) {
            StatTile(title: primary, value: "")
            StatTile(title: String(format: L10n.Stats.streakBestFmt, store.bestStreak()), value: "")
        }
    }

    private func chart(title: String, values: [Int], maxValue: Int, unit: String) -> some View {
        JBCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                SectionHeader(title)
                HStack(alignment: .bottom, spacing: Theme.Spacing.small) {
                    ForEach(0..<values.count, id: \.self) { index in
                        VStack {
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                .fill(Color.accentColor)
                                .frame(width: 18, height: CGFloat(8 + Int(60 * (CGFloat(values[index]) / CGFloat(maxValue)))))
                            Text(shortDay(index))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(String(format: L10n.Stats.dayValueFmt, index + 1, values[index], unit))
                    }
                }
            }
        }
    }

    private func shortDay(_ offset: Int) -> String {
        let cal = Calendar.current
        let now = Date()
        let day = cal.date(byAdding: .day, value: -6 + offset, to: cal.startOfDay(for: now)) ?? now
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: day)
    }
}
