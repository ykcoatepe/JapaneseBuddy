import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: DeckStore

    var body: some View {
        Form {
            Section("Profile") {
                TextField("Name", text: nameBinding)
                    .textContentType(.name)
            }
            Section("Daily Goal") {
                Stepper("New \(store.dailyGoal.newTarget)", value: $store.dailyGoal.newTarget, in: 0...100)
                Stepper("Review \(store.dailyGoal.reviewTarget)", value: $store.dailyGoal.reviewTarget, in: 0...500)
            }
            Section("Reminders") {
                Toggle("Enable", isOn: $store.notificationsEnabled)
                DatePicker("Time", selection: timeBinding, displayedComponents: .hourAndMinute)
                    .disabled(!store.notificationsEnabled)
            }
            Section("Tracing") {
                Toggle("Show Stroke Hints", isOn: $store.showStrokeHints)
            }
            BackupSection()
            Section("Developer") {
                Button("Reset Onboarding") { store.hasOnboarded = false }
                .accessibilityLabel("Reset onboarding")
                .accessibilityHint("Shows the welcome flow on next render")
            }
        }
        .navigationTitle("Settings")
        .onChangeCompat(store.notificationsEnabled) { updateNotifications() }
        .onChangeCompat(store.reminderTime) { updateNotifications() }
    }

    private var timeBinding: Binding<Date> {
        Binding<Date>(
            get: {
                if let comps = store.reminderTime, let d = Calendar.current.date(from: comps) { return d }
                return Calendar.current.date(from: DateComponents(hour: 20)) ?? Date()
            },
            set: { store.reminderTime = Calendar.current.dateComponents([.hour, .minute], from: $0) }
        )
    }

    private func updateNotifications() {
        Task {
            if store.notificationsEnabled, let comps = store.reminderTime {
                await LocalNotifications.requestPermission()
                try? await LocalNotifications.scheduleDaily(at: comps)
            } else {
                await LocalNotifications.cancel(id: "daily-goal")
            }
        }
    }

    private var nameBinding: Binding<String> {
        Binding<String>(
            get: { store.displayName ?? "" },
            set: { store.displayName = $0.isEmpty ? nil : $0 }
        )
    }
}

private extension View {
    @ViewBuilder
    func onChangeCompat<T: Equatable>(_ value: T, perform action: @escaping () -> Void) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: value) { _, _ in action() }
        } else {
            self.onChange(of: value) { _ in action() }
        }
    }
}
