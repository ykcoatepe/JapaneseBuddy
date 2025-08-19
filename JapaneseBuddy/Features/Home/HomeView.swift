import SwiftUI

/// Landing screen with deck toggles and navigation tiles.
struct HomeView: View {
    @EnvironmentObject var store: DeckStore

    var body: some View {
        VStack(spacing: 24) {
            Picker("Deck", selection: $store.currentType) {
                Text("Hiragana").tag(CardType.hiragana)
                Text("Katakana").tag(CardType.katakana)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Toggle("Pencil only", isOn: $store.pencilOnly)
                .padding(.horizontal)

            HStack(spacing: 20) {
                NavigationLink {
                    KanaTraceView()
                } label: {
                    tile(title: "Kana Trace", count: traceCount)
                }

                NavigationLink {
                    SRSView()
                } label: {
                    tile(title: "SRS", count: srsCount)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Home")
    }

    private var traceCount: Int { store.dueCards(type: store.currentType).count }
    private var srsCount: Int { traceCount }

    @ViewBuilder
    private func tile(title: String, count: Int) -> some View {
        VStack {
            Text(title).font(.title2)
            Text("\(count) due").font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.1)))
    }
}

