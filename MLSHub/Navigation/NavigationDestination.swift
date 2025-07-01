import Foundation

enum NavigationDestination: Hashable {
    case teamSelection
    case teamConfirmation(TeamInfo)
    case stats
    case home
}
