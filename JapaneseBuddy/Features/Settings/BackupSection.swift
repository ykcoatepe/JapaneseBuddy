import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct BackupSection: View {
    @EnvironmentObject var store: DeckStore
    @State private var showExporter = false
    @State private var showImporter = false
    @State private var alert: AlertInfo?

    var body: some View {
        Section("Backup & Restore") {
            Button("Export deck.json") { showExporter = true }
            Button("Import deck.json") { showImporter = true }
        }
        .sheet(isPresented: $showExporter) {
            ActivityController(url: BackupService.exportURL)
        }
        .sheet(isPresented: $showImporter) {
            DocumentPicker { url in
                do {
                    try BackupService.importDeck(from: url, into: store)
                    alert = AlertInfo(title: "Import Complete")
                } catch {
                    alert = AlertInfo(title: "Import Failed", message: error.localizedDescription)
                }
            }
        }
        .alert(item: $alert) { info in
            Alert(title: Text(info.title), message: Text(info.message ?? ""), dismissButton: .default(Text("OK")))
        }
    }
}

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
