import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: DeckStore

    var body: some View {
        let mins = store.weeklyMinutes()
        let weekTotal = store.weeklyTotalMinutes()
        let maxM = max(1, mins.max() ?? 1)
        let hasMinuteData = store.sessionLog.contains { $0.durationSec != nil }
        return Group {
            if !hasMinuteData {
                EmptyState(systemImage: "chart.bar", message: L10n.Stats.noData)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                        HStack(spacing: Theme.Spacing.small) {
                            StatTile(title: String(format: L10n.Stats.weekMinutesFmt, weekTotal), value: "")
                            StatTile(title: String(format: L10n.Stats.streakBestFmt, store.bestStreak()), value: "")
                        }
                        .padding(.horizontal)

                        SectionHeader(String(format: L10n.Stats.weekMinutesFmt, weekTotal))
                        HStack(alignment: .bottom, spacing: Theme.Spacing.small) {
                            ForEach(0..<mins.count, id: \.self) { i in
                                VStack {
                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                        .fill(Color.accentColor)
                                        .frame(width: 18, height: CGFloat(8 + Int(60 * (CGFloat(mins[i]) / CGFloat(maxM)))))
                                    Text(shortDay(i))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel("Day \(i+1) \(mins[i]) min")
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .background(Color.washi.ignoresSafeArea())
            }
        }
        .navigationTitle(L10n.Nav.stats)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
    }

    private func shortDay(_ offset: Int) -> String {
        let cal = Calendar.current
        let now = Date()
        let day = cal.date(byAdding: .day, value: -6 + offset, to: cal.startOfDay(for: now)) ?? now
        let df = DateFormatter(); df.dateFormat = "E"; return df.string(from: day)
    }
}
