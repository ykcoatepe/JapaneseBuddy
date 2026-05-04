import SwiftUI

/// Lessons list with filter chips and progress stars.
struct LessonListView: View {
    @EnvironmentObject var lessons: LessonStore
    @State private var filter: LessonLevelFilter = .all

    var body: some View {
        List {
            Picker(L10n.Lessons.filter, selection: $filter) {
                ForEach(availableFilters) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 4)

            ForEach(groupedLevels, id: \.self) { level in
                Section {
                    ForEach(filteredLessons(for: level)) { lesson in
                        lessonRow(lesson)
                    }
                } header: {
                    levelHeader(level)
                }
            }
        }
        .navigationTitle(L10n.Nav.lessons)
    }

    private func lessonRow(_ lesson: Lesson) -> some View {
        let progress = lessons.progress(for: lesson.id)
        let state = lessons.pathState(for: lesson)
        let isUnlocked = state != .locked
        let summary = progressSummary(progress, total: lesson.activities.count, state: state)

        return Group {
            if isUnlocked {
                NavigationLink {
                    LessonRunnerView(lesson: lesson)
                } label: {
                    lessonRowContent(lesson, progress: progress, state: state)
                }
            } else {
                lessonRowContent(lesson, progress: progress, state: state)
            }
        }
        .accessibilityLabel(
            "\(lesson.title), \(lesson.canDo), \(stateLabel(state)), \(summary)"
        )
    }

    private func levelHeader(_ level: Lesson.Level) -> some View {
        let progress = lessons.levelProgress(for: level)

        return VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(level.title)
                Spacer()
                Text(String(format: L10n.Common.countProgressFmt, progress.completed, progress.total))
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            Text(levelSubtitle(level))
                .font(.caption)
                .textCase(nil)
                .foregroundStyle(.secondary)
            ProgressBar(value: progress.ratio)
                .frame(maxWidth: 360)
        }
        .padding(.top, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(level.title), \(String(format: L10n.Common.countProgressFmt, progress.completed, progress.total))"
        )
    }

    private func lessonRowContent(_ lesson: Lesson, progress: LessonProgress, state: Lesson.PathState) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconBackground(for: state))
                    .frame(width: 42, height: 42)
                Image(systemName: iconName(for: state))
                    .foregroundStyle(iconForeground(for: state))
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("\(lesson.pathCode) \(lesson.title)")
                        .font(.headline)
                    if state == .next {
                        Text(L10n.Lessons.next)
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.accentColor.opacity(0.14), in: Capsule())
                            .foregroundStyle(Color.accentColor)
                    }
                }
                Text(lesson.canDo)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(progressSummary(progress, total: lesson.activities.count, state: state))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
        .opacity(state == .locked ? 0.56 : 1)
    }

    private func iconName(for state: Lesson.PathState) -> String {
        switch state {
        case .completed: return "checkmark"
        case .next: return "play.fill"
        case .open: return "book"
        case .locked: return "lock.fill"
        }
    }

    private func iconBackground(for state: Lesson.PathState) -> Color {
        switch state {
        case .completed, .next: return Color.accentColor
        case .open, .locked: return Color.cardBackground
        }
    }

    private func iconForeground(for state: Lesson.PathState) -> Color {
        switch state {
        case .completed, .next: return .white
        case .open, .locked: return .secondary
        }
    }

    private func stateLabel(_ state: Lesson.PathState) -> String {
        switch state {
        case .completed: return L10n.Lessons.completed
        case .next: return L10n.Lessons.next
        case .open: return L10n.Lessons.open
        case .locked: return L10n.Lessons.locked
        }
    }

    private var allLessons: [Lesson] {
        lessons.orderedLessons()
    }

    private var filtered: [Lesson] {
        switch filter {
        case .all: return allLessons
        case let .level(level): return allLessons.filter { $0.level == level }
        }
    }

    private var groupedLevels: [Lesson.Level] {
        Lesson.Level.allCases.filter { level in
            filtered.contains { $0.level == level }
        }
    }

    private var availableFilters: [LessonLevelFilter] {
        let levels = Lesson.Level.allCases.filter { level in
            allLessons.contains { $0.level == level }
        }
        return [.all] + levels.map { .level($0) }
    }

    private func filteredLessons(for level: Lesson.Level) -> [Lesson] {
        filtered.filter { $0.level == level }
    }

    private func levelSubtitle(_ level: Lesson.Level) -> String {
        let count = filteredLessons(for: level).count
        switch level {
        case .foundationA1: return String(format: L10n.Lessons.foundationPathFmt, count)
        case .bridgeA2: return String(format: L10n.Lessons.bridgePathFmt, count)
        case .intermediateB1: return String(format: L10n.Lessons.intermediatePathFmt, count)
        case .other: return String(format: L10n.Lessons.extraPathFmt, count)
        }
    }

    private func progressSummary(_ progress: LessonProgress, total: Int, state: Lesson.PathState) -> String {
        if state == .locked {
            return L10n.Lessons.completePrevious
        }
        if progress.isCompleted {
            return String(format: L10n.Lessons.completedStarsFmt, progress.stars)
        }
        return String(format: L10n.Lessons.stepProgressFmt, progress.lastStep + 1, total)
    }
}

private enum LessonLevelFilter: Hashable, Identifiable {
    case all
    case level(Lesson.Level)

    var id: String {
        switch self {
        case .all: return "all"
        case let .level(level): return level.rawValue
        }
    }

    var title: String {
        switch self {
        case .all: return L10n.Lessons.all
        case let .level(level): return level.title
        }
    }
}
