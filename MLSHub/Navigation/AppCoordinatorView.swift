import SwiftUI

struct AppCoordinatorView: View {
    @Environment(AppContainer.self) private var container
    
    var body: some View {
            // Use @Bindable to create a bindable reference to your container.
            @Bindable var bindableContainer = container

            // Pass a direct binding to the path using the '$' prefix.
            NavigationStack(path: $bindableContainer.navigationCoordinator.path) {
                RootView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
        }
    
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .teamSelection:
            TeamSelectionView()
        case .teamConfirmation(let team):
            TeamConfirmationView(team: team)
        case .stats:
            StatsView()
        case .home:
            HomeView()
        }
    }
}
