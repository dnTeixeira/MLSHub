import SwiftUI

@main
struct MLSHubApp: App {
    @State private var appContainer = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environment(appContainer)
                .task {
                    await appContainer.initialize()
                }
        }
    }
}

struct RootView: View {
    @Environment(AppContainer.self) private var container
    
    private var userSettingsService: UserSettingsServiceProtocol {
        container.userSettingsService
    }
    
    var body: some View {
        Group {
            if userSettingsService.selectedTeam != nil {
                HomeView()
            } else {
                WelcomeView()
            }
        }
        .animation(.default, value: userSettingsService.selectedTeam?.id)
    }
}
