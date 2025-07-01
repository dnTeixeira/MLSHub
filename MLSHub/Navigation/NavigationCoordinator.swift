import SwiftUI

@Observable
final class NavigationCoordinator {
    var path = NavigationPath()
    
    func navigateToTeamSelection() {
        path.append(NavigationDestination.teamSelection)
    }
    
    func navigateToTeamConfirmation(team: TeamInfo) {
        path.append(NavigationDestination.teamConfirmation(team))
    }
    
    func navigateToHome() {
        path = NavigationPath()
    }
    
    func navigateToStats() {
        path.append(NavigationDestination.stats)
    }
    
    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func resetToRoot() {
        path = NavigationPath()
    }
}
