import SwiftUI

struct DailyGoalCard: View {
    let progress: GoalProgress
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Goal").font(.headline)
            HStack {
                Label("New \(progress.newDone)/\(progress.target.newTarget)", systemImage: "sparkles")
                Spacer()
                Label("Review \(progress.reviewDone)/\(progress.target.reviewTarget)", systemImage: "arrow.triangle.2.circlepath")
            }.font(.subheadline)
            ProgressView(value: ratio(progress)).tint(.primary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.quaternary))
    }
    private func ratio(_ p: GoalProgress) -> Double {
        let done = p.newDone + p.reviewDone
        let total = max(1, p.target.newTarget + p.target.reviewTarget)
        return Double(done) / Double(total)
    }
}
