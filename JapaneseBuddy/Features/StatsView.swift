import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: DeckStore

    var body: some View {
        let entries = store.sessionLog
        return Group {
            if entries.isEmpty {
                EmptyState(systemImage: "chart.bar", message: "No stats yet. Practice to see progress!")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                        HStack(spacing: Theme.Spacing.small) {
                            StatTile(title: "Streak", value: "\(streak(entries))")
                            StatTile(title: "This Week", value: "\(weekTotal(entries)) min")
                        }
                        .padding(.horizontal)

                        SectionHeader("Weekly Activity")
                        weekChart(entries)
                            .padding(.horizontal)
                    }
                }
                .background(Color.washi.ignoresSafeArea())
            }
        }
        .navigationTitle("Stats")
        .dynamicTypeSize(.xSmall ... .xxxLarge)
    }

    private func streak(_ entries: [SessionLogEntry], now: Date = .now, cal: Calendar = .current) -> Int {
        let days = Set(entries.map { cal.startOfDay(for: $0.date) })
        var count = 0
        var day = cal.startOfDay(for: now)
        while days.contains(day) {
            count += 1
            day = cal.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return count
    }

    private func weekTotal(_ entries: [SessionLogEntry], now: Date = .now, cal: Calendar = .current) -> Int {
        let start = cal.startOfDay(for: cal.date(byAdding: .day, value: -6, to: now) ?? now)
        let filtered = entries.filter { $0.date >= start }
        return filtered.count // treat each action ≈ 1 min for a simple proxy
    }

    @ViewBuilder
    private func weekChart(_ entries: [SessionLogEntry], now: Date = .now, cal: Calendar = .current) -> some View {
        let start = cal.startOfDay(for: cal.date(byAdding: .day, value: -6, to: now) ?? now)
        let grouped = Dictionary(grouping: entries.filter { $0.date >= start }) { cal.startOfDay(for: $0.date) }
        let days = (0...6).compactMap { cal.date(byAdding: .day, value: -6 + $0, to: cal.startOfDay(for: now)) }
        HStack(alignment: .bottom, spacing: Theme.Spacing.small) {
            ForEach(days, id: \.self) { d in
                let c = grouped[cal.startOfDay(for: d)]?.count ?? 0
                VStack {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .fill(Color.accentColor)
                        .frame(width: 18, height: CGFloat(8 + min(60, c * 6)))
                    Text(shortDay(d)).font(.caption2).foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(shortDay(d)) \(c) min")
            }
        }
    }

    private func shortDay(_ d: Date) -> String {
        let df = DateFormatter(); df.dateFormat = "E"; return df.string(from: d)
    }
}
