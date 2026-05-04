import SwiftUI

struct DailyGoalCard: View {
    let progress: GoalProgress

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: Theme.Spacing.small, alignment: .leading)
    ]

    var body: some View {
        JBCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                HStack(alignment: .firstTextBaseline) {
                    Text(L10n.Home.dailyGoal)
                        .font(.headline)
                    Spacer()
                    Text(statusText)
                        .font(.subheadline.bold())
                        .foregroundStyle(statusColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.12), in: Capsule())
                }

                LazyVGrid(columns: columns, alignment: .leading, spacing: Theme.Spacing.small) {
                    metric(
                        title: L10n.Settings.newCards,
                        done: progress.newDone,
                        target: progress.target.newTarget,
                        systemImage: "sparkles"
                    )
                    metric(
                        title: L10n.Settings.reviewCards,
                        done: progress.reviewDone,
                        target: progress.target.reviewTarget,
                        systemImage: "arrow.triangle.2.circlepath"
                    )
                    metric(
                        title: L10n.Settings.lessons,
                        done: progress.lessonDone,
                        target: progress.target.lessonTarget,
                        systemImage: "checkmark.seal"
                    )
                }
                .font(.subheadline)

                ProgressBar(value: progress.ratio)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.Home.dailyGoalProgress)
        .accessibilityValue("\(statusText), \(countText)")
    }

    private var countText: String {
        String(format: L10n.Common.countProgressFmt, visibleTotalDone, progress.totalTarget)
    }

    private var visibleTotalDone: Int {
        min(progress.totalDone, progress.totalTarget)
    }

    private var statusText: String {
        progress.ratio >= 1 ? L10n.Home.dailyGoalComplete : countText
    }

    private var statusColor: Color {
        progress.ratio >= 1 ? .green : .accentColor
    }

    private func metric(title: String, done: Int, target: Int, systemImage: String) -> some View {
        let visibleDone = min(done, target)

        return Label {
            Text("\(title) \(String(format: L10n.Common.countProgressFmt, visibleDone, target))")
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(Color.accentColor)
        }
    }
}
