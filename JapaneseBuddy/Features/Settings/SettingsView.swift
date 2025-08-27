import SwiftUI
import UniformTypeIdentifiers
import UIKit

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
            Section("Audio") {
                Toggle("Play Speech in Silent Mode", isOn: $store.playSpeechInSilentMode)
            }
            Section("Appearance") {
                Picker("Theme", selection: $store.themeMode) {
                    Text("System").tag(ThemeMode.system)
                    Text("Light").tag(ThemeMode.light)
                    Text("Dark").tag(ThemeMode.dark)
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("App theme")
            }
            SettingsBackupSection()
            Section("Developer") {
                Button("Reset Onboarding") { store.hasOnboarded = false }
                .accessibilityLabel("Reset onboarding")
                .accessibilityHint("Shows the welcome flow on next render")
            }
        }
        .navigationTitle("Settings")
        .onChangeCompat(store.notificationsEnabled) { updateNotifications() }
        .onChangeCompat(store.reminderTime) { updateNotifications() }
        .dynamicTypeSize(.xSmall ... .xxxLarge)
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

// Local fallback implementation to ensure build succeeds if BackupSection.swift
// is not included in the target membership. Namespaced to avoid collisions.
struct SettingsBackupSection: View {
    @EnvironmentObject var store: DeckStore
    @State private var showExporter = false
    @State private var showImporter = false
    @State private var alert: AlertInfo?

    var body: some View {
        Section("Backup & Restore") {
            Button("Export deck.json") { showExporter = true }
            Button("Import deck.json") { showImporter = true }
        }
        .sheet(isPresented: $showExporter) { ActivityController(url: Self.deckURL) }
        .sheet(isPresented: $showImporter) {
            DocumentPicker { url in
                do {
                    try Self.importDeck(from: url, into: store)
                    alert = AlertInfo(title: "Import Complete")
                } catch {
                    alert = AlertInfo(title: "Import Failed", message: error.localizedDescription)
                }
            }
        }
        .alert(item: $alert) { info in
            Alert(title: Text(info.title),
                  message: Text(info.message ?? ""),
                  dismissButton: .default(Text("OK")))
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
        func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
    }

    private struct DocumentPicker: UIViewControllerRepresentable {
        var onPick: (URL) -> Void
        func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }
        func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
            picker.allowsMultipleSelection = false
            picker.delegate = context.coordinator
            return picker
        }
        func updateUIViewController(_ vc: UIDocumentPickerViewController, context: Context) {}
        final class Coordinator: NSObject, UIDocumentPickerDelegate {
            let onPick: (URL) -> Void
            init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }
            func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
                guard let url = urls.first else { return }
                onPick(url)
            }
        }
    }
}
