import SwiftUI

private enum NavItem: String, CaseIterable, Identifiable {
    case home = "Home"
    case lessons = "Lessons"
    case practice = "Practice"
    case review = "Review"
    case stats = "Stats"
    case settings = "Settings"
    var id: String { rawValue }
    var systemImage: String {
        switch self {
        case .home: return "house"
        case .lessons: return "book"
        case .practice: return "pencil.tip"
        case .review: return "rectangle.on.rectangle"
        case .stats: return "chart.bar"
        case .settings: return "gear"
        }
    }
}

struct AppSidebar: View {
    @EnvironmentObject var store: DeckStore
    @State private var selection: NavItem? = .home

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(NavItem.allCases) { item in
                    NavigationLink(value: item) {
                        Label(item.rawValue, systemImage: item.systemImage)
                    }
                    .tag(item)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("JapaneseBuddy")
            .background(Color.washi.ignoresSafeArea())
            .navigationDestination(for: NavItem.self) { item in
                destinationView(item)
            }
        } detail: {
            destinationView(selection ?? .home)
                .background(Color.washi.ignoresSafeArea())
                .navigationDestination(for: NavItem.self) { item in
                    destinationView(item)
                }
        }
        .navigationSplitViewStyle(.balanced)
        .preferredColorScheme(colorScheme)
    }

    @ViewBuilder
    private func destinationView(_ item: NavItem) -> some View {
        switch item {
        case .home: HomeView()
        case .lessons: LessonListView()
        case .practice: KanaTraceView()
        case .review: SRSView()
        case .stats: StatsView()
        case .settings: SettingsView()
        }
    }

    private var colorScheme: ColorScheme? {
        switch store.themeMode {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}
