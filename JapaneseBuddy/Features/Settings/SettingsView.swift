import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: DeckStore

    @State private var time: Date = Date()

    var body: some View {
        Form {
            Section(header: Text("Daily Goals")) {
                Stepper("New: \(store.dailyGoal.newTarget)", value: $store.dailyGoal.newTarget, in: 0...50)
                Stepper("Review: \(store.dailyGoal.reviewTarget)", value: $store.dailyGoal.reviewTarget, in: 0...100)
            }

            Section(header: Text("Reminder")) {
                Toggle("Enable reminder", isOn: $store.notificationsEnabled)
                DatePicker("Time", selection: Binding(get: { pickerDate }, set: { setPickerDate($0) }), displayedComponents: .hourAndMinute)
                    .disabled(!store.notificationsEnabled)
                Button("Apply Reminder Now") { applyReminder() }
                    .disabled(!store.notificationsEnabled)
            }
        }
        .navigationTitle("Settings")
        .onAppear(perform: syncPicker)
        .onChange(of: store.notificationsEnabled) { _ in applyReminder() }
        .onChange(of: store.reminderTime) { _ in applyReminder() }
    }

    private var pickerDate: Date {
        let comps = store.reminderTime ?? DateComponents(hour: 20, minute: 0)
        return Calendar.current.date(from: comps) ?? Date()
    }

    private func setPickerDate(_ newDate: Date) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
        store.reminderTime = comps
    }

    private func syncPicker() { _ = pickerDate }

    private func applyReminder() {
        LocalNotifications.apply(enabled: store.notificationsEnabled, time: store.reminderTime)
    }
}

