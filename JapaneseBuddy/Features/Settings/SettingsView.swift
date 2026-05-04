import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct SettingsView: View {
    @EnvironmentObject var store: DeckStore

    var body: some View {
        Form {
            Section(L10n.Settings.profile) {
                TextField(L10n.Settings.name, text: nameBinding)
                    .textContentType(.name)
            }
            Section(L10n.Home.dailyGoal) {
                goalStepper(L10n.Settings.newCards, value: $store.dailyGoal.newTarget, range: 0...100)
                goalStepper(L10n.Settings.reviewCards, value: $store.dailyGoal.reviewTarget, range: 0...500)
                goalStepper(L10n.Settings.lessons, value: $store.dailyGoal.lessonTarget, range: 0...10)
            }
            Section(L10n.Settings.reminders) {
                Toggle(L10n.Settings.enableReminder, isOn: $store.notificationsEnabled)
                DatePicker(L10n.Settings.time, selection: timeBinding, displayedComponents: .hourAndMinute)
                    .disabled(!store.notificationsEnabled)
            }
            Section(L10n.Settings.tracing) {
                Toggle(L10n.Settings.showStrokeHints, isOn: $store.showStrokeHints)
            }
            Section(L10n.Settings.audio) {
                Toggle(L10n.Settings.playSpeechInSilentMode, isOn: $store.playSpeechInSilentMode)
            }
            Section(L10n.Settings.appearance) {
                Picker(L10n.Settings.theme, selection: $store.themeMode) {
                    Text(L10n.Settings.system).tag(ThemeMode.system)
                    Text(L10n.Settings.light).tag(ThemeMode.light)
                    Text(L10n.Settings.dark).tag(ThemeMode.dark)
                }
                .pickerStyle(.segmented)
                .accessibilityLabel(L10n.Settings.theme)
            }
            SettingsBackupSection()
            Section(L10n.Settings.developer) {
                Button(L10n.Settings.resetOnboarding) { store.hasOnboarded = false }
                .accessibilityLabel(L10n.Settings.resetOnboarding)
                .accessibilityHint(L10n.Settings.resetOnboardingHint)
            }
        }
        .navigationTitle(L10n.Nav.settings)
        .onChangeCompat(store.notificationsEnabled) { updateNotifications() }
        .onChangeCompat(store.reminderTime) { updateNotifications() }
        .dynamicTypeSize(.xSmall ... .xxxLarge)
    }

    private var timeBinding: Binding<Date> {
        Binding<Date>(
            get: {
                if let components = store.reminderTime, let date = Calendar.current.date(from: components) {
                    return date
                }
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

    private func goalStepper(_ title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        Stepper(value: value, in: range) {
            Text("\(title) \(value.wrappedValue)")
        }
        .accessibilityLabel(title)
        .accessibilityValue(String(value.wrappedValue))
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

// Local fallback implementation to ensure build succeeds if BackupSection.swift
// is not included in the target membership. Namespaced to avoid collisions.
struct SettingsBackupSection: View {
    @EnvironmentObject var store: DeckStore
    @State private var showExporter = false
    @State private var showImporter = false
    @State private var alert: AlertInfo?

    var body: some View {
        Section(L10n.Settings.backupRestore) {
            Button(L10n.Settings.exportDeck) { showExporter = true }
            Button(L10n.Settings.importDeck) { showImporter = true }
        }
        .sheet(isPresented: $showExporter) { ActivityController(url: Self.deckURL) }
        .sheet(isPresented: $showImporter) {
            DocumentPicker { url in
                do {
                    try Self.importDeck(from: url, into: store)
                    alert = AlertInfo(title: L10n.Settings.importComplete)
                } catch {
                    alert = AlertInfo(title: L10n.Settings.importFailed, message: error.localizedDescription)
                }
            }
        }
        .alert(item: $alert) { info in
            Alert(title: Text(info.title),
                  message: Text(info.message ?? ""),
                  dismissButton: .default(Text(L10n.Common.okay)))
        }
    }

    // MARK: - Local backup helpers (fallback if BackupService is not in target)
    static var deckURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("deck.json")
    }

    enum BackupError: Error { case invalidFormat }

    static func importDeck(from url: URL, into store: DeckStore) throws {
        let data = try Data(contentsOf: url)
        guard (try? JSONDecoder().decode(DeckStore.State.self, from: data)) != nil else {
            throw BackupError.invalidFormat
        }
        try data.write(to: deckURL, options: .atomic)
        store.reload()
    }

    // MARK: - Nested helpers to avoid cross-file name collisions
    private struct AlertInfo: Identifiable {
        let id = UUID()
        var title: String
        var message: String?
    }

    private struct ActivityController: UIViewControllerRepresentable {
        let url: URL
        func makeUIViewController(context: Context) -> UIActivityViewController {
            UIActivityViewController(activityItems: [url], applicationActivities: nil)
        }
        func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
    }

    private struct DocumentPicker: UIViewControllerRepresentable {
        var onPick: (URL) -> Void
        func makeCoordinator() -> DocumentPickerCoordinator { DocumentPickerCoordinator(onPick: onPick) }
        func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
            picker.allowsMultipleSelection = false
            picker.delegate = context.coordinator
            return picker
        }
        func updateUIViewController(_ controller: UIDocumentPickerViewController, context: Context) {}
    }

    private final class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}
