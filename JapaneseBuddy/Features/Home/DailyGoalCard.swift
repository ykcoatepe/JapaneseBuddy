import SwiftUI

struct DailyGoalCard: View {
    let progress: GoalProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Goal").font(.headline)
            HStack {
                Text("New \(progress.newDone)/\(progress.target.newTarget)")
                Spacer()
                Text("Review \(progress.reviewDone)/\(progress.target.reviewTarget)")
            }
            .font(.subheadline)
            HStack {
                ProgressView(value: min(Double(progress.newDone) / Double(max(progress.target.newTarget, 1)), 1))
                ProgressView(value: min(Double(progress.reviewDone) / Double(max(progress.target.reviewTarget, 1)), 1))
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.1)))
    }
}

