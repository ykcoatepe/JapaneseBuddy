import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct BackupSection: View {
    @EnvironmentObject var store: DeckStore
    @State private var showExport = false
    @State private var showImport = false
    @State private var alert: AlertItem?
    private let service = BackupService()

    var body: some View {
        Section("Backup & Restore") {
            Button("Export deck.json") { showExport = true }
            Button("Import deck.json") { showImport = true }
        }
        .sheet(isPresented: $showExport) {
            ActivityView(items: [service.exportURL()])
        }
        .sheet(isPresented: $showImport) {
            DocumentPicker { urls in handleImport(urls.first) }
        }
        .alert(item: $alert) { a in
            Alert(title: Text(a.title), message: Text(a.message))
        }
    }

    private func handleImport(_ url: URL?) {
        guard let url else { return }
        do {
            try service.importDeck(from: url, into: store)
            alert = AlertItem(title: "Import Complete", message: "Deck restored.")
        } catch {
            alert = AlertItem(title: "Import Failed", message: error.localizedDescription)
        }
    }

    private struct AlertItem: Identifiable {
        let title: String
        let message: String
        var id: String { title }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: ([URL]) -> Void
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.json], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ controller: UIDocumentPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }
    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: ([URL]) -> Void
        init(onPick: @escaping ([URL]) -> Void) { self.onPick = onPick }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onPick(urls)
        }
    }
}
